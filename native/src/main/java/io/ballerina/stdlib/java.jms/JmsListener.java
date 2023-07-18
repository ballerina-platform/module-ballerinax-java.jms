package io.ballerina.stdlib.java.jms;

import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.async.Callback;
import io.ballerina.runtime.api.async.StrandMetadata;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;

import javax.jms.Message;
import javax.jms.MessageListener;

/**
 * A {@link javax.jms.MessageListener} implementation.
 */
public class JmsListener implements MessageListener {
    private final BObject consumerService;
    private final Runtime ballerinaRuntime;
    private final Callback callback = new ConsumerCallback();

    public JmsListener(BObject consumerService, Runtime ballerinaRuntime) {
        this.consumerService = consumerService;
        this.ballerinaRuntime = ballerinaRuntime;
    }

    @Override
    public void onMessage(Message message) {
        Module module = ModuleUtils.getModule();
        BObject jmsMessage = ValueCreator.createObjectValue(
                module, Constants.MESSAGE_BAL_OBJECT_NAME, ValueCreator.createHandleValue(message));
        StrandMetadata metadata = new StrandMetadata(
                module.getOrg(), module.getName(), module.getVersion(), Constants.SERVICE_RESOURCE_ON_MESSAGE);
        Object[] params = {jmsMessage, true};
        ObjectType serviceType = (ObjectType) TypeUtils.getReferredType(TypeUtils.getType(consumerService));
        if (serviceType.isIsolated() && serviceType.isIsolated(Constants.SERVICE_RESOURCE_ON_MESSAGE)) {
            ballerinaRuntime.invokeMethodAsyncConcurrently(
                    consumerService, Constants.SERVICE_RESOURCE_ON_MESSAGE, null, metadata, callback,
                    null, PredefinedTypes.TYPE_NULL, params);
        } else {
            ballerinaRuntime.invokeMethodAsyncSequentially(
                    consumerService, Constants.SERVICE_RESOURCE_ON_MESSAGE, null, metadata, callback,
                    null, PredefinedTypes.TYPE_NULL, params);
        }
    }
}
