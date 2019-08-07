package org.wso2.ei.module.jms;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageProducer;
import javax.jms.Session;

public class JmsProducerUtils {

    private JmsProducerUtils() {}

    public static MessageProducer createJmsProducer(Session session, Destination destination)
            throws BallerinaJmsException {
        try {
            return session.createProducer(destination);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error creating queue sender.", e);
        }
    }
}
