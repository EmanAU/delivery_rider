import 'package:flutter/foundation.dart';

/// Provider to manage state for Deliver Customer Orders Screen
/// Preserves journey started state across rebuilds
class DeliverCustomerOrdersProvider with ChangeNotifier {
  // Map to track which orders have started their journey
  final Map<String, bool> _journeyStarted = {};

  /// Check if journey has started for an order
  bool isJourneyStarted(String orderId) {
    return _journeyStarted[orderId] ?? false;
  }

  /// Mark journey as started for an order
  void setJourneyStarted(String orderId, bool started) {
    _journeyStarted[orderId] = started;
    notifyListeners();
  }

  /// Clear journey started state for an order
  void clearJourneyStarted(String orderId) {
    _journeyStarted.remove(orderId);
    notifyListeners();
  }

  /// Clear all journey started states
  void clearAll() {
    _journeyStarted.clear();
    notifyListeners();
  }
}
