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
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import java.util.Objects;
import java.util.Optional;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Session;
import javax.jms.Topic;

import static io.ballerina.stdlib.java.jms.CommonUtils.getBallerinaMessage;
import static io.ballerina.stdlib.java.jms.CommonUtils.getDestination;
import static io.ballerina.stdlib.java.jms.CommonUtils.getOptionalStringProperty;
import static io.ballerina.stdlib.java.jms.Constants.DESTINATION;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_CONSUMER;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_SESSION;

/**
 * Represents {@link javax.jms.MessageConsumer} related utility functions.
 */
public class JmsConsumer {
    private static final BString CONSUMER_TYPE = StringUtils.fromString("type");
    private static final BString MESSAGE_SELECTOR = StringUtils.fromString("messageSelector");
    private static final BString NO_LOCAL = StringUtils.fromString("noLocal");
    private static final BString SUBSCRIBER_NAME = StringUtils.fromString("subscriberName");
    private static final String DURABLE = "DURABLE";
    private static final String SHARED = "SHARED";
    private static final String SHARED_DURABLE = "SHARED_DURABLE";
    private static final String DEFAULT = "DEFAULT";

    /**
     * Creates a {@link javax.jms.MessageConsumer} object with given {@link javax.jms.Session}.
     *
     * @param consumer Ballerina consumer object
     * @param session Ballerina session object
     * @param consumerOptions JMS MessageConsumer configurations
     * @return A Ballerina `jms:Error` if the JMS provider fails to create the MessageConsumer due to some
     * internal error
     */
    public static Object init(BObject consumer, BObject session, BMap<BString, Object> consumerOptions) {
        Object nativeSession = session.getNativeData(NATIVE_SESSION);
        if (Objects.isNull(nativeSession)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS session"), null, null);
        }
        Session jmsSession = (Session) nativeSession;
        try {
            MessageConsumer jmsConsumer = createConsumer((Session) jmsSession, consumerOptions);
            consumer.addNativeData(NATIVE_CONSUMER, jmsConsumer);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString(exception.getMessage()), cause, null);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while initializing the JMS MessageConsumer"),
                    cause, null);
        }
        return null;
    }

    private static MessageConsumer createConsumer(Session session, BMap<BString, Object> consumerOptions)
            throws BallerinaJmsException, JMSException {
        BMap<BString, Object> destination = (BMap<BString, Object>) consumerOptions.getMapValue(DESTINATION);
        Destination jmsDestination = getDestination(session, destination);
        String consumerType = consumerOptions.getStringValue(CONSUMER_TYPE).getValue();
        String messageSelector = consumerOptions.getStringValue(MESSAGE_SELECTOR).getValue();
        boolean noLocal = consumerOptions.getBooleanValue(NO_LOCAL);
        Optional<String> subscriberNameOpt = getOptionalStringProperty(consumerOptions, SUBSCRIBER_NAME);
        if (!DEFAULT.equals(consumerType)) {
            if (subscriberNameOpt.isEmpty()) {
                throw new BallerinaJmsException(
                        String.format("Subscriber name cannot be empty for consumer type: %s", consumerType)
                );
            }
        }

        if (DEFAULT.equals(consumerType)) {
            return session.createConsumer(jmsDestination, messageSelector, noLocal);
        } else if (DURABLE.equals(consumerType)) {
            return session.createDurableSubscriber(
                    (Topic) jmsDestination, subscriberNameOpt.get(), messageSelector, noLocal);
        } else if (SHARED.equals(consumerType)) {
            return session.createSharedConsumer((Topic) jmsDestination, subscriberNameOpt.get(), messageSelector);
        } else {
            return session.createSharedDurableConsumer(
                    (Topic) jmsDestination, subscriberNameOpt.get(), messageSelector);
        }
    }

    /**
     * Receives the next message that arrives within the specified timeout interval.
     *
     * @param consumer Ballerina consumer object
     * @param timeout The timeout value (in milliseconds)
     * @return A Ballerina `jms:Error` if the JMS MessageConsumer fails to receive the message due to some error
     * or else the next message produced for this message consumer, or null
     */
    public static Object receive(BObject consumer, long timeout) {
        Object nativeConsumer = consumer.getNativeData(NATIVE_CONSUMER);
        if (Objects.isNull(nativeConsumer)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS MessageConsumer"),
                    null, null);
        }
        try {
            Message message = ((MessageConsumer) nativeConsumer).receive(timeout);
            if (Objects.isNull(message)) {
                return null;
            }
            return getBallerinaMessage(message);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while receiving messages"), cause, null);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while processing the received messages"),
                    cause, null);
        } catch (Exception exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Unknown error occurred while processing the received messages"),
                    cause, null);
        }
    }

    /**
     * Receives the next message if one is immediately available.
     *
     * @param consumer Ballerina consumer object
     * @return A Ballerina `jms:Error` if the JMS MessageConsumer fails to receive the message due to some error
     * or else the next message produced for this message consumer, or null
     */
    public static Object receiveNoWait(BObject consumer) {
        Object nativeConsumer = consumer.getNativeData(NATIVE_CONSUMER);
        if (Objects.isNull(nativeConsumer)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS MessageConsumer"),
                    null, null);
        }
        try {
            Message message = ((MessageConsumer) nativeConsumer).receiveNoWait();
            if (Objects.isNull(message)) {
                return null;
            }
            return getBallerinaMessage(message);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while receiving messages"), cause, null);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while processing the received messages"),
                    cause, null);
        } catch (Exception exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Unknown error occurred while processing the received messages"),
                    cause, null);
        }
    }

    /**
     * Closes the message consumer.
     *
     * @param consumer Ballerina consumer object
     * @return A Ballerina `jms:Error` if the JMS provider fails to close the consumer due to some internal error
     */
    public static Object close(BObject consumer) {
        Object nativeConsumer = consumer.getNativeData(NATIVE_CONSUMER);
        if (Objects.isNull(nativeConsumer)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS MessageConsumer"),
                    null, null);
        }
        try {
            ((MessageConsumer) nativeConsumer).close();
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while closing the message consumer"), cause, null);
        }
        return null;
    }

    /**
     * Acknowledges all consumed messages of the session of this consumed message.
     *
     * @param message Ballerina JMS message
     * @return A Ballerina `jms:Error` if the JMS provider fails to acknowledge the messages due to some internal error.
     */
    public static Object acknowledge(BMap<BString, Object> message) {
        try {
            Object nativeMessage = message.getNativeData(Constants.NATIVE_MESSAGE);
            if (Objects.nonNull(nativeMessage)) {
                ((Message) nativeMessage).acknowledge();
            }
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString(
                            String.format("Error occurred while sending acknowledgement for the message: %s",
                                    exception.getMessage())),
                    cause, null);
        }
        return null;
    }
}
