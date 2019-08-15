package org.wso2.ei.module.jms;

import org.ballerinalang.jvm.BRuntime;
import org.ballerinalang.jvm.values.ObjectValue;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;

public class JmsQueueReceiverUtils {

    private JmsQueueReceiverUtils() {
    }

    public static void setMessageListener(MessageConsumer consumer, ObjectValue balObject) throws BallerinaJmsException {
        BRuntime runtime = BRuntime.getCurrentRuntime();
        try {
            consumer.setMessageListener(new ListenerImpl(balObject, runtime));
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while setting the ");
        }
    }

    private static class ListenerImpl implements MessageListener {

        private final ObjectValue ballerinaObject;
        private final BRuntime runtime;

        ListenerImpl(ObjectValue ballerinaObject, BRuntime runtime) {
            this.ballerinaObject = ballerinaObject;
            this.runtime = runtime;
        }

        @Override
        public void onMessage(Message message) {
            Object[] args = {message, true};
            runtime.invokeMethod(ballerinaObject, "onMessage", args);
        }
    }

}
