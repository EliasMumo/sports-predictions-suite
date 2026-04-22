import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:predictions_shared/predictions_shared.dart';

import '../controllers/prediction_admin_controller.dart';
import 'prediction_form_sheet.dart';

class PredictionList extends ConsumerWidget {
  const PredictionList({
    super.key,
    required this.items,
    required this.category,
  });

  final List<Prediction> items;
  final PredictionCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No matches yet. Tap "Add match".'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemBuilder: (_, index) {
        final prediction = items[index];
        return Card(
          child: ListTile(
            title: Text(
              '${prediction.homeTeam} vs ${prediction.awayTeam}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${prediction.league} · ${DateFormat('MMM d, HH:mm').format(prediction.matchTime)}\nTip: ${prediction.prediction}\nScore: ${prediction.score}',
            ),
            isThreeLine: true,
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: 'Update result',
                  icon: Icon(
                    Icons.emoji_events,
                    color: _resultColor(prediction.result),
                  ),
                  onPressed: () => showResultSheet(
                    context,
                    category: category,
                    prediction: prediction,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit match',
                  icon: const Icon(Icons.edit),
                  onPressed: () => showPredictionFormSheet(
                    context,
                    category: category,
                    prediction: prediction,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete match?'),
                            content: const Text(
                                'This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                    if (!confirmed) return;
                    await ref
                        .read(predictionAdminControllerProvider.notifier)
                        .deleteMatch(category: category, match: prediction);
                  },
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }

  Color _resultColor(PredictionResult result) => switch (result) {
        PredictionResult.pending => Colors.amberAccent,
        PredictionResult.won => Colors.lightGreenAccent,
        PredictionResult.lost => Colors.redAccent,
      };
}
