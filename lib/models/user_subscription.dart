class UserSubscription {
  final bool isActive;
  final dynamic id;
  final dynamic planId;
  final dynamic paymentId;
  final String? startedAt;
  final String? expiresAt;
  final String? status;
  final Map<String, dynamic>? rawSubscription;

  UserSubscription({
    required this.isActive,
    this.id,
    this.planId,
    this.paymentId,
    this.startedAt,
    this.expiresAt,
    this.status,
    this.rawSubscription,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    final bool isActive = json['is_active'] == true;
    final sub = json['subscription'] is Map<String, dynamic> ? json['subscription'] as Map<String, dynamic> : null;

    if (sub != null) {
      return UserSubscription(
        isActive: isActive,
        id: sub['id'],
        planId: sub['plan_id'],
        paymentId: sub['payment_id'],
        startedAt: sub['started_at']?.toString(),
        expiresAt: sub['expires_at']?.toString(),
        status: sub['status']?.toString(),
        rawSubscription: sub,
      );
    }

    return UserSubscription(
      isActive: isActive,
      status: json['status']?.toString(),
    );
  }
}
