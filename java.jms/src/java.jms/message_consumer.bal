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
import ballerina/java;
import ballerina/'lang\.object as lang;
import ballerina/observe;

observe:Gauge consumerGauge = new(ACTIVE_JMS_CONSUMERS);

public type MessageConsumer client object {

    *lang:Listener;
    private handle jmsConsumer = JAVA_NULL;

    function __init(handle jmsMessageConsumer) {
        self.jmsConsumer = jmsMessageConsumer;
        registerAndIncrementGauge(consumerGauge);
    }

    # Binds the queue receiver endpoint to a service.
    #
    # + s - The service instance.
    # + name - Name of the service.
    # + return - Returns nil or an error upon failure to register the listener.
    public function __attach(service s, string? name = ()) returns error? {
        string n = (name is string)? name: "";
        log:printDebug("Message consumer attached to service" + n);
        return setMessageListener(self.jmsConsumer, s);
    }

    # Starts the endpoint.
    #
    # + return - Returns nil or an error upon failure to start.
    public function __start() returns error? {
        return;
    }

    public function __gracefulStop() returns error? {
        return self.closeConsumer();
    }

    public function __immediateStop() returns error? {
    }

    public function __detach(service s) returns error? {
    }

    # Stops consuming messages through the QueueListener.
    #
    # + return - Returns nil or an error upon failure to close the queue receiver.
    public function __stop() returns error? {
        return self.closeConsumer();
    }

    private function closeConsumer() returns error? {
        decrementGauge(consumerGauge);
        return self->close();
    }

    public remote function receive(int timeoutMillis = 0) returns Message|()|error {
        var response = receiveJmsMessage(self.jmsConsumer, timeoutMillis);
        registerAndIncrementCounter(new observe:Counter(TOTAL_JMS_MESSAGES_RECEIVED));
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

    public remote function receiveNoWait() returns Message|()|error {
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

    private function getBallerinaMessage(handle jmsMessage) returns Message|error {
        if (isTextMessage(jmsMessage)) {
            return new TextMessage(jmsMessage);
        } else if (isMapMessage(jmsMessage)) {
            return new MapMessage(jmsMessage);
        } else if (isBytesMessage(jmsMessage)) {
            return new BytesMessage(jmsMessage);
        } else if (isStreamMessage(jmsMessage)) {
            return new StreamMessage(jmsMessage);
        } else {
            return new Message(jmsMessage);
        }
    }

    function getJmsConsumer() returns handle {
        return self.jmsConsumer;
    }
};

function receiveJmsMessage(handle jmsMessageConsumer, int timeout) returns handle|error = @java:Method {
    name: "receive",
    paramTypes: ["long"],
    class: "javax.jms.MessageConsumer"
} external;

function receiveNoWaitJmsMessage(handle jmsMessageConsumer) returns handle|error = @java:Method {
    name: "receiveNoWait",
    class: "javax.jms.MessageConsumer"
} external;

function isTextMessage(handle jmsMessage) returns boolean = @java:Method {
    class: "org.ballerinalang.java.jms.JmsMessageUtils"
} external;

function isMapMessage(handle jmsMessage) returns boolean = @java:Method {
    class: "org.ballerinalang.java.jms.JmsMessageUtils"
} external;

function isBytesMessage(handle jmsMessage) returns boolean = @java:Method {
    class: "org.ballerinalang.java.jms.JmsMessageUtils"
} external;

function isStreamMessage(handle jmsMessage) returns boolean = @java:Method {
    class: "org.ballerinalang.java.jms.JmsMessageUtils"
} external;

function closeJmsConsumer(handle jmsConsumer) returns error? = @java:Method {
    name: "close",
    class: "javax.jms.MessageConsumer"
} external;

function setMessageListener(handle jmsConsumer, service serviceObject) returns error? = @java:Method {
    class: "org.ballerinalang.java.jms.JmsMessageListenerUtils"
} external;
