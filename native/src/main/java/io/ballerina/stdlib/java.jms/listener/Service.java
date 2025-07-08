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

import io.ballerina.runtime.api.creators.TypeCreator;
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
import java.util.Optional;
import java.util.stream.Stream;

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
    private static final Type ERROR_TYPE = TypeCreator.createErrorType(JMS_ERROR, getModule());
    private static final BString SERVICE_CONFIG_ANNOTATION = StringUtils.fromString(
            getModule().getOrg() + ORG_NAME_SEPARATOR + getModule().getName() + VERSION_SEPARATOR +
                    getModule().getMajorVersion() + VERSION_SEPARATOR + "ServiceConfig");
    private static final BString QUEUE_NAME = StringUtils.fromString("queueName");
    private static final String ON_MSG_METHOD = "onMessage";
    private static final String ON_ERR_METHOD = "onError";

    private final BObject consumerService;
    private final ServiceType serviceType;
    private final ServiceConfig serviceConfig;
    private final RemoteMethodType onMessage;
    private final Optional<RemoteMethodType> onError;

    Service(BObject consumerService) {
        this.consumerService = consumerService;
        ServiceType svcType = (ServiceType) TypeUtils.getType(consumerService);
        this.serviceType = svcType;
        BMap<BString, Object> svcConfig = (BMap<BString, Object>) svcType.getAnnotation(SERVICE_CONFIG_ANNOTATION);
        this.serviceConfig = svcConfig.containsKey(QUEUE_NAME) ?
                new QueueConfig(svcConfig) : new TopicConfig(svcConfig);
        this.onMessage = Stream.of(svcType.getRemoteMethods())
                .filter(m -> ON_MSG_METHOD.equals(m.getName()))
                .findFirst().get();
        this.onError = Stream.of(svcType.getRemoteMethods())
                .filter(m -> ON_ERR_METHOD.equals(m.getName()))
                .findFirst();
    }

    public static void validateService(BObject consumerService) throws BError {
        ServiceType service = (ServiceType) TypeUtils.getType(consumerService);
        Object svcConfig = service.getAnnotation(SERVICE_CONFIG_ANNOTATION);
        if (Objects.isNull(svcConfig)) {
            throw CommonUtils.createError(JMS_ERROR, "Service configuration annotation is required.");
        }

        if (service.getResourceMethods().length > 0) {
            throw CommonUtils.createError(JMS_ERROR, "JMS service cannot have resource methods.");
        }

        RemoteMethodType[] remoteMethods = service.getRemoteMethods();
        if (remoteMethods.length < 1 || remoteMethods.length > 2) {
            throw CommonUtils.createError(
                    JMS_ERROR, "JMS service must have exactly one or two remote methods.");
        }

        for (RemoteMethodType remoteMethod: remoteMethods) {
            String remoteMethodName = remoteMethod.getName();
            if (ON_MSG_METHOD.equals(remoteMethodName)) {
                validateOnMessageMethod(remoteMethod);
            } else if (ON_ERR_METHOD.equals(remoteMethodName)) {
                validateOnErrorMethod(remoteMethod);
            } else {
                throw CommonUtils.createError(
                        JMS_ERROR, String.format("Invalid remote method name: %s.", remoteMethodName));
            }
        }
    }

    private static void validateOnMessageMethod(RemoteMethodType onMessageMethod) {
        Parameter[] parameters = onMessageMethod.getParameters();
        if (parameters.length < 1 || parameters.length > 2) {
            throw CommonUtils.createError(JMS_ERROR,
                    "onMessage method can have only have either one or two parameters.");
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
                    "onMessage method parameters must be of type 'jms:Message' or 'jms:Caller'.");
        }

        if (Objects.isNull(message)) {
            throw CommonUtils.createError(JMS_ERROR, "Required parameter 'jms:Message' can not be found.");
        }
    }

    private static void validateOnErrorMethod(RemoteMethodType onErrorMethod) {
        if (onErrorMethod.getParameters().length != 1) {
            throw CommonUtils.createError(JMS_ERROR, "onError method must have exactly one parameter.");
        }

        Parameter parameter = onErrorMethod.getParameters()[0];
        Type parameterType = TypeUtils.getReferredType(parameter.type);
        if (!TypeUtils.isSameType(ERROR_TYPE, parameterType)) {
            throw CommonUtils.createError(JMS_ERROR, "onError method parameter must be of type 'jms:Error'.");
        }
    }

    public boolean isOnMessageMethodIsolated() {
        return this.serviceType.isIsolated() && this.onMessage.isIsolated();
    }

    public boolean isOnErrorMethodIsolated() {
        return this.onError.map(m -> this.serviceType.isIsolated() && m.isIsolated()).orElse(false);
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

    public Optional<RemoteMethodType> getOnError() {
        return onError;
    }
}
