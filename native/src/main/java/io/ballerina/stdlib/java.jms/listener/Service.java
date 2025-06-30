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

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Parameter;
import io.ballerina.runtime.api.types.RemoteMethodType;
import io.ballerina.runtime.api.types.ServiceType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.java.jms.CommonUtils;

import java.util.Objects;

import static io.ballerina.runtime.api.constants.RuntimeConstants.ORG_NAME_SEPARATOR;
import static io.ballerina.runtime.api.constants.RuntimeConstants.VERSION_SEPARATOR;
import static io.ballerina.stdlib.java.jms.Constants.CALLER;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.MESSAGE_BAL_RECORD_NAME;
import static io.ballerina.stdlib.java.jms.ModuleUtils.getModule;

/**
 * This is the native representation of the Ballerina JMS service object.
 * This does the relevant configuration and method validation related to the JMS service. Ideally this validations
 * should be replaced by a compiler plugin.
 *
 * @since 1.2.0
 */
public class Service {
    private static final Type MSG_TYPE = ValueCreator.createRecordValue(getModule(), MESSAGE_BAL_RECORD_NAME)
            .getType();
    private static final Type CALLER_TYPE = ValueCreator.createObjectValue(getModule(), CALLER).getOriginalType();
    private static final BString SERVICE_CONFIG_ANNOTATION  = StringUtils.fromString(
            getModule().getOrg() + ORG_NAME_SEPARATOR + getModule().getName() + VERSION_SEPARATOR +
                    getModule().getMajorVersion() + VERSION_SEPARATOR + "ServiceConfig");

    private final BObject consumerService;
    private final ServiceType serviceType;
    private final ServiceConfig serviceConfig;
    private final RemoteMethodType onMessage;

    Service(BObject consumerService) {
        this.consumerService = consumerService;
        ServiceType svcType = (ServiceType) TypeUtils.getType(consumerService);
        this.serviceType = svcType;
        this.serviceConfig = new ServiceConfig(
                (BMap<BString, Object>) svcType.getAnnotation(SERVICE_CONFIG_ANNOTATION));
        this.onMessage = svcType.getRemoteMethods()[0];
    }

    public static void validateService(BObject consumerService) throws BError {
        ServiceType service = (ServiceType) TypeUtils.getType(consumerService);
        Object svcConfig = service.getAnnotation(SERVICE_CONFIG_ANNOTATION);
        if (Objects.isNull(svcConfig)) {
            throw CommonUtils.createError(JMS_ERROR, "Service configuration annotation is required");
        }

        if (service.getResourceMethods().length > 0) {
            throw CommonUtils.createError(JMS_ERROR, "JMS service cannot have resource methods");
        }

        RemoteMethodType[] remoteMethods = service.getRemoteMethods();
        if (remoteMethods.length != 1) {
            throw CommonUtils.createError(JMS_ERROR, "JMS service must have exactly one remote methods");
        }

        RemoteMethodType existingRemoteMethod = remoteMethods[0];
        if (!existingRemoteMethod.getName().equals("onMessage")) {
            throw CommonUtils.createError(JMS_ERROR,
                    "JMS service does not contain the required `onMessage` method");
        }

        validateOnMessageMethod(existingRemoteMethod);
    }

    private static void validateOnMessageMethod(RemoteMethodType onMessageMethod) {
        Parameter[] parameters = onMessageMethod.getParameters();
        if (parameters.length < 1 || parameters.length > 2) {
            throw CommonUtils.createError(JMS_ERROR,
                    "onMessage method can have only have either one or two parameters");
        }

        Parameter message = null;
        for (Parameter parameter : parameters) {
            Type parameterType = TypeUtils.getReferredType(parameter.type);
            if (TypeUtils.isSameType(MSG_TYPE, parameterType)) {
                message = parameter;
                continue;
            }
            if (TypeUtils.isSameType(CALLER_TYPE, parameterType)) {
                continue;
            }
            throw CommonUtils.createError(JMS_ERROR,
                    "onMessage method parameters must be of type 'jms:Message' or `jms:Caller`");
        }

        if (Objects.isNull(message)) {
            throw CommonUtils.createError(JMS_ERROR, "Required parameter 'jms:Message' can not be found");
        }
    }

    public boolean isOnMessageMethodIsolated() {
        return this.serviceType.isIsolated() && this.onMessage.isIsolated();
    }

    public BObject getConsumerService() {
        return consumerService;
    }

    public ServiceConfig getServiceConfig() {
        return serviceConfig;
    }

    public RemoteMethodType getOnMessageMethod() {
        return onMessage;
    }
}
