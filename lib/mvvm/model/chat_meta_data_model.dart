
import 'package:cloud_firestore/cloud_firestore.dart';
enum ChatRole { admin, member }

extension ChatRoleExtension on ChatRole {
  String toShortString() {
    return toString().split('.').last;
  }

  static ChatRole fromString(String role) {
    switch (role) {
      case 'admin':
        return ChatRole.admin;
      case 'member':
        return ChatRole.member;
      default:
        return ChatRole.member; // default fallback
    }
  }
}


class ChatMemberModel {
  final String id;
  final ChatRole role;
  final Timestamp joinedAt;

  ChatMemberModel({
    required this.id,
    required this.role,
    required this.joinedAt,
  });

  factory ChatMemberModel.fromJson(Map<String, dynamic> json) {
    return ChatMemberModel(
      id: json['id'] ?? '',
      role: ChatRoleExtension.fromString(json['role'] ?? 'member'),
      joinedAt: json['joinedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toShortString(),
      'joinedAt': joinedAt,
    };
  }
}


class ChatMetadataModel {
  final String chatId;
  final String chatType;
  final List<ChatMemberModel> members;
  final String? lastMessage;
  final Timestamp? lastMessageTime;


  const ChatMetadataModel({
    required this.chatId,
    required this.chatType,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,

  });

  factory ChatMetadataModel.fromJson(Map<String, dynamic> json) => ChatMetadataModel(
    chatId: json['chatId'] ?? '',
    chatType: json['chatType'] ?? 'direct',
    members: (json['members'] as List<dynamic>? ?? [])
        .map((e) => ChatMemberModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastMessage: json['lastMessage'],
    lastMessageTime: json['lastMessageTime'] is Timestamp
        ? json['lastMessageTime'] as Timestamp
        : Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'chatId': chatId,
    'chatType': chatType,
    'members': members.map((e) => e.toJson()).toList(),
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime ?? FieldValue.serverTimestamp(),
  };

  ChatMetadataModel copyWith({
    String? chatId,
    String? chatType,
    List<ChatMemberModel>? members,
    String? lastMessage,
    Timestamp? lastMessageTime,

  }) =>
      ChatMetadataModel(
        chatId: chatId ?? this.chatId,
        chatType: chatType ?? this.chatType,
        members: members ?? this.members,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,

      );
}

