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

final Session clientAckSession = check createSession(CLIENT_ACKNOWLEDGE);

final MessageProducer queue4Producer = check createProducer(clientAckSession, {
    'type: QUEUE,
    name: "test-queue-4"
});
final MessageConsumer queue4Consumer = check createConsumer(clientAckSession, destination = {
    'type: QUEUE,
    name: "test-queue-4"
});

@test:Config {
    groups: ["sessionClientAck"]
}
isolated function testClientAckWithQueue() returns error? {
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check queue4Producer->send(message);
    Message? response = check queue4Consumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
        check queue4Consumer->acknowledge(response);
    }
}

final MessageProducer topic4Producer = check createProducer(AUTO_ACK_SESSION, {
    'type: TOPIC,
    name: "test-topic-4"
});
final MessageConsumer topic4Consumer = check createConsumer(AUTO_ACK_SESSION, destination = {
    'type: TOPIC,
    name: "test-topic-4"
});

@test:Config {
    groups: ["sessionClientAck"]
}
isolated function testClientAckWithTopic() returns error? {
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check topic4Producer->send(message);
    Message? response = check topic4Consumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
        check topic4Consumer->acknowledge(response);
    }
}

@test:Config {
    groups: ["sessionClientAck"]
}
isolated function testInvalidClientAck() returns error? {
    Session session = check createSession(CLIENT_ACKNOWLEDGE);
    MessageProducer producer = check createProducer(session, {
        'type: QUEUE,
        name: "test-queue-5"
    });
    MessageConsumer consumer = check createConsumer(session, destination = {
        'type: QUEUE,
        name: "test-queue-5"
    });
    string content = "This is a sample message";
    TextMessage message = {
        content: content
    };
    check producer->send(message);
    Message? response = check consumer->receive(5000);
    test:assertTrue(response is TextMessage, "Invalid message type received");
    if response is TextMessage {
        test:assertEquals(response.content, content, "Invalid payload");
        check session->close();
        Error? result = consumer->acknowledge(response);
        test:assertTrue(result is Error, "Successfully acknowledged messages in a closed session");
        if result is Error {
            test:assertEquals(result.message(), 
                "Error occurred while sending acknowledgement for the message: The Consumer is closed", 
                "Invalid client ack error message recieved");
        }
    }
}

@test:AfterGroups {
    value: ["sessionClientAck"]
}
isolated function afterSessionClientAckTests() returns error? {
    check queue4Producer->close();
    check queue4Consumer->close();
    check topic4Producer->close();
    check topic4Consumer->close();
    check clientAckSession->close();
}
