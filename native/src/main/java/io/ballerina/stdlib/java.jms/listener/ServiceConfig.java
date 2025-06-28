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
 * @param config  The configuration for the destination to consume from.
 *                This can be a queue or topic configuration, represented by {@link ConsumerConfig}.
 *
 * @since 1.2.0
 */
public record ServiceConfig(String ackMode, ConsumerConfig config) {
    private static final BString ACK_MODE = StringUtils.fromString("acknowledgementMode");
    private static final BString CONSUMER_CONFIG = StringUtils.fromString("config");
    private static final BString QUEUE_NAME = StringUtils.fromString("queueName");

    @SuppressWarnings("unchecked")
    public ServiceConfig(BMap<BString, Object> configurations) {
        this(
                configurations.getStringValue(ACK_MODE).getValue(),
                getConsumerConfig((BMap<BString, Object>) configurations.getMapValue(CONSUMER_CONFIG))
        );
    }

    private static ConsumerConfig getConsumerConfig(BMap<BString, Object> config) {
        if (config.containsKey(QUEUE_NAME)) {
            return new QueueConfig(config);
        }
        return new TopicConfig(config);
    }
}
