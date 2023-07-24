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
import io.ballerina.runtime.api.values.BString;
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

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 * Representation of {@link javax.jms.Connection} with utility methods to invoke as inter-op functions.
 */
public class JmsConnectionUtils {
    private static final Logger LOGGER = LoggerFactory.getLogger(JmsConnectionUtils.class);

    /**
     * Creates a connection with the default user identity.
     *
     * @param initialContextFactory JNDI config that can be used to lookup JMS connection factory object
     * @param providerUrl URL of the JNDI provider.
     * @param connectionFactoryName Name of connection factory
     * @param optionalConfigs Other JMS configs
     * @return  {@link javax.jms.Connection} object or else an error
     */
    public static Object createJmsConnection(BString initialContextFactory, BString providerUrl,
                                             BString connectionFactoryName, BMap<BString, BString> optionalConfigs) {
        try {
            Connection connection = createConnection(
                    initialContextFactory, providerUrl, connectionFactoryName, optionalConfigs);
            if (connection.getClientID() == null) {
                connection.setClientID(UUID.randomUUID().toString());
            }
            connection.setExceptionListener(new LoggingExceptionListener());
            connection.start();
            return connection;
        } catch (BallerinaJmsException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString(e.getMessage()), cause, null);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while starting connection"), cause, null);
        }
    }

    private static Connection createConnection(BString initialContextFactory, BString providerUrl,
                                               BString connectionFactoryName, BMap<BString, BString> optionalConfigs)
            throws BallerinaJmsException {
        Map<String, String> configParams = new HashMap<>();
        configParams.put(Constants.ALIAS_INITIAL_CONTEXT_FACTORY, initialContextFactory.getValue());
        configParams.put(Constants.ALIAS_PROVIDER_URL, providerUrl.getValue());
        configParams.put(Constants.ALIAS_CONNECTION_FACTORY_NAME, connectionFactoryName.getValue());

        preProcessIfWso2MB(configParams);
        updateMappedParameters(configParams);

        Properties properties = new Properties();
        properties.putAll(configParams);
        optionalConfigs.entrySet().forEach(e -> {
            properties.setProperty(e.getKey().getValue(), e.getValue().getValue());
        });

        try {
            String password = null;
            String username = null;
            InitialContext initialContext = new InitialContext(properties);
            ConnectionFactory connectionFactory =
                    (ConnectionFactory) initialContext.lookup(connectionFactoryName.getValue());
            if (optionalConfigs.containsKey(Constants.ALIAS_USERNAME)) {
                username = optionalConfigs.get(Constants.ALIAS_USERNAME).getValue();
            }
            if (optionalConfigs.containsKey(Constants.ALIAS_PASSWORD)) {
                password = optionalConfigs.get(Constants.ALIAS_PASSWORD).getValue();
            }
            if (notNullOrEmptyAfterTrim(username) && password != null) {
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

    private static void preProcessIfWso2MB(Map<String, String> configParams) throws BallerinaJmsException {
        String initialConnectionFactoryName = configParams.get(Constants.ALIAS_INITIAL_CONTEXT_FACTORY);
        if (Constants.BMB_ICF_ALIAS.equalsIgnoreCase(initialConnectionFactoryName)
                || Constants.MB_ICF_ALIAS.equalsIgnoreCase(initialConnectionFactoryName)) {

            configParams.put(Constants.ALIAS_INITIAL_CONTEXT_FACTORY, Constants.MB_ICF_NAME);
            String connectionFactoryName = configParams.get(Constants.ALIAS_CONNECTION_FACTORY_NAME);
            if (configParams.get(Constants.ALIAS_PROVIDER_URL) != null) {
                System.setProperty("qpid.dest_syntax", "BURL");
                if (notNullOrEmptyAfterTrim(connectionFactoryName)) {
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

    private static boolean notNullOrEmptyAfterTrim(String str) {
        return !(str == null || str.trim().isEmpty());
    }
}
