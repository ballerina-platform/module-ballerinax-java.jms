// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/test;

final Session autoAckSession = check createSession(AUTO_ACKNOWLEDGE);

@test:Config {
    groups: ["session"]
}
isolated function testCreateQueueProducer() returns error? {
    MessageProducer queueProducer = check autoAckSession.createProducer({
        'type: QUEUE,
        name: "producer-create"
    });
    check queueProducer->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateTempQueueProducer() returns error? {
    MessageProducer tempQueueProducer = check autoAckSession.createProducer({
        'type: TEMPORARY_QUEUE
    });
    check tempQueueProducer->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateTopicProducer() returns error? {
    MessageProducer topicProducer = check autoAckSession.createProducer({
        'type: TOPIC,
        name: "producer-create"
    });
    check topicProducer->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateTempTopicProducer() returns error? {
    MessageProducer tempTopicProducer = check autoAckSession.createProducer({
        'type: TEMPORARY_TOPIC
    });
    check tempTopicProducer->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateProducerWithoutDestination() returns error? {
    MessageProducer producer = check autoAckSession.createProducer();
    check producer->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateDefaultQueueConsumer() returns error? {
    MessageConsumer queueConsumer = check autoAckSession.createConsumer(destination = {
        'type: QUEUE,
        name: "consumer-create"
    });
    check queueConsumer->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateDefaultTopicConsumer() returns error? {
    MessageConsumer topicConsumer = check autoAckSession.createConsumer(destination = {
        'type: TOPIC,
        name: "consumer-create"
    });
    check topicConsumer->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateDurableConsumer() returns error? {
    MessageConsumer durableSubscriber = check autoAckSession.createConsumer(
        'type = DURABLE,
        destination = {
            'type: TOPIC,
            name: "consumer-create"
        },
        subscriberName = "durable-subscriber"
    );
    check durableSubscriber->close();
    check autoAckSession->unsubscribe("durable-subscriber");
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateDurableConsumerForQueueError() returns error? {
    MessageConsumer|Error durableSubscriber = autoAckSession.createConsumer(
        'type = DURABLE,
        destination = {
            'type: QUEUE,
            name: "consumer-create"
        },
        subscriberName = "durable-subscriber"
    );
    test:assertTrue(durableSubscriber is Error, "Durable subscription created for a queue");
    if durableSubscriber is Error {
        test:assertEquals(durableSubscriber.message(), 
            "Invalid destination type: QUEUE provided for a DURABLE consumer", 
            "Invalid error message for consumer-creation");
    }
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateDurableConsumerWithoutNameError() returns error? {
    MessageConsumer|Error durableSubscriber = autoAckSession.createConsumer(
        'type = DURABLE,
        destination = {
            'type: TOPIC,
            name: "consumer-create"
        }
    );
    test:assertTrue(durableSubscriber is Error, "Durable subscription created withou a subscriber name");
    if durableSubscriber is Error {
        test:assertEquals(durableSubscriber.message(), 
            "Subscriber name cannot be empty for consumer type DURABLE", 
            "Invalid error message for consumer-creation");
    }
}

@test:Config {
    groups: ["session"]
}
isolated function tesUnsubscribeFromInvalidSubscription() returns error? {
    Session session = check createSession(AUTO_ACKNOWLEDGE);
    Error? result = session->unsubscribe("invalidSubscriber");
    test:assertTrue(result is Error, "Invalid subscription removal allowed");
    if result is Error {
        string errorMsg = "Error while unsubscribing from the subscription session";
        test:assertTrue(result.message().startsWith(errorMsg), 
            "Invalid error message for ubsubscription from invalid-subscriber");
    }
}

// @test:Config {
//     groups: ["session"]
// }
isolated function testCreateSharedConsumer() returns error? {
    MessageConsumer sharedSubscriber = check autoAckSession.createConsumer(
        'type = SHARED,
        destination = {
            'type: TOPIC,
            name: "consumer-create"
        },
        subscriberName = "shared-subscriber"
    );
    check sharedSubscriber->close();
}

// @test:Config {
//     groups: ["session"]
// }
isolated function testCreateSharedDurableConsumer() returns error? {
    MessageConsumer sharedDurableSubscriber = check autoAckSession.createConsumer(
        'type = SHARED_DURABLE,
        destination = {
            'type: TOPIC,
            name: "consumer-create"
        },
        subscriberName = "shared-subscriber"
    );
    check sharedDurableSubscriber->close();
}

@test:Config {
    groups: ["session"]
}
isolated function testCloseSession() returns error? {
    Session session = check createSession(AUTO_ACKNOWLEDGE);
    check session->close();
}

@test:AfterGroups {
    value: ["session"]
}
isolated function afterSessionTests() returns error? {
    check autoAckSession->close();
}
