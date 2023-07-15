package io.ballerina.stdlib.java.jms;

import javax.jms.Destination;
import javax.jms.Queue;
import javax.jms.TemporaryQueue;
import javax.jms.TemporaryTopic;
import javax.jms.Topic;

/**
 * Representation of {@link javax.jms.Destination} with utility methods to invoke as inter-op functions.
 */
public class JmsDestinationUtils {
    private JmsDestinationUtils() {}

    /**
     * Get the {@link javax.jms.Destination} type.
     *
     * @param destination {@link javax.jms.Destination} object
     * @return Ballerina Tuple represent {@link javax.jms.Destination}
     */
    public static String getDestinationType(Destination destination) {
        String destinationType = null;
        if (destination instanceof TemporaryQueue) {
            destinationType = Constants.DESTINATION_TYPE_TEMP_QUEUE;
        } else if (destination instanceof TemporaryTopic) {
            destinationType = Constants.DESTINATION_TYPE_TEMP_TOPIC;
        } else if (destination instanceof Queue) {
            destinationType = Constants.DESTINATION_TYPE_QUEUE;
        } else if (destination instanceof Topic) {
            destinationType = Constants.DESTINATION_TYPE_TOPIC;
        }
        return destinationType;
    }
}
