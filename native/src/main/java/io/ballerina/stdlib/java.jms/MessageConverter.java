/*
 * Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.java.jms;

import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Enumeration;
import java.util.Iterator;
import java.util.Objects;

import javax.jms.BytesMessage;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.Session;
import javax.jms.TextMessage;

import static io.ballerina.stdlib.java.jms.Constants.NATIVE_MESSAGE;

/**
 * {@code MessageConverter} contains the utility functions to convert JMS messages to ballerina messages and backwards.
 *
 * @since 1.2.0
 */
public final class MessageConverter {
    private static final BString MESSAGE_ID = StringUtils.fromString("messageId");
    private static final BString TIMESTAMP = StringUtils.fromString("timestamp");
    private static final BString CORRELATION_ID = StringUtils.fromString("correlationId");
    private static final BString REPLY_TO = StringUtils.fromString("replyTo");
    private static final BString DESTINATION = StringUtils.fromString("destination");
    private static final BString DELIVERY_MODE = StringUtils.fromString("deliveryMode");
    private static final BString REDELIVERED = StringUtils.fromString("redelivered");
    private static final BString JMS_TYPE = StringUtils.fromString("jmsType");
    private static final BString EXPIRATION = StringUtils.fromString("expiration");
    private static final BString DELIVERED_TIME = StringUtils.fromString("deliveredTime");
    private static final BString PRIORITY = StringUtils.fromString("priority");
    private static final BString PROPERTIES = StringUtils.fromString("properties");
    private static final BString CONTENT = StringUtils.fromString("content");


    private MessageConverter() {
    }

    public static Message convertFromBMessage(Session session, BMap<BString, Object> bMessage)
            throws BallerinaJmsException, JMSException {
        Object content = bMessage.get(CONTENT);
        Message message = getJmsMessage(session, content);
        if (bMessage.containsKey(CORRELATION_ID)) {
            BString correlationId = bMessage.getStringValue(CORRELATION_ID);
            message.setJMSCorrelationID(correlationId.getValue());
        }
        if (bMessage.containsKey(REPLY_TO)) {
            BMap<BString, Object> replyTo = (BMap<BString, Object>) bMessage.getMapValue(REPLY_TO);
            Destination replyDestination = CommonUtils.getDestination(session, replyTo);
            message.setJMSReplyTo(replyDestination);
        }
        if (bMessage.containsKey(JMS_TYPE)) {
            BString jmsType = bMessage.getStringValue(JMS_TYPE);
            message.setJMSType(jmsType.getValue());
        }
        if (bMessage.containsKey(PROPERTIES)) {
            BMap<BString, Object> properties = (BMap<BString, Object>) bMessage.getMapValue(PROPERTIES);
            for (BString key: properties.getKeys()) {
                Object value = properties.get(key);
                if (value instanceof Long longValue) {
                    message.setLongProperty(key.getValue(), longValue);
                } else if (value instanceof Boolean booleanValue) {
                    message.setBooleanProperty(key.getValue(), booleanValue);
                } else if (value instanceof Byte byteValue) {
                    message.setByteProperty(key.getValue(), byteValue);
                } else if (value instanceof Double doubleValue) {
                    message.setDoubleProperty(key.getValue(), doubleValue);
                } else if (value instanceof BString stringValue) {
                    message.setStringProperty(key.getValue(), stringValue.getValue());
                }
            }
        }
        return message;
    }

    private static Message getJmsMessage(Session session, Object content) throws JMSException {
        if (content instanceof BString stringContent) {
            TextMessage message = session.createTextMessage();
            message.setText(stringContent.getValue());
            return message;
        } else if (content instanceof BMap) {
            MapMessage message = session.createMapMessage();
            BMap<BString, Object> mapValue = (BMap<BString, Object>) content;
            for (BString key: mapValue.getKeys()) {
                Object value = mapValue.get(key);
                if (value instanceof Long longValue) {
                    message.setLong(key.getValue(), longValue);
                } else if (value instanceof Boolean booleanValue) {
                    message.setBoolean(key.getValue(), booleanValue);
                } else if (value instanceof Byte byteValue) {
                    message.setByte(key.getValue(), byteValue);
                } else if (value instanceof BArray bytesValue) {
                    message.setBytes(key.getValue(), bytesValue.getBytes());
                } else if (value instanceof Double doubleValue) {
                    message.setDouble(key.getValue(), doubleValue);
                } else if (value instanceof BString stringValue) {
                    message.setString(key.getValue(), stringValue.getValue());
                }
            }
            return message;
        } else {
            BArray bytesContent = (BArray) content;
            BytesMessage message = session.createBytesMessage();
            message.writeBytes(bytesContent.getBytes());
            return message;
        }
    }

    public static BMap<BString, Object> convertToBMessage(Message message) throws JMSException, BallerinaJmsException {
        BMap<BString, Object> ballerinaMessage = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                Constants.MESSAGE_BAL_RECORD_NAME);
        ballerinaMessage.put(MESSAGE_ID, StringUtils.fromString(message.getJMSMessageID()));
        ballerinaMessage.put(TIMESTAMP, message.getJMSTimestamp());
        if (Objects.nonNull(message.getJMSCorrelationID())) {
            ballerinaMessage.put(CORRELATION_ID, StringUtils.fromString(message.getJMSCorrelationID()));
        }
        if (Objects.nonNull(message.getJMSReplyTo())) {
            ballerinaMessage.put(REPLY_TO, CommonUtils.getJmsDestinationField(message.getJMSReplyTo()));
        }
        if (Objects.nonNull(message.getJMSDestination())) {
            ballerinaMessage.put(DESTINATION, CommonUtils.getJmsDestinationField(message.getJMSDestination()));
        }
        ballerinaMessage.put(DELIVERY_MODE, message.getJMSDeliveryMode());
        ballerinaMessage.put(REDELIVERED, message.getJMSRedelivered());
        if (Objects.nonNull(message.getJMSType())) {
            ballerinaMessage.put(JMS_TYPE, StringUtils.fromString(message.getJMSType()));
        }
        ballerinaMessage.put(EXPIRATION, message.getJMSExpiration());
        try {
            ballerinaMessage.put(DELIVERED_TIME, message.getJMSDeliveryTime());
        } catch (UnsupportedOperationException e) {
            // This exception occurs when the client connect to a JMS provider who supports JMS 1.x.
            // Hence, ignoring this exception.
        }
        ballerinaMessage.put(PRIORITY, message.getJMSPriority());
        ballerinaMessage.put(PROPERTIES, getMessageProperties(message));
        Object content = getMessageContent(message);
        ballerinaMessage.put(CONTENT, content);
        ballerinaMessage.addNativeData(NATIVE_MESSAGE, message);
        return ballerinaMessage;
    }

    @SuppressWarnings("unchecked")
    private static BMap<BString, Object> getMessageProperties(Message message)
            throws JMSException, BallerinaJmsException {
        UnionType unionType = TypeCreator.createUnionType(
                PredefinedTypes.TYPE_BOOLEAN, PredefinedTypes.TYPE_INT, PredefinedTypes.TYPE_BYTE,
                PredefinedTypes.TYPE_FLOAT, PredefinedTypes.TYPE_STRING);
        MapType mapType = TypeCreator.createMapType("PropertyType", unionType, ModuleUtils.getModule());
        BMap<BString, Object> messageProperties = ValueCreator.createMapValue(mapType);
        Enumeration<String> propertyNames = message.getPropertyNames();
        Iterator<String> iterator = propertyNames.asIterator();
        while (iterator.hasNext()) {
            String key = iterator.next();
            Object value = message.getObjectProperty(key);
            messageProperties.put(StringUtils.fromString(key), getMapValue(value));
        }
        return messageProperties;
    }

    @SuppressWarnings("unchecked")
    private static Object getMessageContent(Message message) throws JMSException, BallerinaJmsException {
        if (message instanceof TextMessage) {
            return StringUtils.fromString(((TextMessage) message).getText());
        } else if (message instanceof MapMessage mapMessage) {
            ArrayType byteArrType = TypeCreator.createArrayType(PredefinedTypes.TYPE_BYTE);
            UnionType unionType = TypeCreator.createUnionType(
                    PredefinedTypes.TYPE_BOOLEAN, PredefinedTypes.TYPE_INT, PredefinedTypes.TYPE_BYTE,
                    PredefinedTypes.TYPE_FLOAT, PredefinedTypes.TYPE_STRING, byteArrType);
            MapType mapType = TypeCreator.createMapType("ValueType", unionType, ModuleUtils.getModule());
            BMap<BString, Object> content = ValueCreator.createMapValue(mapType);
            Enumeration<String> mapNames = mapMessage.getMapNames();
            Iterator<String> iterator = mapNames.asIterator();
            while (iterator.hasNext()) {
                String key = iterator.next();
                Object value = mapMessage.getObject(key);
                content.put(StringUtils.fromString(key), getMapValue(value));
            }
            return content;
        } else if (message instanceof BytesMessage) {
            long bodyLength = ((BytesMessage) message).getBodyLength();
            byte[] payload = new byte[(int) bodyLength];
            ((BytesMessage) message).readBytes(payload);
            return ValueCreator.createArrayValue(payload);
        }
        throw new BallerinaJmsException(
                String.format("Unsupported message type: %s", message.getClass().getTypeName()));
    }

    private static Object getMapValue(Object value) throws BallerinaJmsException {
        if (isPrimitive(value)) {
            Type type = TypeUtils.getType(value);
            return ValueUtils.convert(value, type);
        }
        if (value instanceof String) {
            return StringUtils.fromString((String) value);
        }
        if (value instanceof byte[]) {
            return ValueCreator.createArrayValue((byte[]) value);
        }
        throw new BallerinaJmsException(
                String.format("Unidentified map value type: %s", value.getClass().getTypeName()));
    }

    private static boolean isPrimitive(Object value) {
        return value instanceof Boolean || value instanceof Byte || value instanceof Character ||
                value instanceof Integer || value instanceof Long || value instanceof Float || value instanceof Double;
    }
}
