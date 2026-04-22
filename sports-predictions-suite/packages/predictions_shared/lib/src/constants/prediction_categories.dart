import 'package:flutter/material.dart';

import '../models/prediction_category.dart';
import '../theme/app_colors.dart';

const List<PredictionCategory> kPredictionCategories = [
  PredictionCategory(
    id: 'daily2',
    title: 'Daily 2+ Odds',
    subtitle: 'Consistent low-risk picks',
    group: CategoryGroup.predictions,
    isVip: false,
    icon: Icons.flash_on,
    accentColor: AppColors.sunrise,
  ),
  PredictionCategory(
    id: 'overUnder',
    title: 'Over / Under Tips',
    subtitle: 'Goals-based metrics',
    group: CategoryGroup.predictions,
    isVip: false,
    icon: Icons.trending_up,
    accentColor: AppColors.royal,
  ),
  PredictionCategory(
    id: 'htftHistory',
    title: 'HT/FT VIP History',
    subtitle: 'Historical halftime/fulltime results',
    group: CategoryGroup.history,
    isVip: false,
    icon: Icons.history,
    accentColor: AppColors.lavender,
  ),
  PredictionCategory(
    id: 'correctScore',
    title: 'VIP History',
    subtitle: 'Historical football score results',
    group: CategoryGroup.history,
    isVip: false,
    icon: Icons.history,
    accentColor: AppColors.slate,
  ),
  PredictionCategory(
    id: 'odds10plusVip',
    title: '10+ Odds VIP',
    subtitle: 'High odds premium tips',
    group: CategoryGroup.predictions,
    isVip: true,
    icon: Icons.local_fire_department,
    accentColor: AppColors.coral,
    offeringId: '10_plus',
  ),
  PredictionCategory(
    id: 'htftFixedVip',
    title: 'HT/FT Fixed VIP',
    subtitle: 'Halftime/Fulltime expert picks',
    group: CategoryGroup.predictions,
    isVip: true,
    icon: Icons.timer,
    accentColor: AppColors.amber,
    offeringId: 'ht_ft_fixed',
  ),
  PredictionCategory(
    id: 'overUnderVip',
    title: 'Over/Under VIP',
    subtitle: 'Premium goals-based predictions',
    group: CategoryGroup.predictions,
    isVip: true,
    icon: Icons.trending_up,
    accentColor: AppColors.ocean,
    offeringId: 'over_under',
  ),
  PredictionCategory(
    id: 'vipCombination',
    title: 'VIP Combination',
    subtitle: 'Premium curated combos',
    group: CategoryGroup.predictions,
    isVip: true,
    icon: Icons.workspace_premium,
    accentColor: AppColors.royal,
    offeringId: 'vip_combined',
  ),
];

List<PredictionCategory> get freeCategories =>
    kPredictionCategories.where((c) => !c.isVip).toList(growable: false);

List<PredictionCategory> get vipCategories =>
    kPredictionCategories.where((c) => c.isVip).toList(growable: false);
