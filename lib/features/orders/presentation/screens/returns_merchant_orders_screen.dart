import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/shipment_status_enum.dart';
import '../../../../core/constants/entity_type_enum.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/customer_order_model.dart';
import '../../data/services/order_service.dart';
import '../../data/services/delivery_service.dart';
import '../../data/models/event_log_request_model.dart';

class ReturnsMerchantOrdersScreen extends StatefulWidget {
  const ReturnsMerchantOrdersScreen({super.key});

  @override
  State<ReturnsMerchantOrdersScreen> createState() =>
      _ReturnsMerchantOrdersScreenState();
}

class _ReturnsMerchantOrdersScreenState
    extends State<ReturnsMerchantOrdersScreen> {
  final OrderService _orderService = OrderService();
  final DeliveryService _deliveryService = DeliveryService();
  final StorageService _storageService = StorageService();
  List<CustomerOrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, bool> _processingOrders = {};
  final Map<String, bool> _pickedUp = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
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

      final orders =
          await _orderService.getBranchToMerchantReturnOrders(riderId);
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

  Future<void> _handlePickup(CustomerOrderModel order) async {
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
      // Status: "Rider return to merchant" (18)
      final request = EventLogRequestModel(
        fkMerchantOrderId: order.pkMerchantOrderId,
        fkStatusId: ShipmentStatusEnum.riderReturnToMerchant,
        fkFromEntityTypeId: EntityTypeEnum.branch, // From branch
        fkToEntityTypeId: EntityTypeEnum.customer, // To merchant (using customer enum as per original)
        fkFromEntityId: order.fkFromEntityId, // Branch entity ID
        fkToEntityId: order.fkMerchantId, // Merchant ID
        fkRiderId: riderId,
        fkUpdatedByEntityTypeId: 4175, // Updated by rider
        fkUpdatedBy: riderId,
      );

      final success = await _deliveryService.changeShipmentStatus(request);

      if (mounted) {
        if (success) {
          setState(() {
            _pickedUp[order.pkMerchantOrderId] = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order picked up for return'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to pick up order'),
              backgroundColor: Colors.red,
            ),
          );
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

  Future<void> _handleReturn(CustomerOrderModel order) async {
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
      // Status: "Returned to merchant" (19)
      final request = EventLogRequestModel(
        fkMerchantOrderId: order.pkMerchantOrderId,
        fkStatusId: ShipmentStatusEnum.returnedToMerchant,
        fkFromEntityTypeId: EntityTypeEnum.branch, // From branch
        fkToEntityTypeId: EntityTypeEnum.customer, // To merchant (using customer enum as per original)
        fkFromEntityId: order.fkFromEntityId, // Branch entity ID
        fkToEntityId: order.fkMerchantId, // Merchant ID
        fkRiderId: riderId,
        fkUpdatedByEntityTypeId: 4175, // Updated by rider
        fkUpdatedBy: riderId,
      );

      final success = await _deliveryService.changeShipmentStatus(request);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order returned to merchant successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to return order'),
              backgroundColor: Colors.red,
            ),
          );
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

  void _showReturnConfirmationDialog(CustomerOrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Return Order',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to return this order to merchant?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: AppColors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleReturn(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Return',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
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
          'Returns to Merchant Orders',
          style: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
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
                          final isProcessing =
                              _processingOrders[order.pkMerchantOrderId] ?? false;
                          final pickedUp =
                              _pickedUp[order.pkMerchantOrderId] ?? false;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.5),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.black.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Ref: ${order.orderReferenceNumber}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          Text(
                                            order.orderDate,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
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
                                              order.receiverName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.black,
                                              ),
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order.receiverContactNumber,
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    children: [
                                      if (!pickedUp)
                                        SizedBox(
                                          width: 100,
                                          height: 36,
                                          child: ElevatedButton(
                                            onPressed: isProcessing
                                                ? null
                                                : () => _handlePickup(order),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.black,
                                              foregroundColor: AppColors.white,
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
                                                    'Pickup',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                          ),
                                        )
                                      else
                                        SizedBox(
                                          width: 100,
                                          height: 36,
                                          child: ElevatedButton(
                                            onPressed: isProcessing
                                                ? null
                                                : () =>
                                                    _showReturnConfirmationDialog(
                                                        order),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.black,
                                              foregroundColor: AppColors.white,
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
                                                    'Return',
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
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
