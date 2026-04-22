import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:predictions_shared/predictions_shared.dart';

import '../controllers/prediction_admin_controller.dart';

// Provider to store copied prediction data
final copiedPredictionProvider = NotifierProvider<CopiedPredictionNotifier, PredictionDraft?>(() {
  return CopiedPredictionNotifier();
});

class CopiedPredictionNotifier extends Notifier<PredictionDraft?> {
  @override
  PredictionDraft? build() {
    return null;
  }

  void setCopiedPrediction(PredictionDraft? draft) {
    state = draft;
  }
  
  void clear() {
    state = null;
  }
}

Future<void> showPredictionFormSheet(
  BuildContext context, {
  required PredictionCategory category,
  Prediction? prediction,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: false,
    builder: (_) => PredictionFormSheet(
      category: category,
      prediction: prediction,
    ),
  );
}

Future<void> showResultSheet(
  BuildContext context, {
  required PredictionCategory category,
  required Prediction prediction,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (_) => _ResultSheet(
      category: category,
      prediction: prediction,
    ),
  );
}

class PredictionFormSheet extends ConsumerStatefulWidget {
  const PredictionFormSheet({
    super.key,
    required this.category,
    this.prediction,
  });

  final PredictionCategory category;
  final Prediction? prediction;

  @override
  ConsumerState<PredictionFormSheet> createState() =>
      _PredictionFormSheetState();
}

class _PredictionFormSheetState
    extends ConsumerState<PredictionFormSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController league;
  late final TextEditingController home;
  late final TextEditingController away;
  late final TextEditingController tip;
  late final TextEditingController odds;
  late DateTime matchTime;

  @override
  void initState() {
    super.initState();
    final prediction = widget.prediction;
    
    league = TextEditingController(text: prediction?.league ?? '');
    home = TextEditingController(text: prediction?.homeTeam ?? '');
    away = TextEditingController(text: prediction?.awayTeam ?? '');
    tip = TextEditingController(text: prediction?.prediction ?? '');
    odds = TextEditingController(text: prediction?.odds ?? '');
    matchTime = prediction?.matchTime ?? DateTime.now();
  }

  @override
  void dispose() {
    league.dispose();
    home.dispose();
    away.dispose();
    tip.dispose();
    odds.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: matchTime,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(matchTime),
    );
    if (time == null) return;
    setState(() {
      matchTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _copyPrediction() {
    if (!formKey.currentState!.validate()) return;
    
    final draft = PredictionDraft(
      league: league.text.trim(),
      matchTime: matchTime,
      homeTeam: home.text.trim(),
      awayTeam: away.text.trim(),
      prediction: tip.text.trim(),
      odds: odds.text.trim().isNotEmpty ? odds.text.trim() : null,
    );
    
    ref.read(copiedPredictionProvider.notifier).setCopiedPrediction(draft);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prediction copied! You can paste it in another category.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pastePrediction() {
    final copiedData = ref.read(copiedPredictionProvider);
    if (copiedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No prediction copied')),
      );
      return;
    }
    
    setState(() {
      league.text = copiedData.league;
      home.text = copiedData.homeTeam;
      away.text = copiedData.awayTeam;
      tip.text = copiedData.prediction;
      odds.text = copiedData.odds ?? '';
      matchTime = copiedData.matchTime;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prediction pasted!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    
    final draft = PredictionDraft(
      league: league.text.trim(),
      matchTime: matchTime,
      homeTeam: home.text.trim(),
      awayTeam: away.text.trim(),
      prediction: tip.text.trim(),
      odds: odds.text.trim().isNotEmpty ? odds.text.trim() : null,
    );

    final controller =
        ref.read(predictionAdminControllerProvider.notifier);
    try {
      if (widget.prediction == null) {
        await controller.createMatch(
          category: widget.category,
          draft: draft,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timed out. Check your internet connection.');
          },
        );
      } else {
        await controller.updateMatch(
          category: widget.category,
          match: widget.prediction!,
          draft: draft,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timed out. Check your internet connection.');
          },
        );
      }
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('EEE, d MMM · HH:mm').format(matchTime);
    final controllerState = ref.watch(predictionAdminControllerProvider);
    final isLoading = controllerState.isLoading;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.prediction == null ? 'Add match' : 'Edit match',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: league,
                decoration: const InputDecoration(labelText: 'League'),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: home,
                decoration: const InputDecoration(labelText: 'Home team'),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: away,
                decoration: const InputDecoration(labelText: 'Away team'),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tip,
                decoration: const InputDecoration(labelText: 'Prediction (e.g. Over 2.5)'),
                textInputAction: TextInputAction.next,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: odds,
                decoration:
                    const InputDecoration(
                      labelText: 'Odds (optional)',
                      hintText: 'e.g. 1.85, 2.10',
                    ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Match time (EAT)'),
                subtitle: Text(formattedTime),
                trailing: IconButton(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.schedule),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.prediction == null ? 'Create' : 'Update'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _copyPrediction,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultSheet extends ConsumerStatefulWidget {
  const _ResultSheet({
    required this.category,
    required this.prediction,
  });

  final PredictionCategory category;
  final Prediction prediction;

  @override
  ConsumerState<_ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends ConsumerState<_ResultSheet> {
  final scoreController = TextEditingController();
  PredictionResult result = PredictionResult.pending;

  @override
  void initState() {
    scoreController.text = widget.prediction.score;
    result = widget.prediction.result;
    super.initState();
  }

  @override
  void dispose() {
    scoreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller =
        ref.read(predictionAdminControllerProvider.notifier);
    try {
      await controller.updateResult(
        category: widget.category,
        match: widget.prediction,
        result: result,
        score: scoreController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Finalize result',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: scoreController,
              decoration:
                  const InputDecoration(labelText: 'Score (e.g. 2-1)'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PredictionResult>(
              initialValue: result,
              items: PredictionResult.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => result = value ?? PredictionResult.pending),
              decoration: const InputDecoration(labelText: 'Outcome'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save result'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
