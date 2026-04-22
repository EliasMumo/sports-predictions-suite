import 'package:flutter/material.dart';
import 'package:predictions_shared/predictions_shared.dart';

import 'features/navigation/root_shell.dart';

class EndUserApp extends StatelessWidget {
  const EndUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Predictions',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RootShell(),
    );
  }
}
