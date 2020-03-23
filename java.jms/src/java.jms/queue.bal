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

# Represent the JMS queue
public type Queue object {

    // Add a reference to the `Destination` object type.
    *Destination;

    # Initialized a `Queue` object.
    #
    # + handle - The java reference to the jms text message.
    function __init(handle queue) {
        self.jmsDestination = queue;
    }

    # Get the JMS queue
    #
    # + return - Returns the java reference to the jms queue
    function getJmsDestination() returns handle {
        return self.jmsDestination;
    }

    # Gets the name of this queue.
    #
    # + return - Returns the string value or an error if it fails.
    public function getQueueName() returns string | error? {
        handle|error val = getQueueName(self.jmsDestination);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

};

function getQueueName(handle destination) returns handle | error = @java:Method {
    class: "javax.jms.Queue"
} external;