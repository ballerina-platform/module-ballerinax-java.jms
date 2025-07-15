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

# Represent the valid value types allowed in JMS message properties.
public type PropertyType boolean|int|byte|float|string;

# Represents the allowed value types for entries in the map content of a JMS MapMessage.
public type ValueType PropertyType|byte[];

# Represent the JMS Message used to send and receive content from the a JMS provider.
#
# + messageId - Unique identifier for a JMS message (Only set by the JMS provider)
# + timestamp - Time a message was handed off to a provider to be sent (Only set by the JMS provider)
# + correlationId - Id which can be used to correlate multiple messages 
# + replyTo - JMS destination to which a reply to this message should be sent
# + destination - JMS destination of this message (Only set by the JMS provider)
# + deliveryMode - Delivery mode of this message (Only set by the JMS provider)
# + redelivered - Indication of whether this message is being redelivered (Only set by the JMS provider)
# + jmsType - Message type identifier supplied by the client when the message was sent  
# + expiration - Message expiration time (Only set by the JMS provider)
# + deliveredTime - The earliest time when a JMS provider may deliver the message to a consumer (Only set by the JMS provider)
# + priority - Message priority level (Only set by the JMS provider)
# + properties - Additional message properties
# + content - Message content
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
    map<PropertyType> properties?;
    string|map<ValueType>|byte[] content;
};
