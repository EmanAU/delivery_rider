api/Auth/rider-login

api/Delivery/change-shipment-status

api/RiderOrders/merchant-branch-orders

api/RiderOrders/branch-to-customer

api/RiderOrders/branch-to-merchant-return

api/RiderOrders/verify-otp













---------------------------------------------


Soar API Documentation


Contents
Authentication	1
POST api/Auth/rider-login	1
Delivery Endpoints	2
POST api/Delivery/deliver-order	2
POST api/Delivery/return-order	2
Rider Orders Endpoints	3
GET api/RiderOrders/merchant-branch-orders	3
GET api/RiderOrders/branch-to-customer	3
POST api/RiderOrders/verify-Otp	4











Authentication
POST api/Auth/rider-login
This endpoint takes the rider credentials (username and passwordHash), verifies them against the database, and returns a JWT Access Token. The token is used for authentication and authorization.
Request Body

{
  "username": "string",
  "passwordHash": "string"
}

Response Body

{
  "accessToken": "string",
  "userName": "string",
  "expiresIn": 0
}

Delivery Endpoints
POST api/Delivery/deliver-order
This endpoint is used to post that an order has been delivered. It requires fk_FromEntityId as a query parameter.
Request Body

{
  "fk_MerchantOrderId": "string",
  "fk_StatusId": 0,
  "fk_ToEntityTypeId": 0,
  "fk_ToEntityId": "string",
  "fk_RiderId": "string"
}

POST api/Delivery/return-order
This endpoint is used to post that an order has been returned by the customer. It requires ToEntityName, ToEntityId, and statusId as query parameters.
Request Body

{
  "fk_MerchantOrderId": "string",
  "fk_StatusId": 0,
  "fk_ToEntityTypeId": 0,
  "fk_ToEntityId": "string",
  "fk_RiderId": "string"
}

Rider Orders Endpoints
GET api/RiderOrders/merchant-branch-orders
Retrieves the orders assigned to a rider for pickup from the merchant branch.
Response Body

{
  "pk_MerchantOrderId": "string",
  "fk_MerchantId": "string",
  "orderReferenceNumber": "string",
  "shipmentDescription": "string",
  "orderQuantity": 0,
  "orderWeight": 0,
  "orderLength": 0,
  "orderHeight": 0,
  "orderWidth": 0,
  "specialInstructions": "string",
  "isFragile": false,
  "orderDate": "string",
  "fromEntityName": "string",
  "toEntityName": "string",
  "eventDateTime": "string",
  "pickupAddress": "string",
  "businessName": "string",
  "merchantPhoneNumber": "string"
}

GET api/RiderOrders/branch-to-customer
Fetches all orders assigned to a rider for delivery from the merchant branch to the customer.
Response Body

{
  "pk_MerchantOrderId": "string",
  "fk_MerchantId": "string",
  "orderReferenceNumber": "string",
  "shipmentDescription": "string",
  "fk_FromEntityId": "string",
  "orderQuantity": 0,
  "orderWeight": 0,
  "orderLength": 0,
  "orderHeight": 0,
  "orderWidth": 0,
  "specialInstructions": "string",
  "isFragile": false,
  "orderDate": "string",
  "fromEntityName": "string",
  "toEntityName": "string",
  "eventDateTime": "string",
  "receiverCity": "string",
  "orderAmount": 0,
  "receiverName": "string",
  "receiverContactNumber": "string",
  "deliveryAddress": "string",
  "deliveryLandmark": "string",
  "paymentMethod": "string",
  "isReturnable": false
}

POST api/RiderOrders/verify-Otp
This endpoint is used to verify the customer by entering an OTP.
Response Body

{
  "IsVerified": false
}

