import 'message.dart';

class ConversationModel {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String otherUserRole; // e.g. "Diamond Seller", "Gold Seller", "Buyer"
  final String storeName;
  bool isOnline;
  DateTime? lastSeen;
  int unreadCount;
  bool isArchived;
  bool isBlocked;
  bool isTyping;
  List<MessageModel> messages;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.otherUserRole,
    this.storeName = '',
    this.isOnline = false,
    this.lastSeen,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isBlocked = false,
    this.isTyping = false,
    required this.messages,
  });

  MessageModel? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  ConversationModel copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    String? otherUserRole,
    String? storeName,
    bool? isOnline,
    DateTime? lastSeen,
    int? unreadCount,
    bool? isArchived,
    bool? isBlocked,
    bool? isTyping,
    List<MessageModel>? messages,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      otherUserRole: otherUserRole ?? this.otherUserRole,
      storeName: storeName ?? this.storeName,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      unreadCount: unreadCount ?? this.unreadCount,
      isArchived: isArchived ?? this.isArchived,
      isBlocked: isBlocked ?? this.isBlocked,
      isTyping: isTyping ?? this.isTyping,
      messages: messages ?? this.messages,
    );
  }
}
