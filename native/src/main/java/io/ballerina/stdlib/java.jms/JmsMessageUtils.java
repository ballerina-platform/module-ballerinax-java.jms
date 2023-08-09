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
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 * Representation of {@link javax.jms.BytesMessage} with utility methods to invoke as inter-op functions.
 */
public class JmsMessageUtils {

    /**
     * Writes a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param value   byte[] array as ballerina
     */
    public static Object writeBytes(BytesMessage message, BArray value) {
        try {
            byte[] bytes = value.getBytes();
            message.writeBytes(bytes);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while writing the bytes message."),
                    cause, null);
        }
        return null;
    }

    /**
     * Writes a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.MapMessage} object
     * @param fieldName Name of the map field
     * @param value   byte[] array as ballerina
     */
    public static Object writeBytesField(MapMessage message, String fieldName, BArray value) {
        try {
            byte[] bytes = value.getBytes();
            message.setBytes(fieldName, bytes);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while writing the bytes message."),
                    cause, null);
        }
        return null;
    }
}
