// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
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

listener Listener jmsMessageListener = check new (
    initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    providerUrl = "tcp://localhost:61616"
);

final MessageProducer queue3Producer = check createProducer(AUTO_ACK_SESSION, {'type: QUEUE, name: "test-queue-3"});

isolated int queue3ServiceReceivedMessageCount = 0;
isolated boolean queue3ServiceReceivedTextMsg = false;
isolated boolean queue3ServiceReceivedMapMsg = false;
isolated boolean queue3ServiceReceivedBytesMsg = false;

final MessageProducer topic3Producer = check createProducer(AUTO_ACK_SESSION, {'type: TOPIC, name: "test-topic-3"});

isolated int topic3ServiceReceivedMessageCount = 0;
isolated boolean topic3ServiceReceivedTextMsg = false;
isolated boolean topic3ServiceReceivedMapMsg = false;
isolated boolean topic3ServiceReceivedBytesMsg = false;

@test:BeforeGroups {
    value: ["messageListener"]
}
isolated function beforeMessageListenerTests() returns error? {
    Service queue3Service = @ServiceConfig {
        queueName: "test-queue-3"
    } service object {
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

    Service topic3Service = @ServiceConfig {
        topicName: "test-topic-3"
    } service object {
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
    check jmsMessageListener.attach(queue3Service, "test-queue-3-service");
    check jmsMessageListener.attach(topic3Service, "test-topic-3-service");
    check jmsMessageListener.'start();
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testQueueService() returns error? {
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check queue3Producer->send(textMsg);
    runtime:sleep(2);
    lock {
        test:assertTrue(queue3ServiceReceivedTextMsg, "'test-queue-3' did not received the text message");
    }

    MapMessage mapMessage = {
        content: {
            user: "John Doe",
            message: "This is a sample message"
        }
    };
    check queue3Producer->send(mapMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(queue3ServiceReceivedMapMsg, "'test-queue-3' did not received the map message");
    }

    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check queue3Producer->send(bytesMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(queue3ServiceReceivedBytesMsg, "'test-queue-3' did not received the bytes message");
    }

    lock {
        test:assertEquals(queue3ServiceReceivedMessageCount, 3, "'test-queue-3' did not received the expected number of messages");
    }
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testTopicService() returns error? {
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check topic3Producer->send(textMsg);
    runtime:sleep(2);
    lock {
        test:assertTrue(topic3ServiceReceivedTextMsg, "'test-topic-3' did not received the text message");
    }

    MapMessage mapMessage = {
        content: {
            user: "John Doe",
            message: "This is a sample message"
        }
    };
    check topic3Producer->send(mapMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(topic3ServiceReceivedMapMsg, "'test-topic-3' did not received the map message");
    }

    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check topic3Producer->send(bytesMessage);
    runtime:sleep(2);
    lock {
        test:assertTrue(topic3ServiceReceivedBytesMsg, "'test-topic-3' did not received the bytes message");
    }

    lock {
        test:assertEquals(topic3ServiceReceivedMessageCount, 3, "'test-topic-3' did not received the expected number of messages");
    }
}

boolean textMsgReceived = false;
boolean mapMsgReceived = false;
boolean bytesMsgReceived = false;
int receivedMsgCount = 0;

@test:Config {
    groups: ["messageListener"]
}
function testNonIsolatedService() returns error? {
    Service nonIsolatedSvc = @ServiceConfig {
        queueName: "test-isolation"
    } service object {
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
    check jmsMessageListener.attach(nonIsolatedSvc, "non-isolated-service");

    MessageProducer producer = check createProducer(AUTO_ACK_SESSION, {'type: QUEUE, name: "test-isolation"});
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check producer->send(textMsg);
    runtime:sleep(2);
    test:assertTrue(textMsgReceived, "'test-isolation' queue did not received the text message");

    MapMessage mapMessage = {
        content: {
            user: "John Doe",
            message: "This is a sample message"
        }
    };
    check producer->send(mapMessage);
    runtime:sleep(2);
    test:assertTrue(mapMsgReceived, "'test-isolation' queue did not received the map message");

    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check producer->send(bytesMessage);
    runtime:sleep(2);
    test:assertTrue(bytesMsgReceived, "'test-isolation' queue did not received the bytes message");

    test:assertEquals(receivedMsgCount, 3, "'test-isolation' queue did not received the expected number of messages");
    check producer->close();
}

isolated boolean serviceWithCallerTextMsgReceived = false;
isolated boolean serviceWithCallerMapMsgReceived = false;
isolated boolean serviceWithCallerBytesMsgReceived = false;
isolated int serviceWithCallerReceivedMsgCount = 0;

@test:Config {
    groups: ["messageListener"]
}
isolated function testServiceWithCaller() returns error? {
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: CLIENT_ACKNOWLEDGE,
        queueName: "test-caller"
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
            if message is TextMessage {
                lock {
                    serviceWithCallerTextMsgReceived = true;
                }
            }
            if message is MapMessage {
                lock {
                    serviceWithCallerMapMsgReceived = true;
                }
            }
            if message is BytesMessage {
                lock {
                    serviceWithCallerBytesMsgReceived = true;
                }
            }
            lock {
                serviceWithCallerReceivedMsgCount += 1;
            }
            check caller->acknowledge(message);
        }
    };
    check jmsMessageListener.attach(consumerSvc, "test-caller-service");

    MessageProducer producer = check createProducer(AUTO_ACK_SESSION, {'type: QUEUE, name: "test-caller"});
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check producer->send(textMsg);
    MapMessage mapMessage = {
        content: {
            user: "John Doe",
            message: "This is a sample message"
        }
    };
    check producer->send(mapMessage);
    BytesMessage bytesMessage = {
        content: "This is a sample message".toBytes()
    };
    check producer->send(bytesMessage);

    runtime:sleep(5);
    lock {
        test:assertTrue(serviceWithCallerTextMsgReceived, "'test-caller' queue did not received the text message");
    }
    lock {
        test:assertTrue(serviceWithCallerMapMsgReceived, "'test-caller' queue did not received the map message");
    }
    lock {
        test:assertTrue(serviceWithCallerBytesMsgReceived, "'test-caller' queue did not received the bytes message");
    }
    lock {
        test:assertEquals(serviceWithCallerReceivedMsgCount, 3, "'test-caller' queue did not received the expected number of messages");
    }
    check producer->close();
}

isolated int ServiceWithTransactionsMsgCount = 0;

@test:Config {
    groups: ["messageListener", "svcTrx"]
}
isolated function testServiceWithTransactions() returns error? {
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: SESSION_TRANSACTED,
        queueName: "test-transactions"
    } service object {
        isolated remote function onMessage(Message message, Caller caller) returns error? {
            if message is TextMessage {
                lock {
                    ServiceWithTransactionsMsgCount += 1;
                }
                if message.content == "End of messages" {
                    check caller->'commit();
                }
            }
        }
    };
    check jmsMessageListener.attach(consumerSvc, "test-transacted-service");

    Session transactedSession = check createSession(SESSION_TRANSACTED);
    MessageProducer producer = check createProducer(transactedSession, {'type: QUEUE, name: "test-transactions"});
    check producer->send(<TextMessage>{content: "This is the first message"});
    check producer->send(<TextMessage>{content: "This is the second message"});
    check producer->send(<TextMessage>{content: "This is the third message"});
    check producer->send(<TextMessage>{content: "End of messages"});
    check transactedSession->'commit();

    runtime:sleep(5);
    lock {
        test:assertEquals(ServiceWithTransactionsMsgCount, 4, "Invalid number of received messages");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testServiceWithOnError() returns error? {
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: CLIENT_ACKNOWLEDGE,
        queueName: "test-svc-onerror"
    } service object {
        remote function onMessage(Message message) returns error? {}

        remote function onError(Error err) returns error? {}
    };
    check jmsMessageListener.attach(consumerSvc, "test-onerror-service");
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testServiceReturningError() returns error? {
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: CLIENT_ACKNOWLEDGE,
        queueName: "test-onMessage-error"
    } service object {
        remote function onMessage(Message message) returns error? {
            return error("Error occurred while processing the message");
        }
    };
    check jmsMessageListener.attach(consumerSvc, "test-onMessage-error-service");

    MessageProducer producer = check createProducer(AUTO_ACK_SESSION, {'type: QUEUE, name: "test-onMessage-error"});
    TextMessage textMsg = {
        content: "This is a sample message"
    };
    check producer->send(textMsg);
    runtime:sleep(2);
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testListenerImmediateStop() returns error? {
    Listener msgListener = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: CLIENT_ACKNOWLEDGE,
        queueName: "test-listener-stop"
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
    };
    check msgListener.attach(consumerSvc, "test-caller-service");
    check msgListener.'start();
    runtime:sleep(2);
    check msgListener.immediateStop();
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testServiceAttachWithoutSvcPath() returns error? {
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: CLIENT_ACKNOWLEDGE,
        queueName: "test-svc-attach"
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
    };
    check jmsMessageListener.attach(consumerSvc);
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testServiceDetach() returns error? {
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: CLIENT_ACKNOWLEDGE,
        queueName: "test-svc-attach"
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
    };
    check jmsMessageListener.attach(consumerSvc, "consumer-svc");
    check jmsMessageListener.detach(consumerSvc);
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testDetachFailure() returns error? {
    Service consumerSvc = @ServiceConfig {
        sessionAckMode: CLIENT_ACKNOWLEDGE,
        queueName: "test-svc-attach"
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
    };
    Error? result = jmsMessageListener.detach(consumerSvc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to detach a service from the listener: Could not find the native JMS session",
                "Invalid error message");
    }
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testListenerInitWithInvalidInitialContextFactory() returns error? {
    Listener|Error jmsListener = new (
        initialContextFactory = "io.sample.SampleMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    test:assertTrue(jmsListener is Error, "Listener initialized with invalid initial context factory");
    if jmsListener is Error {
        test:assertEquals(jmsListener.message(),
                "Error occurred while connecting to broker: Cannot instantiate class: io.sample.SampleMQInitialContextFactory",
                "Invalid listener init error message");
    }
}

@test:Config {
    groups: ["messageListener"]
}
isolated function testListenerInitWithInvalidProviderUrl() returns error? {
    Listener|Error jmsListener = new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61615"
    );
    test:assertTrue(jmsListener is Error, "Listener initialized with invalid provider URL");
    if jmsListener is Error {
        test:assertEquals(jmsListener.message(),
                "Error occurred while connecting to broker: Could not connect to broker URL: tcp://localhost:61615. Reason: java.net.ConnectException: Connection refused",
                "Invalid listener init error message");
    }
}

@test:AfterGroups {
    value: ["messageListener"]
}
isolated function afterMessageListenerTests() returns error? {
    check queue3Producer->close();
    check topic3Producer->close();
    check jmsMessageListener.gracefulStop();
}
