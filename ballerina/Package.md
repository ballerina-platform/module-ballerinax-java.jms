## Package overview

The `ballerinax/java.jms` package provides an API to connect to an external JMS provider like ActiveMQ from Ballerina.

This package is created with minimal deviation from the JMS API to make it easy for the developers who are used to working with the JMS API. This package is written to support both JMS 2.0 and JMS 1.0 API. 
 
Currently, the following JMS API Classes are supported through this package.
 
 - Connection
 - Session
 - Destination (Queue, Topic, TemporaryQueue, TemporaryTopic)
 - Message (TextMessage, MapMessage, BytesMessage)
 - MessageConsumer
 - MessageProducer
 
 The following sections provide details on how to use the JMS connector.
 
 - [Samples](#samples)

## Samples

### JMS message Producer

The following Ballerina program sends messages to a queue named *MyQueue*.

```ballerina
import ballerinax/activemq.driver as _;
import ballerinax/java.jms;

public function main() returns error? {
    jms:Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    jms:Session session = check connection->createSession();
    jms:Destination queue = check session->createQueue("MyQueue");
    jms:MessageProducer producer = check session.createProducer(queue);
    jms:TextMessage msg = {
        content: "Hello Ballerina!"
    };
    check producer->send(msg);
}
```

## JMS message consumer
The following Ballerina program receives messages from a queue named *MyQueue*.
```ballerina
import ballerinax/activemq.driver as _;
import ballerinax/java.jms;
import ballerina/log;

public function main() returns error? {
    jms:Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    jms:Session session = check connection->createSession();
    jms:Destination queue = check session->createQueue("MyQueue");
    jms:MessageConsumer consumer = check session.createConsumer(queue);

    while true {
        jms:Message? response = check consumer->receive(3000);
        if response is jms:TextMessage {
            log:printInfo("Message received: ", content = response.toString());
        }
    }
}
```

### Asynchronous message consumer

One of the key deviations from the JMS API was the asynchronous message consumption using message listeners. In 
Ballerina transport listener concept is covered with **service** type, hence we have used the Ballerina service to 
implement the message listener. Following is a message listener example listening on a queue named *MyQueue*.

```ballerina
import ballerinax/activemq.driver as _;
import ballerina/log;
import ballerinax/java.jms;

service "consumer-service" on new jms:Listener(
    connectionConfig = {
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    }
    destination = {
        'type: jms:QUEUE,
        name: "MyQueue"
    }
) {
    remote function onMessage(jms:Message message) returns error? {
        if message is jms:TextMessage {
            log:printInfo("Text message received", content = message.content);
        }
    }
}
```
