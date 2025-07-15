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

    Message message = {
        content: "This is a sample message"
    };
    check queue7Producer->send(message);
    response = check queue7Consumer->receiveNoWait();
    test:assertTrue(response is Message, "Received a invalid message type");
    if response is Message {
        test:assertEquals(response.content, "This is a sample message", "Invalid content received");
    }
}

@test:Config {
    groups: ["consumer"]
}
isolated function testRequestReplyWithQueue() returns error? {
    Message requestMessage = {
        content: "This is a request message",
        correlationId: "cid-123",
        replyTo: {
            'type: QUEUE,
            name: "reply-queue"
        }
    };
    check queue7Producer->send(requestMessage);

    Message? request = check queue7Consumer->receive(5000);
    test:assertTrue(request is Message, "Invalid message received");
    if request is Message {
        MessageProducer replyProducer = check createProducer(AUTO_ACK_SESSION, {
            'type: QUEUE,
            name: "reply-queue"
        });
        test:assertTrue(request.correlationId is string, "Could not find the correlation Id");
        Message replyMessage = {
            content: "This is a reply message"
        };
        replyMessage.correlationId = check request.correlationId.ensureType();
        check replyProducer->send(replyMessage);
        check replyProducer->close();
    } 
}

@test:Config {
    groups: ["consumer"]
}
isolated function testRequestReplyWithTempQueue() returns error? {
    Message requestMessage = {
        content: "This is a request message",
        correlationId: "cid-123",
        replyTo: {
            'type: TEMPORARY_QUEUE,
            name: "temp-reply-queue"
        }
    };
    check queue7Producer->send(requestMessage);

    Message? request = check queue7Consumer->receive(5000);
    test:assertTrue(request is Message, "Invalid message received");
    if request is Message {
        test:assertTrue(request.replyTo is Destination, "Could not find the replyTo destination in a request-message");
        Destination replyTo = check request.replyTo.ensureType();
        MessageProducer replyProducer = check createProducer(AUTO_ACK_SESSION, replyTo);
        test:assertTrue(request.correlationId is string, "Could not find the correlation Id");
        Message replyMessage = {
            content: "This is a reply message"
        };
        replyMessage.correlationId = check request.correlationId.ensureType();
        check replyProducer->send(replyMessage);
        check replyProducer->close();
    } 
}

@test:Config {
    groups: ["consumer"]
}
isolated function testReceiveMapMessageWithMultipleTypes() returns error? {
    map<Value> content = {
        intPayload: 1,
        floatPayload: 1.0,
        strPayload: "This is a sample message",
        bytePayload: "This is a sample message".toBytes(),
        boolPayload: true,
        byteField: 1
    };
    Message message = {
        content: content
    };
    check queue7Producer->send(message);
    runtime:sleep(2);
    Message? response = check queue7Consumer->receiveNoWait();
    test:assertTrue(response is Message, "Received a invalid message type");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid content received");
    }
}

@test:Config {
    groups: ["consumer"]
}
isolated function testReceiveMapMessageWithProperties() returns error? {
    map<Property> properties = {
        intProperty: 1,
        floatProperty: 1.0,
        strProperty: "This is a sample message",
        boolProperty: true,
        byteProperty: 1        
    };
    map<Value> content = {
        intPayload: 1,
        floatPayload: 1.0,
        strPayload: "This is a sample message",
        bytePayload: "This is a sample message".toBytes(),
        boolPayload: true,
        byteField: 1
    };
    Message message = {
        jmsType: "provider-specific-type-1",
        content,
        properties
    };
    check queue7Producer->send(message);
    runtime:sleep(2);
    Message? response = check queue7Consumer->receiveNoWait();
    test:assertTrue(response is Message, "Received a invalid message type");
    if response is Message {
        test:assertEquals(response.content, content, "Invalid content received");
        test:assertEquals(response.properties, properties, "Invalid properties received");
        test:assertEquals(response.jmsType, "provider-specific-type-1", "Invalid JMS type field");
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

    Message message = {
        content: "This is a sample message"
    };
    check topic7Producer->send(message);
    runtime:sleep(2);
    response = check topic7Consumer->receiveNoWait();
    test:assertTrue(response is Message, "Received a invalid message type");
    if response is Message {
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
