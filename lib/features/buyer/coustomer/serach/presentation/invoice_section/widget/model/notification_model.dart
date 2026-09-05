class NotificationModel {
  final int? id;
  final String? title;
  final String? body;
  final String? createdAt;
  final bool? isRead;
  final String? type;

  NotificationModel({
    this.id,
    this.title,
    this.body,
    this.createdAt,
    this.isRead,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      createdAt: json['created_at'] ?? json['createdAt'] as String?,
      isRead: json['is_read'] ?? json['isRead'] ?? json['read'] as bool? ?? false,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'created_at': createdAt,
      'is_read': isRead,
      'type': type,
    };
  }
}
