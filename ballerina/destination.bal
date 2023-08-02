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

# Represent the JMS destination.
#
# + 'type - JMS destination types  
# + name - Name of the destination
public type JmsDestination readonly & record {|
    JmsDestinationType 'type;
    string name?;
|};

# Defines the supported JMS destination types.
public enum JmsDestinationType {
    # Represents JMS Queue
    QUEUE = "QUEUE", 
    # Represents JMS Temporary Queue
    TEMPORARY_QUEUE = "TEMPORARY_QUEUE", 
    # Represents JMS Topic
    TOPIC = "TOPIC", 
    # Represents JMS Temporary Topic
    TEMPORARY_TOPIC = "TEMPORARY_TOPIC"
}

# Represent the JMS destination
public type Destination distinct object {
    
    isolated function getJmsDestination() returns handle;
};
