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
import ballerina/observe;

observe:Gauge consumerGauge = new(ACTIVE_JMS_CONSUMERS);

public isolated client class MessageConsumer {
    private final handle jmsConsumer;

    function init(handle jmsMessageConsumer) {
        self.jmsConsumer = jmsMessageConsumer;
        registerAndIncrementGauge(consumerGauge);
    }

    remote isolated function receive(int timeoutMillis = 0) returns Message|()|error {
        var response = receiveJmsMessage(self.jmsConsumer, timeoutMillis);
        // registerAndIncrementCounter(new observe:Counter(TOTAL_JMS_MESSAGES_RECEIVED));
        if (response is handle) {
            if (java:isNull(response)) {
                return ();
            } else {
                return getBallerinaMessage(response);
            }
        } else {
            return response;
        }
    }

    remote isolated function receiveNoWait() returns Message|()|error {
        handle|error response = receiveNoWaitJmsMessage(self.jmsConsumer);
        if (response is handle) {
            if (java:isNull(response)) {
                return ();
            } else {
                return getBallerinaMessage(response);
            }
        } else {
            return response;
        }
    }

    remote isolated function close() returns JmsError? {
        // decrementGauge(consumerGauge);
        error? result = closeJmsConsumer(self.jmsConsumer);
        if result is error {
            return error JmsError(result.message());
        }
    }

    isolated function getJmsConsumer() returns handle {
        return self.jmsConsumer;
    }
}

isolated function getBallerinaMessage(handle jmsMessage) returns Message|error {
    if isTextMessage(jmsMessage) {
        return new TextMessage(jmsMessage);
    } else if isMapMessage(jmsMessage) {
        return new MapMessage(jmsMessage);
    } else if isBytesMessage(jmsMessage) {
        return new BytesMessage(jmsMessage);
    } else if isStreamMessage(jmsMessage) {
        return new StreamMessage(jmsMessage);
    } else {
        return new Message(jmsMessage);
    }
}

isolated function receiveJmsMessage(handle jmsMessageConsumer, int timeout) returns handle|error = @java:Method {
    name: "receive",
    paramTypes: ["long"],
    'class: "javax.jms.MessageConsumer"
} external;

isolated function receiveNoWaitJmsMessage(handle jmsMessageConsumer) returns handle|error = @java:Method {
    name: "receiveNoWait",
    'class: "javax.jms.MessageConsumer"
} external;

isolated function isTextMessage(handle jmsMessage) returns boolean = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.JmsMessageUtils"
} external;

isolated function isMapMessage(handle jmsMessage) returns boolean = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.JmsMessageUtils"
} external;

isolated function isBytesMessage(handle jmsMessage) returns boolean = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.JmsMessageUtils"
} external;

isolated function isStreamMessage(handle jmsMessage) returns boolean = @java:Method {
    'class: "io.ballerina.stdlib.java.jms.JmsMessageUtils"
} external;

isolated function closeJmsConsumer(handle jmsConsumer) returns error? = @java:Method {
    name: "close",
    'class: "javax.jms.MessageConsumer"
} external;
