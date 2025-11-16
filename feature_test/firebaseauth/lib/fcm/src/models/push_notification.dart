/// Represents a push notification message
class PushNotification {
  /// Notification title
  final String? title;

  /// Notification body/message
  final String? body;

  /// Custom data payload
  final Map<String, dynamic>? data;

  /// Image URL (Android & iOS)
  final String? imageUrl;

  /// Notification ID (for tracking)
  final String? notificationId;

  /// Category/Channel (for grouping)
  final String? category;

  /// Priority (high, normal, low)
  final NotificationPriority priority;

  /// Badge count (iOS)
  final int? badge;

  /// Sound (custom sound file name)
  final String? sound;

  /// Click action/deep link
  final String? clickAction;

  /// Time received
  final DateTime receivedAt;

  const PushNotification({
    this.title,
    this.body,
    this.data,
    this.imageUrl,
    this.notificationId,
    this.category,
    this.priority = NotificationPriority.normal,
    this.badge,
    this.sound,
    this.clickAction,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? const Duration().inMilliseconds as DateTime;

  /// Create from Firebase RemoteMessage
  factory PushNotification.fromRemoteMessage(dynamic message) {
    return PushNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      notificationId: message.messageId,
      clickAction: message.data['click_action']?.toString(),
      receivedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'imageUrl': imageUrl,
      'notificationId': notificationId,
      'category': category,
      'priority': priority.name,
      'badge': badge,
      'sound': sound,
      'clickAction': clickAction,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      notificationId: json['notificationId'] as String?,
      category: json['category'] as String?,
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      badge: json['badge'] as int?,
      sound: json['sound'] as String?,
      clickAction: json['clickAction'] as String?,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }
}

/// Notification priority levels
enum NotificationPriority {
  high,
  normal,
  low,
}

/// Notification action (for interactive notifications)
class NotificationAction {
  final String id;
  final String title;
  final bool requiresAuth;

  const NotificationAction({
    required this.id,
    required this.title,
    this.requiresAuth = false,
  });
}
