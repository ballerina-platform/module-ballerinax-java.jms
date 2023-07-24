# Ballerina `java.jms` Library

[![Build](https://github.com/ballerina-platform/module-ballerina-java.jms/actions/workflows/build-timestamped-master.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerina-java.jms/actions/workflows/build-timestamped-master.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerina-java.jms/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerina-java.jms)
[![Trivy](https://github.com/ballerina-platform/module-ballerina-java.jms/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerina-java.jms/actions/workflows/trivy-scan.yml)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerina-java.jms/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerina-java.jms/actions/workflows/build-with-bal-test-graalvm.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerina-java.jms.svg)](https://github.com/ballerina-platform/module-ballerina-java.jms/commits/master)

The `ballerinax/java.jms` library provides an API to connect to an external JMS provider like ActiveMQ from Ballerina.

This library is created with minimal deviation from the JMS API to make it easy for the developers who are used to working with the JMS API. This library is written to support both JMS 2.0 and JMS 1.0 API. 
 
Currently, the following JMS API Classes are supported through this library.
 
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

## Issues and projects 

Issues and Projects tabs are disabled for this repository as this is part of the Ballerina Standard Library. To report bugs, request new features, start new discussions, view project boards, etc., go to the [Ballerina Standard Library parent repository](https://github.com/ballerina-platform/ballerina-standard-library). 

This repository only contains the source code for the library.

## Build from the source

### Set up the prerequisites

* Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptium.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Docker](https://www.docker.com/). This is required to run the tests.

### Build the source

Execute the commands below to build from the source.

1. To build the library:
   ```    
   ./gradlew clean build
   ```

2. To run the tests:
   ```
   ./gradlew clean test
   ```
3. To build the library without the tests:
   ```
   ./gradlew clean build -x test
   ```
4. To debug library implementation:
   ```
   ./gradlew clean build -Pdebug=<port>
   ```
5. To debug the library with Ballerina language:
   ```
   ./gradlew clean build -PbalJavaDebug=<port>
   ```
6. Publish ZIP artifact to the local `.m2` repository:
   ```
   ./gradlew clean build publishToMavenLocal
   ```
7. Publish the generated artifacts to the local Ballerina central repository:
   ```
   ./gradlew clean build -PpublishToLocalCentral=true
   ```
8. Publish the generated artifacts to the Ballerina central repository:
   ```
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`java.jms` library](https://lib.ballerina.io/ballerinax/java.jms/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
