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

package org.wso2.ei.b7a.jms;

import org.ballerinalang.compiler.plugins.SupportedResourceParamTypes;
import org.ballerinalang.compiler.plugins.AbstractCompilerPlugin;
import org.ballerinalang.model.tree.AnnotationAttachmentNode;
import org.ballerinalang.model.tree.FunctionNode;
import org.ballerinalang.model.tree.ServiceNode;
import org.ballerinalang.util.diagnostic.Diagnostic;
import org.ballerinalang.util.diagnostic.DiagnosticLog;
import org.wso2.ballerinalang.compiler.semantics.analyzer.Types;
import org.wso2.ballerinalang.compiler.semantics.model.types.BType;
import org.wso2.ballerinalang.compiler.tree.BLangFunction;
import org.wso2.ballerinalang.compiler.tree.BLangSimpleVariable;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.ballerinalang.jvm.util.BLangConstants.VERSION_SEPARATOR;

/**
 * Abstract Compiler plugin for validating Jms Listener services.
 *
 * @since 0.995.0
 */
@SupportedResourceParamTypes(expectedListenerType = @SupportedResourceParamTypes.Type(orgName = "wso2", packageName = "jms",
                                                                                      name = "MessageListener"),
                             paramTypes = {
                                     @SupportedResourceParamTypes.Type(orgName = "wso2", packageName = "jms", name = "Message")
                             }
)
public class ServiceCompilerPlugin extends AbstractCompilerPlugin {

    private static final String PACKAGE_NAME = "wso2/jms";
    private static final String VERSION = "0.7.0";

    private static final String PACKAGE_NAME_WITH_VERSION = PACKAGE_NAME + VERSION_SEPARATOR + VERSION;
    private static final String MESSAGE_NAME = "Message";
    private static final String TEXT_MESSAGE_NAME = "TextMessage";
    private static final String MAP_MESSAGE_NAME = "MapMessage";
    private static final String STREAM_MESSAGE_NAME= "StreamMessage";
    private static final String BYTES_MESSAGE_NAME = "BytesMessage";

    private static final String RESOURCE_NAME_ON_MESSAGE = "onMessage";
    private static final String RESOURCE_NAME_ON_TEXT_MESSAGE = "onTextMessage";
    private static final String RESOURCE_NAME_ON_MAP_MESSAGE = "onMapMessage";
    private static final String RESOURCE_NAME_ON_BYTES_MESSAGE = "onBytesMessage";
    private static final String RESOURCE_NAME_ON_STREAM_MESSAGE = "onStreamMessage";
    private static final String RESOURCE_NAME_ON_OTHER_MESSAGE = "onOtherMessage";
    private static final Set<String> SPECIFIC_FUNCTION_SET;
    static {
        SPECIFIC_FUNCTION_SET =  new HashSet<String>() {
            {
                add(RESOURCE_NAME_ON_TEXT_MESSAGE);
                add(RESOURCE_NAME_ON_MAP_MESSAGE);
                add(RESOURCE_NAME_ON_BYTES_MESSAGE);
                add(RESOURCE_NAME_ON_STREAM_MESSAGE);
            }
        };
    }

    private static final String MESSAGE_FULL_NAME = PACKAGE_NAME_WITH_VERSION + ":" + MESSAGE_NAME;
    private static final String TEXT_MESSAGE_FULL_NAME = PACKAGE_NAME_WITH_VERSION + ":" + TEXT_MESSAGE_NAME;
    private static final String MAP_MESSAGE_FULL_NAME = PACKAGE_NAME_WITH_VERSION + ":" + MAP_MESSAGE_NAME;
    private static final String BYTES_MESSAGE_FULL_NAME = PACKAGE_NAME_WITH_VERSION + ":" + BYTES_MESSAGE_NAME;
    private static final String STREAM_MESSAGE_FULL_NAME = PACKAGE_NAME_WITH_VERSION + ":" + STREAM_MESSAGE_NAME;
    private static final String INVALID_RESOURCE_SIGNATURE_FOR = "Invalid resource signature for ";

    private DiagnosticLog dlog = null;
    private Types types = null;
    private BType errorOrNil = null;

    @Override
    public void init(DiagnosticLog diagnosticLog) {
        dlog = diagnosticLog;
    }

    @Override
    public void process(ServiceNode serviceNode, List<AnnotationAttachmentNode> annotations) {

        if (!annotations.isEmpty()) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, serviceNode.getPosition(),
                               "The JMS service does not have a service annotation");
        }

        List<BLangFunction> resources = (List<BLangFunction>) serviceNode.getResources();

        if (resources.isEmpty()) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, serviceNode.getPosition(),
                               "service: at least on resource is expected.");
        }
        if (resources.size() == 1) {
            BLangFunction resource = resources.get(0);
            if (!RESOURCE_NAME_ON_MESSAGE.equals(resource.name.value)) {
                dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos,
                                   "resource: Expected resource name is [" + RESOURCE_NAME_ON_MESSAGE
                                   + "] or one or more of message specific resources with "
                                   +  "[" + RESOURCE_NAME_ON_OTHER_MESSAGE + "] resource.");
            }
        } else {
            boolean otherFunctionFound = false;
            for(BLangFunction resource: resources) {
                if (!isResourceReturnsErrorOrNil(resource)) {
                    dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos, "Invalid return type: expected error?");
                }

                if (!otherFunctionFound && RESOURCE_NAME_ON_OTHER_MESSAGE.equals(resource.getName().getValue()) ) {
                    validateParameter(resource, MESSAGE_FULL_NAME);
                    otherFunctionFound = true;
                } else {
                    validateSpecificFunction(resource);
                }
            }

            if (!otherFunctionFound) {
                dlog.logDiagnostic(Diagnostic.Kind.ERROR, serviceNode.getPosition(),
                                   "resource: Expected resource name [" + RESOURCE_NAME_ON_OTHER_MESSAGE + "] not specified.");
            }
        }

    }

    private void validateSpecificFunction(BLangFunction resource) {
        String resourceName = resource.getName().getValue();
        if (RESOURCE_NAME_ON_MESSAGE.equals(resourceName)) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos,
                               "resource: [" + RESOURCE_NAME_ON_MESSAGE + "] cannot be used with message type" +
                               " specific resources and [" + RESOURCE_NAME_ON_OTHER_MESSAGE + "] resource.");
        }

        if (RESOURCE_NAME_ON_TEXT_MESSAGE.equals(resourceName)) {
            validateParameter(resource, TEXT_MESSAGE_FULL_NAME);
        } else if (RESOURCE_NAME_ON_BYTES_MESSAGE.equals(resourceName)) {
            validateParameter(resource, BYTES_MESSAGE_FULL_NAME);
        } else if (RESOURCE_NAME_ON_MAP_MESSAGE.equals(resourceName)) {
            validateParameter(resource, MAP_MESSAGE_FULL_NAME);
        } else if (RESOURCE_NAME_ON_STREAM_MESSAGE.equals(resourceName)) {
            validateParameter(resource, STREAM_MESSAGE_FULL_NAME);
        } else {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos,
                               "resource: Unknown resource name [" + resourceName + "]");
        }
    }

    private void validateParameter(BLangFunction resource, String messageFullName) {
        List<BLangSimpleVariable> paramDetails = resource.getParameters();
        if (paramDetails == null || paramDetails.size() != 1) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos, INVALID_RESOURCE_SIGNATURE_FOR
                                                                    + resource.getName().getValue() +
                                                                    " Expected " + messageFullName + " parameter only.");
        } else if (!messageFullName.equals(paramDetails.get(0).type.toString())) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos,
                               INVALID_RESOURCE_SIGNATURE_FOR + resource.getName().getValue() +
                               " Parameter should be " + messageFullName + " found: "
                               + paramDetails.get(0).type.toString());
        }
    }

    public boolean isResourceReturnsErrorOrNil(FunctionNode functionNode) {
        BLangFunction resource = (BLangFunction) functionNode;
        return types.isAssignable(resource.symbol.getReturnType(), errorOrNil);
    }
}


