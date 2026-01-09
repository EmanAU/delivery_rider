import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthService {
  Future<LoginResponseModel?> riderLogin(LoginRequestModel request) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.riderLogin),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      // Handle different status codes
      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
          return LoginResponseModel.fromJson(jsonData);
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - invalid credentials
        return null;
      } else if (response.statusCode == 400) {
        // Bad request
        try {
          final errorData = jsonDecode(response.body);
          final message =
              errorData['message'] ?? errorData['Message'] ?? 'Invalid request';
          throw Exception(message);
        } catch (e) {
          throw Exception('Invalid request. Please check your credentials.');
        }
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      } else {
        throw Exception(
          'Request failed with status code: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } on Exception catch (e) {
      // Re-throw our custom exceptions
      throw e;
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
