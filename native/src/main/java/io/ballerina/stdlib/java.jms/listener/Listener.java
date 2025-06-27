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

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

/**
 * Native class for the Ballerina JMS Listener.
 *
 * @since 1.2.0
 */
public final class Listener {

    public static Object init(BObject bListener, BMap<BString, Object> connectionConfig) {
        throw new RuntimeException("Not implemented yet");
    }

    public static Object attach(Environment environment, BObject bListener, BObject bService) {
        throw new RuntimeException("Not implemented yet");
    }

    public static Object detach(BObject bListener, BObject service) {
        throw new RuntimeException("Not implemented yet");
    }

    public static Object start(BObject listener) {
        throw new RuntimeException("Not implemented yet");
    }

    public static Object gracefulStop(BObject listener) {
        throw new RuntimeException("Not implemented yet");
    }

    public static Object immediateStop(BObject listener) {
        throw new RuntimeException("Not implemented yet");
    }
}
