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

class DeliverCustomerOrdersScreen extends StatefulWidget {
  const DeliverCustomerOrdersScreen({super.key});

  @override
  State<DeliverCustomerOrdersScreen> createState() =>
      _DeliverCustomerOrdersScreenState();
}

class _DeliverCustomerOrdersScreenState
    extends State<DeliverCustomerOrdersScreen> {
  final OrderService _orderService = OrderService();
  final DeliveryService _deliveryService = DeliveryService();
  final StorageService _storageService = StorageService();
  List<CustomerOrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, bool> _processingOrders = {};
  final Map<String, bool> _journeyStarted = {};
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
      debugPrint('❌ [DeliverCustomerOrdersScreen] Error formatting date: $e');
      // Return original if parsing fails
      return dateString;
    }
  }

  /// Get formatted address or placeholder
  String _getFormattedAddress(String address) {
    if (address.isEmpty || address.toLowerCase() == 'none' || address.trim().isEmpty) {
      return 'Address not available';
    }
    return address;
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

  Future<void> _handleStartJourney(CustomerOrderModel order) async {
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
      // Flow 2 Step B: "Rider is on the way" - When rider leaves branch with parcel
      // Status: 11 (Rider is on the way to deliver)
      // From: Branch, To: Customer
      final request = EventLogRequestModel(
        fkMerchantOrderId: order.pkMerchantOrderId,
        fkStatusId: ShipmentStatusEnum.riderIsOnTheWayToDeliver, // Status 11: "Rider is on the way"
        fkFromEntityTypeId: EntityTypeEnum.branch, // From branch
        fkToEntityTypeId: EntityTypeEnum.customer, // To customer
        fkFromEntityId: order.fkFromEntityId, // Branch entity ID
        fkToEntityId: '', // Customer entity ID - backend will determine from order
        fkRiderId: riderId,
        fkUpdatedByEntityTypeId: EntityTypeEnum.rider, // Updated by Rider (4)
        fkUpdatedBy: riderId,
      );

      final success = await _deliveryService.changeShipmentStatus(request);

      if (mounted) {
        if (success) {
          setState(() {
            _journeyStarted[order.pkMerchantOrderId] = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journey started successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start journey'),
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

  void _showVerifyOtpDialog(CustomerOrderModel order) {
    _otpController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Verify OTP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          content: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              labelStyle: TextStyle(
                color: AppColors.black.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.black.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.black, width: 2),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _otpController.clear();
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
              onPressed: () async {
                if (_otpController.text.length == 4) {
                  final otp = int.tryParse(_otpController.text);
                  if (otp == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid OTP'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  Navigator.of(context).pop();
                  await _verifyOtp(order, otp);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 4-digit OTP'),
                      backgroundColor: AppColors.black,
                    ),
                  );
                }
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
                'Verify',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyOtp(CustomerOrderModel order, int otp) async {
    setState(() {
      _processingOrders[order.pkMerchantOrderId] = true;
    });

    try {
      final isVerified = await _deliveryService.verifyOtp(
        order.pkMerchantOrderId,
        otp,
      );

      if (mounted) {
        if (isVerified) {
          _showOrderDetailsDialog(order);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid OTP. Please try again.'),
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

  void _showOrderDetailsDialog(CustomerOrderModel order) {
    // Map backend payment methods to dropdown values
    String _mapPaymentMethod(String paymentMethod) {
      if (paymentMethod.isEmpty) return 'Cash';
      // Map "Cash on Delivery" to "Cash"
      if (paymentMethod.toLowerCase().contains('cash') || 
          paymentMethod.toLowerCase().contains('cod')) {
        return 'Cash';
      }
      if (paymentMethod.toLowerCase().contains('card')) {
        return 'Card';
      }
      if (paymentMethod.toLowerCase().contains('online') || 
          paymentMethod.toLowerCase().contains('prepaid')) {
        return 'Online';
      }
      // Default to Cash if unknown
      return 'Cash';
    }

    String selectedPaymentMethod = _mapPaymentMethod(order.paymentMethod);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: AppColors.black.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Order Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Order Amount: ${order.orderAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.black.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPaymentMethod,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                              ),
                              items: ['Cash', 'Card', 'Online'].map(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedPaymentMethod = newValue;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _completeOrder(order);
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
                              'Complete Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
        );
      },
    );
  }

  Future<void> _completeOrder(CustomerOrderModel order) async {
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
      // Flow 2 Step D: "Received by Customer" - After OTP verification, rider hands over package
      // Status: 6 (Received by Customer)
      // From: Branch, To: Customer
      final request = EventLogRequestModel(
        fkMerchantOrderId: order.pkMerchantOrderId,
        fkStatusId: ShipmentStatusEnum.receivedByCustomer, // Status 6: "Received by Customer"
        fkFromEntityTypeId: EntityTypeEnum.branch, // From branch
        fkToEntityTypeId: EntityTypeEnum.customer, // To customer
        fkFromEntityId: order.fkFromEntityId, // Branch entity ID
        fkToEntityId: '', // Customer entity ID - backend will determine from order
        fkRiderId: riderId,
        fkUpdatedByEntityTypeId: EntityTypeEnum.rider, // Updated by Rider (4)
        fkUpdatedBy: riderId,
      );

      final success = await _deliveryService.changeShipmentStatus(request);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to complete order'),
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

  Future<void> _handleReturnToBranch(CustomerOrderModel order) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Return to Branch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          content: const Text(
            'Select reason for return:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: AppColors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
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
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Customer Not Found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _returnOrder(order, ShipmentStatusEnum.customerDidNotAccept);
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
                'Not Accepted',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _returnOrder(order, ShipmentStatusEnum.customerNotFound);
    }
  }

  Future<void> _returnOrder(
    CustomerOrderModel order,
    int statusId,
  ) async {
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
      // Flow 2 - Return: When delivery fails (Customer Not Found or Not Accepted)
      // Status: 12 (Customer Not Found) or 7 (Customer Did Not Accept)
      // From: Customer, To: Branch
      final request = EventLogRequestModel(
        fkMerchantOrderId: order.pkMerchantOrderId,
        fkStatusId: statusId, // Status 12 or 7
        fkFromEntityTypeId: EntityTypeEnum.customer, // From customer
        fkToEntityTypeId: EntityTypeEnum.branch, // To branch
        fkFromEntityId: '', // Customer entity ID - backend will determine
        fkToEntityId: order.fkFromEntityId, // Branch entity ID
        fkRiderId: riderId,
        fkUpdatedByEntityTypeId: EntityTypeEnum.rider, // Updated by Rider (4)
        fkUpdatedBy: riderId,
      );

      final success = await _deliveryService.changeShipmentStatus(request);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order returned to branch'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Deliver to Customer Orders',
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
                          final journeyStarted =
                              _journeyStarted[order.pkMerchantOrderId] ?? false;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ref: ${order.orderReferenceNumber}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(order.orderDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 8),
                                Text(
                                  order.receiverContactNumber,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 24.0),
                                  child: Text(
                                    _getFormattedAddress(order.deliveryAddress),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (!journeyStarted)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: isProcessing
                                          ? null
                                          : () => _handleStartJourney(order),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.black,
                                        foregroundColor: AppColors.white,
                                        disabledBackgroundColor:
                                            AppColors.black.withValues(alpha: 0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: isProcessing
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Start Journey',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: isProcessing
                                                ? null
                                                : () =>
                                                    _showVerifyOtpDialog(order),
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
                                            ),
                                            child: isProcessing
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Verify OTP',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: isProcessing
                                                ? null
                                                : () =>
                                                    _handleReturnToBranch(order),
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
                                            ),
                                            child: const Text(
                                              'Return To Branch',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
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
    );
  }
}
