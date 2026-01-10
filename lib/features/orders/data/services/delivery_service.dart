import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/event_log_request_model.dart';

class DeliveryService {
  final StorageService _storageService = StorageService();

  /// Get authorization headers with access token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    // Debug: Log if token is being sent
    if (token != null) {
      debugPrint('🔐 [DeliveryService] Bearer token found: ${token.substring(0, 20)}...');
      debugPrint('🔐 [DeliveryService] Authorization header: Bearer ${token.substring(0, 20)}...');
    } else {
      debugPrint('⚠️ [DeliveryService] No Bearer token found!');
    }
    
    return headers;
  }

  /// Change shipment status
  Future<bool> changeShipmentStatus(EventLogRequestModel request) async {
    debugPrint('🚚 [DeliveryService] Changing shipment status...');
    debugPrint('🚚 [DeliveryService] MerchantOrderId: ${request.fkMerchantOrderId}');
    debugPrint('🚚 [DeliveryService] StatusId: ${request.fkStatusId}');

    try {
      final headers = await _getHeaders();
      final jsonData = request.toJson();
      final requestBody = jsonEncode(jsonData);

      debugPrint('🚚 [DeliveryService] URL: ${ApiConstants.changeShipmentStatus}');
      debugPrint('🚚 [DeliveryService] Request JSON data:');
      debugPrint('   - fk_MerchantOrderId: ${jsonData['fk_MerchantOrderId']}');
      debugPrint('   - fk_StatusId: ${jsonData['fk_StatusId']}');
      debugPrint('   - fk_FromEntityTypeId: ${jsonData['fk_FromEntityTypeId']}');
      debugPrint('   - fk_ToEntityTypeId: ${jsonData['fk_ToEntityTypeId']}');
      debugPrint('   - fk_FromEntityId: ${jsonData['fk_FromEntityId']}');
      debugPrint('   - fk_ToEntityId: ${jsonData['fk_ToEntityId']}');
      debugPrint('   - fk_RiderId: ${jsonData['fk_RiderId']}');
      debugPrint('   - fk_UpdatedByEntityTypeId: ${jsonData['fk_UpdatedByEntityTypeId']}');
      debugPrint('   - fk_UpdatedBy: ${jsonData['fk_UpdatedBy']}');
      debugPrint('🚚 [DeliveryService] Request body: $requestBody');
      debugPrint('🚚 [DeliveryService] Sending POST request...');

      final response = await http
          .post(
            Uri.parse(ApiConstants.changeShipmentStatus),
            headers: headers,
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('❌ [DeliveryService] Request timeout');
              throw Exception('Connection timeout. Please check your internet connection.');
            },
          );

      debugPrint('🚚 [DeliveryService] Status code: ${response.statusCode}');
      debugPrint('🚚 [DeliveryService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final message = jsonData['message'] ?? '';
        debugPrint('✅ [DeliveryService] Status updated: $message');
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('❌ [DeliveryService] Unauthorized (401)');
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final error = errorData['error'] ?? errorData['message'] ?? 'Bad request';
        debugPrint('❌ [DeliveryService] Bad request: $error');
        throw Exception(error);
      } else {
        debugPrint('❌ [DeliveryService] Request failed: ${response.statusCode}');
        throw Exception('Failed to update status. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [DeliveryService] Error: $e');
      rethrow;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String merchantOrderId, int otp) async {
    debugPrint('🔐 [DeliveryService] Verifying OTP...');
    debugPrint('🔐 [DeliveryService] MerchantOrderId: $merchantOrderId');
    debugPrint('🔐 [DeliveryService] OTP: $otp');

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${ApiConstants.verifyOtp}?merchantOrderId=$merchantOrderId&otp=$otp',
      );

      debugPrint('🔐 [DeliveryService] URL: $uri');
      debugPrint('🔐 [DeliveryService] Sending GET request...');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('❌ [DeliveryService] Request timeout');
              throw Exception('Connection timeout. Please check your internet connection.');
            },
          );

      debugPrint('🔐 [DeliveryService] Status code: ${response.statusCode}');
      debugPrint('🔐 [DeliveryService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final isVerified = jsonData['isVerified'] ?? jsonData['IsVerified'] ?? false;
        debugPrint('✅ [DeliveryService] OTP verified: $isVerified');
        return isVerified as bool;
      } else if (response.statusCode == 401) {
        debugPrint('❌ [DeliveryService] Unauthorized (401)');
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final error = errorData['error'] ?? errorData['message'] ?? 'Invalid OTP';
        debugPrint('❌ [DeliveryService] Bad request: $error');
        throw Exception(error);
      } else {
        debugPrint('❌ [DeliveryService] Request failed: ${response.statusCode}');
        throw Exception('Failed to verify OTP. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [DeliveryService] Error: $e');
      rethrow;
    }
  }
}

