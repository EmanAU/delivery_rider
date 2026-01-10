namespace Models.Enums
{
    public enum EntityTypeEnum : int
    {
        Branch = 2,
        Hub = 3,
        Rider = 4,
        Customer = 5
    }
}

---------------------

namespace Models.Enums
{
    public enum ShipmentStatusEnum : int
    {
        ReadyForPickup = 1,
        ReceivedAtBranch = 2,
        ReceivedAtHub = 3,
        DispatchedToHub = 4,
        DispatchedToBranch = 5,
        ReceivedByCustomer = 6,
        CustomerDidNotAccept = 7,
        ReceiveFromMerchant = 8,
        AssignedToRider = 9,
        PickedByRider = 10,
        RiderIsOnTheWayToDeliver = 11,
        CustomerNotFound = 12,
        ReturnedToBranch = 13,
        ReturnedToHub = 14,
        ReceivedReturnedOrderAtBranch = 16,
        ReceivedReturnedOrderAtHub = 17,
        RiderReturnToMerchent = 18,
        ReturnedToMerchant = 19
    }
}