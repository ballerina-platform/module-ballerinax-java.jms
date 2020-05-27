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

import org.ballerinalang.jvm.BRuntime;
import org.ballerinalang.jvm.BallerinaValues;
import org.ballerinalang.jvm.types.AttachedFunction;
import org.ballerinalang.jvm.types.BPackage;
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

/**
 * Representation of {@link javax.jms.MessageListener} with utility methods to invoke as inter-op functions.
 */
public class JmsMessageListenerUtils {

    private JmsMessageListenerUtils() {
    }

    /**
     * Set {@link javax.jms.MessageListener} to a {@link javax.jms.MessageConsumer}
     *
     * @param consumer {@link javax.jms.MessageConsumer} object
     * @param serviceObject Ballerina service object
     * @throws BallerinaJmsException in an error situation
     */
    public static void setMessageListener(MessageConsumer consumer, ObjectValue serviceObject) throws BallerinaJmsException {
        BRuntime runtime = BRuntime.getCurrentRuntime();
        try {
            consumer.setMessageListener(new ListenerImpl(serviceObject, runtime));
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while setting the message listener");
        }
    }

    /**
     * Passes a message to the listener.
     */
    private static class ListenerImpl implements MessageListener {

        private final ObjectValue serviceObject;
        private final BRuntime runtime;

        ListenerImpl(ObjectValue serviceObject, BRuntime runtime) {
            this.serviceObject = serviceObject;
            this.runtime = runtime;
        }

        @Override
        public void onMessage(Message message) {

            String messageObjectName;
            String specificFunctionName;
            if (message instanceof TextMessage) {
                messageObjectName = Constants.TEXT_MESSAGE_BAL_OBJECT_NAME;
                specificFunctionName = Constants.SERVICE_RESOURCE_ON_TEXT_MESSAGE;
            } else if (message instanceof MapMessage) {
                messageObjectName = Constants.MAP_MESSAGE_BAL_OBJECT_NAME;
                specificFunctionName = Constants.SERVICE_RESOURCE_ON_MAP_MESSAGE;
            } else if (message instanceof BytesMessage) {
                messageObjectName = Constants.BYTE_MESSAGE_BAL_OBJECT_NAME;
                specificFunctionName = Constants.SERVICE_RESOURCE_ON_BYTES_MESSAGE;
            } else if (message instanceof StreamMessage) {
                messageObjectName = Constants.STREAM_MESSAGE_BAL_OBJECT_NAME;
                specificFunctionName = Constants.SERVICE_RESOURCE_ON_STREAM_MESSAGE;
            } else {
                messageObjectName = Constants.MESSAGE_BAL_OBJECT_NAME;
                specificFunctionName = Constants.SERVICE_RESOURCE_ON_OTHER_MESSAGE;
            }

            BPackage jmsPackage = new BPackage(Constants.ORG, Constants.PACKAGE_NAME, Constants.VERSION);
            ObjectValue param = BallerinaValues.createObjectValue(jmsPackage, messageObjectName,
                                                                  new HandleValue(message));
            Object[] params = {param, true};

            AttachedFunction[] attachedFunctions = serviceObject.getType().getAttachedFunctions();
            if (isMessageTypeSpecificFunction(attachedFunctions)) {
                invokeMessageSpecificFunctions(specificFunctionName, attachedFunctions, params);
            } else {
                runtime.invokeMethodAsync(serviceObject, Constants.SERVICE_RESOURCE_ON_MESSAGE, params);
            }
        }

        /**
         * With compiler plugin we guarantee that there are more than 1 resource in a message type specific scenario
         * with the inclusion of mandatory onOtherMessage function.
         *
         * @param functions functions list
         * @return true if there are message type specific functions found.
         */
        private boolean isMessageTypeSpecificFunction(AttachedFunction[] functions) {
            return functions.length > 1;
        }

        private void invokeMessageSpecificFunctions(String specificFunctionName, AttachedFunction[] attachedFunctions, Object[] params) {
            boolean functionFound = false;
            for(AttachedFunction function: attachedFunctions) {
                if (specificFunctionName.equals(function.getName())) {
                    functionFound = true;
                    runtime.invokeMethodAsync(serviceObject, specificFunctionName, params);
                    break;
                }
            }
            if (!functionFound) {
                runtime.invokeMethodAsync(serviceObject, Constants.SERVICE_RESOURCE_ON_OTHER_MESSAGE, params);
            }
        }

    }

}
