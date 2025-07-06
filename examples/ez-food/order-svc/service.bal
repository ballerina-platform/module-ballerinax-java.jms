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
import ordersvc.store;

import ballerina/http;
import ballerina/log;
import ballerina/persist;
import ballerinax/java.jms;

// Holds the Id of the next order
isolated int nextOrderId = 1;

isolated function getNextOrderId() returns int {
    lock {
        int currentId = nextOrderId;
        nextOrderId += 1;
        return currentId;
    }
}

final store:Client datastore = check new ();

# A service representing an online food ordering system
service /orders on new http:Listener(9091) {
    private final jms:MessageProducer producer;

    function init() returns error? {
        jms:Connection connection = check new (activeMqConnectionConfig);
        jms:Session session = check connection->createSession();
        self.producer = check session.createProducer();
        log:printInfo("Started Order Serivce");
    }

    resource function post .(NewOrder 'order) returns OrderCreated|error {
        int[] ids = check datastore->/foodorders.post([
            {
                id: getNextOrderId(),
                status: store:PENDING,
                subtotal: (),
                estimatedCompletionTime: ()
            }
        ]);
        check self.produceMessage(ORDERS_QUEUE, jms:QUEUE, {
            orderId: ids[0],
            details: 'order
        });
        return {
            headers: {
                Link: string `/orders/${ids[0]}`
            },
            body: {
                id: ids[0],
                status: store:PENDING
            }
        };
    }

    resource function get [int id]() returns store:FoodOrder|OrderNotFound|error {
        store:FoodOrder|error 'order = datastore->/foodorders/[id]();
        if 'order is persist:NotFoundError {
            return {
                body: {
                    message: string `Could not find the order for id: ${id}`,
                    path: string `/orders/${id}`
                }
            };
        }
        return 'order;
    }

    resource function post [int id]/payment(PaymentDetails paymentDetails)
            returns http:Ok|OrderNotFound|PaymentNotAccepted|error {
        store:FoodOrder|error 'order = datastore->/foodorders/[id]();
        if 'order is persist:NotFoundError {
            return <OrderNotFound>{
                body: {
                    message: string `Could not find the order for id: ${id}`,
                    path: string `/orders/${id}`
                }
            };
        }
        if 'order is error {
            return 'order;
        }
        if 'order.status != store:PAYMENT_PENDING {
            return <PaymentNotAccepted>{
                body: {
                    message: string `Payment not acceptable for order-id: ${id}, status: ${'order.status}`,
                    path: string `/orders/${id}/payment`
                }
            };
        }
        _ = check datastore->/foodorders/[id].put({
            status: store:ACCEPTED
        });
        check self.produceMessage(ORDER_STATUS_UPDATE_TOPIC, jms:TOPIC, {
            orderId: id,
            status: store:ACCEPTED
        });
        return http:OK;
    }

    isolated function produceMessage(string destinationName, jms:DestinationType destinationType,
            ProducerPayload payload) returns error? {
        string jsonStr = payload.toJsonString();
        jms:BytesMessage message = {
            content: jsonStr.toBytes()
        };
        check self.producer->sendTo({
            'type: destinationType,
            name: destinationName
        }, message);
    }
}
