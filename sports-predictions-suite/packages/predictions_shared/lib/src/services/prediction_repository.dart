import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prediction.dart';
import '../models/prediction_category.dart';

class PredictionRepository {
  PredictionRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _categoryRef(
      PredictionCategory category) {
    return _db
        .collection(category.collectionName)
        .doc(category.id)
        .collection('matches');
  }

  Stream<List<Prediction>> watchCategory(PredictionCategory category) {
    return _categoryRef(category)
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Prediction.fromDoc).toList());
  }

  Future<void> createPrediction({
    required PredictionCategory category,
    required PredictionDraft draft,
  }) async {
    final ref = _categoryRef(category).doc();
    await ref.set(draft.toFirestore());
  }

  Future<void> updatePrediction({
    required PredictionCategory category,
    required String matchId,
    required PredictionDraft draft,
  }) {
    return _categoryRef(category).doc(matchId).update(draft.toFirestore());
  }

  Future<void> updateResult({
    required PredictionCategory category,
    required String matchId,
    required PredictionResult result,
    required String score,
  }) {
    return _categoryRef(category).doc(matchId).update({
      'result': result.wireValue,
      'score': score,
    });
  }

  Future<void> deletePrediction({
    required PredictionCategory category,
    required String matchId,
  }) {
    return _categoryRef(category).doc(matchId).delete();
  }
}
