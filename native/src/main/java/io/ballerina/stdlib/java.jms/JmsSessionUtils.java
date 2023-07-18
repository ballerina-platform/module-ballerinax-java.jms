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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 * Representation of {@link javax.jms.Session} with utility methods to invoke as inter-op functions.
 */
public class JmsSessionUtils {
    private static final Logger LOGGER = LoggerFactory.getLogger(JmsSessionUtils.class);

    private JmsSessionUtils() {}

    /**
     * Creates a {@link javax.jms.Session} object with given {@link javax.jms.Connection}.
     *
     * @param connection {@link javax.jms.Connection} object
     * @param ackModeString Acknowledgment mode
     * @return {@link javax.jms.Session} object
     * @throws BallerinaJmsException in an error situation
     */
    public static Object createJmsSession(Connection connection, String ackModeString) throws BallerinaJmsException {

        int sessionAckMode;
        boolean transactedSession = false;
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("Session ack mode string: {}", ackModeString);
        }

        switch (ackModeString) {
            case Constants.CLIENT_ACKNOWLEDGE_MODE:
                sessionAckMode = Session.CLIENT_ACKNOWLEDGE;
                break;
            case Constants.SESSION_TRANSACTED_MODE:
                sessionAckMode = Session.SESSION_TRANSACTED;
                transactedSession = true;
                break;
            case Constants.DUPS_OK_ACKNOWLEDGE_MODE:
                sessionAckMode = Session.DUPS_OK_ACKNOWLEDGE;
                break;
            case Constants.AUTO_ACKNOWLEDGE_MODE:
                sessionAckMode = Session.AUTO_ACKNOWLEDGE;
                break;
            default:
                return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                        StringUtils.fromString(String.format("Unknown acknowledgment mode: %s", ackModeString)),
                        null, null);
        }

        try {
            return connection.createSession(transactedSession, sessionAckMode);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString(String.format("Error while creating session: %s", e.getMessage())),
                    cause, null);
        }
    }

    /**
     * Creates a {@link javax.jms.TemporaryQueue} object.
     *
     * @param session {@link javax.jms.Session} object
     * @return return temporary queue name
     */
    public static Object createTemporaryJmsQueue(Session session) {
        try {
            TemporaryQueue temporaryQueue = session.createTemporaryQueue();
            return temporaryQueue.getQueueName();
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error creating temporary queue."), cause, null);
        }
    }

    /**
     * Creates a {@link javax.jms.TemporaryTopic} object.
     *
     * @param session {@link javax.jms.Session} object
     * @return return temporary topic name
     */
    public static Object createTemporaryJmsTopic(Session session) {
        try {
            TemporaryTopic temporaryTopic = session.createTemporaryTopic();
            return temporaryTopic.getTopicName();
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error creating temporary topic."), cause, null);
        }
    }
}
