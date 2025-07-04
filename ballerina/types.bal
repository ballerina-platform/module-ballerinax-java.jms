// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

# The JMS service type.
public type Service distinct service object {
    // remote function onMessage(jms:Message message, jms:Caller caller) returns error?;
};

# Represents configurations for a JMS queue subscription.
#
# + sessionAckMode - Configuration indicating how messages received by the session will be acknowledged
# + queueName - The name of the queue to consume messages from
# + messageSelector - Only messages with properties matching the message selector expression are delivered. 
#                     If this value is not set that indicates that there is no message selector for the message consumer
#                     For example, to only receive messages with a property `priority` set to `'high'`, use:
#                     `"priority = 'high'"`. If this value is not set, all messages in the queue will be delivered.
public type QueueConfig record {|
  AcknowledgementMode sessionAckMode = AUTO_ACKNOWLEDGE;
  string queueName;
  string messageSelector?;
|};


# Represents configurations for JMS topic subscription.
#
# + sessionAckMode - Configuration indicating how messages received by the session will be acknowledged
# + topicName - The name of the topic to subscribe to
# + messageSelector - Only messages with properties matching the message selector expression are delivered. 
#                     If this value is not set that indicates that there is no message selector for the message consumer
#                     For example, to only receive messages with a property `priority` set to `'high'`, use:
#                     `"priority = 'high'"`. If this value is not set, all messages in the queue will be delivered.
# + noLocal - If true then any messages published to the topic using this session's connection, or any other connection 
#             with the same client identifier, will not be added to the durable subscription.
# + consumerType - The message consumer type
# + subscriberName - the name used to identify the subscription
public type TopicConfig record {|
  AcknowledgementMode sessionAckMode = AUTO_ACKNOWLEDGE;
  string topicName;
  string messageSelector?;
  boolean noLocal = false;
  ConsumerType consumerType = DEFAULT;
  string subscriberName?;
|};

# The service configuration type for the `jms:Service`.
public type ServiceConfiguration QueueConfig|TopicConfig;

# Annotation to configure the `jms:Service`.
public annotation ServiceConfiguration ServiceConfig on service;
