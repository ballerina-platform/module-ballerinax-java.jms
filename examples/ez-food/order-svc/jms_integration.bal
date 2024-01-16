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

import ballerinax/activemq.driver as _;
import ballerinax/java.jms;

const string ORDERS_QUEUE = "orders";
const string ORDER_CONFIRMATIONS_QUEUE = "order-confirmation";
const string ORDER_STATUS_UPDATE_TOPIC = "order-status-update";

configurable jms:ConnectionConfiguration activeMqConnectionConfig = {
    initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    providerUrl: "tcp://localhost:61616"
};

final jms:MessageProducer producer = check createProducer();

isolated function createProducer() returns jms:MessageProducer|error {
    jms:Connection connection = check new (activeMqConnectionConfig);
    jms:Session session = check connection->createSession();
    return session.createProducer();
}

type OrderProcessingRequest record {|
    int orderId;
    NewOrder details;
|};

type OrderStatusUpdate record {|
    int orderId;
    store:OrderStatus status;
|};

type ProducerPayload OrderProcessingRequest|OrderStatusUpdate;

isolated function produceMessage(string destinationName, jms:DestinationType destinationType,
        ProducerPayload payload) returns error? {
    string jsonStr = payload.toJsonString();
    jms:BytesMessage message = {
        content: jsonStr.toBytes()
    };
    check producer->sendTo(
        {
        'type: destinationType,
        name: destinationName
    }, message
    );
}

service "order-confirmation-service" on new jms:Listener(
    connectionConfig = activeMqConnectionConfig,
    consumerOptions = {
        destination: {
            'type: jms:QUEUE,
            name: ORDER_CONFIRMATIONS_QUEUE
        }
    }
) {
    remote function onMessage(jms:Message message) returns error? {
        if message !is jms:BytesMessage {
            return;
        }
        // todo: implement this method properly
    }
}

service "order-status-update-service" on new jms:Listener(
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
        // todo: implement this method properly
    }
}

