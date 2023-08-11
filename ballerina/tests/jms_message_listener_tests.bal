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

final MessageProducer queue3Producer = check createProducer(AUTO_ACK_SESSION, {
    'type: QUEUE,
    name: "test-queue-3"
});
final Listener queue3Listener = check new (
    connectionConfig = {
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    },
    consumerOptions = {
        destination: {
            'type: QUEUE,
            name: "test-queue-3"
        }
    }
);
isolated int queue3ServiceReceivedMessageCount = 0;
isolated boolean queue3ServiceReceivedTextMsg = false;
isolated boolean queue3ServiceReceivedMapMsg = false;
isolated boolean queue3ServiceReceivedBytesMsg = false;

final MessageProducer topic3Producer = check createProducer(AUTO_ACK_SESSION, {
    'type: TOPIC,
    name: "test-topic-3"
});
final Listener topic3Listener = check new (
    connectionConfig = {
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    },
    consumerOptions = {
        destination: {
            'type: TOPIC,
            name: "test-topic-3"
        }
    }
);
isolated int topic3ServiceReceivedMessageCount = 0;
isolated boolean topic3ServiceReceivedTextMsg = false;
isolated boolean topic3ServiceReceivedMapMsg = false;
isolated boolean topic3ServiceReceivedBytesMsg = false;

@test:BeforeGroups {
    value: ["messageListener"]
}
isolated function beforeMessageListenerTests() returns error? {
    Service queue3Service = service object {
        remote function onMessage(Message message) returns error? {
            if message is TextMessage {
                lock {
                    queue3ServiceReceivedTextMsg = true;
                }
            }
            if message is MapMessage {
                lock {
                    queue3ServiceReceivedMapMsg = true;
                }
            }
            if message is BytesMessage {
                lock {
                    queue3ServiceReceivedBytesMsg = true;
                }
            }
            lock {
                queue3ServiceReceivedMessageCount += 1;
            }
        }
    };
    check queue3Listener.attach(queue3Service, "test-queue-3-service");
    check queue3Listener.'start();

    Service topic3Service = service object {
        remote function onMessage(Message message) returns error? {
            if message is TextMessage {
                lock {
                    topic3ServiceReceivedTextMsg = true;
                }
            }
            if message is MapMessage {
                lock {
                    topic3ServiceReceivedMapMsg = true;
                }
            }
            if message is BytesMessage {
                lock {
                    topic3ServiceReceivedBytesMsg = true;
                }
            }
            lock {
                topic3ServiceReceivedMessageCount += 1;
            }
        }
    };
    check topic3Listener.attach(topic3Service, "test-topic-3-service");
    check topic3Listener.'start();
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testQueueMessageListener() returns error? {
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check queue3Producer->send(textMsg);
    runtime:sleep(2);
    lock {
        test:assertTrue(queue3ServiceReceivedTextMsg,
            "Queue message listener did not received the text message");
    }

    MapMessage mapMessage = {
        content: {
            "user": "John Doe",
            "message": "This is a sample message"
        }
    };
    check queue3Producer->send(mapMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(queue3ServiceReceivedMapMsg,
            "Queue message listener did not received the map message");
    }

    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check queue3Producer->send(bytesMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(queue3ServiceReceivedBytesMsg,
            "Queue message listener did not received the bytes message");
    }

    lock {
        test:assertEquals(queue3ServiceReceivedMessageCount, 3, 
            "Queue message listener did not received the expected number of messages");
    }
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testTopicMessageListener() returns error? {
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check topic3Producer->send(textMsg);
    runtime:sleep(2);
    lock {
        test:assertTrue(topic3ServiceReceivedTextMsg,
            "Topic message listener did not received the text message");
    }

    MapMessage mapMessage = {
        content: {
            "user": "John Doe",
            "message": "This is a sample message"
        }
    };
    check topic3Producer->send(mapMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(topic3ServiceReceivedMapMsg,
            "Topic message listener did not received the map message");
    }

    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check topic3Producer->send(bytesMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(topic3ServiceReceivedBytesMsg,
            "Topic message listener did not received the bytes message");
    }

    lock {
        test:assertEquals(topic3ServiceReceivedMessageCount, 3, 
            "Topic message listener did not received the expected number of messages");
    }
}

boolean textMsgReceived = false;
boolean mapMsgReceived = false;
boolean bytesMsgReceived = false;
int receivedMsgCount = 0;

@test:Config {
    groups: ["messageListener"]
}
function testNonIsolatedMessageListener() returns error? {
    Listener nonIsolatedMsgListener = check new (
        connectionConfig = {
            initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
            providerUrl: "tcp://localhost:61616"
        },
        consumerOptions = {
            destination: {
                'type: QUEUE,
                name: "test-isolation"
            }
        }
    );
    Service nonIsolatedSvc = service object {
        remote function onMessage(Message message) returns error? {
            if message is TextMessage {
                textMsgReceived = true;
            }
            if message is MapMessage {
                mapMsgReceived = true;
            }
            if message is BytesMessage {
                bytesMsgReceived = true;
            }
            receivedMsgCount += 1;
        }
    };
    check nonIsolatedMsgListener.attach(nonIsolatedSvc, "non-isolated-service");
    check nonIsolatedMsgListener.'start();

    MessageProducer producer = check createProducer(AUTO_ACK_SESSION, {
        'type: QUEUE,
        name: "test-isolation"
    });
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check producer->send(textMsg);
    runtime:sleep(2);
    test:assertTrue(textMsgReceived,
            "Queue message listener did not received the text message");

    MapMessage mapMessage = {
        content: {
            "user": "John Doe",
            "message": "This is a sample message"
        }
    };
    check producer->send(mapMessage);
    runtime:sleep(2);
    test:assertTrue(mapMsgReceived,
            "Queue message listener did not received the map message");

    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check producer->send(bytesMessage);
    runtime:sleep(2);
    test:assertTrue(bytesMsgReceived,
            "Queue message listener did not received the bytes message");

    test:assertEquals(receivedMsgCount, 3,
            "Queue message listener did not received the expected number of messages");
    check producer->close();
    check nonIsolatedMsgListener.gracefulStop();
}

isolated boolean msgListenerWithCallerTextMsgReceived = false;
isolated boolean msgListenerWithCallerMapMsgReceived = false;
isolated boolean msgListenerWithCallerBytesMsgReceived = false;
isolated int msgListenerWithCallerReceivedMsgCount = 0;

@test:Config {
    groups: ["messageListener"]
}
isolated function testMessageListenerWithCaller() returns error? { 
    Listener msgListener = check new (
        connectionConfig = {
            initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
            providerUrl: "tcp://localhost:61616"
        },
        acknowledgementMode = CLIENT_ACKNOWLEDGE,
        consumerOptions = {
            destination: {
                'type: QUEUE,
                name: "test-caller"
            }
        }
    );
    Service consumerSvc = service object {
        remote function onMessage(Message message, Caller caller) returns error? {
            if message is TextMessage {
                lock {
                    msgListenerWithCallerTextMsgReceived = true;
                }
            }
            if message is MapMessage {
                lock {
                    msgListenerWithCallerMapMsgReceived = true;
                }
            }
            if message is BytesMessage {
                lock {
                    msgListenerWithCallerBytesMsgReceived = true;
                }
            }
            lock {
                msgListenerWithCallerReceivedMsgCount += 1;
            }
            check caller->acknowledge(message);
        }
    };
    check msgListener.attach(consumerSvc, "test-caller-service");
    check msgListener.'start();

    MessageProducer producer = check createProducer(AUTO_ACK_SESSION, {
        'type: QUEUE,
        name: "test-caller"
    });
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check producer->send(textMsg);
    runtime:sleep(2);
    lock {
        test:assertTrue(msgListenerWithCallerTextMsgReceived,
            "Queue message listener did not received the text message");
    }

    MapMessage mapMessage = {
        content: {
            "user": "John Doe",
            "message": "This is a sample message"
        }
    };
    check producer->send(mapMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(msgListenerWithCallerMapMsgReceived,
            "Queue message listener did not received the map message");
    }

    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check producer->send(bytesMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(msgListenerWithCallerBytesMsgReceived,
            "Queue message listener did not received the bytes message");
    }

    lock {
        test:assertEquals(msgListenerWithCallerReceivedMsgCount, 3,
            "Queue message listener did not received the expected number of messages");
    }
    check producer->close();
    check msgListener.gracefulStop();
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testMessageListenerReturningError() returns error? { 
    Listener msgListener = check new (
        connectionConfig = {
            initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
            providerUrl: "tcp://localhost:61616"
        },
        acknowledgementMode = CLIENT_ACKNOWLEDGE,
        consumerOptions = {
            destination: {
                'type: QUEUE,
                name: "test-onMessage-error"
            }
        }
    );
    Service consumerSvc = service object {
        remote function onMessage(Message message) returns error? {
            return error("Error occurred while processing the message");
        }
    };
    check msgListener.attach(consumerSvc, "test-onMessage-error-service");
    check msgListener.'start();

    MessageProducer producer = check createProducer(AUTO_ACK_SESSION, {
        'type: QUEUE,
        name: "test-onMessage-error"
    });
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check producer->send(textMsg);
    runtime:sleep(2);
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testMessageListenerImmediateStop() returns error? { 
    Listener msgListener = check new (
        connectionConfig = {
            initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
            providerUrl: "tcp://localhost:61616"
        },
        acknowledgementMode = CLIENT_ACKNOWLEDGE,
        consumerOptions = {
            destination: {
                'type: QUEUE,
                name: "test-caller"
            }
        }
    );
    Service consumerSvc = service object {
        remote function onMessage(Message message, Caller caller) returns error? {}
    };
    check msgListener.attach(consumerSvc, "test-caller-service");
    check msgListener.'start();
    runtime:sleep(2);
    check msgListener.immediateStop();
}

@test:AfterGroups {
    value: ["messageListener"]
}
isolated function afterMessageListenerTests() returns error? {
    check queue3Producer->close();
    check queue3Listener.gracefulStop();

    check topic3Producer->close();
    check topic3Listener.gracefulStop();
}
