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

import ballerina/lang.runtime;
import ballerina/io;
import ballerina/test;

final MessageProducer durableTopicProducer = check createProducer(AUTO_ACK_SESSION, { 'type: TOPIC, name: "durable-topic" });

isolated int durableConsumerMsgCount = 0;

@test:Config {
    groups: ["messageListener"]
}
isolated function testSvcWithDurableSubscription() returns error? {
    Service consumerSvc = @ServiceConfig {
        acknowledgementMode: AUTO_ACKNOWLEDGE,
        subscriptionConfig: {
            topicName: "durable-topic",
            consumerType: DURABLE,
            subscriberName: "durable-consumer-svc"
        }
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
            lock {
                durableConsumerMsgCount += 1;
            }
        }
    };
    check jmsMessageListener.attach(consumerSvc, "durable-consumer-svc");

    check sendMessages(durableTopicProducer, 5);
    runtime:sleep(10);

    check jmsMessageListener.detach(consumerSvc);

    runtime:sleep(1);
    check sendMessages(durableTopicProducer, 5);

    check jmsMessageListener.attach(consumerSvc, "durable-consumer-svc");
    runtime:sleep(10);

    lock {
        test:assertEquals(durableConsumerMsgCount, 10, "Invalid message count for durable subscriber");
    }
}

isolated function sendMessages(MessageProducer producer, int numberOfMessages) returns error? {
    foreach int i in 0..<numberOfMessages {
        string content = string `This is the message number: ${i}`;
        check producer->send(<TextMessage> { content });
    }
}
