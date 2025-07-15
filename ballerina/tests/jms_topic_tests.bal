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

final MessageProducer topic1Producer = check createProducer(AUTO_ACK_SESSION, {
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
    Message message = {
        content: content
    };
    check topic1Producer->send(message);
    Message? response = check topic1Consumer->receive(5000);
    test:assertTrue(response is Message, "Invalid message type received");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithMapMessage() returns error? {
    map<Value> content = {
        user: "John Doe",
        message: "This is a sample message"
    };
    Message message = {
        content: content
    };
    check topic1Producer->send(message);
    Message? response = check topic1Consumer->receive(5000);
    test:assertTrue(response is Message, "Invalid message type received");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithBytesMessage() returns error? {
    byte[] content = "This is a sample message".toBytes();
    Message message = {
        content: content
    };
    check topic1Producer->send(message);
    Message? response = check topic1Consumer->receive(5000);
    test:assertTrue(response is Message, "Invalid message type received");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTempTopic() returns error? {
    MessageProducer tempTopicProducer = check createProducer(AUTO_ACK_SESSION, {
        'type: TEMPORARY_TOPIC
    });
    string content = "This is a sample message";
    Message message = {
        content: content
    };
    check tempTopicProducer->send(message);
    check tempTopicProducer->close();
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
    Message message = {
        content: content
    };
    check topicProducerWithoutDestination->sendTo({
        'type: TOPIC,
        name: "test-topic-2"
    }, message);
    Message? response = check topic2Consumer->receive(5000);
    test:assertTrue(response is Message, "Invalid message type received");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicWithMapMessageUsingSendTo() returns error? {
    map<Value> content = {
        user: "John Doe",
        message: "This is a sample message"
    };
    Message message = {
        content: content
    };
    check topicProducerWithoutDestination->sendTo({
        'type: TOPIC,
        name: "test-topic-2"
    }, message);
    Message? response = check topic2Consumer->receive(5000);
    test:assertTrue(response is Message, "Invalid message type received");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["topic"]
}
isolated function testTopicProducerSendToBytesMessage() returns error? {
    byte[] content = "This is a sample message".toBytes();
    Message message = {
        content: content
    };
    check topicProducerWithoutDestination->sendTo({
        'type: TOPIC,
        name: "test-topic-2"
    }, message);
    Message? response = check topic2Consumer->receive(5000);
    test:assertTrue(response is Message, "Invalid message type received");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid payload");
    }
}

@test:Config {
    groups: ["queue"]
}
isolated function testTempTopicUsingSendTo() returns error? {
    MessageProducer tempTopicProducer = check createProducerWithoutDestination(AUTO_ACK_SESSION);
    string content = "This is a sample message";
    Message message = {
        content: content
    };
    check tempTopicProducer->sendTo({
        'type: TEMPORARY_TOPIC
    }, message);
    check tempTopicProducer->close();
}

@test:AfterGroups {
    value: ["topic"]
}
isolated function afterTopicTests() returns error? {
    check topic1Producer->close();
    check topic1Consumer->close();
    check topicProducerWithoutDestination->close();
    check topic2Consumer->close();
}
