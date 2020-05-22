import ballerina/log;
import ballerina/java.jms;

public function main() returns error? {

    jms:Connection connection = check jms:createConnection({
                        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
                        providerUrl: "tcp://localhost:61616"
                    });
    jms:Session session = check connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
    jms:Destination queue = check session->createQueue("MyQueue");
    jms:MessageProducer producer = check session.createProducer(queue);
    jms:MessageConsumer consumer = check session->createConsumer(queue);

    jms:TextMessage msg = check session.createTextMessage("Hello Ballerina!");
    var headerResult = msg.setJMSCorrelationID("Msg:1");
    var propResult = msg.setStringProperty("Instruction", "Do a perfect Pirouette");

    check producer->send(msg);

    jms:Message? response = check consumer->receive(3000);
    if (response is jms:TextMessage) {
        var val = response.getText();
        // print message
        if (val is string) {
            log:printInfo("Message received: " + val);
        } else {
            log:printInfo("Message received without text");
        }

        // print message correlationId header
        string? correlationId = check response.getJMSCorrelationID();
        if (correlationId is string) {
            log:printInfo("Message header correlationId: " + correlationId);
        } else {
            log:printInfo("Message received without header correlationId");
        }

        // print message string property
        string? strProperty = check response.getStringProperty("Instruction");
        if (strProperty is string) {
            log:printInfo("Message property: " + strProperty);
        } else {
            log:printInfo("Message received without property");
        }

    } else {
        log:printInfo("Message received.");
    }
}
