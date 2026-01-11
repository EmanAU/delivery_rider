import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/shipment_status_enum.dart';
import '../../../../core/constants/entity_type_enum.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/customer_order_model.dart';
import '../../data/services/order_service.dart';
import '../../data/services/delivery_service.dart';
import '../../data/models/event_log_request_model.dart';

class PickOrderBranchScreen extends StatefulWidget {
  const PickOrderBranchScreen({super.key});

  @override
  State<PickOrderBranchScreen> createState() => _PickOrderBranchScreenState();
}

class _PickOrderBranchScreenState extends State<PickOrderBranchScreen> {
  final OrderService _orderService = OrderService();
  final DeliveryService _deliveryService = DeliveryService();
  final StorageService _storageService = StorageService();
  List<CustomerOrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, bool> _processingOrders = {};
  String? _toastMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

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
      debugPrint('❌ [PickOrderBranchScreen] Error formatting date: $e');
      // Return original if parsing fails
      return dateString;
    }
  }

  /// Handle pickup - change status to "Rider is on the way"
  Future<void> _handlePickup(CustomerOrderModel order) async {
    final riderId = await _storageService.getRiderId();
    if (riderId == null) {
      if (mounted) {
        setState(() {
          _toastMessage = 'Unable to get rider ID. Please login again.';
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _toastMessage = null;
            });
          }
        });
      }
      return;
    }

    setState(() {
      _processingOrders[order.pkMerchantOrderId] = true;
    });

    try {
      // Pick up order from Branch - Rider picks up order
      // Status: 10 (Picked by Rider)
      // From: Branch, To: Customer
      final request = EventLogRequestModel(
        fkMerchantOrderId: order.pkMerchantOrderId,
        fkStatusId:
            ShipmentStatusEnum.pickedByRider, // Status 10: "Picked by Rider"
        fkFromEntityTypeId: EntityTypeEnum.branch, // From branch (2)
        fkToEntityTypeId: EntityTypeEnum.customer, // To customer (5)
        fkFromEntityId: order.fkFromEntityId, // Branch entity ID
        fkToEntityId: '', // Customer entity ID - backend will determine
        fkRiderId: riderId,
        fkUpdatedByEntityTypeId: EntityTypeEnum.rider, // Updated by Rider (4)
        fkUpdatedBy: riderId,
      );

      final success = await _deliveryService.changeShipmentStatus(request);

      if (mounted) {
        if (success) {
          setState(() {
            _toastMessage = 'Order picked up successfully';
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _toastMessage = null;
              });
            }
          });
          // Reload orders to remove picked up order
          _loadOrders();
        } else {
          setState(() {
            _toastMessage = 'Failed to pick up order';
          });
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
        setState(() {
          _toastMessage = e.toString().replaceAll('Exception: ', '');
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _toastMessage = null;
            });
          }
        });
      }
    } finally {
      setState(() {
        _processingOrders[order.pkMerchantOrderId] = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final riderId = await _storageService.getRiderId();
      if (riderId == null) {
        setState(() {
          _errorMessage = 'Unable to get rider ID. Please login again.';
          _isLoading = false;
        });
        return;
      }

      // This screen shows orders ready to be picked from branch
      // Using branch-to-customer endpoint as it shows orders assigned to rider
      final orders = await _orderService.getBranchToCustomerOrders(riderId);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
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
          'Pick Order from Branch',
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
                                              order.receiverName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              order.deliveryAddress,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                color: AppColors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                            order.receiverContactNumber,
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
                                              onPressed: (_processingOrders[order
                                                          .pkMerchantOrderId] ??
                                                      false)
                                                  ? null
                                                  : () => _handlePickup(order),
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
                                              child: (_processingOrders[order
                                                          .pkMerchantOrderId] ??
                                                      false)
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
                                                      'Pickup',
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
