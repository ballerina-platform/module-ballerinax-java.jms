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

final Session testSession = check createSession("AUTO_ACKNOWLEDGE");

@test:Config {
    groups: ["session"]
}
isolated function testCreateQueue() returns error? {
    Destination queue = check testSession->createQueue("test-session-queue");
    test:assertTrue(queue is Queue);
}

@test:Config {
    groups: ["session"]
}
isolated function testCreateTopic() returns error? {
    Destination topic = check testSession->createTopic("test-session-topic");
    test:assertTrue(topic is Topic);
}
