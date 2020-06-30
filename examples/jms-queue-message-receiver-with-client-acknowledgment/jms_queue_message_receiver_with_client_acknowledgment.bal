import ballerina/log;
import ballerina/java.jms;

jms:Connection connection = check jms:createConnection({
                   initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
                   providerUrl: "tcp://localhost:61616"
              });

listener jms:MessageConsumer jmsConsumer = createListener(connection);

service messageListener on jmsConsumer {

   resource function onMessage(jms:Message message) {
       if (message is jms:TextMessage) {
           var val = message.getText();
           if (val is string) {
               log:printInfo("Message received: " + val );
           } else {
               log:printInfo("Message received without text");
           }
           var result = message->acknowledge();
           if (result is error) {
                log:printError("Error occurred while acknowledging message", err = result);
            }
       } else {
           log:printInfo("Message received.");
       }
   }
}

function createListener(jms:Connection connection) returns  jms:MessageConsumer {
    jms:Session session = check connection->createSession({acknowledgementMode: "CLIENT_ACKNOWLEDGE"});
    jms:Destination queue = check session->createQueue("MyQueue");
    jms:MessageConsumer jmsConsumer = checkpanic session->createConsumer(queue);
    return jmsConsumer;
}
