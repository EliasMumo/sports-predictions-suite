import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:predictions_shared/predictions_shared.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return PredictionRepository(FirebaseFirestore.instance);
});

final predictionsByCategoryProvider = StreamProvider.family
    .autoDispose<List<Prediction>, PredictionCategory>((ref, category) {
  return ref.watch(predictionRepositoryProvider).watchCategory(category);
});

final categoryPredictionsProvider = StreamProvider.family
    .autoDispose<List<Prediction>, String>((ref, categoryId) {
  // Find the category from free and VIP lists
  final allCats = [...freeCategories, ...vipCategories];
  final category = allCats.firstWhere((cat) => cat.id == categoryId);
  return ref.watch(predictionRepositoryProvider).watchCategory(category);
});
