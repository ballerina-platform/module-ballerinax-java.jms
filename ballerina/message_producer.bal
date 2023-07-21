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

# JMS Message Producer client object to send messages to both queues and topics.
public isolated client class MessageProducer {
    private final handle jmsProducer;
    private final handle jmsSession;

    # Initialize the Message Producer client object
    #
    # + jmsProducer - reference to java MessageProducer object
    isolated function init(handle jmsProducer, handle session) returns error? {
        self.jmsProducer = jmsProducer;
        self.jmsSession = session;
    }

    # Sends a message to the JMS provider
    #
    # + message - Message to be sent to the JMS provider
    # + return - Error if unable to send the message to the queue
    isolated remote function send(Message message) returns error? {
        handle jmsMessage = check getJmsMessage(self.jmsSession, message);
        return externSend(self.jmsProducer, jmsMessage);
    }

    # Sends a message to a given destination of the JMS provider
    #
    # + destination - Destination used for the message sender
    # + message - Message to be sent to the JMS provider
    # + return - Error if sending to the given destination fails
    isolated remote function sendTo(Destination destination, Message message) returns error? {
        handle jmsMessage = check getJmsMessage(self.jmsSession, message);
        return externSendTo(self.jmsProducer, destination.getJmsDestination(), jmsMessage);
    }
};

isolated function getJmsMessage(handle session, Message message) returns handle|error {
    if message is TextMessage {
        return createJmsTextMessageWithText(session, java:fromString(message.content));
    } else if message is BytesMessage {
        handle jmsMessage = check createJmsBytesMessage(session);
        check externWriteBytes(jmsMessage, message.content);
        return jmsMessage;
    } else if message is MapMessage {
        handle jmsMessage = check createJmsMapMessage(session);
        check populateMapMessage(jmsMessage, message.content);
        return jmsMessage;
    }
    return error ("Unidentified message type");
}

isolated function populateMapMessage(handle mapMessage, map<anydata> keyValues) returns error? {
    foreach string 'key in keyValues.keys() {
        var value = keyValues.get('key);
        if value is int {
            check externSetLong(mapMessage, java:fromString('key), value);
        } else if value is float {
            check externSetDouble(mapMessage, java:fromString('key), value);
        } else if value is boolean {
            check externSetBoolean(mapMessage, java:fromString('key), value);
        } else if value is string {
            check externSetString(mapMessage, java:fromString('key), java:fromString(value));
        }
    }
}

isolated function externSend(handle messageProducer, handle message) returns error? = @java:Method {
    name: "send",
    paramTypes: ["javax.jms.Message"],
    'class: "javax.jms.MessageProducer"
} external;

isolated function externSendTo(handle messageProducer, handle destination, handle message) returns error? = @java:Method {
    name: "send",
    paramTypes: ["javax.jms.Destination", "javax.jms.Message"],
    'class: "javax.jms.MessageProducer"
} external;
