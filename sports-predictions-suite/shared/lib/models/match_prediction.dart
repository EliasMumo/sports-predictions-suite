import 'package:cloud_firestore/cloud_firestore.dart';

enum PredictionResult { pending, won, lost }

PredictionResult resultFromString(String value) {
  switch (value) {
    case 'won':
      return PredictionResult.won;
    case 'lost':
      return PredictionResult.lost;
    default:
      return PredictionResult.pending;
  }
}

String resultToString(PredictionResult result) {
  switch (result) {
    case PredictionResult.won:
      return 'won';
    case PredictionResult.lost:
      return 'lost';
    case PredictionResult.pending:
      return 'pending';
  }
}

class MatchPrediction {
  const MatchPrediction({
    required this.id,
    required this.categoryId,
    required this.league,
    required this.matchTime,
    required this.homeTeam,
    required this.awayTeam,
    required this.prediction,
    required this.score,
    required this.result,
    required this.createdAt,
  });

  final String id;
  final String categoryId;
  final String league;
  final DateTime matchTime;
  final String homeTeam;
  final String awayTeam;
  final String prediction;
  final String score;
  final PredictionResult result;
  final DateTime createdAt;

  bool get isSettled => result != PredictionResult.pending;

  MatchPrediction copyWith({
    String? score,
    PredictionResult? result,
  }) {
    return MatchPrediction(
      id: id,
      categoryId: categoryId,
      league: league,
      matchTime: matchTime,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      prediction: prediction,
      score: score ?? this.score,
      result: result ?? this.result,
      createdAt: createdAt,
    );
  }

  factory MatchPrediction.fromJson(String id, Map<String, dynamic> data, String categoryId) {
    final timestamp = data['matchTime'] as Timestamp? ?? Timestamp.now();
    final createdTimestamp = data['createdAt'] as Timestamp? ?? Timestamp.now();
    return MatchPrediction(
      id: id,
      categoryId: categoryId,
      league: data['league'] as String? ?? 'Unknown League',
      matchTime: timestamp.toDate(),
      homeTeam: data['homeTeam'] as String? ?? 'Home',
      awayTeam: data['awayTeam'] as String? ?? 'Away',
      prediction: data['prediction'] as String? ?? '-',
      score: data['score'] as String? ?? '—',
      result: resultFromString(data['result'] as String? ?? 'pending'),
      createdAt: createdTimestamp.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'league': league,
      'matchTime': Timestamp.fromDate(matchTime),
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'prediction': prediction,
      'score': score,
      'result': resultToString(result),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
