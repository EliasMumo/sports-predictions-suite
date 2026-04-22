import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:predictions_shared/predictions_shared.dart';

import 'firebase_options.dart';
import 'splash_screen.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Show splash screen immediately
  runApp(const SplashScreen());
  
  // Initialize Firebase and notifications
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  await NotificationService.instance.initialize();
  
  // Small delay to ensure smooth transition
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Load the actual app
  runApp(ProviderScope(child: await builder()));
}
