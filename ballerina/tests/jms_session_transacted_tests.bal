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

final Session transactedProducerSession = check createSession(SESSION_TRANSACTED);
final Session transactedConsumerSession = check createSession(SESSION_TRANSACTED);

final MessageProducer queue5Producer = check createProducer(transactedProducerSession, {
    'type: QUEUE,
    name: "test-queue-5"
});
final MessageConsumer queue5Consumer = check createConsumer(transactedConsumerSession, destination = {
    'type: QUEUE,
    name: "test-queue-5"
});

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionsCommitWithQueue() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check queue5Producer->send(msg1);
    check queue5Producer->send(msg2);
    check queue5Producer->send(msg3);
    check queue5Producer->send(msg4);
    check transactedProducerSession->'commit();

    int receivedMessages = 0;
    while true {
        Message? response = check queue5Consumer->receive(5000);
        if response is Message {
            receivedMessages += 1;
            if response.content == "End of messages" {
                check transactedConsumerSession->'commit();
                break;
            }
        }
    }
    test:assertEquals(receivedMessages, 4, "Invalid number of received messages");
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionsProducerRollbackWithQueue() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check queue5Producer->send(msg1);
    check queue5Producer->send(msg2);
    check queue5Producer->send(msg3);
    check queue5Producer->send(msg4);
    check transactedProducerSession->'rollback();
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionsConsumerRollbackWithQueue() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check queue5Producer->send(msg1);
    check queue5Producer->send(msg2);
    check queue5Producer->send(msg3);
    check queue5Producer->send(msg4);
    check transactedProducerSession->'commit();

    int receivedMessages = 0;
    while true {
        Message? response = check queue5Consumer->receive(5000);
        if response is Message {
            receivedMessages += 1;
            if response.content == "This is the third message" {
                check transactedConsumerSession->'rollback();
                break;
            }
        }
    }
    test:assertEquals(receivedMessages, 3, "Invalid number of received messages");
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testProducerRollbackConsumerCommitWithQueue() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check queue5Producer->send(msg1);
    check queue5Producer->send(msg2);
    check queue5Producer->send(msg3);
    check queue5Producer->send(msg4);
    check transactedProducerSession->'rollback();

    int receivedMessages = 0;
    while true {
        Message? response = check queue5Consumer->receive(5000);
        if response is Message {
            receivedMessages += 1;
            if response.content == "End of messages" {
                check transactedConsumerSession->'commit();
                break;
            }
        } else if response is () {
            check transactedConsumerSession->'commit();
            break;
        }
    }
    test:assertEquals(receivedMessages, 0, "Invalid number of received messages");
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testProducerCommitConsumerRollbackWithQueue() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check queue5Producer->send(msg1);
    check queue5Producer->send(msg2);
    check queue5Producer->send(msg3);
    check queue5Producer->send(msg4);
    check transactedProducerSession->'commit();

    int receivedMessages = 0;
    int numberOfAttempts = 0;
    while true {
        Message? response = check queue5Consumer->receive(5000);
        if response is Message {
            receivedMessages += 1;
            if response.content == "End of messages" {
                if numberOfAttempts == 0 {
                    check transactedConsumerSession->'rollback();
                    numberOfAttempts += 1;
                } else {
                    check transactedConsumerSession->'commit();
                break;

                }
            }
        }
    }
    test:assertEquals(receivedMessages, 8, "Invalid number of received messages");
}

final MessageProducer topic5Producer = check createProducer(transactedProducerSession, {
    'type: TOPIC,
    name: "test-topic-5"
});
final MessageConsumer topic5Consumer = check createConsumer(transactedConsumerSession, destination = {
    'type: TOPIC,
    name: "test-topic-5"
});

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionsCommitWithTopic() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check topic5Producer->send(msg1);
    check topic5Producer->send(msg2);
    check topic5Producer->send(msg3);
    check topic5Producer->send(msg4);
    check transactedProducerSession->'commit();

    int receivedMessages = 0;
    while true {
        Message? response = check topic5Consumer->receive(5000);
        if response is Message {
            receivedMessages += 1;
            if response.content == "End of messages" {
                check transactedConsumerSession->'commit();
                break;
            }
        }
    }
    test:assertEquals(receivedMessages, 4, "Invalid number of received messages");
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionsProducerRollbackWithTopic() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check topic5Producer->send(msg1);
    check topic5Producer->send(msg2);
    check topic5Producer->send(msg3);
    check topic5Producer->send(msg4);
    check transactedProducerSession->'rollback();
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionsConsumerRollbackWithTopic() returns error? {
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check topic5Producer->send(msg1);
    check topic5Producer->send(msg2);
    check topic5Producer->send(msg3);
    check topic5Producer->send(msg4);
    check transactedProducerSession->'commit();

    int receivedMessages = 0;
    while true {
        Message? response = check topic5Consumer->receive(5000);
        if response is Message {
            receivedMessages += 1;
            if response.content == "This is the third message" {
                check transactedConsumerSession->'rollback();
                break;
            }
        }
    }
    test:assertEquals(receivedMessages, 3, "Invalid number of received messages");
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionCommitWithoutTransactedSession() returns error? {
    Session producerSession = check createSession(AUTO_ACKNOWLEDGE);
    MessageProducer producer = check createProducer(producerSession, {
        'type: TOPIC,
        name: "test-transaction-topic"
    });
    Session consumerSession = check createSession(AUTO_ACKNOWLEDGE);
    MessageConsumer consumer = check createConsumer(consumerSession, destination = {
        'type: TOPIC,
        name: "test-transaction-topic"
    });
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check producer->send(msg1);
    check producer->send(msg2);
    check producer->send(msg3);
    check producer->send(msg4);
    Error? producerCommit = producerSession->'commit();
    test:assertTrue(producerCommit is Error, "Commit enabled for non-transacted session");
    if producerCommit is Error {
        test:assertEquals(producerCommit.message(), 
            "Error while committing the JMS transaction: Not a transacted session", 
            "Invalid error message for non-transacted session commit");
    }

    while true {
        Message? response = check consumer->receive(5000);
        if response is Message {
            if response.content == "End of messages" {
                Error? consumerCommit = consumerSession->'commit();
                test:assertTrue(consumerCommit is Error, "Commit enabled for non-transacted session");
                if consumerCommit is Error {
                    test:assertEquals(consumerCommit.message(), 
                        "Error while committing the JMS transaction: Not a transacted session",
                        "Invalid error message for non-transacted session commit");
                }
                break;
            }
        }
    }
    check producer->close();
    check producerSession->close();
    check consumer->close();
    check consumerSession->close();
}

@test:Config {
    groups: ["sessionTransacted"]
}
isolated function testTransactionRollbackWithoutTransactedSession() returns error? {
    Session producerSession = check createSession(AUTO_ACKNOWLEDGE);
    MessageProducer producer = check createProducer(producerSession, {
        'type: TOPIC,
        name: "test-transaction-topic"
    });
    Session consumerSession = check createSession(AUTO_ACKNOWLEDGE);
    MessageConsumer consumer = check createConsumer(consumerSession, destination = {
        'type: TOPIC,
        name: "test-transaction-topic"
    });
    Message msg1 = {
        content: "This is the first message"
    };
    Message msg2 = {
        content: "This is the second message"
    };
    Message msg3 = {
        content: "This is the third message"
    };
    Message msg4 = {
        content: "End of messages"
    };
    check producer->send(msg1);
    check producer->send(msg2);
    check producer->send(msg3);
    check producer->send(msg4);
    Error? producerRollback = producerSession->'rollback();
    test:assertTrue(producerRollback is Error, "Rollback enabled for non-transacted session");
    if producerRollback is Error {
        test:assertEquals(producerRollback.message(), 
            "Error while rolling back the JMS transaction: Not a transacted session", 
            "Invalid error message for non-transacted session rollback");
    }

    while true {
        Message? response = check consumer->receive(5000);
        if response is Message {
            if response.content == "End of messages" {
                Error? consumerRollback = consumerSession->'rollback();
                test:assertTrue(consumerRollback is Error, "Commit enabled for non-transacted session");
                if consumerRollback is Error {
                    test:assertEquals(consumerRollback.message(), 
                        "Error while rolling back the JMS transaction: Not a transacted session",
                        "Invalid error message for non-transacted session rollback");
                }
                break;
            }
        }
    }
    check producer->close();
    check producerSession->close();
    check consumer->close();
    check consumerSession->close();
}

@test:AfterGroups {
    value: ["sessionTransacted"]
}
isolated function afterSessionTransactedTests() returns error? {
    check queue5Producer->close();
    check queue5Consumer->close();
    check topic5Producer->close();
    check topic5Consumer->close();
    check transactedProducerSession->close();
    check transactedConsumerSession->close();
}
