class ApiConfig {
  // Base URL (Single source of truth)
  static const String baseUrl = "http://192.168.3.87:8000/api";
  static const String appUrl = "http://192.168.3.87:8000/api";

  // Endpoint Paths
  static const String signup = "/signup";
  static const String signin = "/signin";
  static const String signout = "/signout";
  static const String dashboard = "/dashboard";
  static const String categories = "/categories";
  static const String movies = "/movies";
  static const String plans = "/plans";
  static const String currentSubscription = "/subscriptions/current";
  static const String subscriptions = "/subscriptions";
  static const String payments = "/payments";
  static const String favorites = "/favorites";
  static const String profile = "/profile";
  static const String profileAvatar = "/profile/avatar";

  // Storage Keys
  static const String tokenKey = "token";

  // Timeout Settings
  static const Duration timeout = Duration(seconds: 15);
}
