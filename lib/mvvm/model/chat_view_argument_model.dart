class ChatViewArguments {
  final String currentUserId;
  final String chatBoxId;
  final String receiverId;
  final String? userName;
  final String? userImage;

  ChatViewArguments({
    required this.currentUserId,
    required this.chatBoxId,
    required this.receiverId,
    required this.userName,
    required this.userImage,
  });

  factory ChatViewArguments.fromMap(Map<String, dynamic> map) {
    return ChatViewArguments(
      currentUserId: map['currentUserId'] ?? '',
      chatBoxId: map['chatBoxId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentUserId': currentUserId,
      'chatBoxId': chatBoxId,
      'receiverId': receiverId,
      'userName': userName,
      'userImage': userImage,
    };
  }
}
