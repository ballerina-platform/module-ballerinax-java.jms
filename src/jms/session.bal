// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

# Represents the JMS session.
#
# + config - Stores the configurations related to a JMS session.
public type Session client object {

    private SessionConfiguration config;
    private handle jmsSession = java:createNull();

    # The default constructor of the JMS session.
    public function __init(Connection connection, SessionConfiguration c) {
        self.config = c;
        self.createSession(connection.getJmsConnection());
    }

    private function createSession(handle jmsConnection) {
        handle ackModeJString = java:fromString(self.config.acknowledgementMode);
        handle|error val = createJmsSession(jmsConnection, ackModeJString);
        if (val is handle) {
            self.jmsSession = val;
        }
    }

    # Unsubscribes a durable subscription that has been created by a client.
    # It is erroneous for a client to delete a durable subscription while there is an active (not closed) consumer
    # for the subscription, or while a consumed message being part of a pending transaction or has not been
    # acknowledged in the session.
    #
    # + subscriptionId - The name, which is used to identify the subscription.
    # + return - Cancels the subscription.
    public remote function unsubscribe(string subscriptionId) returns error? {
        return unsubscribeJmsSubscription(self.jmsSession, java:fromString(subscriptionId));
    }

    # Creates a JMS Queue, which can be used as temporary response destination.
    #
    # + return - Returns the JMS destination for a temporary queue or an error if it fails.
    public remote function createTemporaryQueue() returns Destination|JmsError {
        handle|error val = createTemporaryJmsQueue(self.jmsSession);
        if (val is handle) {
            string? queueVal = java:toString(val);
            if (queueVal is string) {
                Destination destination = new(queueVal, TEMP_QUEUE);
                return destination;
            } else {
                JmsError err = error("empty queue name");
                return err;
            }
        } else {
            return val;
        }
    }

    # Creates a JMS Topic, which can be used as a temporary response destination.
    #
    # + return - Returns the JMS destination for a temporary topic or an error if it fails.
    public function createTemporaryTopic() returns Destination|JmsError {
        handle|error val = createTemporaryJmsTopic(self.jmsSession);
        if (val is handle) {
            string? topicVal = java:toString(val);
            if (topicVal is string) {
                Destination destination = new(topicVal, TEMP_QUEUE);
                return destination;
            } else {
                JmsError err = error("empty topic name");
                return err;
            }
        } else {
            return val;
        }
    }

    # Creates a JMS Queue, which can be used with a message producer.
    #
    # + queueName - The name of the Queue.
    # + return - Returns the JMS destination for a queue or an error if it fails.
    public function createQueue(string queueName) returns Destination|error {
        
        handle|error val = createJmsQueue(self.jmsSession, java:fromString(queueName));
        if (val is handle) {
            Destination destination = new(queueName, QUEUE);
            return destination;
        } else {
            return val;
        }
    }

    # Creates a JMS Topic, which can be used with a message producer.
    #
    # + topicName - The name of the Topic.
    # + return - Returns the JMS destination for a topic or an error if it fails.
    public function createTopic(string topicName) returns Destination|error {
        handle|error val = createJmsTopic(self.jmsSession, java:fromString(topicName));
        if (val is handle) {
            Destination destination = new(topicName, TOPIC);
            return destination;
        } else {
            return val;
        }
    }

    function getJmsSession() returns handle {
        return self.jmsSession;
    }
};

# The Configurations that are related to a JMS session.
#
# + acknowledgementMode - Specifies the session mode that will be used. Valid values are "AUTO_ACKNOWLEDGE",
#                         "CLIENT_ACKNOWLEDGE", "SESSION_TRANSACTED", and "DUPS_OK_ACKNOWLEDGE".
public type SessionConfiguration record {|
    string acknowledgementMode = "AUTO_ACKNOWLEDGE";
|};
