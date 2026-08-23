class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String
  type; // 'ORDER_STATUS', 'PAYMENT_RECEIVED', 'DELIVERY_UPDATE', 'ADMIN_ALERT'
  final bool isRead;
  final DateTime? createdAt;
  final String? link;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.link,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      type: json['type'] ?? 'GENERAL',
      isRead: json['read'] ?? json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      link: json['link'],
    );
  }
}
