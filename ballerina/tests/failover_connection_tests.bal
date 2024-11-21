// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.org).
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
import ballerinax/activemq.driver as _;

final Connection testFailoverConnection = check new (
    initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    providerUrl = "failover:(tcp://localhost:61616)"
);

final Session failoverAutoAckSession = check createSession(AUTO_ACKNOWLEDGE);

isolated function createFailoverSession(AcknowledgementMode acknowledgementMode) returns Session|error {
    return testFailoverConnection->createSession(acknowledgementMode);
}

@test:Config {
    groups: ["failover"]
}
isolated function testQueueWithTextMessageWithFailover() returns error? {
    MessageProducer failoverQueueProducer = check createProducer(failoverAutoAckSession, {
        'type: QUEUE,
        name: "test-failover-queue"
    });
    final MessageConsumer failoverQueueConsumer = check createConsumer(failoverAutoAckSession, destination = {
        'type: QUEUE,
        name: "test-failover-queue"
    });

    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check failoverQueueProducer->send(message);
    Message? response = check failoverQueueConsumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }

    check failoverQueueProducer->close();
    check failoverQueueConsumer->close();
}

@test:Config {
    groups: ["failover"]
}
isolated function testTopicWithTextMessageWithFailover() returns error? {
    MessageProducer failoverTopicProducer = check createProducer(autoAckSession, {
        'type: TOPIC,
        name: "test-failover-topic"
    });
    MessageConsumer failoverTopicConsumer = check createConsumer(autoAckSession, destination = {
        'type: TOPIC,
        name: "test-failover-topic"
    });

    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check failoverTopicProducer->send(message);
    Message? response = check failoverTopicConsumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
    }

    check failoverTopicProducer->close();
    check failoverTopicConsumer->close();
}

@test:AfterGroups {
    groups: ["failover"]
}
isolated function afterSuite() returns error? {
    check failoverAutoAckSession->close();
    check testFailoverConnection->close();
}


