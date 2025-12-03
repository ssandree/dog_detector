class NotificationSettings {
  final bool instantAlert;
  final String? fcmToken;

  const NotificationSettings({
    required this.instantAlert,
    this.fcmToken,
  });

  const NotificationSettings.initial()
      : instantAlert = true,
        fcmToken = null;

  NotificationSettings copyWith({
    bool? instantAlert,
    String? fcmToken,
  }) {
    return NotificationSettings(
      instantAlert: instantAlert ?? this.instantAlert,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      instantAlert: json['instant_alert_enabled'] as bool? ??
          json['instant_alert'] as bool? ??
          false,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instant_alert_enabled': instantAlert,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }
}

class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;
  final bool isRead;

  const NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    this.isRead = false,
  });

  NotificationMessage copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      sentAt: DateTime.tryParse(json['sent_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}

