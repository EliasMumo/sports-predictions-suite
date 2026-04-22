import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for notification requests created by admins
/// Cloud Functions will listen to this collection and send notifications
class NotificationRequest {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final String targetType; // 'all', 'topic'
  final String? topic; // if targetType is 'topic'
  final DateTime createdAt;
  final String createdBy; // admin userId
  final String status; // 'pending', 'processing', 'sent', 'failed'
  final DateTime? sentAt;
  final int? recipientCount;
  final String? error;

  NotificationRequest({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.targetType,
    this.topic,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    this.sentAt,
    this.recipientCount,
    this.error,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'targetType': targetType,
      'topic': topic,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'status': status,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'recipientCount': recipientCount,
      'error': error,
    };
  }

  /// Create from Firestore document
  factory NotificationRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationRequest(
      id: doc.id,
      title: data['title'] as String,
      message: data['message'] as String,
      imageUrl: data['imageUrl'] as String?,
      targetType: data['targetType'] as String,
      topic: data['topic'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
      status: data['status'] as String,
      sentAt: data['sentAt'] != null 
          ? (data['sentAt'] as Timestamp).toDate() 
          : null,
      recipientCount: data['recipientCount'] as int?,
      error: data['error'] as String?,
    );
  }

  /// Create a copy with updated fields
  NotificationRequest copyWith({
    String? id,
    String? title,
    String? message,
    String? imageUrl,
    String? targetType,
    String? topic,
    DateTime? createdAt,
    String? createdBy,
    String? status,
    DateTime? sentAt,
    int? recipientCount,
    String? error,
  }) {
    return NotificationRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      topic: topic ?? this.topic,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      recipientCount: recipientCount ?? this.recipientCount,
      error: error ?? this.error,
    );
  }
}
