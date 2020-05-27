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

# Represent the 'BytesMessage' used to send and receive content from the a JMS provider.
#
# Most message-oriented middleware (MOM) products treat messages as lightweight entities that consist of a header
# and a body. The header contains fields used for message routing and identification; the body contains the
# application data being sent.
public type BytesMessage client object {

    // Add a reference to the `AbstractMessage` object type.
    *AbstractMessage;

    # Initialized a `BytesMessage` object.
    #
    # + handle - The java reference to the jms text message.
    function __init(handle bytesMessage) {
        self.jmsMessage = bytesMessage;
    }

    # Get the number of bytes of the message body.
    #
    # + return - Returns the body length or an error if it fails.
    public function getBodyLength() returns int | error {
        return getBodyLength(self.jmsMessage);
    }

    # Read a boolean from the message.
    #
    # + return - Returns a boolean value or an error if it fails.
    public function readBoolean() returns boolean | error {
        return readBoolean(self.jmsMessage);
    }

    # Read a byte from the message.
    #
    # + return - Returns a byte value or an error if it fails.
    public function readByte() returns byte | error {
        return readByte(self.jmsMessage);
    }

    # Read a byte array from the message.
    #
    # + length - The number of bytes to read
    # + return - Returns a byte array or an error if it fails.
    public function readBytes(int? length = ()) returns byte[] | error {
        if(length is int) {
            return readPortionOfBytes(self.jmsMessage, length);
        } else {
            return readBytes(self.jmsMessage);
        }
    }

//    # Read a unicode character value from the message.
//    #
//    # + return - Returns a string value or an error if it fails.
//    public function readChar() returns string | error {
//        returns readChar(self.jmsMessage);
//    }

    # Read a double value from the message.
    #
    # + return - Returns a double value or an error if it fails.
    public function readDouble() returns float | error {
        return readDouble(self.jmsMessage);
    }

    # Read a float value from the message.
    #
    # + return - Returns a float value or an error if it fails.
    public function readFloat() returns float | error {
        return readFloat(self.jmsMessage);
    }

    # Read an int value from the message.
    #
    # + return - Returns an int value or an error if it fails.
    public function readInt() returns int | error {
        return readInt(self.jmsMessage);
    }

    # Read a long value from the message.
    #
    # + return - Returns a long value or an error if it fails.
    public function readLong() returns int | error {
        return readLong(self.jmsMessage);
    }

    # Read a short value from the message.
    #
    # + return - Returns a short value or an error if it fails.
    public function readShort() returns int | error {
        return readShort(self.jmsMessage);
    }

    # Read an unsigned 8-bit number from the message.
    #
    # + return - Returns a int value or an error if it fails.
    public function readUnsignedByte() returns int | error {
        return readUnsignedByte(self.jmsMessage);
    }

    # Read an unsigned 16-bit number from the message.
    #
    # + return - Returns a int value or an error if it fails.
    public function readUnsignedShort() returns int | error {
        return readUnsignedShort(self.jmsMessage);
    }

    # Read a string that has been encoded using a modified UTF-8 format from the message.
    #
    # + return - Returns a string value or an error if it fails.
    public function readUTF() returns string? | error {
        handle|error val = readUTF(self.jmsMessage);
        if (val is handle) {
            return java:toString(val);
        } else {
            return val;
        }
    }

    # Puts the message body in read-only mode and repositions the stream of bytes to the beginning.
    #
    # + return - Returns an error if it fails.
    public function reset() returns error? {
        return reset(self.jmsMessage);
    }

    # Write a boolean to the message stream as a 1-byte value.
    #
    # + value - The boolean value to be written
    # + return - Returns an error if it fails.
    public function writeBoolean(boolean value) returns error? {
        return writeBoolean(self.jmsMessage, value);
    }

    # Write a byte to the message.
    #
    # + value - The byte value to be written
    # + return - Returns an error if it fails.
    public function writeByte(byte value) returns error? {
        return writeByte(self.jmsMessage, value);
    }

    # Write a byte array to the message.
    #
    # + value - The byte array to be written
    # + offset - The initial offset within the byte array
    # + length - The number of bytes to use
    # + return - Returns an error if it fails.
    public function writeBytes(byte[] value, int? offset = (), int? length = ()) returns error? {
        if(offset is int && length is int) {
            return writePortionOfBytes(self.jmsMessage, value, offset, length);
        } else {
            return writeBytes(self.jmsMessage, value);
        }
    }

//    # Write a char to the message.
//    #
//    # + return - Returns an error if it fails.
//    public function writeChar(string value) returns error? {
//        return writeChar(self.jmsMessage, java:fromString(value));
//    }

    # Write a double to the message.
    #
    # + value - The double value to be written
    # + return - Returns an error if it fails.
    public function writeDouble(float value) returns error? {
        return writeDouble(self.jmsMessage, value);
    }

    # Write a float to the message.
    #
    # + value - The float value to be written
    # + return - Returns an error if it fails.
    public function writeFloat(float value) returns error? {
        return writeFloat(self.jmsMessage, value);
    }

    # Write an int to the message.
    #
    # + value - The int value to be written
    # + return - Returns an error if it fails.
    public function writeInt(int value) returns error? {
        return writeInt(self.jmsMessage, value);
    }

    # Write a long to the message.
    #
    # + value - The long value to be written
    # + return - Returns an error if it fails.
    public function writeLong(int value) returns error? {
        return writeLong(self.jmsMessage, value);
    }

    # Write a short to the message.
    #
    # + value - The short value to be written
    # + return - Returns an error if it fails.
    public function writeShort(int value) returns error? {
        return writeShort(self.jmsMessage, value);
    }

    # Write a string to the message.
    #
    # + value - The string value to be written
    # + return - Returns an error if it fails.
    public function writeUTF(string value) returns error? {
        return writeUTF(self.jmsMessage, java:fromString(value));
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

    # Get the JMS bytes message
    #
    # + return - Returns the java reference to the jms bytes message
    function getJmsMessage() returns handle {
        return self.jmsMessage;
    }

};

function getBodyLength(handle message) returns int | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readBoolean(handle message) returns boolean | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readByte(handle message) returns byte | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readBytes(handle message) returns byte[] | error {
    return trap readJavaBytes(message);
}

function readJavaBytes(handle message) returns byte[] = @java:Method {
    class: "org.ballerinalang.java.jms.JmsBytesMessageUtils"
} external;

function readPortionOfBytes(handle message, int length) returns byte[] | error {
    return trap readPortionOfJavaBytes(message, length);
}

function readPortionOfJavaBytes(handle message, int length) returns byte[] = @java:Method {
    class: "org.ballerinalang.java.jms.JmsBytesMessageUtils"
} external;

//function readChar(handle message) returns int | error = @java:Method {
//    class: "javax.jms.BytesMessage"
//} external;

function readDouble(handle message) returns float | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readFloat(handle message) returns float | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readInt(handle message) returns int | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readLong(handle message) returns int | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readShort(handle message) returns int | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readUnsignedByte(handle message) returns int | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readUnsignedShort(handle message) returns int | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function readUTF(handle message) returns handle | error = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function reset(handle message) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeBoolean(handle message, boolean value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeByte(handle message, byte value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeBytes(handle message, byte[] value) returns error? = @java:Method {
    class: "org.ballerinalang.java.jms.JmsBytesMessageUtils"
} external;

function writePortionOfBytes(handle message, byte[] value, int offset, int length) returns error? = @java:Method {
    class: "org.ballerinalang.java.jms.JmsBytesMessageUtils"
} external;

//function writeChar(handle message, handle value) returns error? = @java:Method {
//    class: "javax.jms.BytesMessage"
//} external;

function writeDouble(handle message, float value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeFloat(handle message, float value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeInt(handle message, int value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeLong(handle message, int value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeShort(handle message, int value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;

function writeUTF(handle message, handle value) returns error? = @java:Method {
    class: "javax.jms.BytesMessage"
} external;
