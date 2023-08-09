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

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Enumeration;
import java.util.Iterator;
import java.util.Objects;
import java.util.Optional;

import javax.jms.BytesMessage;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.Queue;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;
import javax.jms.TextMessage;
import javax.jms.Topic;

/**
 * {@code CommonUtils} contains the common utility functions for the Ballerina JMS connector.
 */
public class CommonUtils {
    private static final BString DESTINATION_TYPE = StringUtils.fromString("type");
    private static final BString DESTINATION_NAME = StringUtils.fromString("name");
    private static final String QUEUE = "QUEUE";
    private static final String TEMPORARY_QUEUE = "TEMPORARY_QUEUE";
    private static final String TOPIC = "TOPIC";

    public static BError createError(String errorType, String message, Throwable throwable) {
        BError cause = ErrorCreator.createError(throwable);
        return ErrorCreator.createError(
                ModuleUtils.getModule(), errorType, StringUtils.fromString(message), cause, null);
    }

    public static Optional<String> getOptionalStringProperty(BMap<BString, Object> config, BString fieldName) {
        if (config.containsKey(fieldName)) {
            return Optional.of(config.getStringValue(fieldName).getValue());
        }
        return Optional.empty();
    }

    @SuppressWarnings("unchecked")
    public static Destination getDestinationOrNull(Session session, Object destination)
            throws JMSException, BallerinaJmsException {
        if (Objects.isNull(destination)) {
            return null;
        }

        return getDestination(session, (BMap<BString, Object>) destination);
    }

    public static Destination getDestination(Session session, BMap<BString, Object> destinationConfig)
            throws BallerinaJmsException, JMSException {
        String destinationType = destinationConfig.getStringValue(DESTINATION_TYPE).getValue();
        Optional<String> destinationNameOpt = getOptionalStringProperty(destinationConfig, DESTINATION_NAME);
        if (QUEUE.equals(destinationType) || TOPIC.equals(destinationType)) {
            if (destinationNameOpt.isEmpty()) {
                throw new BallerinaJmsException(
                        String.format("JMS destination name can not be empty for destination type: %s", destinationType)
                );
            }
        }
        if (QUEUE.equals(destinationType)) {
            return session.createQueue(destinationNameOpt.get());
        } else if (TEMPORARY_QUEUE.equals(destinationType)) {
            return session.createTemporaryQueue();
        } else if (TOPIC.equals(destinationType)) {
            return session.createTopic(destinationNameOpt.get());
        } else {
            return session.createTemporaryTopic();
        }
    }

    public static BMap<BString, Object> getBallerinaMessage(Message message)
            throws JMSException, BallerinaJmsException {
        String messageType = getMessageType(message);
        BMap<BString, Object> ballerinaMessage = ValueCreator.createRecordValue(ModuleUtils.getModule(), messageType);
        ballerinaMessage.put(Constants.MESSAGE_ID, StringUtils.fromString(message.getJMSMessageID()));
        ballerinaMessage.put(Constants.TIMESTAMP, message.getJMSTimestamp());
        ballerinaMessage.put(Constants.CORRELATION_ID, StringUtils.fromString(message.getJMSCorrelationID()));
        if (Objects.nonNull(message.getJMSReplyTo())) {
            ballerinaMessage.put(Constants.REPLY_TO, getJmsDestinationField(message.getJMSReplyTo()));
        }
        if (Objects.nonNull(message.getJMSDestination())) {
            ballerinaMessage.put(Constants.DESTINATION, getJmsDestinationField(message.getJMSDestination()));
        }
        ballerinaMessage.put(Constants.DELIVERY_MODE, message.getJMSDeliveryMode());
        ballerinaMessage.put(Constants.REDELIVERED, message.getJMSRedelivered());
        ballerinaMessage.put(Constants.JMS_TYPE, StringUtils.fromString(message.getJMSType()));
        ballerinaMessage.put(Constants.EXPIRATION, message.getJMSExpiration());
        ballerinaMessage.put(Constants.DELIVERED_TIME, message.getJMSDeliveryTime());
        ballerinaMessage.put(Constants.PRIORITY, message.getJMSPriority());
        ballerinaMessage.put(Constants.PROPERTIES, getMessageProperties(message));
        Object content = getMessageContent(message);
        ballerinaMessage.put(Constants.CONTENT, content);
        ballerinaMessage.addNativeData(Constants.NATIVE_MESSAGE, message);
        return ballerinaMessage;
    }

    private static String getMessageType(Message message) {
        if (message instanceof TextMessage) {
            return Constants.TEXT_MESSAGE_BAL_RECORD_NAME;
        } else if (message instanceof MapMessage) {
            return Constants.MAP_MESSAGE_BAL_RECORD_NAME;
        } else if (message instanceof BytesMessage) {
            return Constants.BYTE_MESSAGE_BAL_RECORD_NAME;
        } else {
            return Constants.MESSAGE_BAL_RECORD_NAME;
        }
    }

    private static BMap<BString, Object> getJmsDestinationField(Destination destination) throws JMSException {
        BMap<BString, Object> values = ValueCreator.createMapValue();
        if (destination instanceof TemporaryQueue) {
            values.put(DESTINATION_TYPE, Constants.TEMPORARY_QUEUE);
        } else if (destination instanceof Queue) {
            String queueName = ((Queue) destination).getQueueName();
            values.put(DESTINATION_TYPE, Constants.QUEUE);
            values.put(DESTINATION_NAME, StringUtils.fromString(queueName));
        } else if (destination instanceof TemporaryTopic) {
            values.put(DESTINATION_TYPE, Constants.TEMPORARY_TOPIC);
        } else {
            String topicName = ((Topic) destination).getTopicName();
            values.put(DESTINATION_TYPE, Constants.TOPIC);
            values.put(DESTINATION_NAME, StringUtils.fromString(topicName));
        }
        return ValueCreator.createReadonlyRecordValue(ModuleUtils.getModule(), "Destination", values);
    }

    @SuppressWarnings("unchecked")
    private static BMap<BString, Object> getMessageProperties(Message message)
            throws JMSException, BallerinaJmsException {
        BMap<BString, Object> messageProperties = ValueCreator.createMapValue();
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
        } else if (message instanceof MapMessage) {
            BMap<BString, Object> content = ValueCreator.createMapValue();
            Enumeration<String> mapNames = (((MapMessage) message)).getMapNames();
            Iterator<String> iterator = mapNames.asIterator();
            while (iterator.hasNext()) {
                String key = iterator.next();
                Object value = ((MapMessage) message).getObject(key);
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
