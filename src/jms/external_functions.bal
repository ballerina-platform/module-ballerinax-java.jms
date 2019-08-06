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


public function createJmsSession(handle connection, handle acknowledgmentMode) returns handle | error = @java:Method {
    class: "org.wso2.ei.module.jms.JmsSessionUtils"
} external;

public function createJmsQueue(handle session, handle queueName) returns handle | error = @java:Method {
    class: "org.wso2.ei.module.jms.JmsSessionUtils"
} external;

public function createJmsTopic(handle session, handle topicName) returns handle | error = @java:Method {
    class: "org.wso2.ei.module.jms.JmsSessionUtils"
} external;

public function createTemporaryJmsQueue(handle session) returns handle | error = @java:Method {
    class: "org.wso2.ei.module.jms.JmsSessionUtils"
} external;

public function createTemporaryJmsTopic(handle session) returns handle | error = @java:Method {
    class: "org.wso2.ei.module.jms.JmsSessionUtils"
} external;

public function unsubscribeJmsSubscription(handle session, handle subscriptionId) returns error? = @java:Method {
    class: "org.wso2.ei.module.jms.JmsSessionUtils"
} external;
