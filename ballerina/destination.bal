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

# Represent the JMS destination
public type Destination distinct object {
    handle jmsDestination;

    function getJmsDestination() returns handle;

};

function getDestination(handle jmsDestination) returns Destination|error {
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
    return error Error("Invalid destination type");
}

function getDestinationType(handle destination) returns handle = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.JmsDestinationUtils"
} external;
