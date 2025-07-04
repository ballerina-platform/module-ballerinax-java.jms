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

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.java.jms.BallerinaJmsException;
import io.ballerina.stdlib.java.jms.LoggingExceptionListener;

import java.util.Objects;
import java.util.UUID;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.MessageConsumer;
import javax.jms.Queue;
import javax.jms.Session;
import javax.jms.Topic;

import static io.ballerina.stdlib.java.jms.CommonUtils.createError;
import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;
import static io.ballerina.stdlib.java.jms.JmsConnection.createJmsConnection;
import static io.ballerina.stdlib.java.jms.JmsSession.getSessionAckMode;

/**
 * Native class for the Ballerina JMS Listener.
 *
 * @since 1.2.0
 */
public final class Listener {
    static final String NATIVE_CONNECTION = "native.connection";
    static final String NATIVE_SERVICE = "native.service";
    static final String NATIVE_SESSION = "native.session";
    static final String NATIVE_CONSUMER = "native.consumer";

    private Listener() {
    }

    public static Object init(BObject bListener, BMap<BString, Object> connectionConfig) {
        try {
            Connection jmsConnection = createJmsConnection(connectionConfig);
            if (jmsConnection.getClientID() == null) {
                jmsConnection.setClientID(UUID.randomUUID().toString());
            }
            jmsConnection.setExceptionListener(new LoggingExceptionListener());
            bListener.addNativeData(NATIVE_CONNECTION, jmsConnection);
        } catch (BallerinaJmsException e) {
            return createError(JMS_ERROR, e.getMessage(), e);
        } catch (JMSException e) {
            String errorMsg = Objects.isNull(e.getMessage()) ? "Unknown error" : e.getMessage();
            return createError(JMS_ERROR,
                    String.format("Error occurred while initializing the Ballerina JMS listener: %s", errorMsg), e);
        }
        return null;
    }

    public static Object attach(Environment environment, BObject bListener, BObject bService, Object name) {
        Connection connection = (Connection) bListener.getNativeData(NATIVE_CONNECTION);
        try {
            Service.validateService(bService);
            Service nativeService = new Service(bService);
            ServiceConfig svcConfig = nativeService.getServiceConfig();
            int sessionAckMode = getSessionAckMode(svcConfig.ackMode());
            boolean transacted = Session.SESSION_TRANSACTED == sessionAckMode;
            Session session = connection.createSession(transacted, sessionAckMode);
            MessageConsumer consumer = getConsumer(session, svcConfig);
            MessageDispatcher messageDispatcher = new MessageDispatcher(
                    environment.getRuntime(), nativeService, session);
            consumer.setMessageListener(messageDispatcher);
            bService.addNativeData(NATIVE_SERVICE, nativeService);
            bService.addNativeData(NATIVE_SESSION, session);
            bService.addNativeData(NATIVE_CONSUMER, consumer);
        } catch (BError | JMSException e) {
            String errorMsg = Objects.isNull(e.getMessage()) ? "Unknown error" : e.getMessage();
            return createError(JMS_ERROR, String.format("Failed to attach service to listener: %s", errorMsg), e);
        }
        return null;
    }

    private static MessageConsumer getConsumer(Session session, ServiceConfig svcConfig)
            throws JMSException {
        if (svcConfig instanceof QueueConfig queueConfig) {
            Queue queue = session.createQueue(queueConfig.queueName());
            return session.createConsumer(queue, queueConfig.messageSelector());
        }
        TopicConfig topicConfig = (TopicConfig) svcConfig;
        Topic topic = session.createTopic(topicConfig.topicName());
        switch (topicConfig.consumerType()) {
            case "DURABLE" -> {
                return session.createDurableConsumer(
                        topic, topicConfig.subscriberName(), topicConfig.messageSelector(), topicConfig.noLocal());
            }
            case "SHARED" -> {
                return session.createSharedConsumer(topic, topicConfig.subscriberName(), topicConfig.messageSelector());
            }
            case "SHARED_DURABLE" -> {
                return session.createSharedDurableConsumer(
                        topic, topicConfig.subscriberName(), topicConfig.messageSelector());
            }
            default -> {
                return session.createConsumer(topic, topicConfig.messageSelector(), topicConfig.noLocal());
            }
        }
    }

    public static Object detach(BObject bService) {
        Session session = (Session) bService.getNativeData(NATIVE_SESSION);
        MessageConsumer consumer = (MessageConsumer) bService.getNativeData(NATIVE_CONSUMER);
        try {
            if (Objects.isNull(session)) {
                throw new BallerinaJmsException("Could not find the native JMS session");
            }
            if (Objects.isNull(consumer)) {
                throw new BallerinaJmsException("Could not find the native JMS consumer");
            }

            consumer.close();
            session.close();
        } catch (Exception e) {
            String errorMsg = Objects.isNull(e.getMessage()) ? "Unknown error" : e.getMessage();
            return createError(JMS_ERROR,
                    String.format("Failed to detach a service from the listener: %s", errorMsg), e);
        }
        return null;
    }

    public static Object start(BObject bListener) {
        Connection connection = (Connection) bListener.getNativeData(NATIVE_CONNECTION);
        try {
            connection.start();
        } catch (JMSException e) {
            String errorMsg = Objects.isNull(e.getMessage()) ? "Unknown error" : e.getMessage();
            return createError(JMS_ERROR,
                    String.format("Error occurred while starting the Ballerina JMS listener: %s", errorMsg), e);
        }
        return null;
    }

    public static Object gracefulStop(BObject bListener) {
        Connection nativeConnection = (Connection) bListener.getNativeData(NATIVE_CONNECTION);
        try {
            nativeConnection.stop();
            nativeConnection.close();
        } catch (JMSException e) {
            String errorMsg = Objects.isNull(e.getMessage()) ? "Unknown error" : e.getMessage();
            return createError(JMS_ERROR,
                    String.format("Error occurred while gracefully stopping the Ballerina JMS listener: %s", errorMsg),
                    e);
        }
        return null;
    }

    public static Object immediateStop(BObject bListener) {
        Connection nativeConnection = (Connection) bListener.getNativeData(NATIVE_CONNECTION);
        try {
            nativeConnection.stop();
            nativeConnection.close();
        } catch (JMSException e) {
            String errorMsg = Objects.isNull(e.getMessage()) ? "Unknown error" : e.getMessage();
            return createError(JMS_ERROR,
                    String.format("Error occurred while gracefully stopping the Ballerina JMS listener: %s", errorMsg),
                    e);
        }
        return null;
    }
}
