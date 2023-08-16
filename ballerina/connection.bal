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
import ballerina/crypto;

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
        name: "init",
        'class: "io.ballerina.stdlib.java.jms.JmsConnection"
    } external;

    # Create a Session object, specifying transacted and acknowledgeMode.
    #
    # + ackMode - Configuration indicating how messages received by the session will be acknowledged
    # + return - Returns the Session or an error if it fails.
    isolated remote function createSession(AcknowledgementMode ackMode = AUTO_ACKNOWLEDGE) returns Session|Error {
        return new Session(self, ackMode);
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

# Configurations related to a JMS connection.
#
# + initialContextFactory - JMS provider specific inital context factory
# + providerUrl - JMS provider specific provider URL used to configure a connection
# + connectionFactoryName - JMS connection factory to be used in creating JMS connections
# + username - Username for the JMS connection
# + password - Password for the JMS connection
# + properties - Additional properties use in initializing the initial context
# + secureSocket - Configurations related to SSL/TLS encryption
public type ConnectionConfiguration record {|
    string initialContextFactory = "wso2mbInitialContextFactory";
    string providerUrl = "amqp://admin:admin@ballerina/default?brokerlist='tcp://localhost:5672'";
    string connectionFactoryName = "ConnectionFactory";
    string username?;
    string password?;
    map<string> properties = {};
    SecureSocket secureSocket?;
|};

# Configurations for secure communication with the JMS provider.
#
# + cert - Configurations associated with crypto:TrustStore that the client trusts
# + key - Configurations associated with crypto:KeyStore of the client
# + protocol - SSL/TLS protocol related options
# + ciphers - List of ciphers to be used. By default, all the available cipher suites are supported
# + provider - Name of the security provider used for SSL connections. The default value is the default security provider
#              of the JVM
public type SecureSocket record {|
   crypto:TrustStore cert;
   record {|
        crypto:KeyStore keyStore;
        string keyPassword?;
  |} key?;
   record {|
        Protocol name;
        string[] versions?;
   |} protocol?;
   string[] ciphers?;
   string provider?;
|};

# Represents protocol options.
public enum Protocol {
   SSL,
   TLS
}
