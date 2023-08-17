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

# The JMS service type.
public type Service distinct service object {
    // remote function onMessage(jms:Message message, jms:Caller caller) returns error?;
};

# Message listener configurations.
#
# + connectionConfig - Configurations related to the broker connection  
# + acknowledgementMode - Configuration indicating how messages received by the session will be acknowledged
# + consumerOptions - Underlying JMS message consumer configurations
public type MessageListenerConfigurations record {|
    ConnectionConfiguration connectionConfig;
    AcknowledgementMode acknowledgementMode = AUTO_ACKNOWLEDGE;
    ConsumerOptions consumerOptions;
|};

# Represents a JMS consumer listener.
public isolated class Listener {
    private final MessageConsumer consumer;

    # Creates a new `jms:Listener`.
    # ```ballerina
    # listener jms:Listener messageListener = check new(
    #   connectionConfig = {
    #       initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    #       providerUrl: "tcp://localhost:61616"
    #   },
    #   consumerOptions = {
    #       destination: {
    #           'type: jms:QUEUE,
    #           name: "test-queue"
    #       }
    #   }
    # );
    # ```
    # 
    # + listenerConfig - Message listener configurations
    # + return - The relevant JMS consumer or a `jms:Error` if there is any error
    public isolated function init(*MessageListenerConfigurations listenerConfig) returns Error? {
        Connection connection = check new (listenerConfig.connectionConfig);
        Session session = check connection->createSession(listenerConfig.acknowledgementMode);
        self.consumer = check new(session, listenerConfig.consumerOptions);
    }

    # Attaches a message consumer service to a listener.
    # ```ballerina
    # check messageListener.attach(jmsService);
    # ```
    # 
    # + 'service - The service instance
    # + name - Name of the service
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function attach(Service 'service, string[]|string? name = ()) returns Error? {
        return setMessageListener(self.consumer, 'service);
    }

    # Detaches a message consumer service from the the listener.
    # ```ballerina
    # check messageListener.detach(jmsService);
    # ```
    #
    # + 'service - The service to be detached
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function detach(Service 'service) returns Error? {}

    # Starts the endpoint.
    # ```ballerina
    # check messageListener.'start();
    # ```
    #
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function 'start() returns Error? {}


    # Stops the JMS listener gracefully.
    # ```ballerina
    # check messageListener.gracefulStop();
    # ```
    #
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function gracefulStop() returns Error? {
        return self.consumer->close();
    }

    # Stops the JMS listener immediately.
    # ```ballerina
    # check messageListener.immediateStop();
    # ```
    #
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function immediateStop() returns Error? {
        return self.consumer->close();
    }
}

isolated function setMessageListener(MessageConsumer consumer, Service 'service) returns Error? = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.listener.Utils"
} external;
