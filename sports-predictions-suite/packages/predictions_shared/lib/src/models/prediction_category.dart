import 'package:flutter/material.dart';

enum CategoryGroup { predictions, history }

class PredictionCategory {
  const PredictionCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.group,
    required this.isVip,
    required this.icon,
    required this.accentColor,
    this.offeringId,
  });

  final String id;
  final String title;
  final String subtitle;
  final CategoryGroup group;
  final bool isVip;
  final IconData icon;
  final Color accentColor;
  /// RevenueCat offering ID for this category's paywall (VIP only).
  final String? offeringId;

  String get collectionName =>
      group == CategoryGroup.predictions ? 'predictions' : 'history';
}
