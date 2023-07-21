## Overview

The `ballerina/java.jms` module provides an API to connect to an external JMS provider like ActiveMQ from Ballerina.

This module is created with minimal deviation from the JMS API to make it easy for the developers who are used to working 
 with the JMS API. This module is written to support both JMS 2.0 and JMS 1.0 API. 
 
Currently, the following JMS API Classes are supported through this module.
 
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
import ballerinax/java.jms;

public function main() returns error? {
    jms:Connection connection = check jms:createConnection({
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    });
    jms:Session session = check connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
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
import ballerinax/java.jms;
import ballerina/log;

public function main() returns error? {
    jms:Connection connection = check jms:createConnection({
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    });
    jms:Session session = check connection->createSession({acknowledgementMode: "AUTO_ACKNOWLEDGE"});
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
import ballerina/log;
import ballerinax/java.jms;

service "consumer-service" on new jms:Listener(
    connectionConfig = {
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    },
    sessionConfig = {
        acknowledgementMode: "AUTO_ACKNOWLEDGE"
    },
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

## Adding the required dependencies 

Add the required dependencies to the `Ballerina.toml` file based on the broker that you're trying to connect to. 
Add the configurations below to run the given examples using `Apache ActiveMQ`. 

```
[[platform.java11.dependency]]
groupId = "org.apache.activemq"
artifactId = "activemq-client"
version = "5.18.2"

[[platform.java11.dependency]]
groupId = "org.apache.geronimo.specs"
artifactId = "geronimo-j2ee-management_1.1_spec"
version = "1.0.1"

[[platform.java11.dependency]]
groupId = "org.fusesource.hawtbuf"
artifactId = "hawtbuf"
version = "1.11"
```
