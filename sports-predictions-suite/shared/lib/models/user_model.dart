import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.isVIP = false,
    this.vipExpiresAt,
    this.subscriptionId,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final bool isVIP;
  final DateTime? vipExpiresAt;
  final String? subscriptionId;
  final DateTime? createdAt;

  bool get hasActiveVIP {
    if (!isVIP) return false;
    if (vipExpiresAt == null) return false;
    return vipExpiresAt!.isAfter(DateTime.now());
  }

  UserModel copyWith({
    String? displayName,
    bool? isVIP,
    DateTime? vipExpiresAt,
    String? subscriptionId,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      isVIP: isVIP ?? this.isVIP,
      vipExpiresAt: vipExpiresAt ?? this.vipExpiresAt,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> data, String uid) {
    final vipExpiresTimestamp = data['vipExpiresAt'] as Timestamp?;
    final createdTimestamp = data['createdAt'] as Timestamp?;
    
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      isVIP: data['isVIP'] as bool? ?? false,
      vipExpiresAt: vipExpiresTimestamp?.toDate(),
      subscriptionId: data['subscriptionId'] as String?,
      createdAt: createdTimestamp?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'isVIP': isVIP,
      'vipExpiresAt': vipExpiresAt != null ? Timestamp.fromDate(vipExpiresAt!) : null,
      'subscriptionId': subscriptionId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
