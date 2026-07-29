import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String? subtitle;
  final Widget icon;
  final List<String>? badgeLabels;

  const PaymentMethod({
    required this.id,
    required this.name,
    this.subtitle,
    required this.icon,
    this.badgeLabels,
  });
}
