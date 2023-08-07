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

final Connection connection = check new (
    initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    providerUrl = "tcp://localhost:61616"
);

final Session autoAckSession = check createSession("AUTO_ACKNOWLEDGE");

isolated function createSession(AcknowledgementMode acknowledgementMode) returns Session|error {
    return connection->createSession(acknowledgementMode);
}

isolated function createQueueProducer(Session session, string queueName) returns MessageProducer|error {
    return session.createProducer({
        'type: QUEUE,
        name: queueName
    });
}

isolated function createProducerWithoutDefaultDestination(Session session) returns MessageProducer|error {
    return session.createProducer();
}

@test:AfterSuite {
    alwaysRun: true
}
isolated function afterSuite() returns error? {
    check connection->stop();
}