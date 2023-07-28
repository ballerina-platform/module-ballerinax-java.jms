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

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Representation of {@link javax.jms.Connection} with utility methods to invoke as inter-op functions.
 */
public class JmsConnection {
    private static final Logger LOGGER = LoggerFactory.getLogger(JmsConnection.class);

    /**
     * Creates a JMS connection with the provided configurations.
     *
     * @param connection Ballerina connection object
     * @param connectionConfigs JMS configurations
     * @return A Ballerina `jms:Error` if the JMS provider fails to create the connection due to some internal error
     */
    public static Object createConnection(BObject connection, BMap<BString, BObject> connectionConfigs) {
        return null;
    }

    /** Starts (or restarts) a connection's delivery of incoming messages.
     * A call to {@code start} on a connection that has already been started is ignored.
     *
     * @param connection Ballerina connection object
     * @return A Ballerina `jms:Error` if the JMS provider fails to start message delivery due to some internal error
     */
    public static Object start(BObject connection) {
        return null;
    }

    /**
     * Temporarily stops a connection's delivery of incoming messages. Delivery
     * can be restarted using the connection's {@code start} method. When
     * the connection is stopped, delivery to all the connection's message
     * consumers is inhibited: synchronous receives block, and messages are not
     * delivered to message listeners.
     *
     * @param connection Ballerina connection object
     * @return A Ballerina `jms:Error` if the JMS provider fails to stop message delivery for one
     *         of the following reasons:
     *         <ul>
     *          <li>an internal error has occurred or
     *          <li>this method has been called in a Java EE web or EJB application (though it is not guaranteed
     *          that an exception is thrown in this case)
     *         </ul>
     */
    public static Object stop(BObject connection) {
        return null;
    }
}
