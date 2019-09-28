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

# The abstract message object is the root of all message objects. It defines message headers, properties, and
# acknowledge methods used for all message objects.
#
# Most message-oriented middleware (MOM) products treat messages as lightweight entities that consist of a header
# and a body. The header contains fields used for message routing and identification; the body contains the
# application data being sent.
public type AbstractMessage abstract client object {

    handle jmsMessage;

    public remote function acknowledge() returns error?;

    public function clearBody() returns error?;

    public function clearProperties() returns error?;

    public function getBooleanProperty(string name) returns boolean | error;

    public function getByteProperty(string name) returns byte | error;

    public function getDoubleProperty(string name) returns float | error;

    public function getFloatProperty(string name) returns float | error;

    public function getIntProperty(string name) returns int | error;

    public function getJMSCorrelationID() returns string | error;

    public function getJMSCorrelationIDAsBytes() returns byte[] | error;

    public function getJMSDeliveryMode() returns int | error;

    public function getJMSDeliveryTime() returns int | error;

    public function getJMSDestination() returns Destination | error;

    public function getJMSExpiration() returns int | error;

    public function getJMSMessageID() returns string | error;

    public function getJMSPriority() returns int | error;

    public function getJMSRedelivered() returns boolean | error;

    public function getJMSReplyTo() returns Destination | error;

    public function getJMSTimestamp() returns int | error;

    public function getJMSType() returns string | error;

    public function getLongProperty(string name) returns int | error;

    public function getPropertyNames() returns string[] | error;

    public function getShortProperty(string name) returns int | error;

    public function getStringProperty(string name) returns string | error;

    public function propertyExists(string name) returns boolean | error;

    public function setBooleanProperty(string name, boolean value) returns error?;

    public function setByteProperty(string name, byte value) returns error?;

    public function setDoubleProperty(string name, float value) returns error?;

    public function setFloatProperty(string name, float value) returns error?;

    public function setIntProperty(string name, int value) returns error?;

    public function setJMSCorrelationID(string correlationId) returns error?;

    public function setJMSCorrelationIDAsBytes(byte[] correlationId) returns error?;

    public function setJMSReplyTo(Destination replyTo) returns error?;

    public function setJMSType(string jmsType) returns error?;

    public function setLongProperty(string name, int value) returns error?;

    public function setShortProperty(string name, int value) returns error?;

    public function setStringProperty(string name, string value) returns error?;

    function getJmsMessage() returns handle;

};
