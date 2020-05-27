Connects to a JMS provider using Ballerina.

## Module overview

The `ballerina/java.jms` module provides an API to connect to an external JMS provider like ActiveMQ from Ballerina.

This module is created with minimal deviation from the JMS API to make it easy for the developers who are used to working 
 with the JMS API. This module is written to support both JMS 2.0 and JMS 1.0 API. 
 
Currently, the following JMS API Classes are supported through this module.
 
 - Connection
 - Session
 - Destination (Queue, Topic, TemporaryQueue, TemporaryTopic)
 - Message (TextMessage, MapMessage, BytesMessage, StreamMessage)
 - MessageConsumer
 - MessageProducer
 
 The following sections provide details on how to use the JMS connector.
 
 - [Compatibility](#compatibility)
 - [Samples](#samples)
 
## Compatibility
 
|  Ballerina Language Version |       JMS Module Version       |
|:---------------------------:|:------------------------------:|
|         1.0.x               |             0.6.x              |
|         1.1.x               |             0.7.x              |
|         1.2.x               |             0.8.x              |

## Samples

### JMS Message Producer and Consumer example

Following is a simple Ballerina program that sends and receives a message from a queue named *MyQueue*.

```ballerina
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

    check producer->send(msg);

    jms:Message? response = check consumer->receive(3000);
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
import ballerina/java.jms;

jms:Connection connection = check jms:createConnection({
                   initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
                   providerUrl: "tcp://localhost:61616"
              });
jms:Session session = check connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
jms:Destination topic = check session->createTopic("MyTopic");

`listener jms:MessageConsumer jmsConsumer = check session->createDurableSubscriber(topic, "sub-1");
`
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
