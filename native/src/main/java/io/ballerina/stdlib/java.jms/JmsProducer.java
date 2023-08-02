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
import javax.jms.MessageProducer;
import javax.jms.Session;

import static io.ballerina.stdlib.java.jms.CommonUtils.getOptionalStringProperty;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_PRODUCER;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_SESSION;

/**
 * Representation of {@link javax.jms.MessageProducer} with utility methods to invoke as inter-op functions.
 */
public class JmsProducer {
    private static final BString DESTINATION_TYPE = StringUtils.fromString("type");
    private static final BString DESTINATION_NAME = StringUtils.fromString("name");
    private static final String QUEUE = "QUEUE";
    private static final String TEMPORARY_QUEUE = "TEMPORARY_QUEUE";
    private static final String TOPIC = "TOPIC";

    /**
     * Creates a {@link javax.jms.MessageProducer} object with given {@link javax.jms.Session}.
     *
     * @param producer Ballerina producer object
     * @param session Ballerina session object
     * @param destination Relevant JMS destination
     * @return A Ballerina `jms:Error` if the JMS provider fails to create the MessageProducer due to some
     * internal error
     */
    public static Object init(BObject producer, BObject session, Object destination) {
        Object nativeSession = session.getNativeData(NATIVE_SESSION);
        if (Objects.isNull(nativeSession)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS session"), null, null);
        }
        Session jmsSession = (Session) nativeSession;
        try {
            Destination jmsDestination = getDestination(jmsSession, destination);
            MessageProducer jmsProducer = jmsSession.createProducer(jmsDestination);
            producer.addNativeData(NATIVE_PRODUCER, jmsProducer);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString(exception.getMessage()), cause, null);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while initializing the JMS MessageProducer"),
                    cause, null);
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private static Destination getDestination(Session session, Object destination)
            throws JMSException, BallerinaJmsException {
        if (Objects.isNull(destination)) {
            return null;
        }

        return createJmsDestination(session, (BMap<BString, BObject>) destination);
    }

    private static Destination createJmsDestination(Session session, BMap<BString, BObject> destinationConfig)
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

    /**
     * Sends a message using the {@code MessageProducer}'s default delivery mode, priority, and time to live.
     *
     * @param producer Ballerina producer object
     * @param message The JMS message
     * @return A Ballerina `jms:Error` if the JMS MessageProducer fails to send the message due to some error
     */
    public static Object send(BObject producer, Message message) {
        Object nativeProducer = producer.getNativeData(NATIVE_PRODUCER);
        if (Objects.isNull(nativeProducer)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS MessageProducer"),
                    null, null);
        }
        try {
            ((MessageProducer) nativeProducer).send(message);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while sending a message to the JMS provider"),
                    cause, null);
        }
        return null;
    }

    /**
     * Sends a message to a destination for an unidentified message producer using the {@code MessageProducer}'s
     * default delivery mode, priority, and time to live.
     *
     * @param producer Ballerina producer object
     * @param session Ballerina session object
     * @param destination Relevant JMS destination
     * @param message The JMS message
     * @return A Ballerina `jms:Error` if the JMS MessageProducer fails to send the message due to some error
     */
    public static Object sendTo(BObject producer, BObject session, BMap<BString, BObject> destination,
                                Message message) {
        Object nativeProducer = producer.getNativeData(NATIVE_PRODUCER);
        if (Objects.isNull(nativeProducer)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS MessageProducer"),
                    null, null);
        }
        Object nativeSession = session.getNativeData(NATIVE_SESSION);
        if (Objects.isNull(nativeSession)) {
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Could not find the native JMS session"), null, null);
        }
        try {
            Destination jmsDestination = createJmsDestination((Session) nativeSession, destination);
            ((MessageProducer) nativeProducer).send(jmsDestination, message);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString(exception.getMessage()), cause, null);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while initializing the JMS MessageProducer"),
                    cause, null);
        }
        return null;
    }
}
