import 'package:flutter/foundation.dart';

/// Provider to manage state for Returns Merchant Orders Screen
/// Preserves picked up state across rebuilds
class ReturnsMerchantOrdersProvider with ChangeNotifier {
  // Map to track which orders have been picked up
  final Map<String, bool> _pickedUp = {};

  /// Check if order has been picked up
  bool isPickedUp(String orderId) {
    return _pickedUp[orderId] ?? false;
  }

  /// Mark order as picked up
  void setPickedUp(String orderId, bool pickedUp) {
    _pickedUp[orderId] = pickedUp;
    notifyListeners();
  }

  /// Clear picked up state for an order
  void clearPickedUp(String orderId) {
    _pickedUp.remove(orderId);
    notifyListeners();
  }

  /// Clear all picked up states
  void clearAll() {
    _pickedUp.clear();
    notifyListeners();
  }
}
