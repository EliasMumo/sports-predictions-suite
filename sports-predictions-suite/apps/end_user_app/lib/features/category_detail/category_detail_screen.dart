import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:predictions_shared/predictions_shared.dart';
import '../controllers/prediction_providers.dart';
import '../vip/vip_upgrade_screen.dart';
import '../widgets/prediction_card.dart';
import '../../src/services/vip_service.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final PredictionCategory category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Subscribe to category topic for notifications
    NotificationService.instance.subscribeToTopic(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    // Gate VIP categories — check per-category subscription
    if (widget.category.isVip && widget.category.offeringId != null) {
      final isUnlocked =
          ref.watch(isVipForCategoryProvider(widget.category.offeringId!));
      if (!isUnlocked) {
        return VIPUpgradeScreen(
          offeringId: widget.category.offeringId,
          categoryTitle: widget.category.title,
        );
      }
    }

    final predictionsAsync = ref.watch(categoryPredictionsProvider(widget.category.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.category.title),
            Text(
              widget.category.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
      body: predictionsAsync.when(
        data: (predictions) {
          if (predictions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer_outlined,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No predictions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for new tips!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              return Padding(
                key: ValueKey(prediction.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: RepaintBoundary(
                  child: PredictionCard(prediction: prediction),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading predictions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
