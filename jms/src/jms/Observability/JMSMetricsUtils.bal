// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/observe;
import ballerina/log;

# Register and increment counter
#
# + counter - counter to be registered and incremented
function registerAndIncrementCounter(observe:Counter counter) {
    error? result = counter.register();
    if (result is error) {
        log:printError("Error in registering counter : " + counter.name, err = result);
    }
    counter.increment();
}

# Register and increment guage
#
# + guage - guage to be registered and incremented
function registerAndIncrementGuage(observe:Gauge guage) {
    error? result = guage.register();
    if (result is error) {
        log:printError("Error in registering guage : " + guage.name, err = result);
    }
    guage.increment();
}

# Decrement guage
#
# + guage - guage to be decremented
function decrementGuage(observe:Gauge guage) {
    guage.decrement();
}
