import 'dart:io';
import 'package:http/http.dart' as http;

/// Utility class to handle network errors and return user-friendly messages
class NetworkErrorHandler {
  /// Check if error is a network error and return user-friendly message
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Check for SocketException (no internet connection)
    if (error is SocketException) {
      return 'No internet connection';
    }

    // Check for ClientException (network errors)
    if (error is http.ClientException) {
      return 'No internet connection';
    }

    // Check for common network error patterns in error string
    if (errorString.contains('socketfailed') ||
        errorString.contains('host lookup') ||
        errorString.contains('no address associated') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection timed out') ||
        errorString.contains('connection reset') ||
        errorString.contains('no internet') ||
        errorString.contains('network error')) {
      return 'No internet connection';
    }

    // Check for timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('connection timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    }

    // If it's already a user-friendly message, return as is
    if (errorString.contains('please check your internet connection') ||
        errorString.contains('no internet connection')) {
      return error.toString().replaceAll('Exception: ', '');
    }

    // For other errors, return the original message (will be handled by UI)
    return error.toString().replaceAll('Exception: ', '');
  }

  /// Check if error is a network-related error
  static bool isNetworkError(dynamic error) {
    if (error is SocketException || error is http.ClientException) {
      return true;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketfailed') ||
        errorString.contains('host lookup') ||
        errorString.contains('no address associated') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection timed out') ||
        errorString.contains('connection reset') ||
        errorString.contains('timeout') ||
        errorString.contains('network error') ||
        errorString.contains('no internet');
  }
}
