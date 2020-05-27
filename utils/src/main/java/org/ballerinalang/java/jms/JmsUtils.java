/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.ballerinalang.java.jms;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Utility class for JMS related common operations.
 */
public class JmsUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(JmsUtils.class);

    /**
     * Utility class cannot be instantiated.
     */
    private JmsUtils() {
    }

    /**
     * Check given string is not null or empty after trimming
     * @param str String value
     * @return true/false based on the input
     */
    static boolean notNullOrEmptyAfterTrim(String str) {
        return !(str == null || str.trim().isEmpty());
    }
}

