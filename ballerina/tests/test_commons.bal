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

final Connection TEST_CONNECTION = check new (
    initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    providerUrl = "tcp://localhost:61616"
);

final Session AUTO_ACK_SESSION = check createSession("AUTO_ACKNOWLEDGE");

isolated function createSession(AcknowledgementMode acknowledgementMode) returns Session|error {
    return TEST_CONNECTION->createSession(acknowledgementMode);
}

isolated function createProducer(Session session, Destination destination) returns MessageProducer|error {
    return session.createProducer(destination);
}

isolated function createProducerWithoutDestination(Session session) returns MessageProducer|error {
    return session.createProducer();
}

isolated function createConsumer(Session session, *ConsumerOptions options) returns MessageConsumer|error {
    return session.createConsumer(options);
}

@test:AfterSuite {
    alwaysRun: true
}
isolated function afterSuite() returns error? {
    check TEST_CONNECTION->close();
}
