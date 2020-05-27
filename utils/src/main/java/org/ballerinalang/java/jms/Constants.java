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

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import javax.naming.Context;

import static org.ballerinalang.jvm.util.BLangConstants.VERSION_SEPARATOR;

/**
 * Constants for jms.
 *
 * @since 0.8.0
 */
public class Constants {

    static final String ORG = "ballerina";
    static final String PACKAGE_NAME = "java.jms";
    public static final String VERSION = "0.8.1";

    public static final String PACKAGE_NAME_WITH_VERSION = PACKAGE_NAME + VERSION_SEPARATOR + VERSION;

    // Destination types
    public static final String DESTINATION_TYPE_QUEUE = "queue";
    public static final String DESTINATION_TYPE_TOPIC = "topic";
    public static final String DESTINATION_TYPE_TEMP_QUEUE = "temporaryQueue";
    public static final String DESTINATION_TYPE_TEMP_TOPIC = "temporaryTopic";

    public static final String CONFIG_FILE_PATH = "configFilePath";

    /**
     * Parameters from the user.
     */
    public static final String ALIAS_CONNECTION_FACTORY_NAME = "connectionFactoryName";

    /**
     * Type of the connection factory. Whether queue or topic connection factory.
     */
    public static final String ALIAS_DESTINATION_TYPE = "destinationType";
    /**
     * jms destination.
     */
    public static final String ALIAS_DESTINATION = "destination";
    /**
     * Connection property factoryInitial parameter name.
     */
    public static final String ALIAS_INITIAL_CONTEXT_FACTORY = "initialContextFactory";
    /**
     * Connection property providerUrl parameter name.
     */
    public static final String ALIAS_PROVIDER_URL = "providerUrl";
    public static final String ALIAS_USERNAME = "username";
    public static final String ALIAS_PASSWORD = "password";
    public static final String ALIAS_ACK_MODE = "acknowledgementMode";
    public static final String ALIAS_CLIENT_ID = "clientId";
    public static final String ALIAS_DURABLE_SUBSCRIBER_ID = "subscriptionId";
    /**
     * Alias for MB initial context factory name.
     */
    public static final String MB_ICF_ALIAS = "wso2mbInitialContextFactory";
    public static final String BMB_ICF_ALIAS = "bmbInitialContextFactory";

    public static final String MB_ICF_NAME = "org.wso2.andes.jndi.PropertiesFileInitialContextFactory";
    public static final String MB_CF_NAME_PREFIX = "connectionfactory.";

    private static Map<String, String> mappingParameters;

    static final String PARAM_CONNECTION_FACTORY_JNDI_NAME = "transport.jms.ConnectionFactoryJNDIName";
    public static final String PARAM_CONNECTION_FACTORY_TYPE = "transport.jms.ConnectionFactoryType";
    public static final String PARAM_DESTINATION_NAME = "transport.jms.Destination";
    public static final String PARAM_ACK_MODE = "transport.jms.SessionAcknowledgement";
    public static final String PARAM_DURABLE_SUB_ID = "transport.jms.DurableSubscriberName";
    public static final String PARAM_CLIENT_ID = "transport.jms.DurableSubscriberClientId";
    static {
        mappingParameters = new HashMap<>();
        mappingParameters.put(ALIAS_INITIAL_CONTEXT_FACTORY, Context.INITIAL_CONTEXT_FACTORY);
        mappingParameters.put(ALIAS_CONNECTION_FACTORY_NAME, PARAM_CONNECTION_FACTORY_JNDI_NAME);
        mappingParameters.put(ALIAS_DESTINATION_TYPE, PARAM_CONNECTION_FACTORY_TYPE);
        mappingParameters.put(ALIAS_PROVIDER_URL, Context.PROVIDER_URL);
        mappingParameters.put(ALIAS_DESTINATION, PARAM_DESTINATION_NAME);
        mappingParameters.put(ALIAS_ACK_MODE, PARAM_ACK_MODE);
        mappingParameters.put(ALIAS_CLIENT_ID, PARAM_CLIENT_ID);
        mappingParameters.put(ALIAS_DURABLE_SUBSCRIBER_ID, PARAM_DURABLE_SUB_ID);
    }


    static final Map<String, String> MAPPING_PARAMETERS = Collections.unmodifiableMap(mappingParameters);

    /**
     * Acknowledge Modes.
     */
    static final String AUTO_ACKNOWLEDGE_MODE = "AUTO_ACKNOWLEDGE";

    static final String CLIENT_ACKNOWLEDGE_MODE = "CLIENT_ACKNOWLEDGE";
    static final String DUPS_OK_ACKNOWLEDGE_MODE = "DUPS_OK_ACKNOWLEDGE";
    static final String SESSION_TRANSACTED_MODE = "SESSION_TRANSACTED";

    static final String TEXT_MESSAGE_BAL_OBJECT_NAME = "TextMessage";
    static final String MESSAGE_BAL_OBJECT_NAME = "Message";
    static final String MAP_MESSAGE_BAL_OBJECT_NAME = "MapMessage";
    static final String BYTE_MESSAGE_BAL_OBJECT_NAME = "BytesMessage";
    static final String STREAM_MESSAGE_BAL_OBJECT_NAME = "StreamMessage";

    static final String SERVICE_RESOURCE_ON_MESSAGE = "onMessage";
    static final String SERVICE_RESOURCE_ON_TEXT_MESSAGE = "onTextMessage";
    static final String SERVICE_RESOURCE_ON_MAP_MESSAGE = "onMapMessage";
    static final String SERVICE_RESOURCE_ON_BYTES_MESSAGE = "onBytesMessage";
    static final String SERVICE_RESOURCE_ON_STREAM_MESSAGE = "onStreamMessage";
    static final String SERVICE_RESOURCE_ON_OTHER_MESSAGE = "onOtherMessage";

    private Constants() {
    }
}
