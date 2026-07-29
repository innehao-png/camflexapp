import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/api_config.dart';
import '../models/payment_response.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import 'api_client.dart';

class SubscriptionService {
  /// Fetch available subscription plans: GET /plans
  static Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await ApiClient.get(ApiConfig.plans, requireAuth: false);
      
      List<dynamic>? list;
      if (response is List) {
        list = response;
      } else if (response is Map && response.containsKey('data') && response['data'] is List) {
        list = response['data'] as List<dynamic>;
      }

      if (list != null && list.isNotEmpty) {
        return list.map((item) => SubscriptionPlan.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback to local predefined plans if backend API is offline or unready
    }

    return subscriptionPlans;
  }

  /// Get the authenticated user's current subscription: GET /subscriptions/current
  static Future<UserSubscription> getCurrentSubscription() async {
    try {
      final response = await ApiClient.get(ApiConfig.currentSubscription);
      if (response is Map<String, dynamic>) {
        return UserSubscription.fromJson(response);
      }
    } catch (_) {
      // Return inactive default on error
    }
    return UserSubscription(isActive: false);
  }

  /// Initiate subscription purchase: POST /subscriptions
  static Future<PaymentResponse> createSubscription(dynamic planId) async {
    // Convert string plan ID to integer if it's numeric
    final parsedId = int.tryParse(planId.toString()) ?? planId;

    final response = await ApiClient.post(
      ApiConfig.subscriptions,
      body: {
        'plan_id': parsedId,
      },
    );

    if (response is Map<String, dynamic>) {
      return PaymentResponse.fromJson(response);
    }

    throw ApiException("Invalid response format when creating subscription");
  }

  /// Poll/Get payment status: GET /payments/{payment}/status
  static Future<String> getPaymentStatus(dynamic paymentId) async {
    final response = await ApiClient.get('${ApiConfig.payments}/$paymentId/status');

    if (response is Map && response.containsKey('status')) {
      return response['status'].toString();
    }

    return 'unknown';
  }

  /// Complete Stripe payment flow using flutter_stripe PaymentSheet
  static Future<bool> processStripePayment({
    required BuildContext context,
    required dynamic planId,
  }) async {
    try {
      // 1. Create PaymentIntent via backend
      final paymentResp = await createSubscription(planId);

      if (paymentResp.clientSecret.isEmpty) {
        throw ApiException("Failed to initialize payment secret");
      }

      // 2. Set publishable key if provided by backend
      if (paymentResp.publishableKey != null && paymentResp.publishableKey!.isNotEmpty) {
        Stripe.publishableKey = paymentResp.publishableKey!;
      }

      // 3. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentResp.clientSecret,
          merchantDisplayName: 'Sastra Film',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFFF007A),
              background: Color(0xFF141414),
              componentBackground: Color(0xFF222222),
              componentText: Colors.white,
              primaryText: Colors.white,
              secondaryText: Colors.grey,
            ),
          ),
        ),
      );

      // 4. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 5. Verify payment status with backend polling endpoint
      final status = await getPaymentStatus(paymentResp.paymentId);
      return status == 'paid' || status == 'succeeded';
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw ApiException("បោះបង់ការទូទាត់ (Payment canceled)");
      }
      throw ApiException(e.error.localizedMessage ?? "Stripe payment error");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Payment failed: $e");
    }
  }
}
