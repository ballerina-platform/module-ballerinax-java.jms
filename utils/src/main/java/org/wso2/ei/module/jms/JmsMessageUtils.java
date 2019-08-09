package org.wso2.ei.module.jms;

import javax.jms.BytesMessage;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.ObjectMessage;
import javax.jms.TextMessage;

public class JmsMessageUtils {

    private JmsMessageUtils() {}

    public static boolean isTextMessage(Message message) {
        return message instanceof TextMessage;
    }

    public static boolean isMapMessage(Message message) {
        return message instanceof MapMessage;
    }

    public static boolean isByteMessage(Message message) {
        return message instanceof BytesMessage;
    }

    public static boolean isObjectMessage(Message message) {
        return message instanceof ObjectMessage;
    }
}
