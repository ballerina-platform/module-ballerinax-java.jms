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

# Represent the JMS text message used to send and receive content from the a JMS provider.
#
# Most message-oriented middleware (MOM) products treat messages as lightweight entities that consist of a header
# and a body. The header contains fields used for message routing and identification; the body contains the
# application data being sent.
public type TextMessage client object {

    private handle jmsTextMessage = java:createNull();

    # Initialized a `TextMessage` object.
    #
    # + handle - The java reference to the jms text message.
    function __init(handle textMessage) {
        self.jmsTextMessage = textMessage;
    }

    # Set the text message.
    #
    # + return - If an error occurred while setting the message's data.
    public function setText(string data) returns error? {
        return setJmsText(self.jmsTextMessage, java:fromString(data));
    }

    # Get the text message.
    #
    # + return - Returns the message's data or an error if it fails.
    public function getText() returns string?|error {
        handle|error val = getJmsText(self.jmsTextMessage);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

};

public function setJmsText(handle textMessage, handle data) returns error? = @java:Method {
    class: "org.wso2.ei.module.jms.JmsTextMessageUtils"
} external;

public function getJmsText(handle textMessage) returns handle | error = @java:Method {
    class: "org.wso2.ei.module.jms.JmsTextMessageUtils"
} external;
