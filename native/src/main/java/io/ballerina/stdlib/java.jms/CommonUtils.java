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

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Objects;
import java.util.Optional;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;
import javax.jms.Topic;

/**
 * {@code CommonUtils} contains the common utility functions for the Ballerina JMS connector.
 */
public class CommonUtils {
    private static final BString DESTINATION_TYPE = StringUtils.fromString("type");
    private static final BString DESTINATION_NAME = StringUtils.fromString("name");
    private static final BString QUEUE = StringUtils.fromString("QUEUE");
    private static final BString TEMPORARY_QUEUE = StringUtils.fromString("TEMPORARY_QUEUE");
    private static final BString TOPIC = StringUtils.fromString("TOPIC");
    private static final BString TEMPORARY_TOPIC = StringUtils.fromString("TEMPORARY_TOPIC");

    public static BError createError(String errorType, String message) {
        return createError(errorType, message, null);
    }

    public static BError createError(String errorType, String message, Throwable throwable) {
        BError cause = null;
        if (throwable != null) {
            cause = ErrorCreator.createError(throwable);
        }
        return ErrorCreator.createError(
                ModuleUtils.getModule(), errorType, StringUtils.fromString(message), cause, null);
    }

    public static Optional<String> getOptionalStringProperty(BMap<BString, Object> config, BString fieldName) {
        if (config.containsKey(fieldName)) {
            return Optional.of(config.getStringValue(fieldName).getValue());
        }
        return Optional.empty();
    }

    @SuppressWarnings("unchecked")
    public static Destination getDestinationOrNull(Session session, Object destination)
            throws JMSException, BallerinaJmsException {
        if (Objects.isNull(destination)) {
            return null;
        }

        return getDestination(session, (BMap<BString, Object>) destination);
    }

    public static Destination getDestination(Session session, BMap<BString, Object> destinationConfig)
            throws BallerinaJmsException, JMSException {
        BString destinationType = destinationConfig.getStringValue(DESTINATION_TYPE);
        Optional<String> destinationNameOpt = getOptionalStringProperty(destinationConfig, DESTINATION_NAME);
        if (QUEUE.equals(destinationType) || TOPIC.equals(destinationType)) {
            if (destinationNameOpt.isEmpty()) {
                throw new BallerinaJmsException(
                        String.format("JMS destination name can not be empty for destination type: %s", destinationType)
                );
            }
        }
        if (QUEUE.equals(destinationType)) {
            return session.createQueue(destinationNameOpt.get());
        } else if (TEMPORARY_QUEUE.equals(destinationType)) {
            return session.createTemporaryQueue();
        } else if (TOPIC.equals(destinationType)) {
            return session.createTopic(destinationNameOpt.get());
        } else {
            return session.createTemporaryTopic();
        }
    }

    public static BMap<BString, Object> getJmsDestinationField(Destination destination) throws JMSException {
        BMap<BString, Object> values = ValueCreator.createMapValue();
        if (destination instanceof TemporaryQueue) {
            values.put(DESTINATION_TYPE, TEMPORARY_QUEUE);
        } else if (destination instanceof Queue) {
            String queueName = ((Queue) destination).getQueueName();
            values.put(DESTINATION_TYPE, QUEUE);
            values.put(DESTINATION_NAME, StringUtils.fromString(queueName));
        } else if (destination instanceof TemporaryTopic) {
            values.put(DESTINATION_TYPE, TEMPORARY_TOPIC);
        } else {
            String topicName = ((Topic) destination).getTopicName();
            values.put(DESTINATION_TYPE, TOPIC);
            values.put(DESTINATION_NAME, StringUtils.fromString(topicName));
        }
        return ValueCreator.createReadonlyRecordValue(ModuleUtils.getModule(), "Destination", values);
    }
}
