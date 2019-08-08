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

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.Session;
import javax.jms.TextMessage;

public class JmsTextMessageUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(JmsTextMessageUtils.class);

    public static Message createJmsTextMessage(Session session) throws BallerinaJmsException {
        try {
            return session.createTextMessage();
        } catch (JMSException e) {
            String message = "Error while creating a text message.";
            LOGGER.error(message, e);
            throw new BallerinaJmsException(message + " " + e.getMessage(), e);
        }
    }

    public static void setJmsText(TextMessage textMessage, String data) throws BallerinaJmsException {
        try {
            textMessage.setText(data);
        } catch (JMSException e) {
            String message = "Error while setting message's data.";
            LOGGER.error(message, e);
            throw new BallerinaJmsException(message + " " + e.getMessage(), e);
        }
    }

    public static String getJmsText(TextMessage textMessage) throws BallerinaJmsException {
        try {
            return textMessage.getText();
        } catch (JMSException e) {
            String message = "Error while getting message's data.";
            LOGGER.error(message, e);
            throw new BallerinaJmsException(message + " " + e.getMessage(), e);
        }
    }
}
