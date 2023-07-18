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
import io.ballerina.runtime.api.values.BString;

import java.util.Collections;
import java.util.List;

import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 * Representation of {@link javax.jms.MapMessage} with utility methods to invoke as inter-op functions.
 */
public class JmsMapMessageUtils {
    private JmsMapMessageUtils() {}

    /**
     * Return all names in the {@link javax.jms.MapMessage} as Ballerina array.
     *
     * @param message {@link javax.jms.MapMessage} object
     * @return Ballerina array consist of map names
     */
    public static Object getJmsMapNames(MapMessage message) {
        try {
            List<String> propertyNames = Collections.list(message.getMapNames());
            return ValueCreator.createArrayValue(propertyNames.toArray(new BString[0]));
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while getting property names"), cause, null);
        }
    }

    /**
     * Returns the byte array value with the specified name.
     *
     * @param message {@link javax.jms.Message} object
     * @param name Field name
     * @return a copy of the byte array value with the specified name; if there is no item by this name,
     * a null value is returned.
     */
    public static Object getBytes(Message message, String name) {
        try {
            MapMessage m = (MapMessage) message;
            byte[] bytearray = m.getBytes(name);
            return ValueCreator.createArrayValue(bytearray);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while getting property names."), cause, null);
        }
    }
}
