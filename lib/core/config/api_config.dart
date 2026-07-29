/// Centralized API configuration.
///
/// Override the base URL at build time:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/api`
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.3.87:8000/api',
  );

  // Endpoint paths
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String signout = '/signout';
  static const String categories = '/categories';
  static const String movies = '/movies';
  static const String plans = '/plans';
  static const String currentSubscription = '/subscriptions/current';
  static const String subscriptions = '/subscriptions';
  static const String payments = '/payments';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String profileAvatar = '/profile/avatar';

  // Storage keys
  static const String tokenKey = 'token';

  // Network settings
  static const Duration timeout = Duration(seconds: 15);
}
