import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:predictions_shared/predictions_shared.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({super.key, required this.prediction});

  final Prediction prediction;

  IconData _resultIcon(PredictionResult result) => switch (result) {
        PredictionResult.pending => Icons.pending,
        PredictionResult.won => Icons.check_circle,
        PredictionResult.lost => Icons.cancel,
      };

  Color _resultColor(PredictionResult result) => switch (result) {
        PredictionResult.pending => Colors.amberAccent,
        PredictionResult.won => Colors.lightGreenAccent,
        PredictionResult.lost => Colors.redAccent,
      };

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEE, d MMM');
    final timeFormatter = DateFormat('HH:mm');
    final matchDate = dateFormatter.format(prediction.matchTime);
    final matchTime = timeFormatter.format(prediction.matchTime);
    final leagueUppercase = prediction.league.toUpperCase();
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  leagueUppercase,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .6),
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• $matchTime EAT',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .6),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(matchDate,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Icon(_resultIcon(prediction.result),
                      size: 20, color: _resultColor(prediction.result)),
                  const SizedBox(width: 6),
                  Text(
                    prediction.score,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${prediction.homeTeam} vs ${prediction.awayTeam}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    prediction.prediction,
                    style: const TextStyle(letterSpacing: 0.3),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (prediction.odds != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.amber.shade700.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '@${prediction.odds}',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
