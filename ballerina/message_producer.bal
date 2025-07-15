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

# JMS Message Producer client object to send messages to both queues and topics.
public isolated client class MessageProducer {
    
    isolated function init(Session session, Destination? destination = ()) returns Error? {
        return self.externInit(session, destination);
    }

    isolated function externInit(Session session, Destination? destination) returns Error? = @java:Method {
        name: "init",
        'class: "io.ballerina.stdlib.java.jms.producer.Actions"
    } external;

    # Sends a message to the JMS provider.
    # ```ballerina
    # check producer->send(message);
    # ```
    #
    # + message - Message to be sent to the JMS provider
    # + return - A `jms:Error` if there is an error or else `()`
    isolated remote function send(Message message) returns Error? = @java:Method {
        name: "send",
        'class: "io.ballerina.stdlib.java.jms.producer.Actions"
    } external;

    # Sends a message to a given destination of the JMS provider.
    # ```ballerina
    # check producer->sendTo({ 'type: QUEUE, name: "test-queue" }, message);
    # ```
    #
    # + destination - Destination used for the message sender
    # + message - Message to be sent to the JMS provider
    # + return - A `jms:Error` if there is an error or else `()`
    isolated remote function sendTo(Destination destination, Message message) returns Error? = @java:Method {
        name: "sendTo",
        'class: "io.ballerina.stdlib.java.jms.producer.Actions"
    } external;

    # Closes the message producer.
    # ```ballerina
    # check producer->close();
    # ```
    # + return - A `jms:Error` if there is an error or else `()`
    isolated remote function close() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.producer.Actions"
    } external;
};
