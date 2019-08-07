package org.wso2.ei.module.jms;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;
import javax.jms.Topic;

public class JmsSessionUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(JmsSessionUtils.class);

    private JmsSessionUtils() {}

    public static Session createJmsSession(Connection connection, String ackModeString) throws BallerinaJmsException {

        int sessionAckMode;
        boolean transactedSession = false;

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
            String message = "Error while creating session.";
            LOGGER.error(message, e);
            throw new BallerinaJmsException(message + " " + e.getMessage(), e);
        }
    }

    public static Queue createJmsQueue(Session session, String queueName) throws BallerinaJmsException {
        try {
            return session.createQueue(queueName);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error creating queue.", e);
        }
    }

    public static Topic createJmsTopic(Session session, String topicName) throws BallerinaJmsException {
        try {
            return session.createTopic(topicName);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error creating topic.", e);
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

    public static void unsubscribeJmsSubscription(Session session, String subscriptionId) throws BallerinaJmsException {
        try {
            session.unsubscribe(subscriptionId);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while un-subscribing for subscription id "
                                            + subscriptionId, e);
        }
    }
}
