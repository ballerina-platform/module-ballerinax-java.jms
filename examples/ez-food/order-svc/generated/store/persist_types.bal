// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

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
    decimal? subtotal;
    int? estimatedCompletionTime;
|};

public type FoodOrderOptionalized record {|
    int id?;
    OrderStatus status?;
    decimal? subtotal?;
    int? estimatedCompletionTime?;
|};

public type FoodOrderTargetType typedesc<FoodOrderOptionalized>;

public type FoodOrderInsert FoodOrder;

public type FoodOrderUpdate record {|
    OrderStatus status?;
    decimal? subtotal?;
    int? estimatedCompletionTime?;
|};

