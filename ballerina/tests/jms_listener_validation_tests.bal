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

import ballerina/test;

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testAnnotationNotFound() returns error? {
    Service svc = service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
    };
    Error? result = jmsMessageListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service to listener: Service configuration annotation is required",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testSvcWithResourceMethods() returns error? {
    Service svc = @ServiceConfig {
        acknowledgementMode: CLIENT_ACKNOWLEDGE,
        subscriptionConfig: {
            queueName: "test-svc-attach"
        }
    } service object {

        resource function get .() returns error? {
        }

        remote function onMessage(Message message, Caller caller) returns error? {
        }
    };
    Error? result = jmsMessageListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service to listener: JMS service cannot have resource methods",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testSvcWithNoRemoteMethods() returns error? {
    Service svc = @ServiceConfig {
        acknowledgementMode: CLIENT_ACKNOWLEDGE,
        subscriptionConfig: {
            queueName: "test-svc-attach"
        }
    } service object {};
    Error? result = jmsMessageListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service to listener: JMS service must have exactly one remote method",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testSvcWithInvalidRemoteMethod() returns error? {
    Service svc = @ServiceConfig {
        acknowledgementMode: CLIENT_ACKNOWLEDGE,
        subscriptionConfig: {
            queueName: "test-svc-attach"
        }
    } service object {

        remote function onRequest(Message message, Caller caller) returns error? {
        }
    };
    Error? result = jmsMessageListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service to listener: JMS service does not contain the required `onMessage` method",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testSvcMethodWithAdditionalParameters() returns error? {
    Service svc = @ServiceConfig {
        acknowledgementMode: CLIENT_ACKNOWLEDGE,
        subscriptionConfig: {
            queueName: "test-svc-attach"
        }
    } service object {

        remote function onMessage(Message message, Caller caller, string requestType) returns error? {
        }
    };
    Error? result = jmsMessageListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service to listener: onMessage method can have only have either one or two parameters",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testSvcMethodWithInvalidParams() returns error? {
    Service svc = @ServiceConfig {
        acknowledgementMode: CLIENT_ACKNOWLEDGE,
        subscriptionConfig: {
            queueName: "test-svc-attach"
        }
    } service object {

        remote function onMessage(Message message, string requestType) returns error? {
        }
    };
    Error? result = jmsMessageListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service to listener: onMessage method parameters must be of type 'jms:Message' or `jms:Caller`",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testSvcMethodMandatoryParamMissing() returns error? {
    Service svc = @ServiceConfig {
        acknowledgementMode: CLIENT_ACKNOWLEDGE,
        subscriptionConfig: {
            queueName: "test-svc-attach"
        }
    } service object {

        remote function onMessage(Caller caller) returns error? {
        }
    };
    Error? result = jmsMessageListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service to listener: Required parameter 'jms:Message' can not be found",
                "Invalid error message received");
    }
}
