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
    connection->stop();
}

@test:Config {
    groups: ["connection"]
}
isolated function testCreateConnectionInvalidInitialContextFactory() returns error? {
    Connection|error connection = new (
        initialContextFactory = "io.sample.SampleMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    test:assertTrue(connection is error, "Success results retured for an errorneous scenario");
}

@test:Config {
    groups: ["connection"]
}
isolated function testCreateConnectionInvalidProviderUrl() returns error? {
    Connection|error connection = new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61615"
    );
    test:assertTrue(connection is error, "Success results retured for an errorneous scenario");
}

@test:Config {
    groups: ["connection"]
}
isolated function testConnectionRestart() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    connection->stop();
    runtime:sleep(2);
    connection->'start();
    runtime:sleep(2);
    connection->stop();
}

@test:Config {
    groups: ["connection"]
}
isolated function testCreateSession() returns error? {
    Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    Session|error session = trap connection->createSession({});
    test:assertTrue(session is Session, "Failure results retured for an successful scenario");
    runtime:sleep(2);
    connection->stop();
}
