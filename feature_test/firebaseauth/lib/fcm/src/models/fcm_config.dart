import 'package:firebase_messaging/firebase_messaging.dart';

/// Configuration for FCM notifications
class FCMConfig {
  /// Request permission on initialization (iOS)
  final bool requestPermissionOnInit;

  /// Show notifications in foreground
  final bool showForegroundNotifications;

  /// Enable analytics tracking
  final bool enableAnalytics;

  /// Auto-initialize FCM
  final bool autoInitEnabled;

  /// Android notification channel ID
  final String androidChannelId;

  /// Android notification channel name
  final String androidChannelName;

  /// Android notification channel description
  final String androidChannelDescription;

  /// Android notification importance
  final AndroidImportance androidImportance;

  /// Android notification sound
  final String? androidSound;

  /// iOS notification presentation options
  final List<AppleNotificationSetting> iosNotificationOptions;

  /// Handle background messages (requires top-level function)
  final BackgroundMessageHandler? backgroundMessageHandler;

  /// Enable notification badge (iOS)
  final bool enableBadge;

  /// Enable notification sound
  final bool enableSound;

  /// Enable notification alert
  final bool enableAlert;

  /// Custom notification icon (Android)
  final String? androidNotificationIcon;

  /// Notification color (Android)
  final String? androidNotificationColor;

  const FCMConfig({
    this.requestPermissionOnInit = true,
    this.showForegroundNotifications = true,
    this.enableAnalytics = false,
    this.autoInitEnabled = true,
    this.androidChannelId = 'default_channel',
    this.androidChannelName = 'Default Channel',
    this.androidChannelDescription = 'Default notification channel',
    this.androidImportance = AndroidImportance.high,
    this.androidSound = 'default',
    this.iosNotificationOptions = const [
      AppleNotificationSetting.alert,
      AppleNotificationSetting.badge,
      AppleNotificationSetting.sound,
    ],
    this.backgroundMessageHandler,
    this.enableBadge = true,
    this.enableSound = true,
    this.enableAlert = true,
    this.androidNotificationIcon,
    this.androidNotificationColor,
  });

  /// Production configuration
  static const production = FCMConfig(
    requestPermissionOnInit: true,
    showForegroundNotifications: true,
    enableAnalytics: true,
    androidImportance: AndroidImportance.high,
  );

  /// Development configuration
  static const development = FCMConfig(
    requestPermissionOnInit: true,
    showForegroundNotifications: true,
    enableAnalytics: false,
    androidImportance: AndroidImportance.high,
  );

  FCMConfig copyWith({
    bool? requestPermissionOnInit,
    bool? showForegroundNotifications,
    bool? enableAnalytics,
    bool? autoInitEnabled,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
    AndroidImportance? androidImportance,
    String? androidSound,
    List<AppleNotificationSetting>? iosNotificationOptions,
    BackgroundMessageHandler? backgroundMessageHandler,
    bool? enableBadge,
    bool? enableSound,
    bool? enableAlert,
    String? androidNotificationIcon,
    String? androidNotificationColor,
  }) {
    return FCMConfig(
      requestPermissionOnInit:
          requestPermissionOnInit ?? this.requestPermissionOnInit,
      showForegroundNotifications:
          showForegroundNotifications ?? this.showForegroundNotifications,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      autoInitEnabled: autoInitEnabled ?? this.autoInitEnabled,
      androidChannelId: androidChannelId ?? this.androidChannelId,
      androidChannelName: androidChannelName ?? this.androidChannelName,
      androidChannelDescription:
          androidChannelDescription ?? this.androidChannelDescription,
      androidImportance: androidImportance ?? this.androidImportance,
      androidSound: androidSound ?? this.androidSound,
      iosNotificationOptions:
          iosNotificationOptions ?? this.iosNotificationOptions,
      backgroundMessageHandler:
          backgroundMessageHandler ?? this.backgroundMessageHandler,
      enableBadge: enableBadge ?? this.enableBadge,
      enableSound: enableSound ?? this.enableSound,
      enableAlert: enableAlert ?? this.enableAlert,
      androidNotificationIcon:
          androidNotificationIcon ?? this.androidNotificationIcon,
      androidNotificationColor:
          androidNotificationColor ?? this.androidNotificationColor,
    );
  }
}

/// Android notification importance levels
enum AndroidImportance {
  none,
  min,
  low,
  defaultImportance,
  high,
  max,
}

/// Apple notification settings
enum AppleNotificationSetting {
  alert,
  badge,
  sound,
  carPlay,
  criticalAlert,
  announcement,
}

/// Callback type for background message handler
typedef BackgroundMessageHandler = Future<void> Function(
    RemoteMessage message);
