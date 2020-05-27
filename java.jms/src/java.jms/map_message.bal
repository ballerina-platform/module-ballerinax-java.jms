// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/java;

# Represent the 'MapMessage' used to send and receive content from the a JMS provider.
#
# Most message-oriented middleware (MOM) products treat messages as lightweight entities that consist of a header
# and a body. The header contains fields used for message routing and identification; the body contains the
# application data being sent.
public type MapMessage client object {

    // Add a reference to the `AbstractMessage` object type.
    *AbstractMessage;

    # Initialized a `MapMessage` object.
    #
    # + handle - The java reference to the jms text message.
    function __init(handle mapMessage) {
        self.jmsMessage = mapMessage;
    }

    # Get the boolean value by given name.
    #
    # + name - The name of the boolean
    # + return - Returns the boolean value or an error if it fails.
    public function getBoolean(string name) returns boolean | error {
        return getBoolean(self.jmsMessage, java:fromString(name));
    }

    # Get the byte value by given name.
    #
    # + name - The name of the byte
    # + return - Returns the byte value or an error if it fails.
    public function getByte(string name) returns byte | error {
        return getByte(self.jmsMessage, java:fromString(name));
    }

    # Get the byte array by given name.
    #
    # + name - The name of the byte array
    # + return - Returns the byte array or an error if it fails.
    public function getBytes(string name) returns byte[] | error {
        return getBytes(self.jmsMessage, java:fromString(name));
    }

//    # Get the char value by given name.
//    #
//    # + return - Returns the char value or an error if it fails.
//    public function getChar(string name) returns string | error {
//        handle|error val = getChar(self.jmsMessage, java:fromString(name));
//        if (val is handle) {
//            return java:toString(val);
//        } else {
//            return val;
//        }
//    }


    # Get the double value by given name.
    #
    # + name - The name of the double
    # + return - Returns the double value or an error if it fails.
    public function getDouble(string name) returns float | error {
        return getDouble(self.jmsMessage, java:fromString(name));
    }

    # Get the float value by given name.
    #
    # + name - The name of the float
    # + return - Returns the float value or an error if it fails.
    public function getFloat(string name) returns float | error {
        return getFloat(self.jmsMessage, java:fromString(name));
    }

    # Get the int value by given name.
    #
    # + name - The name of the int
    # + return - Returns the int value or an error if it fails.
    public function getInt(string name) returns int | error {
        return getInt(self.jmsMessage, java:fromString(name));
    }

    # Get the long value by given name.
    #
    # + name - The name of the long
    # + return - Returns the long value or an error if it fails.
    public function getLong(string name) returns int | error {
        return getLong(self.jmsMessage, java:fromString(name));
    }

    # Get all the names in the MapMessage object.
    #
    # + return - Returns the string[] or an error if it fails.
    public function getMapNames() returns string[] | error {
        return getMapNames(self.jmsMessage);
    }

    # Get the short value by given name.
    #
    # + name - The name of the short
    # + return - Returns the short value or an error if it fails.
    public function getShort(string name) returns int | error {
        return getShort(self.jmsMessage, java:fromString(name));
    }

    # Get the string value by given name.
    #
    # + name - The name of the string
    # + return - Returns the string value or an error if it fails.
    public function getString(string name) returns string? | error {
        handle|error val = getString(self.jmsMessage, java:fromString(name));
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
        return itemExists(self.jmsMessage, java:fromString(name));
    }

    # Set a boolean value with the specified name.
    #
    # + name - The name of the boolean
    # + value - The boolean value to set in the Map
    # + return - Returns an error if it fails.
    public function setBoolean(string name, boolean value) returns error? {
        return setBoolean(self.jmsMessage, java:fromString(name), value);
    }

    # Set a byte value with the specified name.
    #
    # + name - the name of the byte
    # + value - The byte value to set in the Map
    # + return - Returns an error if it fails.
    public function setByte(string name, byte value) returns error? {
        return setByte(self.jmsMessage, java:fromString(name), value);
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

//    # Set a char value with the specified name.
//    #
//    # + name - The name of the Unicode character
//    # + value - The Unicode character value to set in the Map
//    # + return - Returns an error if it fails.
//    public function setChar(string name, string value) returns error? {
//        return setChar(self.jmsMessage, java:fromString(name), java:fromString(value));
//    }

    # Set a double value with the specified name.
    #
    # + name - The name of the double
    # + value - The double value to set in the Map
    # + return - Returns an error if it fails.
    public function setDouble(string name, float value) returns error? {
        return setDouble(self.jmsMessage, java:fromString(name), value);
    }

    # Set a float value with the specified name.
    #
    # + name - The name of the float
    # + value - The float value to set in the Map
    # + return - Returns an error if it fails.
    public function setFloat(string name, float value) returns error? {
        return setFloat(self.jmsMessage, java:fromString(name), value);
    }

    # Set a int value with the specified name.
    #
    # + name - The name of the int
    # + value - The int value to set in the Map
    # + return - Returns an error if it fails.
    public function setInt(string name, int value) returns error? {
        return setInt(self.jmsMessage, java:fromString(name), value);
    }

    # Set a long value with the specified name.
    #
    # + name - The name of the long
    # + value - The long value to set in the Map
    # + return - Returns an error if it fails.
    public function setLong(string name, int value) returns error? {
        return setLong(self.jmsMessage, java:fromString(name), value);
    }

    # Set a short value with the specified name.
    #
    # + name - The name of the short
    # + value - The short value to set in the Map
    # + return - Returns an error if it fails.
    public function setShort(string name, int value) returns error? {
        return setShort(self.jmsMessage, java:fromString(name), value);
    }

    # Set a string value with the specified name.
    #
    # + name - The name of the string
    # + value - The string value to set in the Map
    # + return - Returns an error if it fails.
    public function setString(string name, string value) returns error? {
        return setString(self.jmsMessage, java:fromString(name), java:fromString(value));
    }

    # Acknowledges the reception of this message. This is used when the consumer has chosen CLIENT_ACKNOWLEDGE as its
    # acknowledgment mode.
    #
    # + return - If an error occurred while acknowledging the message.
    public remote function acknowledge() returns error? {
        return acknowledge(self.jmsMessage);
    }

    # Clears out the message body.
    #
    # + return - If an error occurred while clearing out the message properties.
    public function clearBody() returns error? {
        return clearBody(self.jmsMessage);
    }

    # Clears a message's properties.
    #
    # + return - If an error occurred while clearing out the message properties.
    public function clearProperties() returns error? {
        return clearProperties(self.jmsMessage);
    }

    # Get the given boolean property.
    #
    # + name - The name of the boolean property
    # + return - Returns the boolean value or an error if it fails.
    public function getBooleanProperty(string name) returns boolean | error {
        return getBooleanProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given byte property.
    #
    # + name - The name of the byte property
    # + return - Returns the byte value or an error if it fails.
    public function getByteProperty(string name) returns byte | error {
        return getByteProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given double property.
    #
    # + name - The name of the double property
    # + return - Returns the double value or an error if it fails.
    public function getDoubleProperty(string name) returns float | error {
        return getDoubleProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given float property.
    #
    # + name - The name of the float property
    # + return - Returns the float value or an error if it fails.
    public function getFloatProperty(string name) returns float | error {
        return getFloatProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given int property.
    #
    # + name - The name of the int property
    # + return - Returns the int value or an error if it fails.
    public function getIntProperty(string name) returns int | error {
        return getIntProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the message correlation ID.
    #
    # + return - Returns the message correlation ID or an error if it fails.
    public function getJMSCorrelationID() returns string? | error {
        handle|error val = getJMSCorrelationID(self.jmsMessage);
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
        return getJMSCorrelationIDAsBytes(self.jmsMessage);
    }

    # Get the message delivery mode.
    #
    # + return - Returns the message delivery mode or an error if it fails.
    public function getJMSDeliveryMode() returns int | error {
        return getJMSDeliveryMode(self.jmsMessage);
    }

    # Get the message delivery time.
    #
    # + return - Returns the message delivery time or an error if it fails.
    public function getJMSDeliveryTime() returns int | error {
        return getJMSDeliveryTime(self.jmsMessage);
    }

    # Get the message destination object.
    #
    # + return - Returns the message destination object or an error if it fails.
    public function getJMSDestination() returns Destination | error {
        handle|error val = getJMSDestination(self.jmsMessage);
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
        return getJMSExpiration(self.jmsMessage);
    }

    # Get the message ID.
    #
    # + return - Returns the message ID or an error if it fails.
    public function getJMSMessageID() returns string? | error {
        handle|error val = getJMSMessageID(self.jmsMessage);
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
        return getJMSPriority(self.jmsMessage);
    }

    # Get an indication whether the message being redelivered.
    #
    # + return - Returns the message redelivered or an error if it fails.
    public function getJMSRedelivered() returns boolean | error {
        return getJMSRedelivered(self.jmsMessage);
    }

    # Get the Destination object to which a reply to this message should be sent.
    #
    # + return - Returns the reply to destination or an error if it fails.
    public function getJMSReplyTo() returns Destination | error {
        handle|error val = getJMSReplyTo(self.jmsMessage);
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
        return getJMSTimestamp(self.jmsMessage);
    }

    # Get the message type identifier.
    #
    # + return - Returns the message type or an error if it fails.
    public function getJMSType() returns string? | error {
        handle|error val = getJMSType(self.jmsMessage);
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
        return getLongProperty(self.jmsMessage, java:fromString(name));
    }

    # Get string array of property names.
    #
    # + return - Returns the string array of property names or an error if it fails.
    public function getPropertyNames() returns string[] | error {
        return getPropertyNames(self.jmsMessage);
    }

    # Get the given short property.
    #
    # + name - The name of the short property
    # + return - Returns the int value or an error if it fails.
    public function getShortProperty(string name) returns int | error {
        return getShortProperty(self.jmsMessage, java:fromString(name));
    }

    # Get the given string property.
    #
    # + name - The name of the string property
    # + return - Returns the string value or an error if it fails.
    public function getStringProperty(string name) returns string? | error {
        handle|error val = getStringProperty(self.jmsMessage, java:fromString(name));
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
        return propertyExists(self.jmsMessage, java:fromString(name));
    }

    # Set the boolean value with the specified name into the message.
    #
    # + name - The name of the boolean property
    # + value - The boolean property value to set
    # + return - Returns an error if it fails.
    public function setBooleanProperty(string name, boolean value) returns error? {
        return setBooleanProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the byte value with the specified name into the message.
    #
    # + name - The name of the byte property
    # + value - The byte property value to set
    # + return - Returns an error if it fails.
    public function setByteProperty(string name, byte value) returns error? {
        return setByteProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the double value with the specified name into the message.
    #
    # + name - The name of the double property
    # + value - The double property value to set
    # + return - Returns an error if it fails.
    public function setDoubleProperty(string name, float value) returns error? {
        return setDoubleProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the float value with the specified name into the message.
    #
    # + name - The name of the float property
    # + value - The float property value to set
    # + return - Returns an error if it fails.
    public function setFloatProperty(string name, float value) returns error? {
        return setFloatProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the int value with the specified name into the message.
    #
    # + name - The name of the int property
    # + value - The int property value to set
    # + return - Returns an error if it fails.
    public function setIntProperty(string name, int value) returns error? {
        return setIntProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Sets the correlation id for the message.
    # 
    # + correlationId - correlation id of a message as a string
    # + return - Returns an error if it fails.
    public function setJMSCorrelationID(string correlationId) returns error? {
        return setJMSCorrelationID(self.jmsMessage, java:fromString(correlationId));
    }

    # Sets the correlation id an array of bytes for the message.
    # 
    # + correlationId - correlation id value as an array of bytes
    # + return - Returns an error if it fails.
    public function setJMSCorrelationIDAsBytes(byte[] correlationId) returns error? {
        return setJMSCorrelationIDAsBytes(self.jmsMessage, correlationId);
    }

    # Set the reply destination to the message which a reply should send.
    #
    # + replyTo - Destination to which to send a response to this message
    # + return - Returns an error if it fails.
    public function setJMSReplyTo(Destination replyTo) returns error? {
        return setJMSReplyTo(self.jmsMessage, replyTo.getJmsDestination());
    }

    # Set the message type.
    #
    # + jmsType - The message type
    # + return - Returns an error if it fails.
    public function setJMSType(string jmsType) returns error? {
        return setJMSType(self.jmsMessage, java:fromString(jmsType));
    }

    # Set the long value with the specified name into the message.
    #
    # + name - The name of the long property
    # + value - The long property value to set
    # + return - Returns an error if it fails.
    public function setLongProperty(string name, int value) returns error? {
        return setLongProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the short value with the specified name into the message.
    #
    # + name - The name of the short property
    # + value - The short property value to set
    # + return - Returns an error if it fails.
    public function setShortProperty(string name, int value) returns error? {
        return setShortProperty(self.jmsMessage, java:fromString(name), value);
    }

    # Set the string value with the specified name into the message.
    #
    # + name - The name of the string property
    # + value - The string property value to set
    # + return - Returns an error if it fails.
    public function setStringProperty(string name, string value) returns error? {
        return setStringProperty(self.jmsMessage, java:fromString(name), java:fromString(value));
    }

    # Get the JMS map message
    #
    # + return - Returns the java reference to the jms map message
    function getJmsMessage() returns handle {
        return self.jmsMessage;
    }

};

function getBoolean(handle message, handle name) returns boolean | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function getByte(handle message, handle name) returns byte | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function getBytes(handle message, handle name) returns byte[] | error = @java:Method {
    class: "org.ballerinalang.java.jms.JmsMapMessageUtils"
} external;

//function getChar(handle message, handle name) returns int | error = @java:Method {
//    class: "javax.jms.MapMessage"
//} external;

function getDouble(handle message, handle name) returns float | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function getFloat(handle message, handle name) returns float | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function getInt(handle message, handle name) returns int | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function getLong(handle message, handle name) returns int | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function getMapNames(handle message) returns string[] | error {
    return getJmsMapNames(message);
}

function getJmsMapNames(handle message) returns string[] = @java:Method {
    class: "org.ballerinalang.java.jms.JmsMapMessageUtils"
} external;

function getShort(handle message, handle name) returns int | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function getString(handle message, handle name) returns handle | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function itemExists(handle message, handle name) returns boolean | error = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function setBoolean(handle message, handle name, boolean value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function setByte(handle message, handle name, byte value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;

//function setBytes(handle message, handle name, byte[] value) returns error? = @java:Method {
//    class: "javax.jms.MapMessage"
//} external;

//function setPortionOfBytes(handle message, handle name, handle array, int offset, int length) returns error? = @java:Method {
//    name: "setBytes",
//    paramTypes: ["java.lang.String", {class:"byte", dimensions:1}, "int", "int"],
//    class: "javax.jms.MapMessage"
//} external;

//function setChar(handle message, handle name, handle value) returns error? = @java:Method {
//    class: "javax.jms.MapMessage"
//} external;

function setDouble(handle message, handle name, float value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function setFloat(handle message, handle name, float value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function setInt(handle message, handle name, int value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function setLong(handle message, handle name, int value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function setShort(handle message, handle name, int value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;

function setString(handle message, handle name, handle value) returns error? = @java:Method {
    class: "javax.jms.MapMessage"
} external;
