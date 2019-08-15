// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/log;
import ballerinax/java;

public type MessageConsumer client object {

    private handle jmsConsumer = java:createNull();

    private MessageListener? messageListener = ();

    function __init(handle jmsMessageConsumer) {
        self.jmsConsumer = jmsMessageConsumer;
    }

    public remote function receive(int timeoutMillis = 0) returns Message|TextMessage|error {
        var response = receiveJmsMessage(self.jmsConsumer, timeoutMillis);
        if (response is handle) {
            return self.getBallerinaMessage(response);
        } else {
            return response;
        }
    }

    public remote function receiveNoWait() returns Message|TextMessage|()|error {
        handle|error response = receiveNoWaitJmsMessage(self.jmsConsumer);
        if (response is handle) {
            if (java:isNull(response)) {
                return ();
            } else {
                return self.getBallerinaMessage(response);
            }
        } else {
            return response;
        }
    }

    public remote function close() returns error? {
        return closeJmsConsumer(self.jmsConsumer);
    }

    private function getBallerinaMessage(handle jmsMessage) returns Message|TextMessage|error {
        
        if (isTextMessage(jmsMessage)) {
            return new TextMessage(jmsMessage);
        } else {
            return new Message(jmsMessage);
        }
    }

    public function setMessageListener(MessageListener messageListener) returns error? {
        self.messageListener = messageListener;
        return setJmsMessageListener(self.jmsConsumer, self);
    }

    private function onMessage(handle message) returns () {
        var listenerInstance = self.messageListener;
        if (listenerInstance is MessageListener) {
            var msg = self.getBallerinaMessage(message);
            if (msg is error) {
                log:printDebug("Unknown message type");
            } else {
                listenerInstance.onMessage(msg);
            }
        } else {
            log:printDebug("Message listener not set");
        }
    }
};

function receiveJmsMessage(handle jmsMessageConsumer, int timeout) returns handle|error = @java:Method {
    name: "receive",
    paramTypes: ["int"],
    class: "javax.jms.MessageConsumer"
} external;

function receiveNoWaitJmsMessage(handle jmsMessageConsumer) returns handle|error = @java:Method {
    name: "receiveNoWait",
    class: "javax.jms.MessageConsumer"
} external;

function isTextMessage(handle jmsMessage) returns boolean = @java:Method {
    class: "org.wso2.ei.module.jms.JmsMessageUtils"
} external;

function closeJmsConsumer(handle jmsConsumer) returns error? = @java:Method {
    name: "close",
    class: "javax.jms.MessageConsumer"
} external;

function setJmsMessageListener(handle jmsConsumer, MessageConsumer messageConsumer) returns error? = @java:Method {
    name: "setMessageListener",
    class: "org.wso2.ei.module.jms.JmsQueueReceiverUtils"
} external;
