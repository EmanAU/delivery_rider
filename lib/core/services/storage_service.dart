import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/jwt_helper.dart';
import '../utils/network_error_handler.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _userNameKey = 'user_name';
  static const String _riderIdKey = 'rider_id';
  static const String _expiresInKey = 'expires_in';

  // Save login data
  Future<void> saveLoginData({
    required String accessToken,
    required String userName,
    required String riderId,
    required int expiresIn,
  }) async {
    debugPrint('💾 [StorageService] Saving login data...');
    debugPrint('💾 [StorageService] AccessToken length: ${accessToken.length}');
    debugPrint('💾 [StorageService] UserName: $userName');
    debugPrint('💾 [StorageService] RiderId: $riderId');
    debugPrint('💾 [StorageService] ExpiresIn: $expiresIn');

    try {
      if (accessToken.isEmpty) {
        debugPrint('❌ [StorageService] Access token is empty');
        throw Exception('Access token cannot be empty');
      }

      debugPrint('💾 [StorageService] Getting SharedPreferences instance...');
      final prefs = await SharedPreferences.getInstance();

      debugPrint('💾 [StorageService] Saving access token...');
      final tokenSaved = await prefs.setString(_accessTokenKey, accessToken);
      debugPrint('💾 [StorageService] Token saved: $tokenSaved');

      debugPrint('💾 [StorageService] Saving user name...');
      final userNameSaved = await prefs.setString(_userNameKey, userName);
      debugPrint('💾 [StorageService] UserName saved: $userNameSaved');

      debugPrint('💾 [StorageService] Saving rider ID...');
      final riderIdSaved = await prefs.setString(_riderIdKey, riderId);
      debugPrint('💾 [StorageService] RiderId saved: $riderIdSaved');

      debugPrint('💾 [StorageService] Saving expires in...');
      final expiresInSaved = await prefs.setInt(_expiresInKey, expiresIn);
      debugPrint('💾 [StorageService] ExpiresIn saved: $expiresInSaved');

      if (!tokenSaved || !userNameSaved || !riderIdSaved || !expiresInSaved) {
        debugPrint('❌ [StorageService] Failed to save all data');
        throw Exception('Failed to save login data');
      }

      debugPrint('✅ [StorageService] All login data saved successfully');
    } catch (e) {
      debugPrint('❌ [StorageService] Error saving login data: $e');
      // Check if it's a network error (unlikely for storage, but handle it)
      if (NetworkErrorHandler.isNetworkError(e)) {
        throw Exception(NetworkErrorHandler.getErrorMessage(e));
      }
      throw Exception('Failed to save data. Please try again.');
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    debugPrint('💾 [StorageService] Getting access token...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_accessTokenKey);
      if (token != null) {
        debugPrint(
            '✅ [StorageService] Access token retrieved (length: ${token.length})');
      } else {
        debugPrint('⚠️ [StorageService] Access token not found');
      }
      return token;
    } catch (e) {
      debugPrint('❌ [StorageService] Error getting access token: $e');
      return null;
    }
  }

  // Get user name
  Future<String?> getUserName() async {
    debugPrint('💾 [StorageService] Getting user name...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString(_userNameKey);
      if (userName != null) {
        debugPrint('✅ [StorageService] User name retrieved: $userName');
      } else {
        debugPrint('⚠️ [StorageService] User name not found');
      }
      return userName;
    } catch (e) {
      debugPrint('❌ [StorageService] Error getting user name: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    debugPrint('💾 [StorageService] Checking if user is logged in...');
    try {
      final token = await getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      debugPrint('💾 [StorageService] Is logged in: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      debugPrint('❌ [StorageService] Error checking login status: $e');
      return false;
    }
  }

  // Get rider ID from storage (with fallback to JWT token extraction)
  Future<String?> getRiderId() async {
    debugPrint('💾 [StorageService] Getting rider ID...');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // First, try to get rider ID directly from storage
      final riderId = prefs.getString(_riderIdKey);
      if (riderId != null && riderId.isNotEmpty) {
        debugPrint('✅ [StorageService] Rider ID retrieved from storage: $riderId');
        return riderId;
      }
      
      // Fallback: try to extract from JWT token (for backward compatibility)
      debugPrint('⚠️ [StorageService] Rider ID not found in storage, trying JWT token...');
      final token = await getAccessToken();
      if (token == null) {
        debugPrint('⚠️ [StorageService] No token found');
        return null;
      }
      final extractedRiderId = JwtHelper.extractRiderId(token);
      if (extractedRiderId != null) {
        debugPrint('✅ [StorageService] Rider ID extracted from token: $extractedRiderId');
      } else {
        debugPrint('⚠️ [StorageService] Rider ID not found in token');
      }
      return extractedRiderId;
    } catch (e) {
      debugPrint('❌ [StorageService] Error getting rider ID: $e');
      return null;
    }
  }

  // Clear login data (logout)
  Future<void> clearLoginData() async {
    debugPrint('💾 [StorageService] Clearing login data...');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      debugPrint('💾 [StorageService] Access token removed');
      await prefs.remove(_userNameKey);
      debugPrint('💾 [StorageService] User name removed');
      await prefs.remove(_riderIdKey);
      debugPrint('💾 [StorageService] Rider ID removed');
      await prefs.remove(_expiresInKey);
      debugPrint('💾 [StorageService] Expires in removed');
      debugPrint('✅ [StorageService] All login data cleared');
    } catch (e) {
      debugPrint(
          '⚠️ [StorageService] Error clearing login data (non-critical): $e');
      // Silently fail on logout - not critical
    }
  }
}
