import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => "ApiException ($statusCode): $message";
}

class ApiClient {
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (requireAuth) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(ApiConfig.tokenKey);
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  static Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final fullUrl = path.startsWith("http") ? path : "${ApiConfig.baseUrl}$path";
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
      throw ApiException("Request timed out. Please try again.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error occurred: $e");
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
      throw ApiException("Request timed out. Please try again.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error occurred: $e");
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
      throw ApiException("Request timed out. Please try again.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error occurred: $e");
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
      throw ApiException("Request timed out. Please try again.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error occurred: $e");
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
    } else {
      String msg = "";
      if (decodedBody is Map) {
        if (decodedBody.containsKey('errors') && decodedBody['errors'] is Map) {
          final errorsMap = decodedBody['errors'] as Map;
          final messages = <String>[];
          for (var value in errorsMap.values) {
            if (value is List) {
              messages.addAll(value.map((e) => e.toString()));
            } else if (value != null) {
              messages.add(value.toString());
            }
          }
          if (messages.isNotEmpty) {
            msg = messages.join("\n");
          }
        }
        if (msg.isEmpty && decodedBody.containsKey('message')) {
          msg = decodedBody['message'].toString();
        }
      }
      if (msg.isEmpty) {
        msg = "Server error with status code ${response.statusCode}";
      }
      throw ApiException(msg, response.statusCode);
    }
  }
}
