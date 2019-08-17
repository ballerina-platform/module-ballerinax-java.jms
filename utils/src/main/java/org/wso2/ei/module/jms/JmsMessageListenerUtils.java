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

import org.ballerinalang.jvm.BRuntime;
import org.ballerinalang.jvm.BallerinaValues;
import org.ballerinalang.jvm.values.HandleValue;
import org.ballerinalang.jvm.values.ObjectValue;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;
import javax.jms.StreamMessage;
import javax.jms.TextMessage;

public class JmsMessageListenerUtils {

    private JmsMessageListenerUtils() {
    }

    public static void setMessageListener(MessageConsumer consumer, ObjectValue serviceObject) throws BallerinaJmsException {
        BRuntime runtime = BRuntime.getCurrentRuntime();
        try {
            consumer.setMessageListener(new ListenerImpl(serviceObject, runtime));
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while setting the message listener");
        }
    }

    private static class ListenerImpl implements MessageListener {

        private final ObjectValue serviceObject;
        private final BRuntime runtime;

        ListenerImpl(ObjectValue serviceObject, BRuntime runtime) {
            this.serviceObject = serviceObject;
            this.runtime = runtime;
        }

        @Override
        public void onMessage(Message message) {
            ObjectValue value = BallerinaValues.createObjectValue(Constants.PACKAGE_NAME,
                                                                  getMessageObjectName(message),
                                                                  new HandleValue(message));
            Object[] args = {value, true};
            runtime.invokeMethod(serviceObject, Constants.SERVICE_RESOURCE_NAME, args);
        }

        private String getMessageObjectName(Message message) {
            if (message instanceof TextMessage) {
                return Constants.TEXT_MESSAGE_BAL_OBJECT_NAME;
            } else if (message instanceof MapMessage) {
                return Constants.MAP_MESSAGE_BAL_OBJECT_NAME;
            } else if (message instanceof BytesMessage) {
                return Constants.BYTE_MESSAGE_BAL_OBJECT_NAME;
            } else if (message instanceof StreamMessage) {
                return Constants.STREAM_MESSAGE_BAL_OBJECT_NAME;
            } else {
                return Constants.MESSAGE_BAL_OBJECT_NAME;
            }
        }
    }

}
