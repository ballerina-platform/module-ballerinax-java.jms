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
import ordersvc.store;

import ballerina/http;
import ballerina/time;

// Types related to HTTP service
type NewOrder record {|
    record {|
        int itemId;
        int quantity;
    |}[] items;
    string specialInstructions;
|};

type PaymentDetails record {|
    string cardNumber;
    string expiryDate;
    string cvv;
|};

type OrderCreated record {|
    *http:Created;
    map<string> headers;
    record {|
        int id;
        string status;
    |} body;
|};

type OrderNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

type PaymentNotAccepted record {|
    *http:NotAcceptable;
    ErrorDetails body;
|};

type ErrorDetails record {|
    time:Utc timeStamp = time:utcNow();
    string message;
    string path;
|};

// Types related to JMS integration
type OrderProcessingRequest record {|
    int orderId;
    NewOrder details;
|};

type OrderStatusUpdate record {|
    int orderId;
    store:OrderStatus status;
|};

type ProducerPayload OrderProcessingRequest|OrderStatusUpdate;

type OrderConfirmation record {|
    int orderId;
    decimal subTotal;
    int estimatedDuration;
|};
