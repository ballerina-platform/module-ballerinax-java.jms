/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import org.ballerinalang.jvm.values.MapValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.naming.InitialContext;
import javax.naming.NamingException;

/**
 * Utility class for JMS related common operations.
 */
public class JmsUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(JmsUtils.class);

    /**
     * Utility class cannot be instantiated.
     */
    private JmsUtils() {
    }

//
    public static boolean isNullOrEmptyAfterTrim(String str) {
        return str == null || str.trim().isEmpty();
    }
//
//    /**
//     * Extract JMS Message from the struct.
//     *
//     * @param msgObj the Bllerina Message object
//     * @return {@link Message} instance located in struct.
//     */
//    public static Message getJMSMessage(ObjectValue msgObj) {
//        return (Message) msgObj.getNativeData(JmsConstants.JMS_MESSAGE_OBJECT);
//    }
//
//    public static Topic getTopic(Session session, String topicPattern) throws JMSException {
//        return session.createTopic(topicPattern);
//    }
//
//    /**
//     * Extract JMS Destination from the Destination struct.
//     *
//     * @param destinationBObject Destination struct.
//     * @return JMS Destination object or null.
//     */
//    public static Destination getDestination(ObjectValue destinationBObject) {
//        Destination destination = null;
//        if (destinationBObject != null) {
//            Object destObj = destinationBObject.getNativeData(JmsConstants.JMS_DESTINATION_OBJECT);
//            if (destObj instanceof Destination) {
//                destination = (Destination) destObj;
//            }
//        }
//        return destination;
//    }
//
//    public static byte[] getBytesData(ArrayValue bytesArray) {
//        return Arrays.copyOf(bytesArray.getBytes(), bytesArray.size());
//    }
//

//
//    public static ObjectValue createAndPopulateMessageObject(Message jmsMessage, ObjectValue sessionObj) {
//        String msgType;
//        if (jmsMessage instanceof TextMessage) {
//            msgType = JmsConstants.TEXT_MESSAGE;
//        } else if (jmsMessage instanceof BytesMessage) {
//            msgType = JmsConstants.BYTES_MESSAGE;
//        } else if (jmsMessage instanceof StreamMessage) {
//            msgType = JmsConstants.STREAM_MESSAGE;
//        } else if (jmsMessage instanceof MapMessage) {
//            msgType = JmsConstants.MAP_MESSAGE;
//        } else {
//            msgType = JmsConstants.MESSAGE;
//        }
//        ObjectValue messageObj = BallerinaValues.createObjectValue(JmsConstants.PROTOCOL_INTERNAL_PACKAGE_JMS,
//                                                                   JmsConstants.MESSAGE_OBJ_NAME, sessionObj,
//                                                                   msgType);
//        messageObj.addNativeData(JmsConstants.JMS_MESSAGE_OBJECT, jmsMessage);
//        return messageObj;
//    }
}
