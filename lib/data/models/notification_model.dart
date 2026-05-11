class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'order' | 'payment' | 'general' | 'announcement'
  final bool isRead;
  final DateTime createdAt;
  final String? orderId;
  final Map<String, dynamic>? payload;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.orderId,
    this.payload,
  });

  bool get isOrderNotification   => type == 'order';
  bool get isPaymentNotification => type == 'payment';

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        orderId: orderId,
        payload: payload,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id:        json['id'] as String? ?? '',
        title:     json['title'] as String? ?? '',
        body:      json['body'] as String? ?? '',
        type:      json['type'] as String? ?? 'general',
        isRead:    json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        orderId: json['order_id'] as String?,
        payload: json['payload'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
        if (orderId != null) 'order_id': orderId,
      };
}
