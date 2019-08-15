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

import org.ballerinalang.jvm.types.BArrayType;
import org.ballerinalang.jvm.types.BTypes;
import org.ballerinalang.jvm.values.ArrayValue;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.ObjectMessage;
import javax.jms.StreamMessage;
import javax.jms.TextMessage;
import java.util.ArrayList;
import java.util.Collections;

public class JmsMessageUtils {

    private JmsMessageUtils() {}

    public static boolean isTextMessage(Message message) {
        return message instanceof TextMessage;
    }

    public static boolean isMapMessage(Message message) {
        return message instanceof MapMessage;
    }

    public static boolean isBytesMessage(Message message) {
        return message instanceof BytesMessage;
    }

    public static boolean isStreamMessage(Message message) {
        return message instanceof StreamMessage;
    }

    public static boolean isObjectMessage(Message message) {

        return message instanceof ObjectMessage;
    }

    public static ArrayValue getPropertyNames(Message message) throws BallerinaJmsException {
        try {
            ArrayList propertyNames = Collections.list(message.getPropertyNames());
            return new ArrayValue(propertyNames.toArray(), new BArrayType(BTypes.typeString));

        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while getting property names.", e);
        }
    }
}
