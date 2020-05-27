// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/java;

# Represent the JMS destination
public type Destination abstract object {

    handle jmsDestination;

    function getJmsDestination() returns handle;

};

function getDestination(handle jmsDestination) returns Destination | error {
    handle jmsDestinationType = getDestinationType(jmsDestination);
    string? destinationType = java:toString(jmsDestinationType);
    match destinationType {
        "queue" => {
            return new Queue(jmsDestination);
        }
        "topic" => {
            return new Topic(jmsDestination);
        }
        "temporaryQueue" => {
            return new TemporaryQueue(jmsDestination);
        }
        "temporaryTopic" => {
            return new TemporaryTopic(jmsDestination);
        }
    }
    JmsError err = error("Invalid destination type");
    return err;
}

function getDestinationType(handle destination) returns handle = @java:Method {
    class: "org.ballerinalang.java.jms.JmsDestinationUtils"
} external;
