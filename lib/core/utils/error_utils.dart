import 'package:ecommerce/core/network/api_exception.dart';

/// Utilities for consistent error message handling.
class ErrorUtils {
  ErrorUtils._();

  /// Returns a user-friendly message from any thrown object.
  static String userMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    final raw = error.toString();
    return raw.replaceAll(RegExp(r'ApiException \(\d*\): '), '');
  }
}
