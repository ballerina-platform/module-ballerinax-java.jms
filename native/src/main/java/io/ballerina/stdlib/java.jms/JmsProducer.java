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

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.CommonUtils.getDestination;
import static io.ballerina.stdlib.java.jms.CommonUtils.getDestinationOrNull;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_PRODUCER;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_SESSION;

/**
 * Representation of {@link javax.jms.MessageProducer} with utility methods to invoke as inter-op functions.
 */
public class JmsProducer {

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
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            Destination jmsDestination = getDestinationOrNull(nativeSession, destination);
            MessageProducer jmsProducer = nativeSession.createProducer(jmsDestination);
            producer.addNativeData(NATIVE_PRODUCER, jmsProducer);
        } catch (BallerinaJmsException exception) {
            return createError(JMS_ERROR, exception.getMessage(), exception);
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while initializing the JMS MessageProducer: %s",
                            exception.getMessage()), exception);
        }
        return null;
    }

    /**
     * Sends a message using the {@code MessageProducer}'s default delivery mode, priority, and time to live.
     *
     * @param producer Ballerina producer object
     * @param message The JMS message
     * @return A Ballerina `jms:Error` if the JMS MessageProducer fails to send the message due to some error
     */
    public static Object send(BObject producer, Message message) {
        MessageProducer nativeProducer = (MessageProducer) producer.getNativeData(NATIVE_PRODUCER);
        try {
            nativeProducer.send(message);
        } catch (UnsupportedOperationException | JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while sending a message to the JMS provider: %s",
                            exception.getMessage()), exception);
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
    public static Object sendTo(BObject producer, BObject session, BMap<BString, Object> destination,
                                Message message) {
        MessageProducer nativeProducer = (MessageProducer) producer.getNativeData(NATIVE_PRODUCER);
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            Destination jmsDestination = getDestination(nativeSession, destination);
            nativeProducer.send(jmsDestination, message);
        } catch (BallerinaJmsException exception) {
            return createError(JMS_ERROR, exception.getMessage(), exception);
        } catch (UnsupportedOperationException | JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while sending a message to the JMS provider: %s",
                            exception.getMessage()), exception);
        }
        return null;
    }

    /**
     * Closes the message producer.
     *
     * @param producer Ballerina producer object
     * @return A Ballerina `jms:Error` if the JMS provider fails to close the producer due to some internal error.
     */
    public static Object close(BObject producer) {
        MessageProducer nativeProducer = (MessageProducer) producer.getNativeData(NATIVE_PRODUCER);
        try {
            nativeProducer.close();
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while closing the message produce: %s", exception.getMessage()),
                    exception);
        }
        return null;
    }
}
