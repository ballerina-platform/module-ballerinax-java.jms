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

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Properties;
import java.util.UUID;

import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import static io.ballerina.stdlib.java.jms.CommonUtils.getOptionalStringProperty;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.Constants.NATIVE_CONNECTION;

/**
 * Representation of {@link javax.jms.Connection} with utility methods to invoke as inter-op functions.
 */
public class JmsConnection {
    private static final BString INITIAL_CONTEXT_FACTORY = StringUtils.fromString("initialContextFactory");
    private static final BString PROVIDER_URL = StringUtils.fromString("providerUrl");
    private static final BString CONNECTION_FACTORY_NAME = StringUtils.fromString("connectionFactoryName");
    private static final BString USERNAME = StringUtils.fromString("username");
    private static final BString PASSWORD = StringUtils.fromString("password");
    private static final BString PROPERTIES = StringUtils.fromString("properties");

    /**
     * Creates a JMS connection with the provided configurations.
     *
     * @param connection Ballerina connection object
     * @param connectionConfig JMS configurations
     * @return A Ballerina `jms:Error` if the JMS provider fails to create the connection due to some internal error
     */
    public static Object init(BObject connection, BMap<BString, Object> connectionConfig) {
        try {
            Connection jmsConnection = createJmsConnection(connectionConfig);
            if (jmsConnection.getClientID() == null) {
                jmsConnection.setClientID(UUID.randomUUID().toString());
            }
            jmsConnection.setExceptionListener(new LoggingExceptionListener());
            jmsConnection.start();
            connection.addNativeData(NATIVE_CONNECTION, jmsConnection);
        } catch (BallerinaJmsException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString(e.getMessage()), cause, null);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while initializing and starring connection"),
                    cause, null);
        }
        return null;
    }

    private static Connection createJmsConnection(BMap<BString, Object> connectionConfigs)
            throws BallerinaJmsException {
        String connectionFactoryName = connectionConfigs.getStringValue(CONNECTION_FACTORY_NAME).getValue();
        Properties properties = getConnectionProperties(connectionConfigs, connectionFactoryName);
        try {
            InitialContext initialContext = new InitialContext(properties);
            ConnectionFactory connectionFactory =
                    (ConnectionFactory) initialContext.lookup(connectionFactoryName);
            Optional<String> userNameOpt = getOptionalStringProperty(connectionConfigs, USERNAME);
            Optional<String> passwordOpt = getOptionalStringProperty(connectionConfigs, PASSWORD);
            if (userNameOpt.isPresent() && passwordOpt.isPresent()) {
                String username = userNameOpt.get();
                String password = passwordOpt.get();
                if (!username.isBlank()) {
                    return connectionFactory.createConnection(username, password);
                }
            }
            return connectionFactory.createConnection();
        } catch (NamingException | JMSException e) {
            throw new BallerinaJmsException(
                    String.format("Error occurred while connecting to broker: %s", e.getMessage()), e);
        }
    }

    @SuppressWarnings("unchecked")
    private static Properties getConnectionProperties(BMap<BString, Object> connectionConfigs,
                                                      String connectionFactoryName) throws BallerinaJmsException {
        Map<String, String> configProperties = new HashMap<>();

        String initialContextFactory = connectionConfigs.getStringValue(INITIAL_CONTEXT_FACTORY).getValue();
        configProperties.put(Constants.ALIAS_INITIAL_CONTEXT_FACTORY, initialContextFactory);

        String providerUrl = connectionConfigs.getStringValue(PROVIDER_URL).getValue();
        configProperties.put(Constants.ALIAS_PROVIDER_URL, providerUrl);

        configProperties.put(Constants.ALIAS_CONNECTION_FACTORY_NAME, connectionFactoryName);

        preProcessIfWso2MB(configProperties);
        updateMappedParameters(configProperties);

        Properties properties = new Properties();
        properties.putAll(configProperties);
        BMap<BString, BString> additionalProperties = (BMap<BString, BString>) connectionConfigs
                .getMapValue(PROPERTIES);
        additionalProperties.entrySet().forEach(e -> {
            properties.setProperty(e.getKey().getValue(), e.getValue().getValue());
        });
        return properties;
    }

    private static void preProcessIfWso2MB(Map<String, String> configParams) throws BallerinaJmsException {
        String initialConnectionFactoryName = configParams.get(Constants.ALIAS_INITIAL_CONTEXT_FACTORY);
        if (Constants.BMB_ICF_ALIAS.equalsIgnoreCase(initialConnectionFactoryName)
                || Constants.MB_ICF_ALIAS.equalsIgnoreCase(initialConnectionFactoryName)) {

            configParams.put(Constants.ALIAS_INITIAL_CONTEXT_FACTORY, Constants.MB_ICF_NAME);
            String connectionFactoryName = configParams.get(Constants.ALIAS_CONNECTION_FACTORY_NAME);
            if (configParams.get(Constants.ALIAS_PROVIDER_URL) != null) {
                System.setProperty("qpid.dest_syntax", "BURL");
                if (Objects.nonNull(connectionFactoryName) && !connectionFactoryName.isBlank()) {
                    configParams.put(Constants.MB_CF_NAME_PREFIX + connectionFactoryName,
                            configParams.get(Constants.ALIAS_PROVIDER_URL));
                    configParams.remove(Constants.ALIAS_PROVIDER_URL);
                } else {
                    throw new BallerinaJmsException(
                            Constants.ALIAS_CONNECTION_FACTORY_NAME + " property should be set");
                }
            } else if (configParams.get(Constants.CONFIG_FILE_PATH) != null) {
                configParams.put(Constants.ALIAS_PROVIDER_URL, configParams.get(Constants.CONFIG_FILE_PATH));
                configParams.remove(Constants.CONFIG_FILE_PATH);
            }
        }
    }

    private static void updateMappedParameters(Map<String, String> configParams) {
        Iterator<Map.Entry<String, String>> iterator = configParams.entrySet().iterator();
        Map<String, String> tempMap = new HashMap<>();
        while (iterator.hasNext()) {
            Map.Entry<String, String> entry = iterator.next();
            String mappedParam = Constants.MAPPING_PARAMETERS.get(entry.getKey());
            if (mappedParam != null) {
                tempMap.put(mappedParam, entry.getValue());
                iterator.remove();
            }
        }
        configParams.putAll(tempMap);
    }

    /** Starts (or restarts) a connection's delivery of incoming messages.
     * A call to {@code start} on a connection that has already been started is ignored.
     *
     * @param connection Ballerina connection object
     * @return A Ballerina `jms:Error` if the JMS provider fails to start message delivery due to some internal error
     */
    public static Object start(BObject connection) {
        Object nativeConnection = connection.getNativeData(NATIVE_CONNECTION);
        if (Objects.nonNull(nativeConnection)) {
            try {
                ((Connection) nativeConnection).start();
                return null;
            } catch (JMSException exception) {
                BError cause = ErrorCreator.createError(exception);
                return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                        StringUtils.fromString("Error occurred while starting the connection"), cause, null);
            }
        }
        return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                StringUtils.fromString("Could not find the native JMS connection"), null, null);
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
        Object nativeConnection = connection.getNativeData(NATIVE_CONNECTION);
        if (Objects.nonNull(nativeConnection)) {
            try {
                ((Connection) nativeConnection).stop();
                return null;
            } catch (JMSException exception) {
                BError cause = ErrorCreator.createError(exception);
                return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                        StringUtils.fromString("Error occurred while stopping the connection"), cause, null);
            }
        }
        return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                StringUtils.fromString("Could not find the native JMS connection"), null, null);
    }

    /**
     * Closes the connection.
     *
     * @param connection Ballerina connection object
     * @return A Ballerina `jms:Error` if the JMS provider fails to close the
     *                  connection due to some internal error. For example, a failure to release resources or
     *                  to close a socket connection can cause this exception to be thrown.
     */
    public static Object close(BObject connection) {
        Object nativeConnection = connection.getNativeData(NATIVE_CONNECTION);
        if (Objects.nonNull(nativeConnection)) {
            try {
                ((Connection) nativeConnection).close();
                return null;
            } catch (JMSException exception) {
                BError cause = ErrorCreator.createError(exception);
                return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                        StringUtils.fromString("Error occurred while closing the connection"), cause, null);
            }
        }
        return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                StringUtils.fromString("Could not find the native JMS connection"), null, null);
    }
}
