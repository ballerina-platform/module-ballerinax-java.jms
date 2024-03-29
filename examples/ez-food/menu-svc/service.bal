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
import ballerina/http;
import ballerina/log;

type MenuItem record {|
    int id;
    string name;
    decimal price;
    string description;
    int preparationTimeMinutes;
|};

configurable MenuItem[] menu = ?;

# A service representing a menu for an online food ordering system
service /menu on new http:Listener(9090) {

    function init() {
        log:printInfo("Started Menu Serivce");
    }

    resource function get .() returns MenuItem[] {
        return menu;
    }

    resource function get [int id]() returns MenuItem|http:NotFound|http:InternalServerError {
        MenuItem[] items = from MenuItem item in menu
            where item.id == id
            select item;
        if items.length() == 1 {
            return items[0];
        }
        if items.length() == 0 {
            return <http:NotFound>{
                body: {
                    message: string `MenuItem for id: ${id} not found`
                }
            };
        }
        return <http:InternalServerError>{
            body: {
                message: string `Received an invalid result when quering for MenuItem for id: ${id}`
            }
        };
    }
}
