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
import ballerinax/activemq.driver as _;
import ballerinax/java.jms;

const string ORDER_STATUS_UPDATE_TOPIC = "order-status-update";

service "order-status-update-receiver" on new jms:Listener(
    connectionConfig = activeMqConnectionConfig,
    consumerOptions = {
        destination: {
            'type: jms:TOPIC,
            name: ORDER_STATUS_UPDATE_TOPIC
        },
        subscriberName: "order-service-consumer"
    }
) {
    remote function onMessage(jms:Message message) returns error? {
        if message !is jms:BytesMessage {
            return;
        }
        string jsonStr = check string:fromBytes(message.content);
        OrderStatusUpdate orderStatusUpdate = check jsonStr.fromJsonStringWithType();
        _ = check datastore->/foodorders/[orderStatusUpdate.orderId].put({
            status: orderStatusUpdate.status
        });
    }
}

