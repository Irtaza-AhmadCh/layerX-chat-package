

import 'package:cloud_firestore/cloud_firestore.dart';



class FireBaseUserModel {
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? status;
  final String? profileImage;
  final String? userAppId;
  final String? role;
  final String? fcmToken;
  final List<String> inboxIds;

  const FireBaseUserModel({
    this.userEmail,
    this.userPhone,
    required this.role,
    this.userAppId,
    required this.userName,
    required this.status,
    required this.profileImage,
    required this.fcmToken,
    required this.inboxIds,
  });

  factory FireBaseUserModel.fromJson(Map<String, dynamic> json) => FireBaseUserModel(
    userName: json['userName'] ?? '',
    userPhone: json['userPhone'] ?? '',
    userEmail: json['userEmail'] ?? '',
    status: json['status'] ?? '',
    profileImage: json['profileImage'] ?? '',
    userAppId: json['userAppId'],
    role: json['role'] ?? '',
    fcmToken: json['fcmToken'] ?? '',
    inboxIds: List<String>.from(json['inboxIds'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'userEmail': userEmail,
    'userPhone': userPhone,
    'userName': userName,
    'status': status,
    'profileImage': profileImage,
    'userAppId': userAppId,
    'role': role,
    'fcmToken': fcmToken,
    'inboxIds': inboxIds,
  };

  @override
  String toString() =>
      'FireBaseUserModel(userName: $userName, email: $userEmail, phone: $userPhone, status: $status, profileImage: $profileImage, appId: $userAppId, role: $role, fcmToken: $fcmToken, inboxIds: $inboxIds)';
}