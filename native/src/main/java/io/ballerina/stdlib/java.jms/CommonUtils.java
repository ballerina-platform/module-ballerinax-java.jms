package io.ballerina.stdlib.java.jms;

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import java.util.Optional;

/**
 * {@code CommonUtils} contains the common utility functions related to JMS interop functions.
 */
public class CommonUtils {
    public static Optional<String> getOptionalStringProperty(BMap<BString, BObject> configs,
                                                             BString fieldName) {
        if (configs.containsKey(fieldName)) {
            return Optional.of(configs.getStringValue(fieldName).getValue());
        }
        return Optional.empty();
    }
}
