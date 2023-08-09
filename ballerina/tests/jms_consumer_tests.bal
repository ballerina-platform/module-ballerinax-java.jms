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

import ballerina/lang.runtime;
import ballerina/test;


final MessageProducer queue7Producer = check createProducer(AUTO_ACK_SESSION, {
    'type: QUEUE,
    name: "test-queue-7"
});
final MessageConsumer queue7Consumer = check createConsumer(AUTO_ACK_SESSION, destination = {
    'type: QUEUE,
    name: "test-queue-7"
});

@test:Config {
    groups: ["consumer"]
}
isolated function testReceiveNoWaitWithQueue() returns error? {
    Message? response = check queue7Consumer->receiveNoWait();
    test:assertTrue(response is (), "Received a message for non-existing scenario");

    TextMessage message = {
        content: "This is a sample message"
    };
    check queue7Producer->send(message);
    response = check queue7Consumer->receiveNoWait();
    test:assertTrue(response is TextMessage, "Received a invalid message type");
    if response is TextMessage {
        test:assertEquals(response.content, "This is a sample message", "Invalid content received");
    }
}

final MessageProducer topic7Producer = check createProducer(AUTO_ACK_SESSION, {
    'type: TOPIC,
    name: "test-topic-7"
});
final MessageConsumer topic7Consumer = check createConsumer(AUTO_ACK_SESSION, destination = {
    'type: TOPIC,
    name: "test-topic-7"
});

@test:Config {
    groups: ["consumer"]
}
isolated function testReceiveNoWaitWithTopic() returns error? {
    Message? response = check topic7Consumer->receiveNoWait();
    test:assertTrue(response is (), "Received a message for non-existing scenario");

    TextMessage message = {
        content: "This is a sample message"
    };
    check topic7Producer->send(message);
    runtime:sleep(2);
    response = check topic7Consumer->receiveNoWait();
    test:assertTrue(response is TextMessage, "Received a invalid message type");
    if response is TextMessage {
        test:assertEquals(response.content, "This is a sample message", "Invalid content received");
    }
}

@test:AfterGroups {
    value: ["consumer"]
}
isolated function afterConsumerTests() returns error? {
    check queue7Producer->close();
    check queue7Consumer->close();
    check topic7Producer->close();
    check topic7Consumer->close();
}