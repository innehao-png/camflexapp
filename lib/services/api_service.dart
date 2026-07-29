import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.3.87:8000/api";
  static const String appUrl = "http://192.168.3.87:8000/api";

  /// Gets HTTP headers including Bearer token if available
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// Get all categories: GET /categories
  static Future<List<dynamic>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/categories"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body;
      } else if (body is Map && body.containsKey('data')) {
        return body['data'] as List<dynamic>;
      }
      return [];
    } else {
      throw Exception("Failed to load categories: ${response.statusCode}");
    }
  }

  /// Get movies list with optional filters and pagination: GET /movies
  /// Parameters:
  /// - [category]: Category slug to filter by
  /// - [type]: Movie type filter
  /// - [search]: Search query for movie title
  /// - [page]: Page number for pagination (default: 1)
  static Future<Map<String, dynamic>> getMovies({
    String? category,
    String? type,
    String? search,
    int page = 1,
  }) async {
    final headers = await _getHeaders();

    // Construct query parameters
    final queryParameters = <String, String>{};
    if (category != null && category.isNotEmpty) {
      queryParameters['category'] = category;
    }
    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (page > 1) {
      queryParameters['page'] = page.toString();
    }

    final uri = Uri.parse("$baseUrl/movies").replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
      };
    } else {
      throw Exception("Failed to load movies: ${response.statusCode}");
    }
  }

  /// Get single movie details: GET /movies/{idOrSlug}
  static Future<Map<String, dynamic>> getMovieDetails(dynamic movieParam) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/movies/$movieParam"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data as Map<String, dynamic>;
    } else {
      throw Exception("Failed to load movie details: ${response.statusCode}");
    }
  }

  /// Get available subscription plans: GET /plans
  static Future<List<dynamic>> getPlans() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/plans"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body;
      } else if (body is Map && body.containsKey('data')) {
        return body['data'] as List<dynamic>;
      }
      return [];
    } else {
      throw Exception("Failed to load plans: ${response.statusCode}");
    }
  }
}
