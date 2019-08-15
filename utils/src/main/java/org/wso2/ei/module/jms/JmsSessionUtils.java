/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.wso2.ei.module.jms;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;

public class JmsSessionUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(JmsSessionUtils.class);

    private JmsSessionUtils() {}

    public static Session createJmsSession(Connection connection, String ackModeString) throws BallerinaJmsException {

        int sessionAckMode;
        boolean transactedSession = false;
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("Session ack mode string: {}", ackModeString);
        }

        switch (ackModeString) {
            case JmsConstants.CLIENT_ACKNOWLEDGE_MODE:
                sessionAckMode = Session.CLIENT_ACKNOWLEDGE;
                break;
            case JmsConstants.SESSION_TRANSACTED_MODE:
                sessionAckMode = Session.SESSION_TRANSACTED;
                transactedSession = true;
                break;
            case JmsConstants.DUPS_OK_ACKNOWLEDGE_MODE:
                sessionAckMode = Session.DUPS_OK_ACKNOWLEDGE;
                break;
            case JmsConstants.AUTO_ACKNOWLEDGE_MODE:
                sessionAckMode = Session.AUTO_ACKNOWLEDGE;
                break;
            default:
                throw new BallerinaJmsException("Unknown acknowledgment mode: " + ackModeString);
        }

        try {
            return connection.createSession(transactedSession, sessionAckMode);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error while creating session." + e.getMessage(), e);
        }
    }

    public static String createTemporaryJmsQueue(Session session) throws BallerinaJmsException {
        try {
            TemporaryQueue temporaryQueue = session.createTemporaryQueue();
            return temporaryQueue.getQueueName();
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error creating temporary queue.", e);
        }
    }

    public static String createTemporaryJmsTopic(Session session) throws BallerinaJmsException {
        try {
            TemporaryTopic temporaryTopic = session.createTemporaryTopic();
            return temporaryTopic.getTopicName();
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error creating temporary topic.", e);
        }
    }

}
