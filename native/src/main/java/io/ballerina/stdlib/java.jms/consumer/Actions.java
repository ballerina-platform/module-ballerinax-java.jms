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

package io.ballerina.stdlib.java.jms.consumer;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.java.jms.BallerinaJmsException;
import io.ballerina.stdlib.java.jms.MessageConverter;
import io.ballerina.stdlib.java.jms.Util;

import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Session;
import javax.jms.Topic;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.CommonUtils.getDestination;
import static io.ballerina.stdlib.java.jms.CommonUtils.getOptionalStringProperty;
import static io.ballerina.stdlib.java.jms.Constants.DESTINATION;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_CONSUMER;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_MESSAGE;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_SESSION;

/**
 * Represents {@link javax.jms.MessageConsumer} related utility functions.
 */
public class Actions {
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
     * @param consumer        Ballerina consumer object
     * @param session         Ballerina session object
     * @param consumerOptions JMS MessageConsumer configurations
     * @return A Ballerina `jms:Error` if the JMS provider fails to create the MessageConsumer due to some
     * internal error
     */
    public static Object init(BObject consumer, BObject session, BMap<BString, Object> consumerOptions) {
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            MessageConsumer jmsConsumer = createConsumer(nativeSession, consumerOptions);
            consumer.addNativeData(NATIVE_CONSUMER, jmsConsumer);
        } catch (BallerinaJmsException exception) {
            return createError(JMS_ERROR, exception.getMessage(), exception);
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while initializing the JMS MessageConsumer: %s",
                            exception.getMessage()), exception);
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
     * @param env Ballerina runtime environment
     * @param consumer Ballerina consumer object
     * @param timeout  The timeout value (in milliseconds)
     * @return A Ballerina `jms:Error` if the JMS MessageConsumer fails to receive the message due to some error
     * or else the next message produced for this message consumer, or null
     */
    public static Object receive(Environment env, BObject consumer, long timeout) {
        MessageConsumer nativeConsumer = (MessageConsumer) consumer.getNativeData(NATIVE_CONSUMER);
        CompletableFuture<Object> balFuture = new CompletableFuture<>();
        Thread.startVirtualThread(() -> {
            try {
                Message message = nativeConsumer.receive(timeout);
                if (Objects.isNull(message)) {
                    balFuture.complete(null);
                } else {
                    BMap<BString, Object> ballerinaMsg = MessageConverter.convertToBMessage(message);
                    balFuture.complete(ballerinaMsg);
                }
            } catch (JMSException exception) {
                BError bError = createError(JMS_ERROR,
                        String.format("Error occurred while receiving messages: %s", exception.getMessage()),
                        exception);
                balFuture.complete(bError);
            } catch (BallerinaJmsException exception) {
                balFuture.complete(createError(JMS_ERROR, exception.getMessage(), exception));
            } catch (Exception exception) {
                BError bError = createError(JMS_ERROR,
                        String.format("Unknown error occurred while processing the received messages: %s",
                                exception.getMessage()), exception);
                balFuture.complete(bError);
            }
        });
        return Util.getResult(balFuture);
    }

    /**
     * Receives the next message if one is immediately available.
     *
     * @param env Ballerina runtime environment
     * @param consumer Ballerina consumer object
     * @return A Ballerina `jms:Error` if the JMS MessageConsumer fails to receive the message due to some error
     * or else the next message produced for this message consumer, or null
     */
    public static Object receiveNoWait(Environment env, BObject consumer) {
        MessageConsumer nativeConsumer = (MessageConsumer) consumer.getNativeData(NATIVE_CONSUMER);
        CompletableFuture<Object> balFuture = new CompletableFuture<>();
        Thread.startVirtualThread(() -> {
            try {
                Message message = nativeConsumer.receiveNoWait();
                if (Objects.isNull(message)) {
                    balFuture.complete(null);
                } else {
                    BMap<BString, Object> ballerinaMsg = MessageConverter.convertToBMessage(message);
                    balFuture.complete(ballerinaMsg);
                }
            } catch (JMSException exception) {
                BError bError = createError(JMS_ERROR,
                        String.format("Error occurred while receiving messages: %s", exception.getMessage()),
                        exception);
                balFuture.complete(bError);
            } catch (BallerinaJmsException exception) {
                balFuture.complete(createError(JMS_ERROR, exception.getMessage(), exception));
            } catch (Exception exception) {
                BError bError = createError(JMS_ERROR,
                        String.format("Unknown error occurred while processing the received messages: %s",
                                exception.getMessage()), exception);
                balFuture.complete(bError);
            }
        });
        return Util.getResult(balFuture);
    }

    /**
     * Closes the message consumer.
     *
     * @param consumer Ballerina consumer object
     * @return A Ballerina `jms:Error` if the JMS provider fails to close the consumer due to some internal error
     */
    public static Object close(BObject consumer) {
        MessageConsumer nativeConsumer = (MessageConsumer) consumer.getNativeData(NATIVE_CONSUMER);
        try {
            nativeConsumer.close();
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while closing the message consumer: %s", exception.getMessage()),
                    exception);
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
            Object nativeMessage = message.getNativeData(NATIVE_MESSAGE);
            if (Objects.nonNull(nativeMessage)) {
                ((Message) nativeMessage).acknowledge();
            }
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while sending acknowledgement for the message: %s",
                            exception.getMessage()), exception);
        }
        return null;
    }
}
