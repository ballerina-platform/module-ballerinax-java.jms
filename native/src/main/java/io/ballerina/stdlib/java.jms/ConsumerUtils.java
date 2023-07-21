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

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.TextMessage;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Objects;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 * Represents {@code javax.jms.MessageConsumer} related utility functions.
 */
public class ConsumerUtils {
    public static Object receive(MessageConsumer consumer, long timeout) {
        try {
            Message message = consumer.receive(timeout);
            if (Objects.isNull(message)) {
                return null;
            }
            return getBallerinaMessage(message);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while receiving messages"), cause, null);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while processing the received messages"),
                    cause, null);
        } catch (Exception exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Unknown error occurred while processing the received messages"),
                    cause, null);
        }
    }

    public static Object receiveNoWait(MessageConsumer consumer) {
        try {
            Message message = consumer.receiveNoWait();
            if (Objects.isNull(message)) {
                return null;
            }
            return getBallerinaMessage(message);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while receiving messages"), cause, null);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while processing the received messages"),
                    cause, null);
        } catch (Exception exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Unknown error occurred while processing the received messages"),
                    cause, null);
        }
    }

    public static Object acknowledge(BMap<BString, Object> message) {
        try {
            Object nativeMessage = message.getNativeData(Constants.NATIVE_MESSAGE);
            if (Objects.nonNull(nativeMessage)) {
                ((Message) nativeMessage).acknowledge();
            }
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while sending acknowledgement for the message"),
                    cause, null);
        }
        return null;
    }

    private static BMap<BString, Object> getBallerinaMessage(Message message)
            throws JMSException, BallerinaJmsException {
        String messageType = getMessageType(message);
        BMap<BString, Object> ballerinaMessage = ValueCreator.createRecordValue(ModuleUtils.getModule(), messageType);
        ballerinaMessage.put(StringUtils.fromString("messageId"), StringUtils.fromString(message.getJMSMessageID()));
        ballerinaMessage.put(
                StringUtils.fromString("correlationId"), StringUtils.fromString(message.getJMSCorrelationID()));
        ballerinaMessage.put(StringUtils.fromString("jmsType"), StringUtils.fromString(message.getJMSType()));
        ballerinaMessage.put(StringUtils.fromString("priority"), message.getJMSPriority());
        Object content = getMessageContent(message);
        ballerinaMessage.put(StringUtils.fromString("content"), content);
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

    @SuppressWarnings("unchecked")
    private static Object getMessageContent(Message message) throws JMSException, BallerinaJmsException {
        if (message instanceof TextMessage textMessage) {
            return StringUtils.fromString(textMessage.getText());
        } else if (message instanceof MapMessage mapMessage) {
            BMap<BString, Object> content = ValueCreator.createMapValue();
            Enumeration<String> mapNames = (mapMessage).getMapNames();
            Iterator<String> iterator = mapNames.asIterator();
            if (iterator.hasNext()) {
                String key = iterator.next();
                Object value = mapMessage.getObject(key);
                content.put(StringUtils.fromString(key), getMapValue(value));
            }
            return content;
        } else if (message instanceof BytesMessage bytesMessage) {
            long bodyLength = bytesMessage.getBodyLength();
            byte[] payload = new byte[(int) bodyLength];
            bytesMessage.readBytes(payload);
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
        if (value instanceof String stringValue) {
            return StringUtils.fromString(stringValue);
        }
        if (value instanceof byte[] bytes) {
            return ValueCreator.createArrayValue(bytes);
        }
        throw new BallerinaJmsException(
                String.format("Unidentified map value type: %s", value.getClass().getTypeName()));
    }

    private static boolean isPrimitive(Object value) {
        return value instanceof Boolean || value instanceof Byte || value instanceof Character ||
                value instanceof Integer || value instanceof Long || value instanceof Float || value instanceof Double;
    }
}
