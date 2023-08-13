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

package io.ballerina.stdlib.java.jms.listener;

import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.async.Callback;
import io.ballerina.runtime.api.async.StrandMetadata;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.Parameter;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.stdlib.java.jms.BallerinaJmsException;
import io.ballerina.stdlib.java.jms.Constants;
import io.ballerina.stdlib.java.jms.ModuleUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Optional;
import java.util.stream.Stream;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;

import static io.ballerina.runtime.api.TypeTags.OBJECT_TYPE_TAG;
import static io.ballerina.runtime.api.TypeTags.RECORD_TYPE_TAG;
import static io.ballerina.stdlib.java.jms.CommonUtils.getBallerinaMessage;
import static io.ballerina.stdlib.java.jms.Constants.SERVICE_RESOURCE_ON_MESSAGE;

/**
 * A {@link javax.jms.MessageListener} implementation.
 */
public class ListenerImpl implements MessageListener {
    private static final Logger LOGGER = LoggerFactory.getLogger(ListenerImpl.class);

    private final BObject consumerService;
    private final Runtime ballerinaRuntime;
    private final Callback callback = new ListenerCallback();

    public ListenerImpl(BObject consumerService, Runtime ballerinaRuntime) {
        this.consumerService = consumerService;
        this.ballerinaRuntime = ballerinaRuntime;
    }

    @Override
    public void onMessage(Message message) {
        try {
            Module module = ModuleUtils.getModule();
            StrandMetadata metadata = new StrandMetadata(
                    module.getOrg(), module.getName(), module.getVersion(), SERVICE_RESOURCE_ON_MESSAGE);
            ObjectType serviceType = (ObjectType) TypeUtils.getReferredType(TypeUtils.getType(consumerService));
            Object[] params = methodParameters(serviceType, message);
            if (serviceType.isIsolated() && serviceType.isIsolated(SERVICE_RESOURCE_ON_MESSAGE)) {
                ballerinaRuntime.invokeMethodAsyncConcurrently(
                        consumerService, SERVICE_RESOURCE_ON_MESSAGE, null, metadata, callback,
                        null, PredefinedTypes.TYPE_NULL, params);
            } else {
                ballerinaRuntime.invokeMethodAsyncSequentially(
                        consumerService, SERVICE_RESOURCE_ON_MESSAGE, null, metadata, callback,
                        null, PredefinedTypes.TYPE_NULL, params);
            }
        } catch (JMSException | BallerinaJmsException e) {
            LOGGER.error("Unexpected error occurred while async message processing", e);
        }
    }

    private Object[] methodParameters(ObjectType serviceType, Message message)
            throws JMSException, BallerinaJmsException {
        Optional<MethodType> onMessageFuncOpt = Stream.of(serviceType.getMethods())
                .filter(methodType -> SERVICE_RESOURCE_ON_MESSAGE.equals(methodType.getName()))
                .findFirst();
        if (onMessageFuncOpt.isPresent()) {
            MethodType onMessageFunction = onMessageFuncOpt.get();
            Parameter[] parameters = onMessageFunction.getParameters();
            Object[] args = new Object[parameters.length * 2];
            int idx = 0;
            for (Parameter param: parameters) {
                Type referredType = TypeUtils.getReferredType(param.type);
                switch (referredType.getTag()) {
                    case OBJECT_TYPE_TAG:
                        args[idx++] = ValueCreator.createObjectValue(ModuleUtils.getModule(), Constants.CALLER);
                        args[idx++] = true;
                        break;
                    case RECORD_TYPE_TAG:
                        args[idx++] = getBallerinaMessage(message);
                        args[idx++] = true;
                        break;
                    default:
                        throw new BallerinaJmsException(
                                String.format("Unknown service method parameter type: %s", referredType));
                }
            }
            return args;
        }
        throw new BallerinaJmsException("Required method `onMessage` not found in the service");
    }
}
