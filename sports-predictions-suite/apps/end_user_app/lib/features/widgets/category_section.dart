import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:predictions_shared/predictions_shared.dart';

import 'prediction_card.dart';

class PredictionCategorySection extends StatelessWidget {
  const PredictionCategorySection({
    super.key,
    required this.category,
    required this.predictions,
  });

  final PredictionCategory category;
  final AsyncValue<List<Prediction>> predictions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(category: category),
          const SizedBox(height: 12),
          predictions.when(
            data: (items) => Column(
              children: items
                  .map((prediction) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PredictionCard(prediction: prediction),
                      ))
                  .toList(),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Text(
              'Failed to load: $error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.category});

  final PredictionCategory category;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('MMM d').format(DateTime.now());
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: category.accentColor.withValues(alpha: .18),
          child: Icon(category.icon, color: category.accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              Text(
                '${category.subtitle} · $formatted',
                style: TextStyle(color: Colors.white.withValues(alpha: .7)),
              ),
            ],
          ),
        ),
        if (category.isVip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: category.accentColor.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'VIP',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
