package io.ballerina.stdlib.java.jms;

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;

import javax.jms.BytesMessage;
import javax.jms.JMSException;

import static io.ballerina.stdlib.java.jms.Constants.JMS_ERROR;

/**
 * Representation of {@link javax.jms.BytesMessage} with utility methods to invoke as inter-op functions.
 */
public class JmsBytesMessageUtils {
    private JmsBytesMessageUtils() {
    }

    /**
     * Reads a byte array from the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @return Total number of bytes read into the buffer, or -1 if there is no more data
     */
    public static Object readJavaBytes(BytesMessage message) {
        try {
            int bodyLength = (int) message.getBodyLength();
            byte[] bytes = new byte[bodyLength];
            message.readBytes(bytes);
            return ValueCreator.createArrayValue(bytes);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while reading bytes message."), cause, null);
        }
    }

    /**
     * Reads a portion of the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param length  Number of bytes to read
     * @return Total number of bytes read into the buffer, or -1 if there is no more data
     */
    public static Object readPortionOfJavaBytes(BytesMessage message, int length) {
        try {
            long bodyLength = message.getBodyLength();
            if (length > bodyLength) {
                return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                        StringUtils.fromString("Length should be less than or equal to the message's body length."),
                        null, null);
            }
            byte[] bytes = new byte[length];
            message.readBytes(bytes, length);
            return ValueCreator.createArrayValue(bytes);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while reading portion of the bytes message."),
                    cause, null);
        }
    }

    /**
     * Writes a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param value   byte[] array as ballerina
     */
    public static Object writeBytes(BytesMessage message, BArray value) {
        try {
            byte[] bytes = value.getBytes();
            message.writeBytes(bytes);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while writing the bytes message."),
                    cause, null);
        }
        return null;
    }

    /**
     * Writes a portion of a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param value   byte[] array as ballerina {@link BArray}
     * @param offset  Initial offset within the byte array
     * @param length  Number of bytes to use
     */
    public static Object writePortionOfBytes(BytesMessage message, BArray value, int offset, int length)
            throws BallerinaJmsException {
        try {
            byte[] bytes = value.getBytes();
            message.writeBytes(bytes, offset, length);
        } catch (JMSException e) {
            BError cause = ErrorCreator.createError(e);
            return ErrorCreator.createError(ModuleUtils.getModule(), JMS_ERROR,
                    StringUtils.fromString("Error occurred while writing a portion of the bytes message."),
                    cause, null);
        }
        return null;
    }
}
