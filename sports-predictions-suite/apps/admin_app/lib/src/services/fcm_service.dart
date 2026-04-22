import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  FCMService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  /// Send notification to a topic
  Future<bool> sendToTopic({
    required String title,
    required String body,
    String topic = 'all_users',
    Map<String, String>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendNotification');
      final response = await callable.call(<String, dynamic>{
        'title': title,
        'body': body,
        'topic': topic,
        if (data != null) 'data': data,
      });
      final payload = Map<String, dynamic>.from(response.data as Map);
      return payload['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'Failed to send notification via function: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected notification error: $e');
      return false;
    }
  }

  /// Send notification to specific device tokens
  Future<Map<String, int>> sendToDevices({
    required String title,
    required String body,
    required List<String> tokens,
    Map<String, String>? data,
  }) async {
    if (tokens.isEmpty) {
      return {'success': 0, 'failure': 0};
    }

    try {
      final callable = _functions.httpsCallable('sendNotificationToDevices');
      final response = await callable.call(<String, dynamic>{
        'title': title,
        'body': body,
        'tokens': tokens,
        if (data != null) 'data': data,
      });
      final payload = Map<String, dynamic>.from(response.data as Map);
      return {
        'success': (payload['successCount'] as num?)?.toInt() ?? 0,
        'failure': (payload['failureCount'] as num?)?.toInt() ?? 0,
      };
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'Failed to send device notifications via function: ${e.code} ${e.message}');
      return {'success': 0, 'failure': tokens.length};
    } catch (e) {
      debugPrint('Unexpected device notification error: $e');
      return {'success': 0, 'failure': tokens.length};
    }
  }
}
