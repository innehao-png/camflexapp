export 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class AuthService {
  /// Sign up / Register new user: POST /signup
  static Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String? confirmPassword,
  }) async {
    final confirmation = confirmPassword ?? password;
    await ApiClient.post(
      ApiConfig.signup,
      body: {
        "name": name,
        "email": email,
        "password": password,
        "c_password": confirmation,
        "password_confirmation": confirmation,
      },
      requireAuth: false,
    );
    return true;
  }

  /// Alias for signup for backwards compatibility
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? confirmPassword,
  }) =>
      signup(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

  /// Sign in / Login user: POST /signin
  static Future<bool> signin({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.post(
      ApiConfig.signin,
      body: {
        "email": email,
        "password": password,
      },
      requireAuth: false,
    );

    if (data is Map && data.containsKey('token')) {
      String token = data['token'].toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.tokenKey, token);
      return true;
    }
    throw ApiException("Invalid response from server");
  }

  /// Alias for signin for backwards compatibility
  static Future<bool> login({
    required String email,
    required String password,
  }) =>
      signin(email: email, password: password);

  /// Sign out user: POST /signout
  static Future<bool> signout() async {
    try {
      await ApiClient.post(ApiConfig.signout);
    } catch (_) {
      // Ignore network errors during signout
    } finally {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.tokenKey);
    }
    return true;
  }

  /// Alias for signout for backwards compatibility
  static Future<void> logout() => signout();

  /// Retrieve stored authentication token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  /// Fetch dashboard / profile data
  static Future<Map<String, dynamic>?> dashboard() async {
    try {
      final response = await ApiClient.get(ApiConfig.dashboard);
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}