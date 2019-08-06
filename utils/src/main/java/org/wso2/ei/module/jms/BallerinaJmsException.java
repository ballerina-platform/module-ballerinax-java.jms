package org.wso2.ei.module.jms;

public class BallerinaJmsException extends Exception {

    BallerinaJmsException(String message) {
        super(message);
    }

    public BallerinaJmsException(String message, Throwable cause) {
        super(message, cause);
    }
}
