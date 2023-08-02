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

# Represents the JMS session.
public isolated client class Session {

    isolated function init(Connection connection, AcknowledgementMode ackMode) returns error? {
        return self.externInit(connection, ackMode);
    }

    isolated function externInit(Connection connection, AcknowledgementMode ackMode) returns Error? = @java:Method {
        name: "init",
        'class: "io.ballerina.stdlib.java.jms.JmsSession"
    } external;

    # Unsubscribe a durable subscription that has been created by a client.
    # It is erroneous for a client to delete a durable subscription while there is an active (not closed) consumer
    # for the subscription, or while a consumed message being part of a pending transaction or has not been
    # acknowledged in the session.
    #
    # + subscriptionId - The name, which is used to identify the subscription.
    # + return - Cancels the subscription.
    isolated remote function unsubscribe(string subscriptionId) returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.JmsSession"
    } external;

    # Creates a MessageProducer to send messages to the specified destination.
    #
    # + destination - The Destination to send to, or nil if this is a producer which does not have a specified destination
    # + return - Returns jms:MessageProducer
    public isolated function createProducer(Destination? destination = ()) returns MessageProducer|Error {
        return new MessageProducer(self, destination);
    }

    # Creates a MessageConsumer for the specified destination.
    #
    # + consumerOptions - The relevant consumer configurations
    # + return - Returns a jms:MessageConsumer
    public isolated function createConsumer(*ConsumerOptions consumerOptions) returns MessageConsumer|Error {
        return new MessageConsumer(self, consumerOptions);
    }

    isolated function createJmsMessage(string messageType) returns handle|Error = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.JmsSession"
    } external;
}

# Defines the JMS session acknowledgement modes.
public enum AcknowledgementMode {
    # Indicates that the session will use a local transaction which may subsequently 
    # be committed or rolled back by calling the session's `commit` or `rollback` methods. 
    SESSION_TRANSACTED = "SESSION_TRANSACTED",
    # Indicates that the session automatically acknowledges a client's receipt of a message 
    # either when the session has successfully returned from a call to `receive` or when 
    # the message listener the session has called to process the message successfully returns.
    AUTO_ACKNOWLEDGE = "AUTO_ACKNOWLEDGE",
    # Indicates that the client acknowledges a consumed message by calling the 
    # MessageConsumer's or Caller's `acknowledge` method. Acknowledging a consumed message 
    # acknowledges all messages that the session has consumed.
    CLIENT_ACKNOWLEDGE = "CLIENT_ACKNOWLEDGE",
    # Indicates that the session to lazily acknowledge the delivery of messages. 
    # This is likely to result in the delivery of some duplicate messages if the JMS provider fails, 
    # so it should only be used by consumers that can tolerate duplicate messages. 
    # Use of this mode can reduce session overhead by minimizing the work the session does to prevent duplicates.
    DUPS_OK_ACKNOWLEDGE = "DUPS_OK_ACKNOWLEDGE"
}
