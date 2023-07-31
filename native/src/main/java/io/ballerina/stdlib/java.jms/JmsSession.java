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
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Session;

import java.util.Objects;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_CONNECTION;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_SESSION;

/**
 * Representation of {@link javax.jms.Session} with utility methods to invoke as inter-op functions.
 */
public class JmsSession {

    /**
     * Creates a {@link javax.jms.Session} object with given {@link javax.jms.Connection}.
     *
     * @param session Ballerina session object
     * @param connection Ballerina connection object
     * @param ackMode Acknowledgment mode
     * @return A Ballerina `jms:Error` if the JMS provider fails to create the connection due to some internal error
     */
    public static Object init(BObject session, BObject connection, BString ackMode) {
        int sessionAckMode = getSessionAckMode(ackMode.getValue());
        try {
            Object nativeConnection = connection.getNativeData(NATIVE_CONNECTION);
            if (Objects.isNull(nativeConnection)) {
                return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                        StringUtils.fromString("Could not find the native JMS connection"), null, null);
            }
            boolean transacted = Session.SESSION_TRANSACTED == sessionAckMode;
            Session jmsSession = ((Connection) nativeConnection).createSession(transacted, sessionAckMode);
            session.addNativeData(NATIVE_SESSION, jmsSession);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString(String.format("Error while creating session: %s", e.getMessage())),
                    cause, null);
        }
        return null;
    }

    private static int getSessionAckMode(String ackMode) {
        if (Constants.SESSION_TRANSACTED_MODE.equals(ackMode)) {
            return Session.SESSION_TRANSACTED;
        } else if (Constants.AUTO_ACKNOWLEDGE_MODE.equals(ackMode)) {
            return Session.AUTO_ACKNOWLEDGE;
        } else if (Constants.CLIENT_ACKNOWLEDGE_MODE.equals(ackMode)) {
            return Session.CLIENT_ACKNOWLEDGE;
        } else {
            return Session.DUPS_OK_ACKNOWLEDGE;
        }
    }
}
