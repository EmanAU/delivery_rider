/// Shipment Status Enum based on backend enum
class ShipmentStatusEnum {
  static const int readyForPickup = 1;
  static const int receivedAtBranch = 2;
  static const int receivedAtHub = 3;
  static const int dispatchedToHub = 4;
  static const int dispatchedToBranch = 5;
  static const int receivedByCustomer = 6;
  static const int customerDidNotAccept = 7;
  static const int receiveFromMerchant = 8;
  static const int assignedToRider = 9;
  static const int pickedByRider = 10;
  static const int riderIsOnTheWayToDeliver = 11;
  static const int customerNotFound = 12;
  static const int returnedToBranch = 13;
  static const int returnedToHub = 14;
  static const int receivedReturnedOrderAtBranch = 15;
  static const int receivedReturnedOrderAtHub = 16;
  static const int riderReturnToMerchant = 17;
  static const int returnedToMerchant = 18;
}

