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

import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;

import java.util.Arrays;
import java.util.List;

/**
 * This is the native representation of the Ballerina JMS service object.
 * This does the relevant configuration and method validation related to the JMS service. Ideally this validations
 * should be replaced by a compiler plugin.
 *
 * @since 1.2.0
 */
public class Service {
    private final BObject consumerService;
    private final boolean isIsolated;
    private final List<MethodType> methods;

    public Service(BObject consumerService) {
        this.consumerService = consumerService;
        ObjectType serviceType = (ObjectType) TypeUtils.getReferredType(TypeUtils.getType(consumerService));
        this.isIsolated = serviceType.isIsolated();

        // validate the methods here
        this.methods = Arrays.asList(serviceType.getMethods());
    }
}
