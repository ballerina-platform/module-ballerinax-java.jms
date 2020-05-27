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

import org.ballerinalang.jvm.values.MapValueImpl;
import org.ballerinalang.jvm.values.api.BMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;
import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.naming.InitialContext;
import javax.naming.NamingException;

/**
 * Representation of {@link javax.jms.Connection} with utility methods to invoke as inter-op functions.
 */
public class JmsConnectionUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(JmsConnectionUtils.class);

    private JmsConnectionUtils() {
    }

    /**
     * Creates a connection with the default user identity.
     *
     * @param initialContextFactory JNDI config that can be used to lookup JMS connection factory object
     * @param providerUrl URL of the JNDI provider.
     * @param connectionFactoryName Name of connection factory
     * @param optionalConfigs Other JMS configs
     * @return  {@link javax.jms.Connection} object
     * @throws BallerinaJmsException in an error situation
     */
    public static Connection createJmsConnection(String initialContextFactory, String providerUrl,
                                                 String connectionFactoryName,
                                                 BMap<String, String> optionalConfigs) throws BallerinaJmsException {
        Connection connection = createConnection(initialContextFactory, providerUrl, connectionFactoryName,
                                                          optionalConfigs);
        try {
            if (connection.getClientID() == null) {
                connection.setClientID(UUID.randomUUID().toString());
            }
            connection.setExceptionListener(new LoggingExceptionListener());
            connection.start();
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while starting connection.", e);
        }
        return connection;
    }

    /**
     * Starts (or restarts) a connection's delivery of incoming messages.
     *
     * @param connection {@javax.jms.Connection} object to start the connection
     * @throws BallerinaJmsException in an error situation
     */
    public static void startJmsConnection(Connection connection) throws BallerinaJmsException {
        try {
            connection.start();
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error starting connection", e);
        }
    }

    /**
     * Temporarily stops a connection's delivery of incoming messages.
     *
     * @param connection {@link javax.jms.Connection} object to stop the connection
     * @throws BallerinaJmsException in an error situation
     */
    public static void stopJmsConnection(Connection connection) throws BallerinaJmsException {
        try {
            connection.stop();
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error stopping connection", e);
        }
    }

    /**
     * Read ConnectionConfiguration and create connection with relevant JMS provider
     *
     * @param initialContextFactory JNDI config that can be used to lookup JMS connection factory object
     * @param providerUrl URL of the JNDI provider.
     * @param connectionFactoryName Name of connection factory
     * @param optionalConfigs Other JMS configs
     * @return  {@javax.jms.Connection} object
     * @throws BallerinaJmsException in an error situation
     */
    private static Connection createConnection(String initialContextFactory, String providerUrl,
                                              String connectionFactoryName ,
                                              BMap<String, String> optionalConfigs) throws BallerinaJmsException{
        Map<String, String> configParams = new HashMap<>();
        configParams.put(Constants.ALIAS_INITIAL_CONTEXT_FACTORY, initialContextFactory);
        configParams.put(Constants.ALIAS_PROVIDER_URL, providerUrl);
        configParams.put(Constants.ALIAS_CONNECTION_FACTORY_NAME, connectionFactoryName);

        preProcessIfWso2MB(configParams);
        updateMappedParameters(configParams);

        Properties properties = new Properties();
        configParams.forEach(properties::put);
        optionalConfigs.entrySet().forEach(e -> {
            properties.setProperty(e.getKey(), e.getValue());
        });

        try {
            InitialContext initialContext = new InitialContext(properties);
            ConnectionFactory connectionFactory = (ConnectionFactory) initialContext.lookup(connectionFactoryName);
            String username = optionalConfigs.get(Constants.ALIAS_USERNAME);
            String password = optionalConfigs.get(Constants.ALIAS_PASSWORD);

            if (JmsUtils.notNullOrEmptyAfterTrim(username) && password != null) {
                return connectionFactory.createConnection(username, password);
            } else {
                return connectionFactory.createConnection();
            }
        } catch (NamingException | JMSException e) {
            String message = "Error while connecting to broker.";
            LOGGER.error(message, e);
            throw new BallerinaJmsException(message + " " + e.getMessage(), e);
        }
    }


    /**
     * If ConnectionConfiguration, then default to WSO2 MB as the JMS provider
     *
     * @param configParams JMS provider specific parameters
     * @throws BallerinaJmsException in an error situation
     */
    private static void preProcessIfWso2MB(Map<String, String> configParams) throws BallerinaJmsException {
        String initialConnectionFactoryName = configParams.get(Constants.ALIAS_INITIAL_CONTEXT_FACTORY);
        if (Constants.BMB_ICF_ALIAS.equalsIgnoreCase(initialConnectionFactoryName)
            || Constants.MB_ICF_ALIAS.equalsIgnoreCase(initialConnectionFactoryName)) {

            configParams.put(Constants.ALIAS_INITIAL_CONTEXT_FACTORY, Constants.MB_ICF_NAME);
            String connectionFactoryName = configParams.get(Constants.ALIAS_CONNECTION_FACTORY_NAME);
            if (configParams.get(Constants.ALIAS_PROVIDER_URL) != null) {
                System.setProperty("qpid.dest_syntax", "BURL");
                if (JmsUtils.notNullOrEmptyAfterTrim(connectionFactoryName)) {
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

    /**
     * Update JMS provider specific config parameter
     *
     * @param configParams JMS provider specific parameters
     */
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
}
