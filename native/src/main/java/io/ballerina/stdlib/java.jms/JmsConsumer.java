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
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import java.util.Objects;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;

import static io.ballerina.stdlib.java.jms.CommonUtils.getBallerinaMessage;

/**
 * Represents {@link javax.jms.MessageConsumer} related utility functions.
 */
public class JmsConsumer {
    public static Object init(BObject consumer, BObject session, BMap<BString, Object> consumerOptions) {
        return null;
    }

    public static Object receive(MessageConsumer consumer, long timeout) {
        try {
            Message message = consumer.receive(timeout);
            if (Objects.isNull(message)) {
                return null;
            }
            return getBallerinaMessage(message);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while receiving messages"), cause, null);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while processing the received messages"),
                    cause, null);
        } catch (Exception exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Unknown error occurred while processing the received messages"),
                    cause, null);
        }
    }

    public static Object receiveNoWait(MessageConsumer consumer) {
        try {
            Message message = consumer.receiveNoWait();
            if (Objects.isNull(message)) {
                return null;
            }
            return getBallerinaMessage(message);
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while receiving messages"), cause, null);
        } catch (BallerinaJmsException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while processing the received messages"),
                    cause, null);
        } catch (Exception exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Unknown error occurred while processing the received messages"),
                    cause, null);
        }
    }

    public static Object close(BObject consumer) {
        return null;
    }

    public static Object acknowledge(BMap<BString, Object> message) {
        try {
            Object nativeMessage = message.getNativeData(Constants.NATIVE_MESSAGE);
            if (Objects.nonNull(nativeMessage)) {
                ((Message) nativeMessage).acknowledge();
            }
        } catch (JMSException exception) {
            BError cause = ErrorCreator.createError(exception);
            return ErrorCreator.createError(ModuleUtils.getModule(), Constants.JMS_ERROR,
                    StringUtils.fromString("Error occurred while sending acknowledgement for the message"),
                    cause, null);
        }
        return null;
    }
}
