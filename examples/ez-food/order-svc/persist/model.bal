import ballerina/persist as _;

public type FoodOrder record {|
    readonly int id;
    OrderStatus status;
    decimal? subtotal;
    int? estimatedCompletionTime;
|};

public enum OrderStatus {
    PENDING,
    PAYMENT_PENDING,
    ACCEPTED,
    PROCESSING,
    COMPLETED,
    CANCELED
}
