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

final MessageProducer topicProducer = check createProducer(AUTO_ACK_SESSION, {
    'type: TOPIC,
    name: "test-topic-1"
});
final MessageConsumer topic1Consumer = check createConsumer(AUTO_ACK_SESSION, destination = {
    'type: TOPIC,
    name: "test-topic-1"
});

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithTextMessage() returns error? {
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check topicProducer->send(message);
    Message? response = check topic1Consumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithMapMessage() returns error? {
    map<anydata> content = {
        "user": "John Doe",
        "message": "This is a sample message"
    };
    MapMessage message = {
        content: content
    };
    check topicProducer->send(message);
    Message? response = check topic1Consumer->receive(5000);
    test:assertTrue(response is MapMessage, "Invalid message type received");
    if response is MapMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithBytesMessage() returns error? {
    byte[] content = "This is a sample message".toBytes();
    BytesMessage message = {
        content: content
    };
    check topicProducer->send(message);
    Message? response = check topic1Consumer->receive(5000);
    test:assertTrue(response is BytesMessage, "Invalid message type received");
    if response is BytesMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

final MessageProducer topicProducerWithoutDestination = check createProducerWithoutDestination(AUTO_ACK_SESSION);
final MessageConsumer topic2Consumer = check createConsumer(AUTO_ACK_SESSION, destination = {
    'type: TOPIC,
    name: "test-topic-2"
});

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithTextMessageUsingSendTo() returns error? {
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check topicProducerWithoutDestination->sendTo({
        'type: TOPIC,
        name: "test-topic-2"
    }, message);
    Message? response = check topic2Consumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithMapMessageUsingSendTo() returns error? {
    map<anydata> content = {
        "user": "John Doe",
        "message": "This is a sample message"
    };
    MapMessage message = {
        content: content
    };
    check topicProducerWithoutDestination->sendTo({
        'type: TOPIC,
        name: "test-topic-2"
    }, message);
    Message? response = check topic2Consumer->receive(5000);
    test:assertTrue(response is MapMessage, "Invalid message type received");
    if response is MapMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicProducerSendToBytesMessage() returns error? {
    byte[] content = "This is a sample message".toBytes();
    BytesMessage message = {
        content: content
    };
    check topicProducerWithoutDestination->sendTo({
        'type: TOPIC,
        name: "test-topic-2"
    }, message);
    Message? response = check topic2Consumer->receive(5000);
    test:assertTrue(response is BytesMessage, "Invalid message type received");
    if response is BytesMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:AfterGroups {
    value: ["topic"]
}
isolated function afterTopicTests() returns error? {
    check topicProducer->close();
    check topic1Consumer->close();
    check topicProducerWithoutDestination->close();
    check topic2Consumer->close();
}
