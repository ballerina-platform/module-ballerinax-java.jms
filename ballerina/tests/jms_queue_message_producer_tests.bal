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

import ballerina/test;
import ballerina/io;

final Connection connection = check new (
    initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    providerUrl = "tcp://localhost:61616"
);

isolated function createProducer() returns MessageProducer|error {
    Session session = check connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
    Destination queue = check session->createQueue("MyQueue");
    return session.createProducer(queue);
}

@test:Config {}
isolated function testCase() returns error? {
    io:println("Log");
}