package io.ballerina.stdlib.java.jms;

import io.ballerina.runtime.api.async.Callback;
import io.ballerina.runtime.api.values.BError;

/**
 * Callback code to be executed when the message-listener complete a message producing cycle to the ballerina service.
 */
public class ConsumerCallback implements Callback {
    @Override
    public void notifySuccess(Object o) {
        if (o instanceof BError) {
            ((BError) o).printStackTrace();
        }
    }

    @Override
    public void notifyFailure(BError bError) {
        bError.printStackTrace();
        System.exit(1);
    }
}
