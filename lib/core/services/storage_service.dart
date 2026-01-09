import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _userNameKey = 'user_name';
  static const String _expiresInKey = 'expires_in';

  // Save login data
  Future<void> saveLoginData({
    required String accessToken,
    required String userName,
    required int expiresIn,
  }) async {
    try {
      if (accessToken.isEmpty) {
        throw Exception('Access token cannot be empty');
      }

      final prefs = await SharedPreferences.getInstance();
      final tokenSaved = await prefs.setString(_accessTokenKey, accessToken);
      final userNameSaved = await prefs.setString(_userNameKey, userName);
      final expiresInSaved = await prefs.setInt(_expiresInKey, expiresIn);

      if (!tokenSaved || !userNameSaved || !expiresInSaved) {
        throw Exception('Failed to save login data');
      }
    } catch (e) {
      throw Exception('Storage error: ${e.toString()}');
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get user name
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Clear login data (logout)
  Future<void> clearLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_expiresInKey);
    } catch (e) {
      // Silently fail on logout - not critical
    }
  }
}
