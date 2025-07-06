// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
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

import ballerinax/java.jms;

const string ORDERS_QUEUE = "orders";
const string ORDER_CONFIRMATIONS_QUEUE = "order-confirmation";
const string ORDER_STATUS_UPDATE_TOPIC = "order-status-update";

configurable jms:ConnectionConfiguration activeMqConnectionConfig = {
    initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
    providerUrl: "tcp://localhost:61616"
};

listener jms:Listener activeMqListener = check new (activeMqConnectionConfig);
