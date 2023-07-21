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

import ballerina/jballerina.java;

# JMS Message Consumer client object to receive messages from both queues and topics.
public isolated client class MessageConsumer {
    private final handle jmsConsumer;

    # Initialize the Message Consumer client object.
    #
    # + jmsProducer - reference to java MessageConsumer object
    isolated function init(handle jmsMessageConsumer) {
        self.jmsConsumer = jmsMessageConsumer;
    }

    # Receives the next message that arrives within the specified timeout interval.
    #
    # + timeoutMillis - Message receive timeout
    # + return - `jms:JmsMessage` or `jsm:Error` if there is an error in the execution
    isolated remote function receive(int timeoutMillis = 0) returns JmsMessage|Error? {
        return externReceive(self.jmsConsumer, timeoutMillis);
    };

    # Receives the next message if one is immediately available.
    #
    # + return - `jms:JmsMessage` or `jsm:Error` if there is an error in the execution
    isolated remote function receiveNoWait() returns JmsMessage|Error? {
        return externReceiveNoWait(self.jmsConsumer);
    }

    # Mark a JMS message as received.
    #
    # + message - JMS message record
    # + return - `jms:Error` if there is an error in the execution or else nil
    isolated remote function acknowledge(JmsMessage message) returns Error? {
        return externConsumerAcknowledge(message);
    }

    # Closes the message consumer.
    # 
    # + return - `jms:Error` if there is an error or else nil
    isolated remote function close() returns Error? {
        error? result = externClose(self.jmsConsumer);
        if result is error {
            return error Error(result.message());
        }
    }

    isolated function getJmsConsumer() returns handle {
        return self.jmsConsumer;
    }
}

isolated function externReceive(handle jmsMessageConsumer, int timeout) returns JmsMessage|Error? = @java:Method {
    name: "receive",
    'class: "io.ballerina.stdlib.java.jms.ConsumerUtils"
} external;

isolated function externReceiveNoWait(handle jmsMessageConsumer) returns JmsMessage|Error? = @java:Method {
    name: "receiveNoWait",
    'class: "io.ballerina.stdlib.java.jms.ConsumerUtils"
} external;

isolated function externConsumerAcknowledge(JmsMessage message) returns Error? = @java:Method {
    name: "acknowledge",
    'class: "io.ballerina.stdlib.java.jms.ConsumerUtils"
} external;

isolated function externClose(handle jmsConsumer) returns error? = @java:Method {
    name: "close",
    'class: "javax.jms.MessageConsumer"
} external;
