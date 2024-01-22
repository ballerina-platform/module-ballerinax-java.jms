// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/persist as _;
import ballerina/time;

public type FoodOrder record {|
    readonly int id;
    OrderStatus status;
    Item[] items;
    int estimatedDuration;
    time:Utc? processingStartedTime;
|};

public type Item record {|
    readonly int id;
    FoodOrder 'order;
    string name;
    int quantity;
    decimal unitPrice;
    int prepTimePerUnit;
|};

public enum OrderStatus {
    PENDING,
    PAYMENT_PENDING,
    ACCEPTED,
    PROCESSING,
    COMPLETED,
    CANCELED
}
