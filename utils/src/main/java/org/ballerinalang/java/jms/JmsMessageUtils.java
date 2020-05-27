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

import org.ballerinalang.jvm.util.exceptions.BallerinaException;
import org.ballerinalang.jvm.values.api.BArray;
import org.ballerinalang.jvm.values.api.BValueCreator;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.StreamMessage;
import javax.jms.TextMessage;
import java.util.Collections;
import java.util.List;

/**
 *  Representation of {@link javax.jms.Message} with utility methods to invoke as inter-op functions.
 */
public class JmsMessageUtils {

    private JmsMessageUtils() {}

    /**
     * Check whether {@link javax.jms.Message} is {@link javax.jms.TextMessage}
     *
     * @param message {@link javax.jms.Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isTextMessage(Message message) {
        return message instanceof TextMessage;
    }

    /**
     * Check whether {@link javax.jms.Message} is {@link javax.jms.MapMessage}
     *
     * @param message {@link javax.jms.Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isMapMessage(Message message) {
        return message instanceof MapMessage;
    }

    /**
     * Check whether {@link javax.jms.Message} is {@link javax.jms.BytesMessage}
     *
     * @param message {@link javax.jms.Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isBytesMessage(Message message) {
        return message instanceof BytesMessage;
    }

    /**
     * Check whether {@link javax.jms.Message} is {@link javax.jms.StreamMessage}
     *
     * @param message {@link javax.jms.Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isStreamMessage(Message message) {
        return message instanceof StreamMessage;
    }

    /**
     * Return all property names in the {@link javax.jms.MapMessage} as Ballerina array
     *
     * @param message {@link javax.jms.Message} object
     * @return Ballerina array consist of property names
     * @throws BallerinaException throw a RuntimeException in an error situation
     */
    //TODO: Fix this workaround when Ballerina lang support to return primitive array and error as a union type
    public static BArray getJmsPropertyNames(Message message) {
        try {
            List<String> propertyNames = Collections.list(message.getPropertyNames());
            return BValueCreator.createArrayValue(propertyNames.toArray(new String[0]));

        } catch (JMSException e) {
            throw new BallerinaException("Error occurred while getting property names.", e);
        }
    }

    public static BArray getJMSCorrelationIDAsBytes(Message message) {
        try {
            MapMessage m = (MapMessage) message;
            return BValueCreator.createArrayValue(m.getJMSCorrelationIDAsBytes());
        } catch (JMSException e) {
            throw new BallerinaException("Error occurred while getting property names.", e);
        }
    }

        /**
     * Set the JMS correlation id value as an array of byte
     *
     * @param message {@link javax.jms.Message} object
     * @param value correlation id value as an array of byte
     * @throws BallerinaJmsException in an error situation
     */
    public static void setJMSCorrelationIDAsBytes(Message message,  BArray value) throws BallerinaJmsException {
        try {
            byte[] correlationId = value.getBytes();
            message.setJMSCorrelationIDAsBytes(correlationId);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while setting correlationId value " +
                    "as an array of bytes", e);
        }
    }
}
