import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecommerce/core/config/api_config.dart';
import 'package:ecommerce/core/network/api_exception.dart';

/// Central HTTP client for all API communication.
class ApiClient {
  ApiClient._();

  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConfig.tokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final fullUrl = path.startsWith('http') ? path : '${ApiConfig.baseUrl}$path';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: $e');
    }
  }

  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: $e');
    }
  }

  static Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: $e');
    }
  }

  static Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _processResponse(response);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred: $e');
    }
  }

  static dynamic _processResponse(http.Response response) {
    dynamic decodedBody;
    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    var message = '';
    if (decodedBody is Map) {
      if (decodedBody.containsKey('errors') && decodedBody['errors'] is Map) {
        final errorsMap = decodedBody['errors'] as Map;
        final messages = <String>[];
        for (final value in errorsMap.values) {
          if (value is List) {
            messages.addAll(value.map((e) => e.toString()));
          } else if (value != null) {
            messages.add(value.toString());
          }
        }
        if (messages.isNotEmpty) {
          message = messages.join('\n');
        }
      }
      if (message.isEmpty && decodedBody.containsKey('message')) {
        message = decodedBody['message'].toString();
      }
    }
    if (message.isEmpty) {
      message = 'Server error with status code ${response.statusCode}';
    }
    throw ApiException(message, response.statusCode);
  }
}
