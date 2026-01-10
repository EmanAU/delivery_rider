import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/shipment_status_enum.dart';
import '../../../../core/constants/entity_type_enum.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/merchant_order_model.dart';
import '../../data/services/order_service.dart';
import '../../data/services/delivery_service.dart';
import '../../data/models/event_log_request_model.dart';

class MerchantOrdersScreen extends StatefulWidget {
  const MerchantOrdersScreen({super.key});

  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> {
  final OrderService _orderService = OrderService();
  final DeliveryService _deliveryService = DeliveryService();
  final StorageService _storageService = StorageService();
  List<MerchantOrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, bool> _processingOrders = {};
  String? _toastMessage;

  /// Format date from ISO string to readable format
  String _formatDate(String dateString) {
    try {
      // Handle ISO format: 2025-12-15T14:29:37.227
      DateTime dateTime;
      if (dateString.contains('T')) {
        // Remove milliseconds if present
        final cleanDate = dateString.split('.')[0];
        dateTime = DateTime.parse(cleanDate);
      } else {
        dateTime = DateTime.parse(dateString);
      }

      // Format: "15 Dec 2025, 2:29 PM"
      final dateFormat = DateFormat('d MMM yyyy, h:mm a', 'en_US');
      return dateFormat.format(dateTime);
    } catch (e) {
      debugPrint('❌ [MerchantOrdersScreen] Error formatting date: $e');
      // Return original if parsing fails
      return dateString;
    }
  }

  /// Get formatted address or placeholder
  String _getFormattedAddress(String address) {
    if (address.isEmpty ||
        address.toLowerCase() == 'address' ||
        address.trim().isEmpty) {
      return 'Address not available';
    }
    return address;
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    debugPrint('📦 [MerchantOrdersScreen] Loading orders...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('📦 [MerchantOrdersScreen] Getting rider ID from storage...');
      final riderId = await _storageService.getRiderId();
      debugPrint('📦 [MerchantOrdersScreen] Rider ID retrieved: $riderId');

      if (riderId == null) {
        debugPrint('❌ [MerchantOrdersScreen] Rider ID is null');
        setState(() {
          _errorMessage = 'Unable to get rider ID. Please login again.';
          _isLoading = false;
        });
        return;
      }

      debugPrint(
          '📦 [MerchantOrdersScreen] Calling getMerchantBranchOrders with riderId: $riderId');
      final orders = await _orderService.getMerchantBranchOrders(riderId);
      debugPrint(
          '📦 [MerchantOrdersScreen] Orders received: ${orders.length} orders');

      // Log each order's details including status
      for (int i = 0; i < orders.length; i++) {
        final order = orders[i];
        debugPrint('📦 [MerchantOrdersScreen] Order $i:');
        debugPrint('   - pkMerchantOrderId: ${order.pkMerchantOrderId}');
        debugPrint('   - orderReferenceNumber: ${order.orderReferenceNumber}');
        debugPrint('   - businessName: ${order.businessName}');
        debugPrint('   - pickupAddress: ${order.pickupAddress}');
        debugPrint('   - orderDate: ${order.orderDate}');
        debugPrint('   - merchantPhoneNumber: ${order.merchantPhoneNumber}');
        debugPrint('   - toEntityName: ${order.toEntityName}');
        debugPrint(
            '   - fkShipmentStatusId: ${order.fkShipmentStatusId} ${order.fkShipmentStatusId == 10 ? "✅ PICKED BY RIDER" : ""}');
      }

      // Count orders by status
      final pickedOrders =
          orders.where((o) => o.fkShipmentStatusId == 10).length;
      debugPrint(
          '📦 [MerchantOrdersScreen] Orders with status 10 (Picked by Rider): $pickedOrders');

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
      debugPrint(
          '✅ [MerchantOrdersScreen] Orders loaded successfully. Total: ${_orders.length}');
    } catch (e) {
      debugPrint('❌ [MerchantOrdersScreen] Error loading orders: $e');
      debugPrint('❌ [MerchantOrdersScreen] Error type: ${e.runtimeType}');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleReceive(MerchantOrderModel order) async {
    final riderId = await _storageService.getRiderId();
    if (riderId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get rider ID. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _processingOrders[order.pkMerchantOrderId] = true;
    });

    try {
      // Flow 1 Step B: "Picked by Rider" - When rider physically picks up parcel from Merchant
      final request = EventLogRequestModel(
        fkMerchantOrderId: order.pkMerchantOrderId,
        fkStatusId:
            ShipmentStatusEnum.pickedByRider, // Status 10: "Picked by Rider"
        fkFromEntityTypeId: EntityTypeEnum.customer, // From Merchant
        fkToEntityTypeId: EntityTypeEnum.branch, // To Branch
        fkFromEntityId: order.fkMerchantId, // Merchant ID
        fkToEntityId: '', // Branch ID - backend will determine
        fkRiderId: riderId,
        fkUpdatedByEntityTypeId: EntityTypeEnum.rider, // Updated by Rider
        fkUpdatedBy: riderId,
      );

      final success = await _deliveryService.changeShipmentStatus(request);

      if (mounted) {
        if (success) {
          // Show toast message below appbar
          setState(() {
            _toastMessage = 'Order successfully picked';
          });
          // Hide toast after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _toastMessage = null;
              });
            }
          });
          // Reload orders - backend will decide if order stays or goes
          _loadOrders();
        } else {
          setState(() {
            _toastMessage = 'Failed to pick up order';
          });
          // Hide toast after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _toastMessage = null;
              });
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _processingOrders[order.pkMerchantOrderId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Merchant Orders',
          style: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toast message below appbar
          if (_toastMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _toastMessage!.contains('successfully')
                  ? Colors.green
                  : Colors.red,
              child: Row(
                children: [
                  Icon(
                    _toastMessage!.contains('successfully')
                        ? Icons.check_circle
                        : Icons.error,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _toastMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.black,
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.black,
                                foregroundColor: AppColors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? const Center(
                            child: Text(
                              'No orders available',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.black,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            color: AppColors.black,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                final isProcessing = _processingOrders[
                                        order.pkMerchantOrderId] ??
                                    false;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.white.withValues(alpha: 0.5),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.black
                                            .withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left side - Order details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '${index + 1}.',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Ref: ${order.orderReferenceNumber}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              order.businessName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getFormattedAddress(
                                                  order.pickupAddress),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                color: AppColors.black,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Right side - Date, Phone, and Receive button
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatDate(order.orderDate),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            order.merchantPhoneNumber,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: 100,
                                            height: 36,
                                            child: ElevatedButton(
                                              onPressed: isProcessing
                                                  ? null
                                                  : () => _handleReceive(order),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.black,
                                                foregroundColor:
                                                    AppColors.white,
                                                disabledBackgroundColor:
                                                    AppColors.black
                                                        .withValues(alpha: 0.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: isProcessing
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Receive',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
