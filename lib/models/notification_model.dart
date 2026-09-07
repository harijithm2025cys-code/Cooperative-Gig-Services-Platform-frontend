class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'system',
    this.referenceId,
    this.isRead = false,
    this.createdAt,
    this.data,
  });

  String get notificationType => type;
  String? get bookingId => referenceId;
  Map<String, dynamic> get metadata => data ?? const {};

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      type: (json['type'] ?? json['notification_type'])?.toString() ?? 'system',
      referenceId: json['reference_id']?.toString() ?? json['booking_id']?.toString(),
      isRead: json['is_read'] == true || json['read'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      data: (json['data'] ?? json['metadata']) is Map<String, dynamic>
          ? (json['data'] ?? json['metadata']) as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'notification_type': type,
      'reference_id': referenceId,
      'booking_id': referenceId,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
      'data': data,
      'metadata': data,
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? referenceId,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}
