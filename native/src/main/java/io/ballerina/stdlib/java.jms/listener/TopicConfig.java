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
 * Represents configuration details for consuming messages from a JMS topic subscription.
 *
 * @param topicName       The name of the JMS topic to subscribe to.
 *
 * @param messageSelector An optional JMS message selector expression. Only messages with properties
 *                        matching this selector will be delivered to the consumer.
 *                        If {@code null}, no message selector is applied.
 *
 * @param noLocal         If {@code true}, messages published to the topic using the same connection
 *                        (or one with the same client ID) will not be delivered to this subscriber.
 *
 * @param consumerType    The type of message consumer. Expected values include types such as
 *                        "DEFAULT", "DURABLE", or "SHARED" depending on your implementation.
 *
 * @param subscriberName  An optional name used to identify the subscription, especially for durable
 *                        or shared subscriptions. If {@code null}, no name is associated.
 *
 * @since 1.2.0
 */
public record TopicConfig(String topicName, String messageSelector, boolean noLocal, String consumerType,
                          String subscriberName) implements ConsumerConfig {
    private static final BString TOPIC_NAME = StringUtils.fromString("topicName");
    private static final BString MSG_SELECTOR = StringUtils.fromString("messageSelector");
    private static final BString NO_LOCAL = StringUtils.fromString("noLocal");
    private static final BString CONSUMER_TYPE = StringUtils.fromString("consumerType");
    private static final BString SUBSCRIBER_NAME = StringUtils.fromString("subscriberName");

    @SuppressWarnings("unchecked")
    public TopicConfig(BMap<BString, Object> configurations) {
        this(
                configurations.getStringValue(TOPIC_NAME).getValue(),
                configurations.containsKey(MSG_SELECTOR) ?
                        configurations.getStringValue(MSG_SELECTOR).getValue() : null,
                configurations.getBooleanValue(NO_LOCAL),
                configurations.getStringValue(CONSUMER_TYPE).getValue(),
                configurations.containsKey(SUBSCRIBER_NAME) ?
                        configurations.getStringValue(SUBSCRIBER_NAME).getValue() : null
        );
    }
}
