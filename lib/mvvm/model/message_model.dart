import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, call, file, image, video, audio, deleted, location , link }
enum ReadStatues { unread, read, sent, unsent }


class MessageModel {
  final String messageBody;
  final String messageType;
  final String messageSenderId;
  final String messageReceiverId;
  final String readStatus;
  final String messageId;
  final dynamic messageSendTime;
  final List<ReactionModel> reactions;
  final List<MessageFileModel> messageFiles;  // ✅ New field

  const MessageModel({
    required this.messageBody,
    required this.messageType,
    required this.messageSenderId,
    required this.messageReceiverId,
    required this.readStatus,
    required this.messageSendTime,
    required this.messageId,
    this.reactions = const [],
    this.messageFiles = const [],  // ✅ Default empty list
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    messageBody: json['messageBody'] ?? '',
    messageType: json['messageType'] ?? '',
    messageSenderId: json['messageSenderId'] ?? '',
    messageReceiverId: json['messageReceiverId'] ?? '',
    readStatus: json['readStatus'] ?? '',
    messageSendTime: json['messageSendTime'],
    messageId: json['messageId'] ?? '',
    reactions: (json['reactions'] as List<dynamic>? ?? [])
        .map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    messageFiles: (json['messageFiles'] as List<dynamic>? ?? [])
        .map((e) => MessageFileModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'messageBody': messageBody,
    'messageType': messageType,
    'messageSenderId': messageSenderId,
    'messageReceiverId': messageReceiverId,
    'readStatus': readStatus,
    'messageSendTime': messageSendTime,
    'messageId': messageId,
    'reactions': reactions.map((e) => e.toJson()).toList(),
    'messageFiles': messageFiles.map((e) => e.toJson()).toList(),
  };

  MessageModel copyWith({
    String? messageBody,
    String? messageType,
    String? messageSenderId,
    String? messageReceiverId,
    String? readStatus,
    dynamic messageSendTime,
    String? messageId,
    List<ReactionModel>? reactions,
    List<MessageFileModel>? messageFiles,
  }) =>
      MessageModel(
        messageBody: messageBody ?? this.messageBody,
        messageType: messageType ?? this.messageType,
        messageSenderId: messageSenderId ?? this.messageSenderId,
        messageReceiverId: messageReceiverId ?? this.messageReceiverId,
        readStatus: readStatus ?? this.readStatus,
        messageSendTime: messageSendTime ?? this.messageSendTime,
        messageId: messageId ?? this.messageId,
        reactions: reactions ?? this.reactions,
        messageFiles: messageFiles ?? this.messageFiles,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageModel &&
              other.messageBody == messageBody &&
              other.messageType == messageType &&
              other.messageSenderId == messageSenderId &&
              other.messageReceiverId == messageReceiverId &&
              other.readStatus == readStatus &&
              other.messageSendTime == messageSendTime &&
              other.messageId == messageId &&
              other.reactions == reactions &&
              other.messageFiles == messageFiles;

  @override
  int get hashCode => Object.hash(
    messageBody,
    messageType,
    messageSenderId,
    messageReceiverId,
    readStatus,
    messageSendTime,
    messageId,
    reactions,
    messageFiles,
  );
}

class MessageFileModel {
  final String name;
  final String type;
  final String id;
  final int size;
  final String link;

  const MessageFileModel({
    required this.name,
    required this.type,
    required this.id,
    required this.size,
    required this.link,
  });

  factory MessageFileModel.fromJson(Map<String, dynamic> json) => MessageFileModel(
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    id: json['id'] ?? '',
    size: json['size'] ?? 0,
    link: json['link'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'id': id,
    'size': size,
    'link': link,
  };
}

class ReactionModel {
  final String react;
  final String by;
  final Timestamp time;

  ReactionModel({
    required this.react,
    required this.by,
    required this.time,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) => ReactionModel(
    react: json['react'] ?? '',
    by: json['by'] ?? '',
    time: json['time'] ?? Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'react': react,
    'by': by,
    'time': time,
  };
}
