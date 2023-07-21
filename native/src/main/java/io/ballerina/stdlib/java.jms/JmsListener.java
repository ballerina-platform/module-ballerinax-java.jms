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
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;

import static io.ballerina.stdlib.java.jms.ConsumerUtils.getBallerinaMessage;

/**
 * A {@link javax.jms.MessageListener} implementation.
 */
public class JmsListener implements MessageListener {
    private static final Logger LOGGER = LoggerFactory.getLogger(JmsListener.class);

    private final BObject consumerService;
    private final Runtime ballerinaRuntime;
    private final Callback callback = new ConsumerCallback();

    public JmsListener(BObject consumerService, Runtime ballerinaRuntime) {
        this.consumerService = consumerService;
        this.ballerinaRuntime = ballerinaRuntime;
    }

    @Override
    public void onMessage(Message message) {
        try {
            Module module = ModuleUtils.getModule();
            BMap<BString, Object> ballerinaMessage = getBallerinaMessage(message);
            StrandMetadata metadata = new StrandMetadata(
                    module.getOrg(), module.getName(), module.getVersion(), Constants.SERVICE_RESOURCE_ON_MESSAGE);
            Object[] params = {ballerinaMessage, true};
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
        } catch (JMSException | BallerinaJmsException e) {
            LOGGER.error("Unexpected error occurred while async message processing", e);
        }
    }
}
