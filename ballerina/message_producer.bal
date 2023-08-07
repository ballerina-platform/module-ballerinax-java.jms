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
    private final Session session;

    isolated function init(Session session, Destination? destination = ()) returns Error? {
        self.session = session;
        return self.externInit(session, destination);
    }

    isolated function externInit(Session session, Destination? destination) returns Error? = @java:Method {
        name: "init",
        'class: "io.ballerina.stdlib.java.jms.JmsProducer"
    } external;

    # Sends a message to the JMS provider.
    #
    # + message - Message to be sent to the JMS provider
    # + return - Error if unable to send the message to the queue
    isolated remote function send(Message message) returns Error? {
        handle jmsMessage = check getJmsMessage(self.session, message);
        return self.externSend(jmsMessage);
    }

    isolated function externSend(handle message) returns Error? = @java:Method {
        name: "send",
        'class: "io.ballerina.stdlib.java.jms.JmsProducer"
    } external;

    # Sends a message to a given destination of the JMS provider.
    #
    # + destination - Destination used for the message sender
    # + message - Message to be sent to the JMS provider
    # + return - Error if sending to the given destination fails
    isolated remote function sendTo(Destination destination, Message message) returns Error? {
        handle jmsMessage = check getJmsMessage(self.session, message);
        return self.externSendTo(self.session, destination, jmsMessage);
    }

    isolated function externSendTo(Session session, Destination destination, handle message) 
        returns Error? = @java:Method {
        name: "sendTo",
        'class: "io.ballerina.stdlib.java.jms.JmsProducer"
    } external;
};

isolated function getJmsMessage(Session session, Message message) returns handle|Error {
    if message is TextMessage {
        handle jmsMessage = check session.createJmsMessage("TEXT");
        error? result = trap externWriteText(jmsMessage, java:fromString(message.content));
        if result is error {
            return error Error(result.message());
        }
        return jmsMessage;
    } else if message is BytesMessage {
        handle jmsMessage = check session.createJmsMessage("BYTES");
        error? result = trap externWriteBytes(jmsMessage, message.content);
        if result is error {
            return error Error(result.message());
        }
        return jmsMessage;
    } else if message is MapMessage {
        handle jmsMessage = check session.createJmsMessage("MAP");
        error? result = trap populateMapMessage(jmsMessage, message.content);
        if result is error {
            return error Error(result.message());
        }
        return jmsMessage;
    }
    return error Error("Unidentified message type");
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
