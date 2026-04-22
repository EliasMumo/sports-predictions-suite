import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:predictions_shared/predictions_shared.dart';

import 'dashboard_providers.dart';

final predictionAdminControllerProvider =
    NotifierProvider<PredictionAdminController, AsyncValue<void>>(() {
  return PredictionAdminController();
});

class PredictionAdminController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  PredictionRepository get _repository => ref.watch(predictionRepositoryProvider);

  Future<void> createMatch({
    required PredictionCategory category,
    required PredictionDraft draft,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createPrediction(category: category, draft: draft);
    });
  }

  Future<void> updateMatch({
    required PredictionCategory category,
    required Prediction match,
    required PredictionDraft draft,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updatePrediction(
        category: category,
        matchId: match.id,
        draft: draft,
      );
    });
  }

  Future<void> updateResult({
    required PredictionCategory category,
    required Prediction match,
    required PredictionResult result,
    required String score,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateResult(
        category: category,
        matchId: match.id,
        result: result,
        score: score,
      );
    });
  }

  Future<void> deleteMatch({
    required PredictionCategory category,
    required Prediction match,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deletePrediction(
          category: category,
          matchId: match.id,
        ));
  }
}
