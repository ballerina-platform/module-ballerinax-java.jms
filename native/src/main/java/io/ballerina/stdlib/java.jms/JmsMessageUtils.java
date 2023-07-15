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

package io.ballerina.stdlib.java.jms;

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BString;

import java.util.Collections;
import java.util.List;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.StreamMessage;
import javax.jms.TextMessage;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 *  Representation of {@link Message} with utility methods to invoke as inter-op functions.
 */
public class JmsMessageUtils {

    private JmsMessageUtils() {}

    /**
     * Check whether {@link Message} is {@link TextMessage}.
     *
     * @param message {@link Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isTextMessage(Message message) {
        return message instanceof TextMessage;
    }

    /**
     * Check whether {@link Message} is {@link MapMessage}.
     *
     * @param message {@link Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isMapMessage(Message message) {
        return message instanceof MapMessage;
    }

    /**
     * Check whether {@link Message} is {@link BytesMessage}.
     *
     * @param message {@link Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isBytesMessage(Message message) {
        return message instanceof BytesMessage;
    }

    /**
     * Check whether {@link Message} is {@link StreamMessage}.
     *
     * @param message {@link Message} object
     * @return true/false based on the evaluation
     */
    public static boolean isStreamMessage(Message message) {
        return message instanceof StreamMessage;
    }

    /**
     * Return all property names in the {@link MapMessage} as Ballerina array.
     *
     * @param message {@link Message} object
     * @return Ballerina array consist of property names
     */
    public static Object getJmsPropertyNames(Message message) {
        try {
            List<String> propertyNames = Collections.list(message.getPropertyNames());
            return ValueCreator.createArrayValue(propertyNames.toArray(new BString[0]));
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while getting property names."), cause, null);
        }
    }

    public static Object getJMSCorrelationIDAsBytes(Message message) {
        try {
            MapMessage m = (MapMessage) message;
            return ValueCreator.createArrayValue(m.getJMSCorrelationIDAsBytes());
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while getting property names."), cause, null);
        }
    }

        /**
     * Set the JMS correlation id value as an array of byte.
     *
     * @param message {@link Message} object
     * @param value correlation id value as an array of byte
     */
    public static Object setJMSCorrelationIDAsBytes(Message message,  BArray value) {
        try {
            byte[] correlationId = value.getBytes();
            message.setJMSCorrelationIDAsBytes(correlationId);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while setting correlationId value as an array of bytes."),
                    cause, null);
        }
        return null;
    }
}
