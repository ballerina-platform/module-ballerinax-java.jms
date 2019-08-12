package org.wso2.ei.module.jms;

import org.ballerinalang.jvm.types.BArrayType;
import org.ballerinalang.jvm.types.BTypes;
import org.ballerinalang.jvm.values.ArrayValue;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.ObjectMessage;
import javax.jms.TextMessage;
import java.util.ArrayList;
import java.util.Collections;

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

    public static ArrayValue getPropertyNames(Message message) throws BallerinaJmsException {
        try {
            ArrayList propertyNames = Collections.list(message.getPropertyNames());
            return new ArrayValue(propertyNames.toArray(), new BArrayType(BTypes.typeString));

        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while getting property names.", e);
        }
    }
}
