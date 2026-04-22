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

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, PredictionCategory>(() {
  return SelectedCategoryNotifier();
});

class SelectedCategoryNotifier extends Notifier<PredictionCategory> {
  @override
  PredictionCategory build() {
    return kPredictionCategories.first;
  }

  void setCategory(PredictionCategory category) {
    state = category;
  }
}
