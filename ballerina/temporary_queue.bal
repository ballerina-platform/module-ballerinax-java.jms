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

# Represent the JMS temporary queue.
public isolated class TemporaryQueue {
    *Destination;
    
    private final handle jmsDestination;
    
    # Initialized a `TemporaryQueue` object.
    #
    # + handle - The java reference to the jms text message.
    isolated function init(handle temporaryQueue) {
        self.jmsDestination = temporaryQueue;
    }

    # Get the JMS temporary queue
    #
    # + return - Returns the java reference to the jms temporary queue
    isolated function getJmsDestination() returns handle {
        return self.jmsDestination;
    }

    # Gets the name of this temporary queue.
    #
    # + return - Returns the string value or an error if it fails.
    public isolated function getQueueName() returns string | error? {
        handle|error val = getQueueName(self.jmsDestination);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Deletes this temporary queue.
    #
    # + return - Returns an error if it fails.
    public isolated function delete() returns error? {
        return deleteTemporaryQueue(self.jmsDestination);
    }
}

isolated function deleteTemporaryQueue(handle destination) returns error? = @java:Method {
    name: "delete",
    'class: "javax.jms.TemporaryQueue"
} external;
