using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
        ReceivedReturnedOrderAtBranch = 15,
        ReceivedReturnedOrderAtHub = 16,
        RiderReturnOrderToMerchant = 17,
        ReturnedToMerchant = 18
    }
}