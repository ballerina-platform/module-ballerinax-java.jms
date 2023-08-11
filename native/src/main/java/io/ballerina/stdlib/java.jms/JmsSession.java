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

import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Session;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_CONNECTION;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_SESSION;

/**
 * Representation of {@link javax.jms.Session} with utility methods to invoke as inter-op functions.
 */
public class JmsSession {
    private static final String TEXT = "TEXT";
    private static final String MAP = "MAP";

    /**
     * Creates a {@link javax.jms.Session} object with given {@link javax.jms.Connection}.
     *
     * @param session Ballerina session object
     * @param connection Ballerina connection object
     * @param ackMode Acknowledgment mode
     * @return A Ballerina `jms:Error` if the JMS provider fails to create the connection due to some internal error
     */
    public static Object init(BObject session, BObject connection, BString ackMode) {
        int sessionAckMode = getSessionAckMode(ackMode.getValue());
        try {
            Connection nativeConnection = (Connection) connection.getNativeData(NATIVE_CONNECTION);
            boolean transacted = Session.SESSION_TRANSACTED == sessionAckMode;
            Session jmsSession = nativeConnection.createSession(transacted, sessionAckMode);
            session.addNativeData(NATIVE_SESSION, jmsSession);
        } catch (JMSException e) {
            return createError(JMS_ERROR, String.format("Error while creating session: %s", e.getMessage()), e);
        }
        return null;
    }

    private static int getSessionAckMode(String ackMode) {
        if (Constants.SESSION_TRANSACTED_MODE.equals(ackMode)) {
            return Session.SESSION_TRANSACTED;
        } else if (Constants.AUTO_ACKNOWLEDGE_MODE.equals(ackMode)) {
            return Session.AUTO_ACKNOWLEDGE;
        } else if (Constants.CLIENT_ACKNOWLEDGE_MODE.equals(ackMode)) {
            return Session.CLIENT_ACKNOWLEDGE;
        } else {
            return Session.DUPS_OK_ACKNOWLEDGE;
        }
    }

    /**
     * Unsubscribes a durable subscription that has been created by a client.
     *
     * @param session Ballerina session object
     * @param subscriptionId Subscriber ID
     * @return A Ballerina `jms:Error` if the session fails to unsubscribe to the durable subscription due to some
     * internal error.
     */
    public static Object unsubscribe(BObject session, BString subscriptionId) {
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            nativeSession.unsubscribe(subscriptionId.getValue());
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error while unsubscribing from the subscription session: %s",
                            exception.getMessage()), exception);
        }
        return null;
    }

    /**
     * Creates a JMS message.
     *
     * @param session Ballerina session object
     * @param messageType JMS message type
     * @return {@link javax.jms.Message} or Ballerina `jms:Error` if the JMS provider fails to create this message due
     * to some internal error.
     */
    public static Object createJmsMessage(BObject session, BString messageType) {
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        String jmsMessageType = messageType.getValue();
        try {
            // currently ballerina JMS only support `Text`, `Map` and, `Bytes` message types
            if (TEXT.equals(jmsMessageType)) {
                return nativeSession.createTextMessage();
            } else if (MAP.equals(jmsMessageType)) {
                return nativeSession.createMapMessage();
            } else {
                return nativeSession.createBytesMessage();
            }
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error while creating JMS message: %s", exception.getMessage()), exception);
        }
    }

    /**
     * Commits all messages done in this transaction and releases any locks currently held.
     *
     * @param session Ballerina session object
     * @return {@link javax.jms.Message} or Ballerina `jms:Error` if the session is not using a local transaction or
     * else the JMS provider fails to commit the transaction due to some internal error.
     */
    public static Object commit(BObject session) {
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            nativeSession.commit();
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error while committing the JMS transaction: %s", exception.getMessage()), exception);
        }
        return null;
    }

    /**
     * Rolls back any messages done in this transaction and releases any locks currently held.
     *
     * @param session Ballerina session object
     * @return {@link javax.jms.Message} or Ballerina `jms:Error` if the session is not using a local transaction or
     * else the JMS provider fails to roll back the transaction due to some internal error.
     */
    public static Object rollback(BObject session) {
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            nativeSession.rollback();
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error while rolling back the JMS transaction: %s", exception.getMessage()),
                    exception);
        }
        return null;
    }

    /**
     * Closes the session.
     *
     * @param session Ballerina session object
     * @return {@link javax.jms.Message} or Ballerina `jms:Error` iif the JMS provider fails to close the session due
     * to some internal error.
     */
    public static Object close(BObject session) {
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            nativeSession.close();
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error while closing the JMS session: %s", exception.getMessage()), exception);
        }
        return null;
    }
}
