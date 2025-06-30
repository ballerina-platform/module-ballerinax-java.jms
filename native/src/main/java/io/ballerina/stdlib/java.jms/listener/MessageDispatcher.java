/*
 * Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

package io.ballerina.stdlib.java.jms.listener;

import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.concurrent.StrandMetadata;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Parameter;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.stdlib.java.jms.BallerinaJmsException;
import io.ballerina.stdlib.java.jms.Constants;
import io.ballerina.stdlib.java.jms.ModuleUtils;
import io.ballerina.stdlib.java.jms.Util;

import java.io.PrintStream;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;

import static io.ballerina.stdlib.java.jms.CommonUtils.getBallerinaMessage;
import static io.ballerina.stdlib.java.jms.ModuleUtils.getProperties;

/**
 * A {@link javax.jms.MessageListener} implementation used to dispatch messages to a Ballerina JMS service.
 *
 * @since 1.2.0.
 */
public class MessageDispatcher implements MessageListener {
    private static final String ON_MESSAGE_METHOD = "onMessage";

    private static final PrintStream ERR_OUT = System.err;
    private final Runtime ballerinaRuntime;
    private final Service nativeService;

    public MessageDispatcher(Runtime ballerinaRuntime, Service nativeService) {
        this.ballerinaRuntime = ballerinaRuntime;
        this.nativeService = nativeService;
    }

    @Override
    public void onMessage(Message message) {
        Thread.startVirtualThread(() -> {
            try {
                boolean isConcurrentSafe = this.nativeService.isOnMessageMethodIsolated();
                Object[] params = getOnMessageParams(message);
                StrandMetadata metadata = new StrandMetadata(isConcurrentSafe, getProperties(ON_MESSAGE_METHOD));
                Object result = ballerinaRuntime.callMethod(
                        this.nativeService.getConsumerService(), ON_MESSAGE_METHOD, metadata, params);
                Util.notifySuccess(result);
            } catch (JMSException | BallerinaJmsException e) {
                ERR_OUT.println("Unexpected error occurred while async message processing: " + e.getMessage());
            } catch (BError bError) {
                bError.printStackTrace();
            }
        });
    }

    private Object[] getOnMessageParams(Message message)
            throws JMSException, BallerinaJmsException {
        Parameter[] parameters = this.nativeService.getOnMessageMethod().getParameters();
        Object[] args = new Object[parameters.length];
        int idx = 0;
        for (Parameter param: parameters) {
            Type referredType = TypeUtils.getReferredType(param.type);
            switch (referredType.getTag()) {
                case TypeTags.OBJECT_TYPE_TAG:
                    args[idx++] = ValueCreator.createObjectValue(ModuleUtils.getModule(), Constants.CALLER);
                    break;
                case TypeTags.RECORD_TYPE_TAG:
                    args[idx++] = getBallerinaMessage(message);
                    break;
            }
        }
        return args;
    }
}
