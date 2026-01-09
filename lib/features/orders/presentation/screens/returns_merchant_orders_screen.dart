import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ReturnsMerchantOrdersScreen extends StatelessWidget {
  const ReturnsMerchantOrdersScreen({super.key});

  void _showReturnConfirmationDialog(BuildContext context) {
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
            'Are you sure you want to return this order?',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order returned successfully'),
                    backgroundColor: AppColors.black,
                  ),
                );
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
    // Sample data - replace with actual data from API
    final List<Map<String, String>> orders = [
      {
        'ref': '12345',
        'merchantName': 'Abdullah Traders',
        'address': 'F8/2 Street 23',
        'date': '07-01-2026',
        'phone': '03214567890',
      },
      {
        'ref': '12345',
        'merchantName': 'Abdullah Traders',
        'address': 'F8/2 Street 23',
        'date': '07-01-2026',
        'phone': '03214567890',
      },
      {
        'ref': '12345',
        'merchantName': 'Abdullah Traders',
        'address': 'F8/2 Street 23',
        'date': '07-01-2026',
        'phone': '03214567890',
      },
      {
        'ref': '12345',
        'merchantName': 'Abdullah Traders',
        'address': 'F8/2 Street 23',
        'date': '07-01-2026',
        'phone': '03214567890',
      },
      {
        'ref': '12345',
        'merchantName': 'Abdullah Traders',
        'address': 'F8/2 Street 23',
        'date': '07-01-2026',
        'phone': '03214567890',
      },
    ];

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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
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
                // Left side - Order details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ref and Date row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ref: ${order['ref']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            order['date']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Merchant name
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
                              order['merchantName']!,
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
                      // Phone number
                      Text(
                        order['phone']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Address
                      Text(
                        order['address']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Return button
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: SizedBox(
                    width: 100,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        _showReturnConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Return',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
