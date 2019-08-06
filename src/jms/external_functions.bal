import ballerinax/java;

public function createJmsConnection(handle initialContextFactory, handle providerUrl,
                                    handle connectionFactoryName, map<string> otherPropeties) returns handle | error = @java:Method {
                                            class: "org.wso2.ei.module.jms.JmsConnectionUtils"
                                        } external;

public function startJmsConnection(handle jmsConnection) returns error? = @java:Method {
    class: "org.wso2.ei.module.jms.JmsConnectionUtils"
} external;


public function stopJmsConnection(handle jmsConnection) returns error? = @java:Method {
    class: "org.wso2.ei.module.jms.JmsConnectionUtils"
} external;
