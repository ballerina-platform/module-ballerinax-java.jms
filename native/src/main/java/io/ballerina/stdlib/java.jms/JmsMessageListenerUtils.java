package io.ballerina.stdlib.java.jms;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;

import javax.jms.JMSException;
import javax.jms.MessageConsumer;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 * Representation of {@link javax.jms.MessageListener} with utility methods to invoke as inter-op functions.
 */
public class JmsMessageListenerUtils {
    private JmsMessageListenerUtils() {
    }

    public static Object setMessageListener(Environment environment, MessageConsumer consumer,
                                            BObject serviceObject) {
        Runtime bRuntime = environment.getRuntime();
        try {
            consumer.setMessageListener(new JmsListener(serviceObject, bRuntime));
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while setting the message listener"), cause, null);
        }
        return null;
    }
}
