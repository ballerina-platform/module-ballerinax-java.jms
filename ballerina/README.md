## Overview

Java Message Service (JMS) is a standard API for sending messages between two or more clients. It provides a common way for programs to create, send, receive, and read distributed enterprise messages. The JMS connector enables seamless integration with JMS providers, supporting various messaging patterns such as publish-subscribe and point-to-point.

### Key Features

- Support for both queue and topic-based messaging
- Comprehensive support for JMS 1.1 and 2.0
- Reliable message delivery with persistent and non-persistent modes
- Support for various message types including Text, Map, and Bytes
- Secure communication with connection-level authentication
- GraalVM compatible for native image builds

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
    jms:MessageProducer producer = check session.createProducer({
        'type: jms:QUEUE,
        name: "MyQueue"
    });
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
    jms:MessageConsumer consumer = check session.createConsumer(
        destination = {
            'type: jms:QUEUE,
            name: "MyQueue"
    });
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
    },
    consumerOptions = {
        destination: {
            'type: jms:QUEUE,
            name: "MyQueue"
        }
    }
) {
    remote function onMessage(jms:Message message) returns error? {
        if message is jms:TextMessage {
            log:printInfo("Text message received", content = message.content);
        }
    }
}
```
