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

@test:Config {
    groups: ["producer"]
}
isolated function testCreateProducerWithoutQueueName() returns error? {
    MessageProducer|Error producer = AUTO_ACK_SESSION.createProducer({
        'type: QUEUE
    });
    test:assertTrue(producer is Error, "Allowing creating a queue-producer without queue-name");
    if producer is Error {
        test:assertEquals(producer.message(), 
            "JMS destination name can not be empty for destination type: QUEUE", 
            "Invalid error message for producer init error");
    }
}

@test:Config {
    groups: ["producer"]
}
isolated function testProducerSendToWithoutQueueName() returns error? {
    MessageProducer producer = check AUTO_ACK_SESSION.createProducer();
    TextMessage message = {
        content: "This is a sample message"
    };
    Error? result = producer->sendTo({ 'type: QUEUE }, message);
    test:assertTrue(result is Error, "Allowing sending messages to a queue without queue-name");
    if result is Error {
        test:assertEquals(result.message(), 
            "JMS destination name can not be empty for destination type: QUEUE", 
            "Invalid error message for producer init error");
    }
}

@test:Config {
    groups: ["producer"]
}
isolated function testReplyToErrorForQueue() returns error? {
    MessageProducer producer = check AUTO_ACK_SESSION.createProducer();
    TextMessage message = {
        content: "This is a request message",
        correlationId: "cid-123",
        replyTo: {
            'type: QUEUE
        }
    };
    Error? result = producer->sendTo({
        'type: QUEUE,
        name: "reply-to-error-queue"
    }, message);
    test:assertTrue(result is Error, "Sent message with errorneous replyTo field");
    if result is Error {
        test:assertEquals(result.message(), 
            "JMS destination name can not be empty for destination type: QUEUE", 
            "Invalid error message for invalid-destination error");
    }
}

@test:Config {
    groups: ["producer"]
}
isolated function testReplyToErrorForTopic() returns error? {
    MessageProducer producer = check AUTO_ACK_SESSION.createProducer();
    TextMessage message = {
        content: "This is a request message",
        correlationId: "cid-123",
        replyTo: {
            'type: TOPIC
        }
    };
    Error? result = producer->sendTo({
        'type: TOPIC,
        name: "reply-to-error-topic"
    }, message);
    test:assertTrue(result is Error, "Sent message with errorneous replyTo field");
    if result is Error {
        test:assertEquals(result.message(), 
            "JMS destination name can not be empty for destination type: TOPIC", 
            "Invalid error message for invalid-destination error");
    }
}
