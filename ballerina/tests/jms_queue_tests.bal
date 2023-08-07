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

final MessageProducer queueProducer = check createProducer(AUTO_ACK_SESSION, {
    'type: QUEUE,
    name: "test-queue-1"
});
final MessageConsumer queue1Consumer = check createConsumer(AUTO_ACK_SESSION, destination = {
    'type: QUEUE,
    name: "test-queue-1"
});

@test:Config {
    groups: ["queue"]
}
isolated function testQueueWithTextMessage() returns error? {
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check queueProducer->send(message);
    Message? response = check queue1Consumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["queue"]
}
isolated function testQueueWithMapMessage() returns error? {
    map<anydata> content = {
        "user": "John Doe",
        "message": "This is a sample message"
    };
    MapMessage message = {
        content: content
    };
    check queueProducer->send(message);
    Message? response = check queue1Consumer->receive(5000);
    test:assertTrue(response is MapMessage, "Invalid message type received");
    if response is MapMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["queue"]
}
isolated function testQueueWithBytesMessage() returns error? {
    byte[] content = "This is a sample message".toBytes();
    BytesMessage message = {
        content: content
    };
    check queueProducer->send(message);
    Message? response = check queue1Consumer->receive(5000);
    test:assertTrue(response is BytesMessage, "Invalid message type received");
    if response is BytesMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["queue"]
}
isolated function testTempQueue() returns error? {
    MessageProducer tempQueueProducer = check createProducer(AUTO_ACK_SESSION, {
        'type: TEMPORARY_QUEUE
    });
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check tempQueueProducer->send(message);
    check tempQueueProducer->close();
}

@test:Config {
    groups: ["queue"]
}
isolated function testQueueProducerSendToError() returns error? {
    TextMessage message = {
        content: "This is a sample message"
    };
    Error? result = queueProducer->sendTo({
        'type: QUEUE,
        name: "unsupported-queue"
    }, message);
    test:assertTrue(result is Error, 
        "Allowing to send messages to other destination rather than the configured destination");
}

final MessageProducer queueProducerWithoutDestination = check createProducerWithoutDestination(AUTO_ACK_SESSION);
final MessageConsumer queue2Consumer = check createConsumer(AUTO_ACK_SESSION, destination = {
    'type: QUEUE,
    name: "test-queue-2"
});

@test:Config {
    groups: ["queue"]
}
isolated function testQueueWithTextMessageUsingSendTo() returns error? {
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check queueProducerWithoutDestination->sendTo({
        'type: QUEUE,
        name: "test-queue-2"
    }, message);
    Message? response = check queue2Consumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["queue"]
}
isolated function testQueueWithMapMessageUsingSendTo() returns error? {
    map<anydata> content = {
        "user": "John Doe",
        "message": "This is a sample message"
    };
    MapMessage message = {
        content: content
    };
    check queueProducerWithoutDestination->sendTo({
        'type: QUEUE,
        name: "test-queue-2"
    }, message);
    Message? response = check queue2Consumer->receive(5000);
    test:assertTrue(response is MapMessage, "Invalid message type received");
    if response is MapMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["queue"]
}
isolated function testQueueWithBytesMessageUsingSendTo() returns error? {
    byte[] content = "This is a sample message".toBytes();
    BytesMessage message = {
        content: content
    };
    check queueProducerWithoutDestination->sendTo({
        'type: QUEUE,
        name: "test-queue-2"
    }, message);
    Message? response = check queue2Consumer->receive(5000);
    test:assertTrue(response is BytesMessage, "Invalid message type received");
    if response is BytesMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["queue"]
}
isolated function testTempQueueUsingSendTo() returns error? {
    MessageProducer tempQueueProducer = check createProducerWithoutDestination(AUTO_ACK_SESSION);
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check tempQueueProducer->sendTo({
        'type: TEMPORARY_QUEUE
    }, message);
    check tempQueueProducer->close();
}

@test:Config {
    groups: ["queue"]
}
isolated function testQueueProducerSendError() returns error? {
    TextMessage message = {
        content: "This is a sample message"
    };
    Error? result = queueProducerWithoutDestination->send(message);
    test:assertTrue(result is Error, "Allowing to send messages without providing a destination");
}

@test:AfterGroups {
    value: ["queue"]
}
isolated function afterQueueTests() returns error? {
    check queueProducer->close();
    check queue1Consumer->close();
    check queueProducerWithoutDestination->close();
    check queue2Consumer->close();
}
