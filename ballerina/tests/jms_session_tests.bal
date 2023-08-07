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
    test:assertTrue(queueConsumer is MessageConsumer);
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
    test:assertTrue(topicConsumer is MessageConsumer);
    check topicConsumer->close();
}

@test:AfterGroups {
    value: ["session"]
}
isolated function afterSessionTests() returns error? {
    check autoAckSession->close();
}