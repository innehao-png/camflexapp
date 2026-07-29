import '../services/subscription_service.dart';

class SubscriptionPlan {
  final dynamic rawId;
  final String id;
  final double price;
  final String label;
  final String description;
  final String currency;
  final int? durationDays;

  const SubscriptionPlan({
    required this.id,
    dynamic rawId,
    required this.price,
    required this.label,
    required this.description,
    this.currency = 'USD',
    this.durationDays,
  }) : rawId = rawId ?? id;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final priceVal = json['price'];
    final double parsedPrice = priceVal is num
        ? priceVal.toDouble()
        : double.tryParse(priceVal?.toString() ?? '0') ?? 0.0;
    
    final currencyStr = json['currency']?.toString() ?? 'USD';
    final duration = json['duration_days'] is int
        ? json['duration_days'] as int
        : int.tryParse(json['duration_days']?.toString() ?? '');

    final nameStr = json['name']?.toString() ?? json['label']?.toString() ?? 'Subscription Plan';
    final descStr = json['description']?.toString() ?? (duration != null ? 'គម្រោង $duration ថ្ងៃ' : 'គម្រោង VIP');
    final formattedLabel = '\$${parsedPrice.toStringAsFixed(1)}';

    return SubscriptionPlan(
      id: rawId?.toString() ?? '',
      rawId: rawId,
      price: parsedPrice,
      label: formattedLabel,
      description: descStr.isNotEmpty ? descStr : nameStr,
      currency: currencyStr,
      durationDays: duration,
    );
  }

  /// Fetch subscription plans directly from backend API endpoint: GET /plans
  static Future<List<SubscriptionPlan>> fetchPlans() async {
    return SubscriptionService.getPlans();
  }
}

// Predefined subscription plans
const List<SubscriptionPlan> subscriptionPlans = [
  SubscriptionPlan(
    id: '30_days',
    price: 5.0,
    label: '\$5.0',
    description: 'គម្រោង 30 ថ្ងៃ',
  ),
  SubscriptionPlan(
    id: '90_days',
    price: 12.0,
    label: '\$12.0',
    description: 'គម្រោង 3 ខែ (90 ថ្ងៃ)',
  ),
  SubscriptionPlan(
    id: '180_days',
    price: 22.0,
    label: '\$22.0',
    description: 'គម្រោង 6 ខែ (180 ថ្ងៃ)',
  ),
  SubscriptionPlan(
    id: '360_days',
    price: 36.0,
    label: '\$36.0',
    description: 'គម្រោង 12 ខែ (360 ថ្ងៃ)',
  ),
];
