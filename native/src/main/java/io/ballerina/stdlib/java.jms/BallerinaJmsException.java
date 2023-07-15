package io.ballerina.stdlib.java.jms;

/**
 * Representation of the custom exception in the JMS module.
 */
public class BallerinaJmsException extends Exception {

    BallerinaJmsException(String message) {
        super(message);
    }

    public BallerinaJmsException(String message, Throwable cause) {
        super(message, cause);
    }
}
