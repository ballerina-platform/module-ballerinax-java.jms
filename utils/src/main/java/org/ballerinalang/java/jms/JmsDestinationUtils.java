/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.ballerinalang.java.jms;

import org.ballerinalang.jvm.types.BTupleType;
import org.ballerinalang.jvm.types.BType;
import org.ballerinalang.jvm.types.BTypes;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.HandleValue;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;
import javax.jms.Topic;

/**
 * Representation of {@link javax.jms.Destination} with utility methods to invoke as inter-op functions.
 */
public class JmsDestinationUtils {

    /**
     * Get the {@link javax.jms.Destination} type
     *
     * @param destination {@link javax.jms.Destination} object
     * @return Ballerina Tuple represent {@link javax.jms.Destination}
     */
    public static String getDestinationType(Destination destination) {
        String destinationType = null;

        if (destination instanceof TemporaryQueue) {
            destinationType = Constants.DESTINATION_TYPE_TEMP_QUEUE;
        } else if (destination instanceof TemporaryTopic) {
            destinationType = Constants.DESTINATION_TYPE_TEMP_TOPIC;
        } else if (destination instanceof Queue) {
            destinationType = Constants.DESTINATION_TYPE_QUEUE;
        } else if (destination instanceof Topic) {
            destinationType = Constants.DESTINATION_TYPE_TOPIC;
        }

        return destinationType;
    }

}
