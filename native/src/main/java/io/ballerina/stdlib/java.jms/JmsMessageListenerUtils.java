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

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.values.BObject;

import javax.jms.JMSException;
import javax.jms.MessageConsumer;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_CONSUMER;

/**
 * Representation of {@link javax.jms.MessageListener} with utility methods to invoke as inter-op functions.
 */
public class JmsMessageListenerUtils {

    public static Object setMessageListener(Environment environment, BObject consumer,
                                            BObject serviceObject) {
        MessageConsumer nativeConsumer = (MessageConsumer) consumer.getNativeData(NATIVE_CONSUMER);
        Runtime bRuntime = environment.getRuntime();
        try {
            nativeConsumer.setMessageListener(new JmsListener(serviceObject, bRuntime));
        } catch (JMSException e) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while setting the message listener: %s", e.getMessage()), e);
        }
        return null;
    }
}
