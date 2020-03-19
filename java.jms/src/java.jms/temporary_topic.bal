// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/observe;

observe:Gauge temporaryTopicGauge = new(ACTIVE_JMS_TEMPORARY_TOPICS);

# Represent the JMS temporary topic
public type TemporaryTopic object {

    // Add a reference to the `Destination` object type.
    *Destination;

    # Initialized a `TemporaryTopic` object.
    #
    # + handle - The java reference to the jms text message.
    function __init(handle temporaryTopic) {
        registerAndIncrementGauge(temporaryTopicGauge);
        self.jmsDestination = temporaryTopic;
    }

    # Get the JMS temporary topic
    #
    # + return - Returns the java reference to the jms temporary topic
    function getJmsDestination() returns handle {
        return self.jmsDestination;
    }

    # Gets the name of this temporary topic.
    #
    # + return - Returns the string value or an error if it fails.
    public function getTopicName() returns string | error? {
        handle|error val = getTopicName(self.jmsDestination);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Deletes this temporary topic.
    #
    # + return - Returns an error if it fails.
    public function delete() returns error? {
        decrementGauge(temporaryTopicGauge);
        return deleteTemporaryTopic(self.jmsDestination);
    }

};

function deleteTemporaryTopic(handle destination) returns error? = @java:Method {
    name: "delete",
    class: "javax.jms.TemporaryTopic"
} external;