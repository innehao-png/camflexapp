/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Sastra Film';
  static const String brandName = 'CAMFLEX';
  static const String brandBadge = 'SASTRA';

  // Movie filters
  static const String movieTypeUpcoming = 'upcoming';

  // Payment method identifiers
  static const String paymentCreditCard = 'credit_card';
  static const String paymentGoogle = 'google';
  static const String paymentAbaPay = 'aba_pay';

  // Search
  static const Duration searchDebounce = Duration(milliseconds: 400);
}
