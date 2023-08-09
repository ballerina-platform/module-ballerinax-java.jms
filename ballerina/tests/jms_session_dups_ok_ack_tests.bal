// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/test;

final Session dupsOkAckSession = check createSession(DUPS_OK_ACKNOWLEDGE);

final MessageProducer queue6Producer = check createProducer(dupsOkAckSession, {
    'type: QUEUE,
    name: "test-queue-6"
});
final MessageConsumer queue6Consumer = check createConsumer(dupsOkAckSession, destination = {
    'type: QUEUE,
    name: "test-queue-6"
});

@test:Config {
    groups: ["sessionDupsOkAck"]
}
isolated function testDupsOkAckWithQueue() returns error? {
    MapMessage msg1 = {
        content: {
            "messageId": 1,
            "payload": "This is the first message"
        }
    };
    MapMessage msg2 = {
        content: {
            "messageId": 2,
            "payload": "This is the second message"
        }
    };
    MapMessage msg3 = {
        content: {
            "messageId": 3,
            "payload": "This is the third message"
        }
    };
    MapMessage msg4 = {
        content: {
            "messageId": 4,
            "payload": "This is the fourth message"
        }
    };
    check queue6Producer->send(msg1);
    check queue6Producer->send(msg2);
    check queue6Producer->send(msg3);
    check queue6Producer->send(msg4);

    int[] messageIds = [];
    while true {
        Message? response = check queue6Consumer->receive(5000);
        if response is MapMessage {
            int messageId = check response.content["messageId"].ensureType();
            if messageIds.indexOf(messageId) is () {
                messageIds.push(messageId);
            }
        } else {
            break;
        }
    }
    test:assertEquals(messageIds, [1, 2, 3, 4], "Invalid set of message Ids found");
}

final MessageProducer topic6Producer = check createProducer(dupsOkAckSession, {
    'type: TOPIC,
    name: "test-topic-6"
});
final MessageConsumer topic6Consumer = check createConsumer(dupsOkAckSession, destination = {
    'type: TOPIC,
    name: "test-topic-6"
});

@test:Config {
    groups: ["sessionDupsOkAck"]
}
isolated function testDupsOkAckWithTopic() returns error? {
    MapMessage msg1 = {
        content: {
            "messageId": 1,
            "payload": "This is the first message"
        }
    };
    MapMessage msg2 = {
        content: {
            "messageId": 2,
            "payload": "This is the second message"
        }
    };
    MapMessage msg3 = {
        content: {
            "messageId": 3,
            "payload": "This is the third message"
        }
    };
    MapMessage msg4 = {
        content: {
            "messageId": 4,
            "payload": "This is the fourth message"
        }
    };
    check topic6Producer->send(msg1);
    check topic6Producer->send(msg2);
    check topic6Producer->send(msg3);
    check topic6Producer->send(msg4);

    int[] messageIds = [];
    while true {
        Message? response = check topic6Consumer->receive(5000);
        if response is MapMessage {
            int messageId = check response.content["messageId"].ensureType();
            if messageIds.indexOf(messageId) is () {
                messageIds.push(messageId);
            }
        } else {
            break;
        }
    }
    test:assertEquals(messageIds, [1, 2, 3, 4], "Invalid set of message Ids found");
}

@test:AfterGroups {
    value: ["sessionDupsOkAck"]
}
isolated function afterSessionDupsOkAckTests() returns error? {
    check queue6Producer->close();
    check queue6Consumer->close();
    check topic6Producer->close();
    check topic6Consumer->close();
    check dupsOkAckSession->close();
}
