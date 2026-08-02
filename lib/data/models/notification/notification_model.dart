class NotificationModel {
  const NotificationModel({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  final int notificationId;
  final String type;
  final String title;
  final String content;
  final bool isRead;
  final DateTime createdAt;
}
