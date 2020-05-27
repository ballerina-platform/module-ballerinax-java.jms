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

package org.ballerinalang.java.jms;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageProducer;
import javax.jms.Session;

/**
 * Representation of {@link javax.jms.MessageProducer} with utility methods to invoke as inter-op functions.
 */
public class JmsProducerUtils {

    private JmsProducerUtils() {}

    /**
     * Creates a MessageProducer to send messages to the specified destination.
     *
     * @param session {@link javax.jms.Session} object
     * @param destination {@link javax.jms.Destination} object
     * @return  {@link javax.jms.MessageProducer} object
     * @throws BallerinaJmsException in an error situation
     */
    public static MessageProducer createJmsProducer(Session session, Destination destination)
            throws BallerinaJmsException {
        try {
            return session.createProducer(destination);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error creating queue sender.", e);
        }
    }
}
