import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/prediction_categories.dart';
import '../models/prediction.dart';
import '../models/prediction_category.dart';

/// Automatically generates VIP combination predictions from other VIP categories
class CombinationGenerator {
  CombinationGenerator(this._db);

  final FirebaseFirestore _db;

  /// Generate a combination prediction by selecting best picks from VIP categories
  /// This is triggered when predictions are added/updated in VIP sections
  Future<void> generateCombination() async {
    // Get the VIP combination category
    final comboCat = kPredictionCategories.firstWhere(
      (cat) => cat.id == 'vipCombination',
    );

    // Get all other VIP categories (excluding combination itself)
    final vipCats = vipCategories.where((cat) => cat.id != 'vipCombination').toList();

    // Collect today's pending predictions from each VIP category
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final allPicks = <Prediction>[];
    
    for (final category in vipCats) {
      final snapshot = await _db
          .collection(category.collectionName)
          .doc(category.id)
          .collection('matches')
          .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('time', isLessThan: Timestamp.fromDate(todayEnd))
          .where('result', isEqualTo: 'pending')
          .orderBy('time')
          .limit(5)
          .get();

      allPicks.addAll(snapshot.docs.map(Prediction.fromDoc));
    }

    if (allPicks.isEmpty) {
      return; // No pending predictions to combine
    }

    // Select the best picks (up to 5 matches)
    final selectedPicks = _selectBestPicks(allPicks, maxPicks: 5);

    if (selectedPicks.isEmpty) {
      return;
    }

    // Generate combination text
    final combinationText = _generateCombinationText(selectedPicks);
    
    // Calculate combined odds
    final combinedOdds = _calculateCombinedOdds(selectedPicks);

    // Create the combination prediction
    final draft = PredictionDraft(
      league: 'VIP Combo',
      matchTime: selectedPicks.first.matchTime,
      homeTeam: 'Multi-Match',
      awayTeam: 'Combination',
      prediction: combinationText,
      odds: combinedOdds.toStringAsFixed(2),
      result: PredictionResult.pending,
      score: '--',
    );

    // Save to vipCombination category
    final ref = _db
        .collection(comboCat.collectionName)
        .doc(comboCat.id)
        .collection('matches')
        .doc();
    
    await ref.set(draft.toFirestore());
  }

  /// Select the best picks based on odds and diversity
  List<Prediction> _selectBestPicks(List<Prediction> picks, {required int maxPicks}) {
    // Sort by odds (higher is better for VIP picks)
    final sorted = List<Prediction>.from(picks);
    sorted.sort((a, b) {
      final oddsA = double.tryParse(a.odds ?? '0') ?? 0;
      final oddsB = double.tryParse(b.odds ?? '0') ?? 0;
      return oddsB.compareTo(oddsA);
    });

    // Take diverse picks (not all from same time slot)
    final selected = <Prediction>[];
    final usedTimes = <int>[];

    for (final pick in sorted) {
      if (selected.length >= maxPicks) break;
      
      final hourSlot = pick.matchTime.hour;
      
      // Prefer picks from different time slots for variety
      if (!usedTimes.contains(hourSlot) || selected.length < maxPicks - 1) {
        selected.add(pick);
        usedTimes.add(hourSlot);
      }
    }

    return selected.take(maxPicks).toList();
  }

  /// Generate readable combination text
  String _generateCombinationText(List<Prediction> picks) {
    final lines = <String>[];
    
    for (var i = 0; i < picks.length; i++) {
      final pick = picks[i];
      lines.add('${i + 1}. ${pick.homeTeam} vs ${pick.awayTeam} - ${pick.prediction}');
    }

    return lines.join('\n');
  }

  /// Calculate combined odds
  double _calculateCombinedOdds(List<Prediction> picks) {
    double combined = 1.0;
    
    for (final pick in picks) {
      final odds = double.tryParse(pick.odds ?? '1.0') ?? 1.0;
      combined *= odds;
    }

    return combined;
  }

  /// Update combination result based on individual match results
  Future<void> updateCombinationResults() async {
    final comboCat = kPredictionCategories.firstWhere(
      (cat) => cat.id == 'vipCombination',
    );

    // Get all pending combinations
    final snapshot = await _db
        .collection(comboCat.collectionName)
        .doc(comboCat.id)
        .collection('matches')
        .where('result', isEqualTo: 'pending')
        .get();

    for (final doc in snapshot.docs) {
      final combo = Prediction.fromDoc(doc);
      
      // Check if all matches in the combination are complete
      // For now, we'll mark as won/lost based on a simple heuristic
      // In a real implementation, you'd parse the combination and check each match
      
      // You can enhance this by storing match IDs in the combination document
    }
  }
}
