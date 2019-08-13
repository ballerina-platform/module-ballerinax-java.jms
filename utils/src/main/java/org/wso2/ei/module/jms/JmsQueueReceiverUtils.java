package org.wso2.ei.module.jms;

import org.ballerinalang.jvm.scheduling.Scheduler;
import org.ballerinalang.jvm.scheduling.Strand;
import org.ballerinalang.jvm.values.ObjectValue;

import java.io.File;
import java.util.function.Consumer;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;

public class JmsQueueReceiverUtils {

    private JmsQueueReceiverUtils() {
    }

//    private static Scheduler scheduler = new Scheduler(1, false);

//    static {
//        scheduler.start();
//    }

    public static void setMessageListener(MessageConsumer consumer, ObjectValue balObject) throws BallerinaJmsException {
        try {
            consumer.setMessageListener(new ListenerImpl(balObject));
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while setting the ");
        }
    }
    private static class ListenerImpl implements MessageListener {

        private final ObjectValue ballerinaObject;

        ListenerImpl(ObjectValue ballerinaObject) {
            this.ballerinaObject = ballerinaObject;
        }

        @Override
        public void onMessage(Message message) {
            Consumer func = o -> {
                Object[] objects = new Object[2];
                objects[0] = message;
                objects[1] = true;
                ballerinaObject.call((Strand) ((Object[]) o)[0], "onMessage", objects);
            };
            Object[] params = new Object[1];
//            scheduler.schedule(params, func, null);
        }
    }

}
