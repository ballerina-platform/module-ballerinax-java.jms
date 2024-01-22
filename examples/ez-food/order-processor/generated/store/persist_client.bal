// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.
import ballerina/jballerina.java;
import ballerina/persist;
import ballerinax/persist.inmemory;

const FOOD_ORDER = "foodorders";
const ITEM = "items";
final isolated table<FoodOrder> key(id) foodordersTable = table [];
final isolated table<Item> key(id) itemsTable = table [];

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final map<inmemory:InMemoryClient> persistClients;

    public isolated function init() returns persist:Error? {
        final map<inmemory:TableMetadata> metadata = {
            [FOOD_ORDER] : {
                keyFields: ["id"],
                query: queryFoodorders,
                queryOne: queryOneFoodorders,
                associationsMethods: {"items": queryFoodOrderItems}
            },
            [ITEM] : {
                keyFields: ["id"],
                query: queryItems,
                queryOne: queryOneItems
            }
        };
        self.persistClients = {
            [FOOD_ORDER] : check new (metadata.get(FOOD_ORDER).cloneReadOnly()),
            [ITEM] : check new (metadata.get(ITEM).cloneReadOnly())
        };
    }

    isolated resource function get foodorders(FoodOrderTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
        name: "query"
    } external;

    isolated resource function get foodorders/[int id](FoodOrderTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
        name: "queryOne"
    } external;

    isolated resource function post foodorders(FoodOrderInsert[] data) returns int[]|persist:Error {
        int[] keys = [];
        foreach FoodOrderInsert value in data {
            lock {
                if foodordersTable.hasKey(value.id) {
                    return persist:getAlreadyExistsError("FoodOrder", value.id);
                }
                foodordersTable.put(value.clone());
            }
            keys.push(value.id);
        }
        return keys;
    }

    isolated resource function put foodorders/[int id](FoodOrderUpdate value) returns FoodOrder|persist:Error {
        lock {
            if !foodordersTable.hasKey(id) {
                return persist:getNotFoundError("FoodOrder", id);
            }
            FoodOrder foodorder = foodordersTable.get(id);
            foreach var [k, v] in value.clone().entries() {
                foodorder[k] = v;
            }
            foodordersTable.put(foodorder);
            return foodorder.clone();
        }
    }

    isolated resource function delete foodorders/[int id]() returns FoodOrder|persist:Error {
        lock {
            if !foodordersTable.hasKey(id) {
                return persist:getNotFoundError("FoodOrder", id);
            }
            return foodordersTable.remove(id).clone();
        }
    }

    isolated resource function get items(ItemTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
        name: "query"
    } external;

    isolated resource function get items/[int id](ItemTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
        name: "queryOne"
    } external;

    isolated resource function post items(ItemInsert[] data) returns int[]|persist:Error {
        int[] keys = [];
        foreach ItemInsert value in data {
            lock {
                if itemsTable.hasKey(value.id) {
                    return persist:getAlreadyExistsError("Item", value.id);
                }
                itemsTable.put(value.clone());
            }
            keys.push(value.id);
        }
        return keys;
    }

    isolated resource function put items/[int id](ItemUpdate value) returns Item|persist:Error {
        lock {
            if !itemsTable.hasKey(id) {
                return persist:getNotFoundError("Item", id);
            }
            Item item = itemsTable.get(id);
            foreach var [k, v] in value.clone().entries() {
                item[k] = v;
            }
            itemsTable.put(item);
            return item.clone();
        }
    }

    isolated resource function delete items/[int id]() returns Item|persist:Error {
        lock {
            if !itemsTable.hasKey(id) {
                return persist:getNotFoundError("Item", id);
            }
            return itemsTable.remove(id).clone();
        }
    }

    public isolated function close() returns persist:Error? {
        return ();
    }
}

isolated function queryFoodorders(string[] fields) returns stream<record {}, persist:Error?> {
    table<FoodOrder> key(id) foodordersClonedTable;
    lock {
        foodordersClonedTable = foodordersTable.clone();
    }
    return from record {} 'object in foodordersClonedTable
        select persist:filterRecord({
            ...'object
        }, fields);
}

isolated function queryOneFoodorders(anydata key) returns record {}|persist:NotFoundError {
    table<FoodOrder> key(id) foodordersClonedTable;
    lock {
        foodordersClonedTable = foodordersTable.clone();
    }
    from record {} 'object in foodordersClonedTable
    where persist:getKey('object, ["id"]) == key
    do {
        return {
            ...'object
        };
    };
    return persist:getNotFoundError("FoodOrder", key);
}

isolated function queryItems(string[] fields) returns stream<record {}, persist:Error?> {
    table<Item> key(id) itemsClonedTable;
    lock {
        itemsClonedTable = itemsTable.clone();
    }
    table<FoodOrder> key(id) foodordersClonedTable;
    lock {
        foodordersClonedTable = foodordersTable.clone();
    }
    return from record {} 'object in itemsClonedTable
        outer join var 'order in foodordersClonedTable on ['object.orderId] equals ['order?.id]
        select persist:filterRecord({
            ...'object,
            "'order": 'order
        }, fields);
}

isolated function queryOneItems(anydata key) returns record {}|persist:NotFoundError {
    table<Item> key(id) itemsClonedTable;
    lock {
        itemsClonedTable = itemsTable.clone();
    }
    table<FoodOrder> key(id) foodordersClonedTable;
    lock {
        foodordersClonedTable = foodordersTable.clone();
    }
    from record {} 'object in itemsClonedTable
    where persist:getKey('object, ["id"]) == key
    outer join var 'order in foodordersClonedTable on ['object.orderId] equals ['order?.id]
    do {
        return {
            ...'object,
            "'order": 'order
        };
    };
    return persist:getNotFoundError("Item", key);
}

isolated function queryFoodOrderItems(record {} value, string[] fields) returns record {}[] {
    table<Item> key(id) itemsClonedTable;
    lock {
        itemsClonedTable = itemsTable.clone();
    }
    return from record {} 'object in itemsClonedTable
        where 'object.'orderId == value["id"]
        select persist:filterRecord({
            ...'object
        }, fields);
}

