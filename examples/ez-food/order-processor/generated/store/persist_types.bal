// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.
import ballerina/time;

public enum OrderStatus {
    PENDING,
    PAYMENT_PENDING,
    ACCEPTED,
    PROCESSING,
    COMPLETED,
    CANCELED
}

public type FoodOrder record {|
    readonly int id;
    OrderStatus status;
    int estimatedDuration;
    time:Utc? processingStartedTime;
|};

public type FoodOrderOptionalized record {|
    int id?;
    OrderStatus status?;
    int estimatedDuration?;
    time:Utc? processingStartedTime?;
|};

public type FoodOrderWithRelations record {|
    *FoodOrderOptionalized;
    ItemOptionalized[] items?;
|};

public type FoodOrderTargetType typedesc<FoodOrderWithRelations>;

public type FoodOrderInsert FoodOrder;

public type FoodOrderUpdate record {|
    OrderStatus status?;
    int estimatedDuration?;
    time:Utc? processingStartedTime?;
|};

public type Item record {|
    readonly int id;
    int orderId;
    string name;
    int quantity;
    decimal unitPrice;
    int prepTimePerUnit;
|};

public type ItemOptionalized record {|
    int id?;
    int orderId?;
    string name?;
    int quantity?;
    decimal unitPrice?;
    int prepTimePerUnit?;
|};

public type ItemWithRelations record {|
    *ItemOptionalized;
    FoodOrderOptionalized 'order?;
|};

public type ItemTargetType typedesc<ItemWithRelations>;

public type ItemInsert Item;

public type ItemUpdate record {|
    int orderId?;
    string name?;
    int quantity?;
    decimal unitPrice?;
    int prepTimePerUnit?;
|};

