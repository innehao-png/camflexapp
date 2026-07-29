import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/payment_method.dart';
import 'plan_selection_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  List<PaymentMethod> _buildPaymentMethods() {
    return [
      PaymentMethod(
        id: 'google',
        name: 'Google',
        subtitle: '(ភ្ជាប់ដោយស្វ័យប្រវត្តិ)',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFFEA4335),
                  Color(0xFFFBBC05),
                  Color(0xFF34A853),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(
                Icons.g_mobiledata_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),
      ),
      PaymentMethod(
        id: 'aba_pay',
        name: 'ABA PAY',
        subtitle: 'Tap to pay with ABA Mobile',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF005E82),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ABA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'PAY',
                  style: TextStyle(
                    color: Color(0xFF00B4D8),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      PaymentMethod(
        id: 'credit_card',
        name: 'Credit/Debit Card',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF007791),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.credit_card_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        badgeLabels: ['VISA', 'MC', 'UnionPay', 'JCB'],
      ),
      PaymentMethod(
        id: 'topup_card',
        name: 'Top Up Card',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
              SizedBox(height: 2),
              Text(
                'SASTRA FILM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      PaymentMethod(
        id: 'khqr',
        name: 'KHQR',
        subtitle: 'Scan to pay with member bank a...',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE21A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'KHQR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
      PaymentMethod(
        id: 'acleda',
        name: 'ACLEDA mobile app',
        subtitle: 'Required ACLEDA APP installed\nand registered',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0D3B66),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.stars_rounded,
              color: Color(0xFFF4D03F),
              size: 28,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = _buildPaymentMethods();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Close Button Header
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

            // Crown Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF4A1028),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.king_bed_outlined, // or crown icon style
                color: AppColors.primary,
                size: 36,
              ),
            ),

            const SizedBox(height: 16),

            // Title in Khmer
            const Text(
              'ជ្រើសរើសវិធីបង់ប្រាក់',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle in Khmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'ជ្រើសរើសវិធីបង់ប្រាក់ណាមួយដែលងាយស្រួល និងរហ័សសម្រាប់អ្នក។',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: paymentMethods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return _PaymentMethodTile(
                    method: method,
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlanSelectionScreen(
                            paymentMethodId: method.id,
                            paymentMethodName: method.name,
                            paymentMethodIcon: method.icon,
                          ),
                        ),
                      );
                      if (result == true && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatefulWidget {
  final PaymentMethod method;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.onTap,
  });

  @override
  State<_PaymentMethodTile> createState() => _PaymentMethodTileState();
}

class _PaymentMethodTileState extends State<_PaymentMethodTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            widget.method.icon,

            const SizedBox(width: 16),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.method.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.method.id == 'google' &&
                          widget.method.subtitle != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.method.subtitle!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.method.id != 'google' &&
                      widget.method.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.method.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (widget.method.badgeLabels != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: widget.method.badgeLabels!.map((label) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(label),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(String label) {
    switch (label) {
      case 'VISA':
        return const Color(0xFF1A1F71);
      case 'MC':
        return const Color(0xFFEB001B);
      case 'UnionPay':
        return const Color(0xFF00447C);
      case 'JCB':
        return const Color(0xFF0B7B3E);
      default:
        return Colors.grey;
    }
  }
}
