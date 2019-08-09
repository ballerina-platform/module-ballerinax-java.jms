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

# Represent the JMS message used to send and receive content from the a JMS provider.
#
# Most message-oriented middleware (MOM) products treat messages as lightweight entities that consist of a header
# and a body. The header contains fields used for message routing and identification; the body contains the
# application data being sent.
public type Message client object {

    handle jmsMessage = java:createNull();

    # Initialized a `Message` object.
    # 
    # + handle - The java reference to the jms message.
    function __init(handle message) {
        self.jmsMessage = message;
    }

    # Acknowledges the reception of this message. This is used when the consumer has chosen CLIENT_ACKNOWLEDGE as its
    # acknowledgment mode.
    #
    # + return - If an error occurred while acknowledging the message.
    public remote function acknowledge() returns error? {
        return acknowledgeMessage(self.jmsMessage);
    }

    # Clears a message's properties.
    #
    # + return - If an error occurred while clearing out the message properties.
    public function clearProperties() returns error? {
        return clearMessageBody(self.jmsMessage);
    }

    function getJmsMessage() returns handle {
        return self.jmsMessage;
    }
};

public function acknowledgeMessage(handle message) returns error? = @java:Method {
    class: "org.wso2.ei.module.jms.JmsMessageUtils"
} external;

public function clearMessageBody(handle message) returns error? = @java:Method {
    class: "org.wso2.ei.module.jms.JmsMessageUtils"
} external;

