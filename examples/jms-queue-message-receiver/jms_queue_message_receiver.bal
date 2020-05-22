import ballerina/log;
import ballerina/java.jms;

jms:Connection connection = check jms:createConnection({
                   initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
                   providerUrl: "tcp://localhost:61616"
              });
jms:Session session = check connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
jms:Destination queue = check session->createQueue("MyQueue");

listener jms:MessageConsumer jmsConsumer = check session->createConsumer(queue);

service messageListener on jmsConsumer {

   resource function onMessage(jms:Message message) {
       if (message is jms:TextMessage) {
           var val = message.getText();
           if (val is string) {
               log:printInfo("Message received: " + val );
           } else {
               log:printInfo("Message received without text");
           }
       } else {
           log:printInfo("Message received.");
       }
   }
}
