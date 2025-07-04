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

# Represents a JMS caller, which can be used to mark JMS message as received.
public isolated client class Caller {

    # Mark a JMS message as received.
    #
    # + message - JMS message record
    # + return - `jms:Error` if there is an error in the execution or else nil
    isolated remote function acknowledge(Message message) returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Caller"
    } external;

    # Commits all messages received in this transaction and releases any locks currently held.
    # ```ballerina
    # check session->'commit();
    # ```
    # 
    # + return - A `jms:Error` if there is an error or else `()`
    isolated remote function 'commit() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Caller"
    } external;

    # Rolls back any messages received in this transaction and releases any locks currently held.
    # ```ballerina
    # check session->'rollback();
    # ```
    # 
    # + return - A `jms:Error` if there is an error or else `()`
    isolated remote function 'rollback() returns Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jms.listener.Caller"
    } external;
}
