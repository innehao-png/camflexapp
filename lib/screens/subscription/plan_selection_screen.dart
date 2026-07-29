import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/subscription_plan.dart';
import '../../services/subscription_service.dart';
import '../../widgets/state_widgets.dart';

class PlanSelectionScreen extends StatefulWidget {
  final String paymentMethodId;
  final String paymentMethodName;
  final Widget paymentMethodIcon;

  const PlanSelectionScreen({
    super.key,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.paymentMethodIcon,
  });

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  List<SubscriptionPlan> _plans = subscriptionPlans;
  String _selectedPlanId = subscriptionPlans.first.id;
  bool _isLoadingPlans = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final fetched = await SubscriptionService.getPlans();
      if (mounted && fetched.isNotEmpty) {
        setState(() {
          _plans = fetched;
          _selectedPlanId = fetched.first.id;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlans = false);
      }
    }
  }

  Future<void> _handlePurchase() async {
    final selectedPlan = _plans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => _plans.first,
    );

    setState(() => _isProcessing = true);

    try {
      if (widget.paymentMethodId == 'credit_card') {
        // Full Stripe PaymentSheet integration
        final success = await SubscriptionService.processStripePayment(
          context: context,
          planId: selectedPlan.rawId,
        );

        if (!mounted) return;

        if (success) {
          _showSuccessAndDismiss("ការបង់ប្រាក់បានជោគជ័យ! (Payment Successful)");
        } else {
          _showSnackBar("ការទូទាត់មិនទាន់បានជោគជ័យ (Payment pending or not completed)", isError: true);
        }
      } else {
        // Fallback flow for other payment methods (e.g. ABA/KHQR simulation via backend store endpoint)
        final paymentResp = await SubscriptionService.createSubscription(selectedPlan.rawId);
        final status = await SubscriptionService.getPaymentStatus(paymentResp.paymentId);

        if (!mounted) return;

        if (status == 'paid' || status == 'succeeded') {
          _showSuccessAndDismiss("ការបង់ប្រាក់បានជោគជ័យ! (Payment Successful)");
        } else {
          _showSnackBar("បានបង្កើតការទូទាត់សម្រាប់ ${selectedPlan.description}! ស្ថានភាព: $status");
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll("ApiException (null): ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessAndDismiss(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop(true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Close Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Selected Payment Method Icon Header
            Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: widget.paymentMethodIcon,
              ),
            ),

            const SizedBox(height: 16),

            // Header Title
            Text(
              widget.paymentMethodName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Header Subtitle in Khmer
            Text(
              'ជ្រើសរើសគម្រោងសម្រាប់ទស្សនា',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Plans list
            Expanded(
              child: _isLoadingPlans
                  ? const AppLoading()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _plans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        final isSelected = plan.id == _selectedPlanId;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlanId = plan.id;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.1),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  plan.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Policy Text & Subscribe Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'ដោយទិញគម្រោង លោកអ្នកនឹងយល់ព្រមទៅនឹង ',
                        ),
                        TextSpan(
                          text: 'គោលការណ៍នៃសេវាកម្ម',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' និង ',
                        ),
                        TextSpan(
                          text: 'គោលការណ៍ព័ត៌មានផ្ទាល់ខ្លួន',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'ទិញគម្រោង',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

