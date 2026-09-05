import 'dart:convert';

enum MessageType { text, image, file, voice }
enum MessageStatus { sent, delivered, seen }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  MessageStatus status;
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSenderName;
  final bool isForwarded;
  final String? attachmentName;
  final String? attachmentSize;
  final Duration? voiceDuration;
  bool isDeleted;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.replyToContent,
    this.replyToSenderName,
    this.isForwarded = false,
    this.attachmentName,
    this.attachmentSize,
    this.voiceDuration,
    this.isDeleted = false,
  });

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderName,
    bool? isForwarded,
    String? attachmentName,
    String? attachmentSize,
    Duration? voiceDuration,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      isForwarded: isForwarded ?? this.isForwarded,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
