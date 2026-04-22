import 'package:flutter/material.dart';

enum CategoryCollectionType { predictions, history }

enum CategoryAccess { free, vip }

class PredictionCategory {
  const PredictionCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.collectionType,
    required this.access,
    required this.order,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final CategoryCollectionType collectionType;
  final CategoryAccess access;
  final int order;

  bool get isVip => access == CategoryAccess.vip;
  bool get isHistory => collectionType == CategoryCollectionType.history;
}

const List<PredictionCategory> allCategories = [
  PredictionCategory(
    id: 'daily2',
    title: 'Daily 2+ Odds',
    description: 'Hand-picked slip with solid two-plus odds.',
    icon: Icons.trending_up,
    collectionType: CategoryCollectionType.predictions,
    access: CategoryAccess.free,
    order: 0,
  ),
  PredictionCategory(
    id: 'over_under',
    title: 'Over / Under Tips',
    description: 'Totals-focused football picks.',
    icon: Icons.swap_vert,
    collectionType: CategoryCollectionType.predictions,
    access: CategoryAccess.free,
    order: 1,
  ),
  PredictionCategory(
    id: 'basketball',
    title: 'Basketball Tips',
    description: 'Euroleague & NBA value picks.',
    icon: Icons.sports_basketball_outlined,
    collectionType: CategoryCollectionType.predictions,
    access: CategoryAccess.free,
    order: 2,
  ),
  PredictionCategory(
    id: 'tennis',
    title: 'Tennis Tips',
    description: 'ATP & WTA moneyline locks.',
    icon: Icons.sports_tennis,
    collectionType: CategoryCollectionType.predictions,
    access: CategoryAccess.free,
    order: 3,
  ),
  PredictionCategory(
    id: 'vip_correct_score',
    title: 'VIP History',
    description: 'VIP archive and VIP-only picks.',
    icon: Icons.scoreboard_outlined,
    collectionType: CategoryCollectionType.history,
    access: CategoryAccess.vip,
    order: 4,
  ),
  PredictionCategory(
    id: 'vip_halftime_fulltime',
    title: 'Halftime / Fulltime VIP',
    description: 'Premium half-time vs full-time combos.',
    icon: Icons.timelapse,
    collectionType: CategoryCollectionType.history,
    access: CategoryAccess.vip,
    order: 5,
  ),
  PredictionCategory(
    id: 'vip_odds10plus',
    title: '10+ Odds VIP',
    description: 'High-odds accumulator archive.',
    icon: Icons.flash_on,
    collectionType: CategoryCollectionType.history,
    access: CategoryAccess.vip,
    order: 6,
  ),
];

extension PredictionCategoryX on Iterable<PredictionCategory> {
  List<PredictionCategory> filter({CategoryAccess? access, CategoryCollectionType? collection}) {
    return where((category) {
      final matchesAccess = access == null || category.access == access;
      final matchesCollection = collection == null || category.collectionType == collection;
      return matchesAccess && matchesCollection;
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
