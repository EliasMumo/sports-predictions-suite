import 'package:cloud_firestore/cloud_firestore.dart';

typedef JsonMap = Map<String, dynamic>;

enum PredictionResult { pending, won, lost }

extension PredictionResultCodec on PredictionResult {
  String get wireValue => switch (this) {
        PredictionResult.pending => 'pending',
        PredictionResult.won => 'won',
        PredictionResult.lost => 'lost',
      };

  static PredictionResult fromWire(String value) => switch (value) {
        'won' => PredictionResult.won,
        'lost' => PredictionResult.lost,
        _ => PredictionResult.pending,
      };
}

class Prediction {
  const Prediction({
    required this.id,
    required this.league,
    required this.matchTime,
    required this.homeTeam,
    required this.awayTeam,
    required this.prediction,
    required this.result,
    required this.score,
    this.odds,
  });

  final String id;
  final String league;
  final DateTime matchTime;
  final String homeTeam;
  final String awayTeam;
  final String prediction;
  final PredictionResult result;
  final String score;
  final String? odds;

  factory Prediction.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Prediction(
      id: doc.id,
      league: data['league'] as String? ?? '',
      matchTime: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      homeTeam: data['homeTeam'] as String? ?? '',
      awayTeam: data['awayTeam'] as String? ?? '',
      prediction: data['prediction'] as String? ?? '',
      result:
          PredictionResultCodec.fromWire(data['result'] as String? ?? 'pending'),
      score: data['score'] as String? ?? '--',
      odds: data['odds'] as String?,
    );
  }

  JsonMap toJson() => {
        'league': league,
        'time': Timestamp.fromDate(matchTime),
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'prediction': prediction,
        'result': result.wireValue,
        'score': score,
        'odds': odds,
      };
}

class PredictionDraft {
  const PredictionDraft({
    required this.league,
    required this.matchTime,
    required this.homeTeam,
    required this.awayTeam,
    required this.prediction,
    this.score = '--',
    this.result = PredictionResult.pending,
    this.odds,
  });

  final String league;
  final DateTime matchTime;
  final String homeTeam;
  final String awayTeam;
  final String prediction;
  final String score;
  final PredictionResult result;
  final String? odds;

  JsonMap toFirestore() => {
        'league': league,
        'time': Timestamp.fromDate(matchTime),
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'prediction': prediction,
        'score': score,
        'result': result.wireValue,
        'odds': odds,
      };

  PredictionDraft copyWith({
    String? league,
    DateTime? matchTime,
    String? homeTeam,
    String? awayTeam,
    String? prediction,
    String? score,
    PredictionResult? result,
    String? odds,
  }) =>
      PredictionDraft(
        league: league ?? this.league,
        matchTime: matchTime ?? this.matchTime,
        homeTeam: homeTeam ?? this.homeTeam,
        awayTeam: awayTeam ?? this.awayTeam,
        prediction: prediction ?? this.prediction,
        score: score ?? this.score,
        result: result ?? this.result,
        odds: odds ?? this.odds,
      );
}
