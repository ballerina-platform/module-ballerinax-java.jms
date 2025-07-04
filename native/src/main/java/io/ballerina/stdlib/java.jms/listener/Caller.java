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

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import java.util.Objects;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.Session;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_MESSAGE;
import static io.ballerina.stdlib.java.jms.listener.Listener.NATIVE_SESSION;

/**
 * Native class for the Ballerina JMS Caller.
 *
 * @since 1.2.0
 */
public class Caller {

    private Caller() {
    }

    public static Object commit(BObject caller) {
        Session nativeSession = (Session) caller.getNativeData(NATIVE_SESSION);
        try {
            nativeSession.commit();
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error while committing the JMS transaction: %s", exception.getMessage()), exception);
        }
        return null;
    }

    public static Object rollback(BObject caller) {
        Session nativeSession = (Session) caller.getNativeData(NATIVE_SESSION);
        try {
            nativeSession.rollback();
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error while rolling back the JMS transaction: %s", exception.getMessage()),
                    exception);
        }
        return null;
    }

    public static Object acknowledge(BMap<BString, Object> message) {
        try {
            Object nativeMessage = message.getNativeData(NATIVE_MESSAGE);
            if (Objects.nonNull(nativeMessage)) {
                ((Message) nativeMessage).acknowledge();
            }
        } catch (JMSException exception) {
            return createError(JMS_ERROR,
                    String.format("Error occurred while sending acknowledgement for the message: %s",
                            exception.getMessage()), exception);
        }
        return null;
    }
}
