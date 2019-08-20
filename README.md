## Module overview

The `wso2/jms` module provides an API to connect to an external JMS provider like ActiveMQ from Ballerina.

This module is created with minimal deviation from the JMS API to make it easy for the developers who are used to working 
 with the JMS API. This module is written to support both JMS 2.0 and JMS 1.0 API. 
 
 Currently, following JMS API Classes are supported through this module
 
 - Connection
 - Session
 - Destination (Queue, Topic, TemporaryQueue, TemporaryTopic)
 - Message (TextMessage, MapMessage, BytesMessage, StreamMessage)
 - MessageConsumer
 - MessageProducer

## Samples

### JMS Message Producer and Consumer example

Following is a simple Ballerina program that sends and receives a message from a queue named *MyQueue*.

```ballerina
import ballerina/log;
import wso2/jms;

public function main() returns error? {

        jms:Connection connection = jms:createConnection({
                          initialContextFactory: "org.apache.activemq.artemis.jndi.ActiveMQInitialContextFactory",
                          providerUrl: "tcp://localhost:61616"
                        });
        jms:Session session = check connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
        jms:Destination queue = check session->createQueue("MyQueue");
        jms:MessageProducer producer = check session.createProducer(queue);
        jms:MessageConsumer consumer = check session->createConsumer(queue);

        jms:TextMessage msg = check session.createTextMessage("Hello Ballerina!");

        check producer->send(msg);

        jms:Message response = check consumer->receive(3000);
        if (response is jms:TextMessage) {
            var val = response.getText();
            if (val is string) {
                log:printInfo("Message received: " + val);
            } else {
                log:printInfo("Message received without text");
            }
        } else {
            log:printInfo("Message received.");
        }
}
```

### Asynchronous message consumer

One of the key deviations from the JMS API was the asynchronous message consumption using message listeners. In 
Ballerina transport listener concept is covered with **service** type, hence we have used the Ballerina service to 
implement the message listener. Following is a message listener example listening on a topic named *MyTopic*.

```ballerina
import ballerina/log;
import wso2/jms;

jms:Connection connection = jms:createConnection({
                   initialContextFactory: "org.apache.activemq.artemis.jndi.ActiveMQInitialContextFactory",
                   providerUrl: "tcp://localhost:61616"
              });
jms:Session session = check con->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
jms:Destination dest = check session->createTopic("MyTopic");

listener jms:MessageConsumer jmsConsumer = check session->createDurableSubscriber(dest, "sub-1");

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
```