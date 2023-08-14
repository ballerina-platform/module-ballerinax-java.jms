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
    #
    # + consumer - The relevant JMS consumer.
    public isolated function init(*MessageListenerConfigurations consumerConfig) returns error? {
        Connection connection = check new (consumerConfig.connectionConfig);
        Session session = check connection->createSession(consumerConfig.acknowledgementMode);
        self.consumer = check new(session, consumerConfig.consumerOptions);
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
        return setMessageListener(self.consumer, 'service);
    }

    # Detaches a message consumer service from the the listener.
    # ```ballerina
    # error? result = listener.detach(jmsService);
    # ```
    #
    # + 'service - The service to be detached
    # + return - A `jms:Error` if an error is encountered while detaching a service or else `()`
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

isolated function setMessageListener(MessageConsumer consumer, Service 'service) returns Error? = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.listener.Utils"
} external;
