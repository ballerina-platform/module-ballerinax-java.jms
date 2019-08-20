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

package org.wso2.ei.module.jms;

import static org.ballerinalang.jvm.util.BLangConstants.VERSION_SEPARATOR;

/**
 * Constants for jms.
 *
 * @since 0.8.0
 */
class Constants {

    static final String PACKAGE_NAME = "wso2/jms";
    static final String VERSION = "0.6.0";

    static final String PACKAGE_NAME_WITH_VERSION = PACKAGE_NAME + VERSION_SEPARATOR + VERSION;
    static final String MESSAGE_BAL_OBJECT_NAME = "Message";
    static final String RESOURCE_NAME = "onMessage";
    static final String MESSAGE_BAL_OBJECT_FULL_NAME = PACKAGE_NAME_WITH_VERSION + ":" + MESSAGE_BAL_OBJECT_NAME;

    private Constants() {
    }
}
