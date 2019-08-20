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

import org.ballerinalang.compiler.plugins.SupportedResourceParamTypes;
import org.ballerinalang.model.tree.AnnotationAttachmentNode;
import org.ballerinalang.model.tree.ServiceNode;
import org.ballerinalang.util.diagnostic.Diagnostic;
import org.ballerinalang.util.diagnostic.DiagnosticLog;
import org.wso2.ballerinalang.compiler.tree.BLangFunction;
import org.wso2.ballerinalang.compiler.tree.BLangSimpleVariable;
import org.wso2.ballerinalang.util.AbstractTransportCompilerPlugin;

import java.util.List;

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
public class ServiceCompilerPlugin extends AbstractTransportCompilerPlugin {

    private static final String INVALID_RESOURCE_SIGNATURE_FOR = "Invalid resource signature for ";
    private DiagnosticLog dlog = null;

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
        if (resources.size() > 1) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, serviceNode.getPosition(),
                               "Only one resource is allowed in the service");
        }
        validate(resources.get(0));
    }

    private void validate(BLangFunction resource) {
        if (!isResourceReturnsErrorOrNil(resource)) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos, "Invalid return type: expected error?");
        }

        if (!Constants.RESOURCE_NAME.equals(resource.name.value)) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos,
                               "resource: Expected resource name is [" + Constants.RESOURCE_NAME + "] found ["
                               + resource.name.value + "]");
        }
        List<BLangSimpleVariable> paramDetails = resource.getParameters();
        if (paramDetails == null || paramDetails.size() != 1) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos, INVALID_RESOURCE_SIGNATURE_FOR
                    + resource.getName().getValue() +
                    " resource: Expected " + Constants.MESSAGE_BAL_OBJECT_FULL_NAME + " parameter only.");
            return;
        }
        if (!Constants.MESSAGE_BAL_OBJECT_FULL_NAME.equals(paramDetails.get(0).type.toString())) {
            dlog.logDiagnostic(Diagnostic.Kind.ERROR, resource.pos,
                               INVALID_RESOURCE_SIGNATURE_FOR + resource.getName().getValue() +
                               " resource: Parameter should be " + Constants.MESSAGE_BAL_OBJECT_FULL_NAME);
        }
    }

}


