/*
 * Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
 *
 *  WSO2 LLC. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied. See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
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
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.stdlib.java.jms.BallerinaJmsException;
import io.ballerina.stdlib.java.jms.Constants;

import java.io.PrintStream;
import java.util.HashMap;
import java.util.Map;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.Session;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.CommonUtils.getBallerinaMessage;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.ModuleUtils.getModule;
import static io.ballerina.stdlib.java.jms.listener.Listener.NATIVE_SESSION;

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
    private final Session session;

    MessageDispatcher(Runtime ballerinaRuntime, Service nativeService, Session session) {
        this.ballerinaRuntime = ballerinaRuntime;
        this.nativeService = nativeService;
        this.session = session;
    }

    @Override
    public void onMessage(Message message) {
        Thread.startVirtualThread(() -> {
            try {
                boolean isConcurrentSafe = this.nativeService.isOnMessageMethodIsolated();
                StrandMetadata metadata = new StrandMetadata(isConcurrentSafe, getPropertiesForOnMsgMethod());
                Object[] params = getOnMessageParams(message);
                Object result = ballerinaRuntime.callMethod(
                        this.nativeService.getConsumerService(), ON_MESSAGE_METHOD, metadata, params);
                notifySuccess(result);
            } catch (Throwable e) {
                ERR_OUT.println("Unexpected error occurred while async message processing: " + e.getMessage());
                BError error = createError(JMS_ERROR, "Failed to fetch the message", e);
                throw error;
            }
        });
    }

    private Map<String, Object> getPropertiesForOnMsgMethod() {
        Map<String, Object> properties = new HashMap<>();
        properties.put("moduleOrg", getModule().getOrg());
        properties.put("moduleName", getModule().getName());
        properties.put("moduleVersion", getModule().getMajorVersion());
        properties.put("parentFunctionName", ON_MESSAGE_METHOD);
        return properties;
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
                    args[idx++] = getCaller();
                    break;
                case TypeTags.RECORD_TYPE_TAG:
                    args[idx++] = getBallerinaMessage(message);
                    break;
            }
        }
        return args;
    }

    private BObject getCaller() {
        BObject caller = ValueCreator.createObjectValue(getModule(), Constants.CALLER);
        caller.addNativeData(NATIVE_SESSION, session);
        return caller;
    }

    private void notifySuccess(Object o) {
        if (o instanceof BError) {
            ((BError) o).printStackTrace();
        }
    }
}
