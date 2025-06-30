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

import ballerina/jballerina.java;

// todo: implement this method properly

# Represents a JMS Listener endpoint that can be used to receive messages from an JMS topic or a queue.
public isolated class Listener2 {

    # Initializes a new `jms:Listener`.
    # ```ballerina
    # listener jms:Listener messageListener = check new(
    #   initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    #   providerUrl = "tcp://localhost:61616"
    # );
    # ```
    # 
    # + connectionConfig - The configurations to be used when initializing the JMS listener
    # + return - The relevant JMS consumer or a `jms:Error` if there is any error
    public isolated function init(*ConnectionConfiguration connectionConfig) returns Error? {
        return self.initListener(connectionConfig);
    }

    isolated function initListener(ConnectionConfiguration configurations) returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Listener",
        name: "init"
    } external;

    # Attaches a JMS service to the JMS listener.
    # ```ballerina
    # check messageListener.attach(jmsService);
    # ```
    # 
    # + 'service - The service instance
    # + name - Name of the service
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function attach(Service s, string[]|string? name = ()) returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Listener"
    } external;

    # Detaches a JMS service from the JMS listener.
    # ```ballerina
    # check messageListener.detach(jmsService);
    # ```
    #
    # + 'service - The service to be detached
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function detach(Service s) returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Listener"
    } external;

    # Starts the endpoint.
    # ```ballerina
    # check messageListener.'start();
    # ```
    #
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function 'start() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Listener"
    } external;


    # Stops the JMS listener gracefully.
    # ```ballerina
    # check messageListener.gracefulStop();
    # ```
    #
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function gracefulStop() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Listener"
    } external;

    # Stops the JMS listener immediately.
    # ```ballerina
    # check messageListener.immediateStop();
    # ```
    #
    # + return - A `jms:Error` if there is an error or else `()`
    public isolated function immediateStop() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Listener"
    } external;
}
