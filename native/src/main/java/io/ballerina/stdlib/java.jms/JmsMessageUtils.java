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

import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import javax.jms.BytesMessage;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.Session;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.CommonUtils.getDestination;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_SESSION;

/**
 * Representation of {@link javax.jms.BytesMessage} with utility methods to invoke as inter-op functions.
 */
public class JmsMessageUtils {

    /**
     * Writes a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param value   byte[] array as ballerina
     */
    public static Object writeBytes(BytesMessage message, BArray value) {
        try {
            byte[] bytes = value.getBytes();
            message.writeBytes(bytes);
        } catch (JMSException e) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while writing the bytes message: %s", e.getMessage()), e);
        }
        return null;
    }

    /**
     * Writes a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.MapMessage} object
     * @param fieldName Name of the map field
     * @param value   byte[] array as ballerina
     */
    public static Object writeBytesField(MapMessage message, String fieldName, BArray value) {
        try {
            byte[] bytes = value.getBytes();
            message.setBytes(fieldName, bytes);
        } catch (JMSException e) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while setting a byte array field to a map message: %s",
                            e.getMessage()), e);
        }
        return null;
    }

    /**
     * Updates `replyTo` field in the JMS message.
     *
     * @param session Ballerina JMS session object
     * @param message JMS message
     * @param replyTo Relevant JMS destination
     * @return A Ballerina `jms:Error` if there is an error while setting replyTo field to the JMS message
     */
    public static Object setReplyTo(BObject session, Message message, BMap<BString, Object> replyTo) {
        Session nativeSession = (Session) session.getNativeData(NATIVE_SESSION);
        try {
            Destination replyToDestination = getDestination(nativeSession, replyTo);
            message.setJMSReplyTo(replyToDestination);
        } catch (BallerinaJmsException exception) {
            return createError(JMS_ERROR, exception.getMessage(), exception);
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while setting a reply-to field in the JMS message: %s",
                            exception.getMessage()), exception);
        }
        return null;
    }

    /**
     * Updates `correlationId` field in the JMS message.
     *
     * @param message JMS message
     * @param correlationId Message correlationId
     * @return A Ballerina `jms:Error` if there is an error while setting correlationId field to the JMS message
     */
    public static Object setCorrelationId(Message message, BString correlationId) {
        try {
            message.setJMSCorrelationID(correlationId.getValue());
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while setting correlation-id field to the JMS message: %s",
                            exception.getMessage()), exception);
        }
        return null;
    }
}
