import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();
  
  static final NotificationService instance = NotificationService._();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  String? _userId;
  
  final _tokenStreamController = StreamController<String>.broadcast();
  Stream<String> get tokenStream => _tokenStreamController.stream;
  
  final _messageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;
  
  /// Initialize notification service
  Future<void> initialize({String? userId}) async {
    _userId = userId;
    
    try {
      // Request permission (iOS and Android 13+)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('Notification permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');
        
        if (_fcmToken != null) {
          _tokenStreamController.add(_fcmToken!);
          
          // Save token to Firestore if userId provided
          if (_userId != null) {
            await _saveFcmToken(
              userId: _userId!,
              token: _fcmToken!,
            );
          }
        }
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          debugPrint('FCM Token refreshed: $token');
          _tokenStreamController.add(token);
          
          // Update token in Firestore
          if (_userId != null) {
            _saveFcmToken(
              userId: _userId!,
              token: token,
            );
          }
        });
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Foreground message received: ${message.messageId}');
          debugPrint('Title: ${message.notification?.title}');
          debugPrint('Body: ${message.notification?.body}');
          _messageStreamController.add(message);
        });
        
        // Handle notification tap when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('Notification tapped (background): ${message.messageId}');
          _messageStreamController.add(message);
        });
        
        // Handle notification tap when app was terminated
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('App opened from terminated state: ${initialMessage.messageId}');
          _messageStreamController.add(initialMessage);
        }
        
        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        
        // Subscribe to "all_users" topic for broadcast notifications
        await subscribeToTopic('all_users');
        
        debugPrint('Notification service initialized successfully');
      } else {
        debugPrint('Notification permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }
  
  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }
  
  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }
  
  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
  
  /// Save FCM token to Firestore
  Future<void> _saveFcmToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _firestore.collection('fcmTokens').doc(userId).set({
        'token': token,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));
      debugPrint('FCM token saved for user: $userId');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
  
  void dispose() {
    _tokenStreamController.close();
    _messageStreamController.close();
  }
}
