import ballerina/java.jms;

public function main() returns error? {

    jms:Connection connection = check jms:createConnection({
                        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
                        providerUrl: "tcp://localhost:61616"
                    });
    jms:Session session = check connection->createSession({acknowledgementMode: "SESSION_TRANSACTED"});
    jms:Destination queue = check session->createQueue("MyQueue");
    jms:MessageProducer producer = check session.createProducer(queue);
    transaction {
        jms:TextMessage msg = check session.createTextMessage("Hello Ballerina!");
        check producer->send(msg);
    }
}
