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

import ballerinax/java.jms;

const string ORDERS_QUEUE = "orders";
const string ORDER_CONFIRMATIONS_QUEUE = "order-confirmation";

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

listener jms:Listener orderDetailsListener = check new (activeMqConnectionConfig);

@jms:ServiceConfig {
    queueName: ORDERS_QUEUE
}
service "order-details-receiver" on orderDetailsListener {
    remote function onMessage(jms:Message message) returns error? {
        if message !is jms:BytesMessage {
            return;
        }
        string jsonStr = check string:fromBytes(message.content);
        OrderProcessingRequest orderProcessingRequest = check jsonStr.fromJsonStringWithType();
        check processRequest(orderProcessingRequest);
    }
}

isolated function processRequest(OrderProcessingRequest request) returns error? {
    store:Item[] items = check mapToStoreItems(request);
    int estimatedDuration = items.'map(itm => itm.prepTimePerUnit * itm.quantity)
        .reduce(isolated function(int a, int b) returns int => a + b, 0);
    decimal subTotal = items.'map(itm => itm.unitPrice * itm.quantity)
        .reduce(isolated function(decimal a, decimal b) returns decimal => a + b, 0d);
    check produceMessage(ORDER_CONFIRMATIONS_QUEUE, jms:QUEUE, {
        orderId: request.orderId,
        subTotal: subTotal,
        estimatedDuration: estimatedDuration
    });
    check updateDb(request.orderId, estimatedDuration, items);
}

isolated function mapToStoreItems(OrderProcessingRequest request) returns store:Item[]|error {
    store:Item[] result = [];
    foreach var item in request.details.items {
        MenuItem itemDetails = check menu->/[item.itemId].get();
        result.push({
            id: getNextOrderItemId(),
            orderId: request.orderId,
            name: itemDetails.name,
            quantity: item.quantity,
            unitPrice: itemDetails.price,
            prepTimePerUnit: itemDetails.preparationTimeMinutes
        });
    }
    return result;
}

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

isolated function updateDb(int orderId, int estimatedDuration, store:Item[] items) returns error? {
    store:FoodOrderInsert foodOrder = {
        id: orderId,
        status: store:PAYMENT_PENDING,
        estimatedDuration: estimatedDuration,
        processingStartedTime: ()
    };
    _ = check store->/foodorders.post([foodOrder]);
    _ = check store->/items.post(items);
}

// Holds the Id of the next order-item
isolated int nextOrderItemId = 1;

isolated function getNextOrderItemId() returns int {
    lock {
        int currentId = nextOrderItemId;
        nextOrderItemId += 1;
        return currentId;
    }
}
