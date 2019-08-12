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

package org.wso2.ei.module.jms;

import org.ballerinalang.jvm.types.BTupleType;
import org.ballerinalang.jvm.types.BType;
import org.ballerinalang.jvm.types.BTypes;
import org.ballerinalang.jvm.values.ArrayValue;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.Queue;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;
import javax.jms.Topic;
import java.util.ArrayList;

public class JmsDestinationUtils {

    public static ArrayValue toDestination(Destination destination) throws BallerinaJmsException {
        String name = null;
        String type = null;
        try {
            if (destination instanceof TemporaryQueue) {
                name = ((TemporaryQueue) destination).getQueueName();
                type = JmsConstants.DESTINATION_TYPE_TEMP_QUEUE;
            } else if (destination instanceof TemporaryTopic) {
                name = ((TemporaryTopic) destination).getTopicName();
                type = JmsConstants.DESTINATION_TYPE_TEMP_TOPIC;
            } else if (destination instanceof Queue) {
                name = ((Queue) destination).getQueueName();
                type = JmsConstants.DESTINATION_TYPE_QUEUE;
            } else if (destination instanceof Topic) {
                name = ((Topic) destination).getTopicName();
                type = JmsConstants.DESTINATION_TYPE_TOPIC;
            }

            return new ArrayValue(new String[] {name, type}, new BTupleType(new ArrayList<BType>(){
                {
                    add(BTypes.typeString);
                    add(BTypes.typeString);
                }
            }));
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while extracting JMS Destination.", e);
        }
    }

}
