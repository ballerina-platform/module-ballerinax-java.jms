// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/log;
import ballerinax/java;


# JMS QueueSender Endpoint
#
# + session - Session of the queue sender
public type MessageProducer client object {

    public Session session;
    private handle jmsProducer = java:createNull();
    private handle JAVA_NULL = java:createNull();

    # Initialize the QueueSender endpoint
    #
    # + c - The JMS Session object or Configurations related to the receiver
    # + queueName - Name of the target queue
    public function __init(Session|SenderEndpointConfiguration c, Destination? queue = ()) {
        if (c is Session) {
            self.session = c;
        } else {
            Connection conn = new({
                    initialContextFactory: c.initialContextFactory,
                    providerUrl: c.providerUrl,
                    connectionFactoryName: c.connectionFactoryName,
                    properties: c.properties
                });
            self.session = new Session(conn, {
                    acknowledgementMode: c.acknowledgementMode
                });
        }
        if (queue is Destination) {
            self.initMessageProducer(self.session, queue.getJmsDestination());
        } else {
            self.initMessageProducer(self.session, self.JAVA_NULL);
        }
    }

    function initMessageProducer(Session session, handle jmsDestination) {
        handle|error val = createJmsProducer(session.getJmsSession(), jmsDestination);
        if (val is handle) {
            self.jmsProducer = val;
        } else {
            log:printError("Error occurred while creating producer");
        }
    }

    # Sends a message to the JMS provider
    #
    # + message - Message to be sent to the JMS provider
    # + return - Error if unable to send the message to the queue
    public remote function send(TextMessage message) returns error? {
        return send(self.jmsProducer, message.getJmsMessage());
    }

    # Sends a message to a given destination of the JMS provider
    #
    # + destination - Destination used for the message sender
    # + message - Message to be sent to the JMS provider
    # + return - Error if sending to the given destination fails
    public remote function sendTo(Destination destination, TextMessage message) returns error? {
        return sendToDestination(self.jmsProducer, destination.getJmsDestination(), message.getJmsMessage());
    }
};

public function createJmsProducer(handle session, handle destination) returns handle|error = @java:Method {
    name: "createProducer",
    class: "javax.jms.Session"
} external;

public function send(handle messageProducer, handle message) returns error? = @java:Method {
    name: "send",
    paramTypes: ["javax.jms.Message"],
    class: "javax.jms.MessageProducer"
} external;

public function sendToDestination(handle messageProducer, handle destination, handle message) returns error? = @java:Method {
    name: "send",
    paramTypes: ["javax.jms.Destination", "javax.jms.Message"],
    class: "javax.jms.MessageProducer"
} external;
