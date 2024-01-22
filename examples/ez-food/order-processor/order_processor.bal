// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import orderprocessor.store;

import ballerina/http;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/time;
import ballerinax/activemq.driver as _;
import ballerinax/java.jms;

final http:Client menu = check new ("localhost:9090/menu");
final store:Client store = check new ();

public function main() {
    _ = start startPaymentCompletedOrder();
    _ = start markFinishedOrdersAsCompleted();
    log:printInfo("Started Order Processing Serivce");
}

isolated function startPaymentCompletedOrder() returns error? {
    while true {
        store:FoodOrder[] orders = check from store:FoodOrder 'order in store->/foodorders(store:FoodOrder)
            where 'order.status == store:ACCEPTED
            select 'order;
        foreach store:FoodOrder 'order in orders {
            _ = check store->/foodorders/['order.id].put({
                status: store:PROCESSING,
                processingStartedTime: time:utcNow()
            });
            _ = check produceMessage(ORDER_STATUS_UPDATE_TOPIC, jms:TOPIC, {
                orderId: 'order.id,
                status: store:PROCESSING
            });
        }
        runtime:sleep(5);
    }
}

isolated function markFinishedOrdersAsCompleted() returns error? {
    while true {
        store:FoodOrder[] orders = check from store:FoodOrder 'order in store->/foodorders(store:FoodOrder)
            where 'order.status == store:PROCESSING
            select 'order;
        foreach store:FoodOrder 'order in orders {
            time:Utc currentTime = time:utcNow();
            time:Utc orderCompletionTime = time:utcAddSeconds(<time:Utc>'order.processingStartedTime, 0);
            if time:utcDiffSeconds(currentTime, orderCompletionTime) > 0d {
                continue;
            }
            _ = check store->/foodorders/['order.id].put({
                status: store:PROCESSING
            });
            _ = check produceMessage(ORDER_STATUS_UPDATE_TOPIC, jms:TOPIC, {
                orderId: 'order.id,
                status: store:PROCESSING
            });
        }
        runtime:sleep(5);
    }
}

