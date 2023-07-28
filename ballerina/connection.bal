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

# Represents JMS Connection.
public isolated client class Connection {
    private final readonly & ConnectionConfiguration config;

    # Initialize and starts a JMS connection.
    #
    # + connectionConfig - The configurations to be used when initializing the JMS connection
    # + return - The `jms:Connection` or an `jms:Error` if the initialization failed
    public isolated function init(*ConnectionConfiguration connectionConfig) returns Error? {
        self.config = connectionConfig.cloneReadOnly();
        return self.externInit(connectionConfig);
    }

    isolated function externInit(ConnectionConfiguration connectionConfig) returns Error? = @java:Method {
        name: "createConnection",
        'class: "io.ballerina.stdlib.java.jms.JmsConnection"
    } external;

    # Create a Session object, specifying transacted and acknowledgeMode
    #
    # + sessionConfig - SessionConfiguration record consist with JMS session config
    # + return - Returns the Session or an error if it fails.
    isolated remote function createSession(SessionConfiguration sessionConfig) returns Session|error {
        return new Session(JAVA_NULL, sessionConfig);
    }

    # Starts (or restarts) a connection's delivery of incoming messages.
    # A call to start on a connection that has already been started is ignored.
    #
    # + return - A `jms:Error` if threre is an error while starting the connection
    isolated remote function 'start() returns Error? = @java:Method {
        name: "start",
        'class: "io.ballerina.stdlib.java.jms.JmsConnection"
    } external;

    # Temporarily stops a connection's delivery of incoming messages.
    # Delivery can be restarted using the connection's start method.
    #
    # + return - A `jms:Error` if threre is an error while stopping the connection
    isolated remote function stop() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.JmsConnection"
    } external;

    # Closes the connection.
    #
    # + return - A `jms:Error` if threre is an error while closing the connection
    isolated remote function close() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.JmsConnection"
    } external;
}

# Configurations related to a JMS connection
#
# + initialContextFactory - JMS provider specific inital context factory
# + providerUrl - JMS provider specific provider URL used to configure a connection
# + connectionFactoryName - JMS connection factory to be used in creating JMS connections
# + username - Username for the JMS connection
# + password - Password for the JMS connection
# + properties - Additional properties use in initializing the initial context
public type ConnectionConfiguration record {|
    string initialContextFactory = "wso2mbInitialContextFactory";
    string providerUrl = "amqp://admin:admin@ballerina/default?brokerlist='tcp://localhost:5672'";
    string connectionFactoryName = "ConnectionFactory";
    string username?;
    string password?;
    map<string> properties = {};
|};
