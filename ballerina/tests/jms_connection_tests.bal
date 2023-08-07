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
    test:assertTrue(connection is Error, "Success results retured for an errorneous scenario");
}

@test:Config {
    groups: ["connection"]
}
isolated function testCreateConnectionInvalidProviderUrl() returns error? {
    Connection|Error connection = new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61615"
    );
    test:assertTrue(connection is Error, "Success results retured for an errorneous scenario");
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
isolated function testCreateSession() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    Session session = check connection->createSession();
    check session->close();
    check connection->close();
}