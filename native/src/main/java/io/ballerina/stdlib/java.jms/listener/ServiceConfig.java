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

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * Represents the service-level configuration for a JMS service.
 *
 * @param ackMode The acknowledgement mode for message consumption. This determines how
 *                messages received by the session are acknowledged.
 *                Common values include "AUTO_ACKNOWLEDGE", "CLIENT_ACKNOWLEDGE", and "DUPS_OK_ACKNOWLEDGE".
 *
 * @param subscriptionConfig  The configuration for the subscription configuration
 *                            represented by {@link SubscriptionConfig}.
 *
 * @since 1.2.0
 */
public record ServiceConfig(String ackMode, SubscriptionConfig subscriptionConfig) {
    private static final BString ACK_MODE = StringUtils.fromString("acknowledgementMode");
    private static final BString SUBSCRIPTION_CONFIG = StringUtils.fromString("subscriptionConfig");
    private static final BString QUEUE_NAME = StringUtils.fromString("queueName");

    @SuppressWarnings("unchecked")
    ServiceConfig(BMap<BString, Object> configurations) {
        this(
                configurations.getStringValue(ACK_MODE).getValue(),
                getConsumerConfig((BMap<BString, Object>) configurations.getMapValue(SUBSCRIPTION_CONFIG))
        );
    }

    private static SubscriptionConfig getConsumerConfig(BMap<BString, Object> config) {
        if (config.containsKey(QUEUE_NAME)) {
            return new QueueConfig(config);
        }
        return new TopicConfig(config);
    }
}
