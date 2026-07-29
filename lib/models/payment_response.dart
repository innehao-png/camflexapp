class PaymentResponse {
  final dynamic paymentId;
  final String clientSecret;
  final String? publishableKey;

  PaymentResponse({
    required this.paymentId,
    required this.clientSecret,
    this.publishableKey,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['payment_id'],
      clientSecret: json['client_secret']?.toString() ?? '',
      publishableKey: json['publishable_key']?.toString(),
    );
  }
}
