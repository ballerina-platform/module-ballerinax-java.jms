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

# Defines the supported JMS message consumer types.
public enum ConsumerType {
    # Represents JMS durable subscriber
    DURABLE = "DURABLE", 
    # Represents JMS shared consumer
    SHARED = "SHARED", 
    # Represents JMS shared durable subscriber
    SHARED_DURABLE = "SHARED_DURABLE", 
    # Represents JMS default consumer
    DEFAULT = "DEFAULT"
}

# Message consumer listener configurations.
#
# + type - Message consumer type
# + destination - Name of the JMS destination
# + messageSelector - only messages with properties matching the message selector expression are added to the durable subscription. 
#                     An empty string indicates that there is no message selector for the durable subscription.
# + noLocal - if true then any messages published to the topic using this session's connection, or any other connection 
#             with the same client identifier, will not be added to the durable subscription.
public type ConsumerOptions record {|
    ConsumerType 'type = DEFAULT;
    JmsDestination destination;
    string messageSelector = "";
    boolean noLocal = false;
|};

# JMS Message Consumer client object to receive messages from both queues and topics.
public isolated client class MessageConsumer {
    private final Session session;
    private final handle jmsConsumer = JAVA_NULL;

    isolated function init(Session session) {
        self.session = session;
    }

    # Receives the next message that arrives within the specified timeout interval.
    #
    # + timeoutMillis - Message receive timeout
    # + return - `jms:JmsMessage` or `jsm:Error` if there is an error in the execution
    isolated remote function receive(int timeoutMillis = 0) returns Message|Error? {
        return externReceive(self.jmsConsumer, timeoutMillis);
    };

    # Receives the next message if one is immediately available.
    #
    # + return - `jms:JmsMessage` or `jsm:Error` if there is an error in the execution
    isolated remote function receiveNoWait() returns Message|Error? {
        return externReceiveNoWait(self.jmsConsumer);
    }

    # Mark a JMS message as received.
    #
    # + message - JMS message record
    # + return - `jms:Error` if there is an error in the execution or else nil
    isolated remote function acknowledge(Message message) returns Error? {
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

isolated function externReceive(handle jmsMessageConsumer, int timeout) returns Message|Error? = @java:Method {
    name: "receive",
    'class: "io.ballerina.stdlib.java.jms.ConsumerUtils"
} external;

isolated function externReceiveNoWait(handle jmsMessageConsumer) returns Message|Error? = @java:Method {
    name: "receiveNoWait",
    'class: "io.ballerina.stdlib.java.jms.ConsumerUtils"
} external;

isolated function externConsumerAcknowledge(Message message) returns Error? = @java:Method {
    name: "acknowledge",
    'class: "io.ballerina.stdlib.java.jms.ConsumerUtils"
} external;

isolated function externClose(handle jmsConsumer) returns error? = @java:Method {
    name: "close",
    'class: "javax.jms.MessageConsumer"
} external;
