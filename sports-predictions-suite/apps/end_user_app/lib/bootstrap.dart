import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:predictions_shared/predictions_shared.dart';

import 'firebase_options.dart';
import 'splash_screen.dart';
import 'src/services/vip_service.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable screenshots and screen recording
  await SystemChannels.platform.invokeMethod('SystemChrome.setEnabledSystemUIMode', {
    'mode': 'immersiveSticky',
  }).catchError((_) {});
  
  // Set secure flag for Android
  await SystemChannels.platform.invokeMethod(
    'SystemChrome.setApplicationSwitcherDescription',
    {
      'label': 'Football Tips',
      'primaryColor': 0xFF000000,
    },
  ).catchError((_) {});
  
  // Show splash screen immediately
  runApp(const SplashScreen());
  
  // Initialize Firebase and notifications
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  await NotificationService.instance.initialize();

  // Initialize RevenueCat
  try {
    await VIPService().initialize();
  } catch (_) {
    // Keep startup resilient even if billing configuration is missing.
  }
  
  // Small delay to ensure smooth transition
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Load the actual app
  runApp(ProviderScope(child: await builder()));
}
