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

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * Represents configuration details for consuming messages from a JMS queue.
 *
 * @param ackMode The acknowledgement mode for message consumption. This determines how
 *                messages received by the session are acknowledged.
 *                Common values include "AUTO_ACKNOWLEDGE", "CLIENT_ACKNOWLEDGE", and "DUPS_OK_ACKNOWLEDGE".
 * @param queueName       The name of the JMS queue to consume messages from.
 * @param messageSelector An optional JMS message selector expression. Only messages with properties
 *                        matching this selector will be delivered to the consumer.
 *                        If this value is {@code null}, no selector is applied.
 * @since 1.2.0
 */
public record QueueConfig(String ackMode, String queueName, String messageSelector) implements ServiceConfig {
    private static final BString SESSION_ACK_MODE = StringUtils.fromString("sessionAckMode");
    private static final BString QUEUE_NAME = StringUtils.fromString("queueName");
    private static final BString MSG_SELECTOR = StringUtils.fromString("messageSelector");

    @SuppressWarnings("unchecked")
    QueueConfig(BMap<BString, Object> configurations) {
        this(
                configurations.getStringValue(SESSION_ACK_MODE).getValue(),
                configurations.getStringValue(QUEUE_NAME).getValue(),
                configurations.containsKey(MSG_SELECTOR) ? configurations.getStringValue(MSG_SELECTOR).getValue() : null
        );
    }
}
