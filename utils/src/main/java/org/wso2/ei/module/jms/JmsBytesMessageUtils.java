package org.wso2.ei.module.jms;

import org.ballerinalang.jvm.values.ArrayValue;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.MapMessage;

/**
 * Representation of {@link javax.jms.BytesMessage} with utility methods to invoke as inter-op functions.
 */
public class JmsBytesMessageUtils {

    /**
     * Reads a byte array from the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @return Total number of bytes read into the buffer, or -1 if there is no more data
     * @throws BallerinaJmsException in an error situation
     */
    public static ArrayValue readBytes(BytesMessage message) throws BallerinaJmsException {
        try {
            int bodyLength = (int)message.getBodyLength();
            byte[] bytes = new byte[bodyLength];
            message.readBytes(bytes);
            return new ArrayValue(bytes);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while reading bytes message.", e);
        }
    }

    /**
     * Reads a portion of the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param length Number of bytes to read
     * @return Total number of bytes read into the buffer, or -1 if there is no more data
     * @throws BallerinaJmsException in an error situation
     */
    public static ArrayValue readPortionOfBytes(BytesMessage message, int length)
            throws BallerinaJmsException {
        try {
            long bodyLength = message.getBodyLength();
            if (length > bodyLength) {
                throw new BallerinaJmsException("Length should be less than or equal to the message's body length.");
            }
            byte[] bytes = new byte[length];
            message.readBytes(bytes, length);
            return new ArrayValue(bytes);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while reading portion of the bytes message.", e);
        }
    }

    /**
     * Writes a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param value byte[] array as ballerina {@link ArrayValue}
     * @throws BallerinaJmsException in an error situation
     */
    public static void writeBytes(BytesMessage message, ArrayValue value) throws BallerinaJmsException {
        try {
            byte[] bytes = value.getBytes();
            message.writeBytes(bytes);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while writing the bytes message.", e);
        }
    }

    /**
     * Writes a portion of a byte array to the bytes message stream.
     *
     * @param message {@link javax.jms.BytesMessage} object
     * @param value byte[] array as ballerina {@link ArrayValue}
     * @param offset Initial offset within the byte array
     * @param length Number of bytes to use
     * @throws BallerinaJmsException in an error situation
     */
    public static void writePortionOfBytes(BytesMessage message, ArrayValue value, int offset, int length)
            throws BallerinaJmsException {
        try {
            byte[] bytes = value.getBytes();
            message.writeBytes(bytes, offset, length);
        } catch (JMSException e) {
            throw new BallerinaJmsException("Error occurred while reading bytes.", e);
        }
    }
}
