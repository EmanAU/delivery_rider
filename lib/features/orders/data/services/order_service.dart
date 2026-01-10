import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/merchant_order_model.dart';
import '../models/customer_order_model.dart';

class OrderService {
  final StorageService _storageService = StorageService();

  /// Get authorization headers with access token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get merchant branch orders
  Future<List<MerchantOrderModel>> getMerchantBranchOrders(
    String riderId,
  ) async {
    debugPrint('📦 [OrderService] Fetching merchant branch orders...');
    debugPrint('📦 [OrderService] RiderId: $riderId');

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${ApiConstants.merchantBranchOrders}?RiderId=$riderId',
      );

      debugPrint('📦 [OrderService] URL: $uri');
      debugPrint('📦 [OrderService] Sending GET request...');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('❌ [OrderService] Request timeout');
              throw Exception('Connection timeout. Please check your internet connection.');
            },
          );

      debugPrint('📦 [OrderService] Status code: ${response.statusCode}');
      debugPrint('📦 [OrderService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('📦 [OrderService] Parsing response JSON...');
        final List<dynamic> jsonList = jsonDecode(response.body);
        debugPrint('📦 [OrderService] JSON list length: ${jsonList.length}');
        
        final orders = jsonList
            .map((json) {
              debugPrint('📦 [OrderService] Parsing order JSON: $json');
              return MerchantOrderModel.fromJson(json as Map<String, dynamic>);
            })
            .toList();
        
        debugPrint('✅ [OrderService] Fetched ${orders.length} merchant orders');
        
        // Log each parsed order's details
        for (int i = 0; i < orders.length; i++) {
          final order = orders[i];
          debugPrint('📦 [OrderService] Parsed Order $i:');
          debugPrint('   - pkMerchantOrderId: ${order.pkMerchantOrderId}');
          debugPrint('   - orderReferenceNumber: ${order.orderReferenceNumber}');
          debugPrint('   - businessName: ${order.businessName}');
          debugPrint('   - pickupAddress: ${order.pickupAddress}');
          debugPrint('   - orderDate: ${order.orderDate}');
          debugPrint('   - merchantPhoneNumber: ${order.merchantPhoneNumber}');
          debugPrint('   - toEntityName: ${order.toEntityName}');
        }
        
        return orders;
      } else if (response.statusCode == 401) {
        debugPrint('❌ [OrderService] Unauthorized (401)');
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [OrderService] No orders found (404)');
        return [];
      } else {
        debugPrint('❌ [OrderService] Request failed: ${response.statusCode}');
        throw Exception('Failed to fetch orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [OrderService] Error: $e');
      rethrow;
    }
  }

  /// Get branch to customer orders
  Future<List<CustomerOrderModel>> getBranchToCustomerOrders(
    String riderId,
  ) async {
    debugPrint('📦 [OrderService] Fetching branch to customer orders...');
    debugPrint('📦 [OrderService] RiderId: $riderId');

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${ApiConstants.branchToCustomer}?riderId=$riderId',
      );

      debugPrint('📦 [OrderService] URL: $uri');
      debugPrint('📦 [OrderService] Sending GET request...');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('❌ [OrderService] Request timeout');
              throw Exception('Connection timeout. Please check your internet connection.');
            },
          );

      debugPrint('📦 [OrderService] Status code: ${response.statusCode}');
      debugPrint('📦 [OrderService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final orders = jsonList
            .map((json) => CustomerOrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✅ [OrderService] Fetched ${orders.length} customer orders');
        return orders;
      } else if (response.statusCode == 401) {
        debugPrint('❌ [OrderService] Unauthorized (401)');
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [OrderService] No orders found (404)');
        return [];
      } else {
        debugPrint('❌ [OrderService] Request failed: ${response.statusCode}');
        throw Exception('Failed to fetch orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [OrderService] Error: $e');
      rethrow;
    }
  }

  /// Get branch to merchant return orders
  Future<List<CustomerOrderModel>> getBranchToMerchantReturnOrders(
    String riderId,
  ) async {
    debugPrint('📦 [OrderService] Fetching branch to merchant return orders...');
    debugPrint('📦 [OrderService] RiderId: $riderId');

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${ApiConstants.branchToMerchantReturn}?riderId=$riderId',
      );

      debugPrint('📦 [OrderService] URL: $uri');
      debugPrint('📦 [OrderService] Sending GET request...');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('❌ [OrderService] Request timeout');
              throw Exception('Connection timeout. Please check your internet connection.');
            },
          );

      debugPrint('📦 [OrderService] Status code: ${response.statusCode}');
      debugPrint('📦 [OrderService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final orders = jsonList
            .map((json) => CustomerOrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✅ [OrderService] Fetched ${orders.length} return orders');
        return orders;
      } else if (response.statusCode == 401) {
        debugPrint('❌ [OrderService] Unauthorized (401)');
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [OrderService] No orders found (404)');
        return [];
      } else {
        debugPrint('❌ [OrderService] Request failed: ${response.statusCode}');
        throw Exception('Failed to fetch orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [OrderService] Error: $e');
      rethrow;
    }
  }
}

