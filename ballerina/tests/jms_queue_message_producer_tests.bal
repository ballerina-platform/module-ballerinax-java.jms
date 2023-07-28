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

// import ballerina/log;
import ballerina/test;

final MessageProducer queueProducer = check createQueueProducer(autoAckSession, "test-queue-1");

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendTextMessage() returns error? {
    TextMessage message = {
        content: "This is a sample message"
    };
    check queueProducer->send(message);
}

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendMapMessage() returns error? {
    MapMessage message = {
        content: {
            "user": "John Doe",
            "message": "This is a sample message"
        }
    };
    check queueProducer->send(message);
}

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendBytesMessage() returns error? {
    BytesMessage message = {
        content: "This is a sample message".toBytes()
    };
    check queueProducer->send(message);
}

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendToError() returns error? {
    Destination queue = check createJmsDestination(autoAckSession, QUEUE, "unsupported-queue");
    TextMessage message = {
        content: "This is a sample message"
    };
    error? result = trap queueProducer->sendTo(queue, message);
    test:assertTrue(result is error, "Success results retured for an errorneous scenario");
}

final MessageProducer producerWithoutDefaultDestination = check createProducerWithoutDefaultDestination(autoAckSession);

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendToTextMessage() returns error? {
    TextMessage message = {
        content: "This is a sample message"
    };
    Destination queue = check createJmsDestination(autoAckSession, QUEUE, "test-queue-2");
    check producerWithoutDefaultDestination->sendTo(queue, message);
}

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendToMapMessage() returns error? {
    MapMessage message = {
        content: {
            "user": "John Doe",
            "message": "This is a sample message"
        }
    };
    Destination queue = check createJmsDestination(autoAckSession, QUEUE, "test-queue-2");
    check producerWithoutDefaultDestination->sendTo(queue, message);
}

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendToBytesMessage() returns error? {
    BytesMessage message = {
        content: "This is a sample message".toBytes()
    };
    Destination queue = check createJmsDestination(autoAckSession, QUEUE, "test-queue-2");
    check producerWithoutDefaultDestination->sendTo(queue, message);
}

@test:Config {
    groups: ["queueProducer"]
}
isolated function testQueueProducerSendError() returns error? {
    TextMessage message = {
        content: "This is a sample message"
    };
    error? result = trap producerWithoutDefaultDestination->send(message);
    test:assertTrue(result is error, "Success results retured for an errorneous scenario");
}

// @test:Config {
//     groups: ["queueProducer"]
// }
// isolated function testTempQueueCreation() returns error? {
//     Destination|error dest = trap autoAckSession->createTemporaryQueue();
//     if dest is error {
//         log:printError(string `error occurred [temp-queue]: ${dest.message()}`, dest);
//         return;
//     }
//     MessageProducer|error producer = trap autoAckSession.createProducer(dest);
//     if producer is error {
//         log:printError(string `error occurred [producer]: ${producer.message()}`, producer, stackTrace = producer.stackTrace());
//         return;
//     }
// }
