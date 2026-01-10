import 'dart:convert';
import 'package:flutter/foundation.dart';

class JwtHelper {
  /// Extracts the rider ID from the JWT token payload
  /// Returns null if the token is invalid or rider ID is not found
  static String? extractRiderId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('❌ [JwtHelper] Invalid JWT token format (expected 3 parts)');
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = base64.normalize(payload);
      final decodedBytes = base64.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = jsonDecode(decodedString) as Map<String, dynamic>;

      debugPrint('🔍 [JwtHelper] JWT Payload keys: ${payloadMap.keys.toList()}');
      debugPrint('🔍 [JwtHelper] JWT Payload: $payloadMap');

      // Try different possible keys for rider ID
      final riderId = payloadMap['RiderId'] as String? ??
          payloadMap['riderId'] as String? ??
          payloadMap['RiderID'] as String? ??
          payloadMap['riderID'] as String? ??
          payloadMap['fk_RiderId'] as String? ??
          payloadMap['fkRiderId'] as String? ??
          payloadMap['sub'] as String? ??
          payloadMap['nameid'] as String? ??
          payloadMap['userId'] as String? ??
          payloadMap['UserId'] as String? ??
          payloadMap['user_id'] as String? ??
          payloadMap['id'] as String?;

      if (riderId != null) {
        debugPrint('✅ [JwtHelper] Rider ID found: $riderId');
      } else {
        debugPrint('❌ [JwtHelper] Rider ID not found in token payload');
        debugPrint('🔍 [JwtHelper] Available keys: ${payloadMap.keys.join(", ")}');
      }

      return riderId;
    } catch (e) {
      debugPrint('❌ [JwtHelper] Error extracting rider ID: $e');
      return null;
    }
  }
}

