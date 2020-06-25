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
       } else {
           log:printInfo("Message received.");
       }
   }
}

function createListener(jms:Connection connection) returns  jms:MessageConsumer {
    jms:Session session = checkpanic connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
    jms:Destination topic = checkpanic session->createTopic("MyTopic");
    jms:MessageConsumer jmsConsumer = check session->createDurableSubscriber(topic, "sub-1");
    return jmsConsumer;
}
