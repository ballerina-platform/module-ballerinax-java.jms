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
import org.ballerinalang.jvm.values.ObjectValue;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;

public class JmsQueueReceiverUtils {

    private JmsQueueReceiverUtils() {
    }

    public static void setMessageListener(MessageConsumer consumer, ObjectValue balObject) throws BallerinaJmsException {
        BRuntime runtime = BRuntime.getCurrentRuntime();
        try {
            consumer.setMessageListener(new ListenerImpl(balObject, runtime));
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while setting the ");
        }
    }

    private static class ListenerImpl implements MessageListener {

        private final ObjectValue ballerinaObject;
        private final BRuntime runtime;

        ListenerImpl(ObjectValue ballerinaObject, BRuntime runtime) {
            this.ballerinaObject = ballerinaObject;
            this.runtime = runtime;
        }

        @Override
        public void onMessage(Message message) {
            Object[] args = {message, true};
            runtime.invokeMethod(ballerinaObject, "onMessage", args);
        }
    }

}
