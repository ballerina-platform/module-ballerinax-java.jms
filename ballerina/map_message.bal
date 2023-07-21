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

# Represent the 'MapMessage' used to send and receive content from the a JMS provider.
#
# Most message-oriented middleware (MOM) products treat messages as lightweight entities that consist of a header
# and a body. The header contains fields used for message routing and identification; the body contains the
# application data being sent.
public client class MapMessage {
    *AbstractMessage;

    # Initialized a `MapMessage` object.
    #
    # + handle - The java reference to the jms text message.
    isolated function init(handle mapMessage) {
        self.jmsMessage = mapMessage;
    }

    # Get the boolean value by given name.
    #
    # + name - The name of the boolean
    # + return - Returns the boolean value or an error if it fails.
    public function getBoolean(string name) returns boolean | error {
        return externGetBoolean(self.jmsMessage, java:fromString(name));
    }

    # Get the byte value by given name.
    #
    # + name - The name of the byte
    # + return - Returns the byte value or an error if it fails.
    public function getByte(string name) returns byte | error {
        return externGetByte(self.jmsMessage, java:fromString(name));
    }

    # Get the byte array by given name.
    #
    # + name - The name of the byte array
    # + return - Returns the byte array or an error if it fails.
    public function getBytes(string name) returns byte[] | error {
        return externGetBytes(self.jmsMessage, java:fromString(name));
    }

    # Get the double value by given name.
    #
    # + name - The name of the double
    # + return - Returns the double value or an error if it fails.
    public function getDouble(string name) returns float | error {
        return externGetDouble(self.jmsMessage, java:fromString(name));
    }

    # Get the float value by given name.
    #
    # + name - The name of the float
    # + return - Returns the float value or an error if it fails.
    public function getFloat(string name) returns float | error {
        return externGetFloat(self.jmsMessage, java:fromString(name));
    }

    # Get the int value by given name.
    #
    # + name - The name of the int
    # + return - Returns the int value or an error if it fails.
    public function getInt(string name) returns int | error {
        return externGetInt(self.jmsMessage, java:fromString(name));
    }

    # Get the long value by given name.
    #
    # + name - The name of the long
    # + return - Returns the long value or an error if it fails.
    public function getLong(string name) returns int | error {
        return externGetLong(self.jmsMessage, java:fromString(name));
    }

    # Get all the names in the MapMessage object.
    #
    # + return - Returns the string[] or an error if it fails.
    public function getMapNames() returns string[] | error {
        return externGetMapNames(self.jmsMessage);
    }

    # Get the short value by given name.
    #
    # + name - The name of the short
    # + return - Returns the short value or an error if it fails.
    public function getShort(string name) returns int | error {
        return externGetShort(self.jmsMessage, java:fromString(name));
    }

    # Get the string value by given name.
    #
    # + name - The name of the string
    # + return - Returns the string value or an error if it fails.
    public function getString(string name) returns string? | error {
        handle|error val = externGetString(self.jmsMessage, java:fromString(name));
        if(val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Check whether an item exists in this MapMessage.
    #
    # + name - The name of the item to test
    # + return - Returns the item exists or an error if it fails.
    public function itemExists(string name) returns boolean | error {
        return externItemExists(self.jmsMessage, java:fromString(name));
    }

    # Set a boolean value with the specified name.
    #
    # + name - The name of the boolean
    # + value - The boolean value to set in the Map
    # + return - Returns an error if it fails.
    public function setBoolean(string name, boolean value) returns error? {
        return externSetBoolean(self.jmsMessage, java:fromString(name), value);
    }

    # Set a byte value with the specified name.
    #
    # + name - the name of the byte
    # + value - The byte value to set in the Map
    # + return - Returns an error if it fails.
    public function setByte(string name, byte value) returns error? {
        return externSetByte(self.jmsMessage, java:fromString(name), value);
    }

    # Set a byte array with the specified name.
    #
    # + name - The name of the byte array
    # + value - The byte array value to set in the Map
    # + offset - The initial offset within the byte array
    # + length - The number of bytes to use
    # + return - Returns an error if it fails.
    public function setBytes(string name, byte[] value, int? offset = (), int? length = ()) returns error? {
        if(offset is int && length is int) {
 //           return setPortionOfBytes(self.jmsMessage, java:fromString(name), value, offset, length);
       } else {
 //           return setBytes(self.jmsMessage, java:fromString(name), value);
        }
    }

    # Set a double value with the specified name.
    #
    # + name - The name of the double
    # + value - The double value to set in the Map
    # + return - Returns an error if it fails.
    public function setDouble(string name, float value) returns error? {
        return externSetDouble(self.jmsMessage, java:fromString(name), value);
    }

    # Set a float value with the specified name.
    #
    # + name - The name of the float
    # + value - The float value to set in the Map
    # + return - Returns an error if it fails.
    public function setFloat(string name, float value) returns error? {
        return externSetFloat(self.jmsMessage, java:fromString(name), value);
    }

    # Set a int value with the specified name.
    #
    # + name - The name of the int
    # + value - The int value to set in the Map
    # + return - Returns an error if it fails.
    public function setInt(string name, int value) returns error? {
        return externSetInt(self.jmsMessage, java:fromString(name), value);
    }

    # Set a long value with the specified name.
    #
    # + name - The name of the long
    # + value - The long value to set in the Map
    # + return - Returns an error if it fails.
    public function setLong(string name, int value) returns error? {
        return externSetLong(self.jmsMessage, java:fromString(name), value);
    }

    # Set a short value with the specified name.
    #
    # + name - The name of the short
    # + value - The short value to set in the Map
    # + return - Returns an error if it fails.
    public function setShort(string name, int value) returns error? {
        return externSetShort(self.jmsMessage, java:fromString(name), value);
    }

    # Set a string value with the specified name.
    #
    # + name - The name of the string
    # + value - The string value to set in the Map
    # + return - Returns an error if it fails.
    public function setString(string name, string value) returns error? {
        return externSetString(self.jmsMessage, java:fromString(name), java:fromString(value));
    }

    # Acknowledges the reception of this message. This is used when the consumer has chosen CLIENT_ACKNOWLEDGE as its
    # acknowledgment mode.
    #
    # + return - If an error occurred while acknowledging the message.
    remote function acknowledge() returns error? {
        return externAcknowledge(self.jmsMessage);
    }

    # Clears out the message body.
    #
    # + return - If an error occurred while clearing out the message properties.
    public function clearBody() returns error? {
        return externClearBody(self.jmsMessage);
    }

    # Clears a message's properties.
    #
    # + return - If an error occurred while clearing out the message properties.
    public function clearProperties() returns error? {
        return externClearProperties(self.jmsMessage);
    }

    # Get the given boolean property.
    #
    # + name - The name of the boolean property
    # + return - Returns the boolean value or an error if it fails.
    public function getBooleanProperty(string name) returns boolean | error {
        return externGetBooleanProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given byte property.
    #
    # + name - The name of the byte property
    # + return - Returns the byte value or an error if it fails.
    public function getByteProperty(string name) returns byte | error {
        return externGetByteProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given double property.
    #
    # + name - The name of the double property
    # + return - Returns the double value or an error if it fails.
    public function getDoubleProperty(string name) returns float | error {
        return externGetDoubleProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given float property.
    #
    # + name - The name of the float property
    # + return - Returns the float value or an error if it fails.
    public function getFloatProperty(string name) returns float | error {
        return externGetFloatProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given int property.
    #
    # + name - The name of the int property
    # + return - Returns the int value or an error if it fails.
    public function getIntProperty(string name) returns int | error {
        return externGetIntProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the message correlation ID.
    #
    # + return - Returns the message correlation ID or an error if it fails.
    public function getJMSCorrelationID() returns string? | error {
        handle|error val = externGetJMSCorrelationID(self.jmsMessage);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Get the message correlation ID as an array of bytes.
    #
    # + return - Returns the message correlation ID as an byte array or an error if it fails.
    public function getJMSCorrelationIDAsBytes() returns byte[] | error {
        return externGetJMSCorrelationIDAsBytes(self.jmsMessage);
    }

    # Get the message delivery mode.
    #
    # + return - Returns the message delivery mode or an error if it fails.
    public function getJMSDeliveryMode() returns int | error {
        return externGetJMSDeliveryMode(self.jmsMessage);
    }

    # Get the message delivery time.
    #
    # + return - Returns the message delivery time or an error if it fails.
    public function getJMSDeliveryTime() returns int | error {
        return externGetJMSDeliveryTime(self.jmsMessage);
    }

    # Get the message destination object.
    #
    # + return - Returns the message destination object or an error if it fails.
    public function getJMSDestination() returns Destination | error {
        handle|error val = externGetJMSDestination(self.jmsMessage);
        if (val is handle) {
            return getDestination(val);
        } else {
            return val;
        }
    }

    # Get the message expiration time.
    #
    # + return - Returns the message expiration time or an error if it fails.
    public function getJMSExpiration() returns int | error {
        return externGetJMSExpiration(self.jmsMessage);
    }

    # Get the message ID.
    #
    # + return - Returns the message ID or an error if it fails.
    public function getJMSMessageID() returns string? | error {
        handle|error val = externGetJMSMessageID(self.jmsMessage);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Get the message priority.
    #
    # + return - Returns the message priority or an error if it fails.
    public function getJMSPriority() returns int | error {
        return externGetJMSPriority(self.jmsMessage);
    }

    # Get an indication whether the message being redelivered.
    #
    # + return - Returns the message redelivered or an error if it fails.
    public function getJMSRedelivered() returns boolean | error {
        return externGetJMSRedelivered(self.jmsMessage);
    }

    # Get the Destination object to which a reply to this message should be sent.
    #
    # + return - Returns the reply to destination or an error if it fails.
    public function getJMSReplyTo() returns Destination | error {
        handle|error val = externGetJMSReplyTo(self.jmsMessage);
        if (val is handle) {
            return getDestination(val);
        } else {
            return val;
        }
    }

    # Get the message timestamp.
    #
    # + return - Returns the message timestamp or an error if it fails.
    public function getJMSTimestamp() returns int | error {
        return externGetJMSTimestamp(self.jmsMessage);
    }

    # Get the message type identifier.
    #
    # + return - Returns the message type or an error if it fails.
    public function getJMSType() returns (string|error)? {
        handle|error val = externGetJMSType(self.jmsMessage);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Get the given long property.
    #
    # + name - The name of the long property
    # + return - Returns the int value or an error if it fails.
    public function getLongProperty(string name) returns int | error {
        return externGetLongProperty(self.jmsMessage, java:fromString(name));
    }

    # Get string array of property names.
    #
    # + return - Returns the string array of property names or an error if it fails.
    public function getPropertyNames() returns string[] | error {
        return externGetPropertyNames(self.jmsMessage);
    }

    # Get the given short property.
    #
    # + name - The name of the short property
    # + return - Returns the int value or an error if it fails.
    public function getShortProperty(string name) returns int | error {
        return externGetShortProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given string property.
    #
    # + name - The name of the string property
    # + return - Returns the string value or an error if it fails.
    public function getStringProperty(string name) returns (string|error)? {
        handle|error val = externGetStringProperty(self.jmsMessage, java:fromString(name));
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Indicate whether a property value exists.
    #
    # + name - The name of the property to test
    # + return - Returns true if the property exists or an error if it fails.
    public function propertyExists(string name) returns boolean | error {
        return externPropertyExists(self.jmsMessage, java:fromString(name));
    }

    # Set the boolean value with the specified name into the message.
    #
    # + name - The name of the boolean property
    # + value - The boolean property value to set
    # + return - Returns an error if it fails.
    public function setBooleanProperty(string name, boolean value) returns error? {
        return externSetBooleanProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the byte value with the specified name into the message.
    #
    # + name - The name of the byte property
    # + value - The byte property value to set
    # + return - Returns an error if it fails.
    public function setByteProperty(string name, byte value) returns error? {
        return externSetByteProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the double value with the specified name into the message.
    #
    # + name - The name of the double property
    # + value - The double property value to set
    # + return - Returns an error if it fails.
    public function setDoubleProperty(string name, float value) returns error? {
        return externSetDoubleProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the float value with the specified name into the message.
    #
    # + name - The name of the float property
    # + value - The float property value to set
    # + return - Returns an error if it fails.
    public function setFloatProperty(string name, float value) returns error? {
        return externSetFloatProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the int value with the specified name into the message.
    #
    # + name - The name of the int property
    # + value - The int property value to set
    # + return - Returns an error if it fails.
    public function setIntProperty(string name, int value) returns error? {
        return externSetIntProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Sets the correlation id for the message.
    # 
    # + correlationId - correlation id of a message as a string
    # + return - Returns an error if it fails.
    public function setJMSCorrelationID(string correlationId) returns error? {
        return externSetJMSCorrelationID(self.jmsMessage, java:fromString(correlationId));
    }

    # Sets the correlation id an array of bytes for the message.
    # 
    # + correlationId - correlation id value as an array of bytes
    # + return - Returns an error if it fails.
    public function setJMSCorrelationIDAsBytes(byte[] correlationId) returns error? {
        return externSetJMSCorrelationIDAsBytes(self.jmsMessage, correlationId);
    }

    # Set the reply destination to the message which a reply should send.
    #
    # + replyTo - Destination to which to send a response to this message
    # + return - Returns an error if it fails.
    public function setJMSReplyTo(Destination replyTo) returns error? {
        return externSetJMSReplyTo(self.jmsMessage, replyTo.getJmsDestination());
    }

    # Set the message type.
    #
    # + jmsType - The message type
    # + return - Returns an error if it fails.
    public function setJMSType(string jmsType) returns error? {
        return externSetJMSType(self.jmsMessage, java:fromString(jmsType));
    }

    # Set the long value with the specified name into the message.
    #
    # + name - The name of the long property
    # + value - The long property value to set
    # + return - Returns an error if it fails.
    public function setLongProperty(string name, int value) returns error? {
        return externSetLongProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the short value with the specified name into the message.
    #
    # + name - The name of the short property
    # + value - The short property value to set
    # + return - Returns an error if it fails.
    public function setShortProperty(string name, int value) returns error? {
        return externSetShortProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the string value with the specified name into the message.
    #
    # + name - The name of the string property
    # + value - The string property value to set
    # + return - Returns an error if it fails.
    public function setStringProperty(string name, string value) returns error? {
        return externSetStringProperty(self.jmsMessage, java:fromString(name), java:fromString(value));
    }

    # Get the JMS map message
    #
    # + return - Returns the java reference to the jms map message
    function getJmsMessage() returns handle {
        return self.jmsMessage;
    }
}

function externGetBoolean(handle message, handle name) returns boolean | error = @java:Method {
    name: "getBoolean",
    'class: "javax.jms.MapMessage"
} external;

function externGetByte(handle message, handle name) returns byte | error = @java:Method {
    name: "getByte",
    'class: "javax.jms.MapMessage"
} external;

function externGetBytes(handle message, handle name) returns byte[] | error = @java:Method {
    name: "getBytes",
    'class: "io.ballerina.stdlib.java.jms.JmsMapMessageUtils"
} external;

function externGetDouble(handle message, handle name) returns float | error = @java:Method {
    name: "getDouble",
    'class: "javax.jms.MapMessage"
} external;

function externGetFloat(handle message, handle name) returns float | error = @java:Method {
    name: "getFloat",
    'class: "javax.jms.MapMessage"
} external;

function externGetInt(handle message, handle name) returns int | error = @java:Method {
    name: "getInt",
    'class: "javax.jms.MapMessage"
} external;

function externGetLong(handle message, handle name) returns int | error = @java:Method {
    name: "getLong",
    'class: "javax.jms.MapMessage"
} external;

function externGetMapNames(handle message) returns string[] | error = @java:Method {
    name: "getJmsMapNames",
    'class: "io.ballerina.stdlib.java.jms.JmsMapMessageUtils"
} external;

function externGetShort(handle message, handle name) returns int | error = @java:Method {
    name: "getShort",
    'class: "javax.jms.MapMessage"
} external;

function externGetString(handle message, handle name) returns handle | error = @java:Method {
    name: "getString",
    'class: "javax.jms.MapMessage"
} external;

function externItemExists(handle message, handle name) returns boolean | error = @java:Method {
    name: "itemExists",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetBoolean(handle message, handle name, boolean value) returns error? = @java:Method {
    name: "setBoolean",
    'class: "javax.jms.MapMessage"
} external;

function externSetByte(handle message, handle name, byte value) returns error? = @java:Method {
    name: "setByte",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetDouble(handle message, handle name, float value) returns error? = @java:Method {
    name: "setDouble",
    'class: "javax.jms.MapMessage"
} external;

function externSetFloat(handle message, handle name, float value) returns error? = @java:Method {
    name: "setFloat",
    'class: "javax.jms.MapMessage"
} external;

function externSetInt(handle message, handle name, int value) returns error? = @java:Method {
    name: "setInt",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetLong(handle message, handle name, int value) returns error? = @java:Method {
    name: "setLong",
    'class: "javax.jms.MapMessage"
} external;

function externSetShort(handle message, handle name, int value) returns error? = @java:Method {
    name: "setShort",
    'class: "javax.jms.MapMessage"
} external;

isolated function externSetString(handle message, handle name, handle value) returns error? = @java:Method {
    name: "setString",
    'class: "javax.jms.MapMessage"
} external;
