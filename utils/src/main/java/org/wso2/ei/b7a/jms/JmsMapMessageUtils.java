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

package org.wso2.ei.b7a.jms;

import org.ballerinalang.jvm.util.exceptions.BallerinaException;
import org.ballerinalang.jvm.values.ArrayValue;

import javax.jms.JMSException;
import javax.jms.MapMessage;
import java.util.Collections;
import java.util.List;

/**
 * Representation of {@link javax.jms.MapMessage} with utility methods to invoke as inter-op functions.
 */
public class JmsMapMessageUtils {

    /**
     * Return all names in the {@link javax.jms.MapMessage} as Ballerina array
     *
     * @param message {@link javax.jms.MapMessage} object
     * @return Ballerina array consist of map names
     * @throws BallerinaException throw a RuntimeException in an error situation
     */
    //TODO: Fix this workaround when Ballerina lang support to return primitive array and error as a union type
    public static ArrayValue getJmsMapNames(MapMessage message) {
        try {
            List<String> propertyNames = Collections.list(message.getMapNames());
            return new ArrayValue(propertyNames.toArray(new String[0]));

        } catch (JMSException e) {
            throw new BallerinaException("Error occurred while getting property names.", e);
        }
    }
}
