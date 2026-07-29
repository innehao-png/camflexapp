import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class ProfileService {
  // ─── GET /profile ───────────────────────────────────────────────────────────
  Future<UserProfile> getProfile() async {
    final response = await ApiClient.get(ApiConfig.profile);
    if (response is Map<String, dynamic>) {
      return UserProfile.fromJson(response);
    }
    throw ApiException('Unexpected response format from /profile');
  }

  // ─── PUT /profile ────────────────────────────────────────────────────────────
  /// Updates profile with optional text fields and/or a new avatar [File].
  /// Returns the updated [UserProfile].
  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    File? avatarFile,
  }) async {
    if (avatarFile != null) {
      // Multipart upload when avatar is included.
      return _updateProfileMultipart(
        name: name,
        email: email,
        avatarFile: avatarFile,
      );
    }

    // JSON-only update.
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;

    final response = await ApiClient.put(ApiConfig.profile, body: body);
    if (response is Map<String, dynamic>) {
      return UserProfile.fromJson(response);
    }
    throw ApiException('Unexpected response format from PUT /profile');
  }

  Future<UserProfile> _updateProfileMultipart({
    String? name,
    String? email,
    required File avatarFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);

    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json';

    // Laravel requires _method=PUT for multipart spoofing.
    request.fields['_method'] = 'PUT';

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;

    request.files.add(
      await http.MultipartFile.fromPath('avatar', avatarFile.path),
    );

    final streamed = await request.send().timeout(ApiConfig.timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Re-fetch to get the fresh avatar URL after upload.
      return getProfile();
    }

    // Try to parse error message.
    String msg = 'Failed to update profile (${response.statusCode})';
    try {
      final decoded = response.body;
      if (decoded.contains('"message"')) {
        final match = RegExp(r'"message":"([^"]+)"').firstMatch(decoded);
        if (match != null) msg = match.group(1)!;
      }
    } catch (_) {}
    throw ApiException(msg, response.statusCode);
  }

  // ─── DELETE /profile/avatar ──────────────────────────────────────────────────
  Future<void> deleteAvatar() async {
    await ApiClient.delete(ApiConfig.profileAvatar);
  }
}
