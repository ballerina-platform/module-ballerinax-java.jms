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

import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.async.Callback;
import io.ballerina.runtime.api.async.StrandMetadata;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;

import javax.jms.BytesMessage;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.StreamMessage;
import javax.jms.TextMessage;

/**
 * A {@link javax.jms.MessageListener} implementation.
 */
public class JmsListener implements MessageListener {
    private final BObject consumerService;
    private final Runtime ballerinaRuntime;
    private final Callback callback = new ConsumerCallback();

    public JmsListener(BObject consumerService, Runtime ballerinaRuntime) {
        this.consumerService = consumerService;
        this.ballerinaRuntime = ballerinaRuntime;
    }

    @Override
    public void onMessage(Message message) {
        Module module = ModuleUtils.getModule();
        String messageType = getMessageType(message);
        BObject jmsMessage = ValueCreator.createObjectValue(
                module, messageType, ValueCreator.createHandleValue(message));
        StrandMetadata metadata = new StrandMetadata(
                module.getOrg(), module.getName(), module.getVersion(), Constants.SERVICE_RESOURCE_ON_MESSAGE);
        Object[] params = {jmsMessage, true};
        ObjectType serviceType = (ObjectType) TypeUtils.getReferredType(TypeUtils.getType(consumerService));
        if (serviceType.isIsolated() && serviceType.isIsolated(Constants.SERVICE_RESOURCE_ON_MESSAGE)) {
            ballerinaRuntime.invokeMethodAsyncConcurrently(
                    consumerService, Constants.SERVICE_RESOURCE_ON_MESSAGE, null, metadata, callback,
                    null, PredefinedTypes.TYPE_NULL, params);
        } else {
            ballerinaRuntime.invokeMethodAsyncSequentially(
                    consumerService, Constants.SERVICE_RESOURCE_ON_MESSAGE, null, metadata, callback,
                    null, PredefinedTypes.TYPE_NULL, params);
        }
    }

    private String getMessageType(Message message) {
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
