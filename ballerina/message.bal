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

# Represent the JMS Message used to send and receive content from the a JMS provider.
#
# + messageId - Unique identifier for a JMS message  
# + timestamp - Time a message was handed off to a provider to be sent 
# + correlationId - Id which can be use to correlate multiple messages 
# + replyTo - JMS destination to which a reply to this message should be sent
# + destination - JMS destination of this message 
# + deliveryMode - Delivery mode of this message  
# + redelivered - Indication of whether this message is being redelivered
# + jmsType - Message type identifier supplied by the client when the message was sent  
# + expiration - Message expiration time  
# + deliveredTime - The earliest time when a JMS provider may deliver the message to a consumer  
# + priority - Message priority level  
# + properties - Additional message properties
public type Message record {
    string messageId?;
    int timestamp?;
    string correlationId?;
    Destination replyTo?;
    Destination destination?;
    int deliveryMode?;
    boolean redelivered?;
    string jmsType?;
    int expiration?;
    int deliveredTime?;
    int priority?;
    map<anydata> properties?;
};

# Represent the JMS Text Message.
# 
# + content - Message content  
public type TextMessage record {|
    *Message;
    string content;
|};

# Represent the JMS Map Message.
# 
# + content - Message content 
public type MapMessage record {|
    *Message;
    map<anydata> content;
|};

# Represent the JMS Bytes Message.
# 
# + content - Message content 
public type BytesMessage record {|
    *Message;
    byte[] content;
|};

isolated function externWriteText(handle message, handle value) returns error? = @java:Method {
    name: "setText",
    'class: "javax.jms.TextMessage"
} external;

isolated function externWriteBytes(handle message, byte[] value) returns error? = @java:Method {
    name: "writeBytes",
    'class: "io.ballerina.stdlib.java.jms.JmsMessageUtils"
} external;

isolated function externSetBoolean(handle message, handle name, boolean value) returns error? = @java:Method {
    name: "setBoolean",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetDouble(handle message, handle name, float value) returns error? = @java:Method {
    name: "setDouble",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetLong(handle message, handle name, int value) returns error? = @java:Method {
    name: "setLong",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetString(handle message, handle name, handle value) returns error? = @java:Method {
    name: "setString",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetBytes(handle message, handle name, byte[] value) returns error? = @java:Method {
    name: "writeBytesField",
    'class: "io.ballerina.stdlib.java.jms.JmsMessageUtils"
} external;
