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
import ballerina/log;

# The JMS service type.
public type Service distinct service object {
    // remote function onMessage(jms:Message message) returns error?;
};

# Defines the supported JMS destinations.
public enum JmsDestinationType {
    # Represents JMS Queue
    QUEUE = "QUEUE", 
    # Represents JMS Temporary Queue
    TEMPORARY_QUEUE = "TEMPORARY_QUEUE", 
    # Represents JMS Topic
    TOPIC = "TOPIC", 
    # Represents JMS Temporary Topic
    TEMPORARY_TOPIC = "TEMPORARY_TOPIC"
}

# Message consumer configurations.
#
# + connectionConfig - Configurations related to the broker connection  
# + sessionConfig - Configurations related to the JMS session
# + destination - Name of the JMS destination
# + messageSelector - only messages with properties matching the message selector expression are added to the durable subscription. 
#                     An empty string indicates that there is no message selector for the durable subscription.
# + noLocal - if true then any messages published to the topic using this session's connection, or any other connection 
#             with the same client identifier, will not be added to the durable subscription.
public type ConsumerConfiguration record {|
    ConnectionConfiguration connectionConfig;
    SessionConfiguration sessionConfig;
    record {|
        JmsDestinationType 'type;
        string name?;
    |} destination;
    string messageSelector = "";
    boolean noLocal = false;
|};

# Represents a JMS consumer listener.
public isolated class Listener {
    private final MessageConsumer consumer;

    # Creates a new `jms:Listener`.
    #
    # + consumer - The relevant JMS consumer.
    public isolated function init(*ConsumerConfiguration consumerConfig) returns error? {
        Connection connection = check new (consumerConfig.connectionConfig);
        Session session = check connection->createSession(consumerConfig.sessionConfig);
        Destination destination = check createJmsDestination(
            session, consumerConfig.destination.'type, consumerConfig.destination?.name);
        self.consumer = check session->createConsumer(
            destination, consumerConfig.messageSelector, consumerConfig.noLocal);
    }

    # Attaches a message consumer service to a listener.
    # ```ballerina
    # error? result = listener.attach(jmsService);
    # ```
    # 
    # + 'service - The service instance.
    # + name - Name of the service.
    # + return - Returns nil or an error upon failure to register the listener.
    public isolated function attach(Service 'service, string[]|string? name = ()) returns Error? {
        return setMessageListener(self.consumer.getJmsConsumer(), 'service);
    }

    # Detaches a message consumer service from the the listener.
    # ```ballerina
    # error? result = listener.detach(jmsService);
    # ```
    #
    # + 'service - The service to be detached
    # + return - A `kafka:Error` if an error is encountered while detaching a service or else `()`
    public isolated function detach(Service 'service) returns Error? {}

    # Starts the endpoint.
    #
    # + return - Returns nil or an error upon failure to start.
    public isolated function 'start() returns Error? {}


    # Stops the JMS listener gracefully.
    # ```ballerina
    # error? result = listener.gracefulStop();
    # ```
    #
    # + return - A `jms:JmsError` if an error is encountered during the listener-stopping process or else `()`
    public isolated function gracefulStop() returns Error? {
        return self.consumer->close();
    }

    # Stops the JMS listener immediately.
    # ```ballerina
    # error? result = listener.immediateStop();
    # ```
    #
    # + return - A `jms:JmsError` if an error is encountered during the listener-stopping process or else `()`
    public isolated function immediateStop() returns Error? {
        return self.consumer->close();
    }
}

isolated function createJmsDestination(Session session, JmsDestinationType 'type, string? name) returns Destination|error {
    if 'type is TEMPORARY_QUEUE || 'type is TEMPORARY_TOPIC {
        if name is string {
            log:printWarn("Temporary JSM destinations does not support naming");
        }
    }
    if 'type is QUEUE || 'type is TOPIC {
        if name is () {
            return error ("JMS destination name can not be empty");
        }
    } 
    match 'type {
        QUEUE => {
            return session->createQueue(<string> name);
        }
        TEMPORARY_QUEUE => {
            return session->createTemporaryQueue();
        }
        TOPIC => {
            return session->createTopic(<string> name);
        }
        TEMPORARY_TOPIC => {
            return session->createTemporaryTopic();
        }
        _ => {
            return error (string `Unidentified JSM destination type: ${'type}`);
        }
    }
}

isolated function setMessageListener(handle jmsConsumer, Service 'service) returns Error? = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.JmsMessageListenerUtils"
} external;
