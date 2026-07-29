import 'package:flutter/material.dart';

import 'package:ecommerce/core/config/app_colors.dart';

/// Displays user initials inside a circular avatar fallback.
class UserAvatarInitials extends StatelessWidget {
  final String initials;
  final double fontSize;

  const UserAvatarInitials({
    super.key,
    required this.initials,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
