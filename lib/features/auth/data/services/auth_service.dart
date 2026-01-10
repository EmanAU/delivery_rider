import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthService {
  Future<LoginResponseModel?> riderLogin(LoginRequestModel request) async {
    debugPrint('🔐 [AuthService] Starting rider login...');
    debugPrint('🔐 [AuthService] URL: ${ApiConstants.riderLogin}');
    debugPrint('🔐 [AuthService] Username: ${request.username}');
    debugPrint(
        '🔐 [AuthService] PasswordHash: ${'*' * request.passwordHash.length}');

    try {
      debugPrint('🔐 [AuthService] Preparing request...');
      final requestBody = jsonEncode(request.toJson());
      debugPrint('🔐 [AuthService] Request body: $requestBody');

      debugPrint('🔐 [AuthService] Sending POST request...');
      final stopwatch = Stopwatch()..start();

      final response = await http
          .post(
        Uri.parse(ApiConstants.riderLogin),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('❌ [AuthService] Request timeout after 30 seconds');
          throw Exception(
            'Connection timeout. Please check your internet connection.',
          );
        },
      );

      stopwatch.stop();
      debugPrint(
        '🔐 [AuthService] Response received in ${stopwatch.elapsedMilliseconds}ms',
      );
      debugPrint('🔐 [AuthService] Status code: ${response.statusCode}');
      debugPrint('🔐 [AuthService] Response headers: ${response.headers}');
      debugPrint('🔐 [AuthService] Response body: ${response.body}');

      // Handle different status codes
      if (response.statusCode == 200) {
        debugPrint('✅ [AuthService] Login successful (200 OK)');
        try {
          debugPrint('🔐 [AuthService] Parsing JSON response...');
          final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('🔐 [AuthService] Parsed JSON: $jsonData');

          final loginResponse = LoginResponseModel.fromJson(jsonData);
          debugPrint('✅ [AuthService] Login response parsed successfully');
          debugPrint(
            '🔐 [AuthService] AccessToken: ${loginResponse.accessToken.substring(0, 20)}...',
          );
          debugPrint('🔐 [AuthService] UserName: ${loginResponse.userName}');
          debugPrint('🔐 [AuthService] RiderId: ${loginResponse.riderId}');
          debugPrint(
            '🔐 [AuthService] ExpiresIn: ${loginResponse.expiresIn} seconds',
          );

          return loginResponse;
        } catch (e) {
          debugPrint('❌ [AuthService] JSON parsing error: $e');
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ [AuthService] Unauthorized (401) - Invalid credentials');
        return null;
      } else if (response.statusCode == 400) {
        debugPrint('❌ [AuthService] Bad request (400)');
        try {
          final errorData = jsonDecode(response.body);
          final message =
              errorData['message'] ?? errorData['Message'] ?? 'Invalid request';
          debugPrint('❌ [AuthService] Error message: $message');
          throw Exception(message);
        } catch (e) {
          debugPrint('❌ [AuthService] Error parsing error response: $e');
          throw Exception('Invalid request. Please check your credentials.');
        }
      } else if (response.statusCode == 500) {
        debugPrint('❌ [AuthService] Internal server error (500)');
        throw Exception('Server error. Please try again later.');
      } else if (response.statusCode >= 500) {
        debugPrint('❌ [AuthService] Server error (${response.statusCode})');
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      } else {
        debugPrint(
          '❌ [AuthService] Request failed with status: ${response.statusCode}',
        );
        throw Exception(
          'Request failed with status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ [AuthService] Network/Client exception: $e');
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException catch (e) {
      debugPrint('❌ [AuthService] Format exception: $e');
      throw Exception('Invalid response format from server.');
    } on Exception catch (e) {
      debugPrint('❌ [AuthService] Exception: $e');
      // Re-throw our custom exceptions
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthService] Unexpected error: $e');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
