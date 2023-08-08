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

import ballerina/lang.runtime;
import ballerina/test;

@test:Config {
    groups: ["connection"]
}
isolated function testCreateConnectionSuccess() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    check connection->close();
}

@test:Config {
    groups: ["connection"]
}
isolated function testCreateConnectionInvalidInitialContextFactory() returns error? {
    Connection|Error connection = new (
        initialContextFactory = "io.sample.SampleMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    test:assertTrue(connection is Error, 
        "Connection created with invalid initial context factory");
    if connection is Error {
        test:assertEquals(connection.message(), 
            "Error occurred while connecting to broker: Cannot instantiate class: io.sample.SampleMQInitialContextFactory", 
            "Invalid connection init error message");
    }
}

@test:Config {
    groups: ["connection"]
}
isolated function testCreateConnectionInvalidProviderUrl() returns error? {
    Connection|Error connection = new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61615"
    );
    test:assertTrue(connection is Error, 
        "Connection created with invalid provider URL");
    if connection is Error {
        test:assertEquals(connection.message(), 
            "Error occurred while connecting to broker: Could not connect to broker URL: tcp://localhost:61615. Reason: java.net.ConnectException: Connection refused (Connection refused)", 
            "Invalid connection init error message");
    }
}

@test:Config {
    groups: ["connection"]
}
isolated function testConnectionRestart() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    check connection->stop();
    runtime:sleep(2);
    check connection->'start();
    runtime:sleep(2);
    check connection->close();
}

@test:Config {
    groups: ["connection"]
}
isolated function testConnectionRestartAfterClosing() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    check connection->close();
    runtime:sleep(2);
    Error? result = connection->'start();
    test:assertTrue(result is Error, 
        "Connection restarted successfully after closing"); 
    if result is Error {
        test:assertEquals(result.message(), 
            "Error occurred while starting the connection: The connection is already closed",
            "Invalid connection restart error message");
    }   
}

@test:Config {
    groups: ["connection"]
}
isolated function testConnectionStopAfterClosing() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    check connection->close();
    runtime:sleep(2);
    Error? result = connection->stop();
    test:assertTrue(result is Error, 
        "Connection stopped successfully after closing"); 
    if result is Error {
        test:assertEquals(result.message(), 
            "Error occurred while stopping the connection: The connection is already closed",
            "Invalid connection restart error message");
    }   
}

@test:Config {
    groups: ["connection"]
}
isolated function testCreateSession() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    Session session = check connection->createSession();
    check session->close();
    check connection->close();
}
