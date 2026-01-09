class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://www.careho.pk/api';

  // Auth Endpoints
  static const String riderLogin = '$baseUrl/Auth/rider-login';

  // Delivery Endpoints
  static const String changeShipmentStatus =
      '$baseUrl/Delivery/change-shipment-status';

  // Rider Orders Endpoints
  static const String merchantBranchOrders =
      '$baseUrl/RiderOrders/merchant-branch-orders';
  static const String branchToCustomer =
      '$baseUrl/RiderOrders/branch-to-customer';
  static const String branchToMerchantReturn =
      '$baseUrl/RiderOrders/branch-to-merchant-return';
  static const String verifyOtp = '$baseUrl/RiderOrders/verify-otp';
}
