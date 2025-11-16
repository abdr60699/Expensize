import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/push_notification.dart';
import '../models/fcm_config.dart';

/// Main service for handling FCM notifications
class FCMService {
  static FCMService? _instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FCMConfig config;
  final StreamController<PushNotification> _notificationController =
      StreamController<PushNotification>.broadcast();
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();

  String? _currentToken;

  FCMService._internal(this.config);

  /// Get singleton instance
  static FCMService get instance {
    if (_instance == null) {
      throw Exception(
        'FCMService not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize FCM service
  static Future<FCMService> initialize(FCMConfig config) async {
    // Initialize Firebase
    await Firebase.initializeApp();

    _instance = FCMService._internal(config);
    await _instance!._setup();

    return _instance!;
  }

  /// Setup FCM and local notifications
  Future<void> _setup() async {
    // Request permission (iOS)
    if (config.requestPermissionOnInit) {
      await requestPermission();
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await getToken();

    // Setup message handlers
    _setupMessageHandlers();

    // Setup token refresh listener
    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      _tokenController.add(token);
    });
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createAndroidChannel();
    }
  }

  /// Create Android notification channel
  Future<void> _createAndroidChannel() async {
    final channel = AndroidNotificationChannel(
      config.androidChannelId,
      config.androidChannelName,
      description: config.androidChannelDescription,
      importance: _mapImportance(config.androidImportance),
      sound: config.androidSound != null
          ? RawResourceAndroidNotificationSound(config.androidSound!)
          : null,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = PushNotification.fromRemoteMessage(message);
      _notificationController.add(notification);

      if (config.showForegroundNotifications) {
        _showLocalNotification(notification);
      }
    });

    // Background messages (app in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notification = PushNotification.fromRemoteMessage(message);
      _notificationController.add(notification);
    });

    // Handle initial message (app opened from terminated state)
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        final notification = PushNotification.fromRemoteMessage(message);
        _notificationController.add(notification);
      }
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(PushNotification notification) async {
    final androidDetails = AndroidNotificationDetails(
      config.androidChannelId,
      config.androidChannelName,
      channelDescription: config.androidChannelDescription,
      importance: _mapImportance(config.androidImportance),
      priority: Priority.high,
      icon: config.androidNotificationIcon,
      color: config.androidNotificationColor != null
          ? _hexToColor(config.androidNotificationColor!)
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: config.enableAlert,
      presentBadge: config.enableBadge,
      presentSound: config.enableSound,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.clickAction,
    );
  }

  /// Request notification permission
  Future<NotificationSettings> requestPermission() async {
    return await _messaging.requestPermission(
      alert: config.enableAlert,
      badge: config.enableBadge,
      sound: config.enableSound,
      provisional: false,
    );
  }

  /// Get FCM token
  Future<String?> getToken() async {
    _currentToken = await _messaging.getToken();
    if (_currentToken != null) {
      _tokenController.add(_currentToken!);
    }
    return _currentToken;
  }

  /// Get current token (cached)
  String? get currentToken => _currentToken;

  /// Delete FCM token
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _currentToken = null;
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Stream of incoming notifications
  Stream<PushNotification> get notificationStream =>
      _notificationController.stream;

  /// Stream of token updates
  Stream<String> get tokenStream => _tokenController.stream;

  /// Callback when notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Handle click action / deep link
      // This will be exposed through the notification stream
    }
  }

  /// Map importance enum
  Importance _mapImportance(AndroidImportance importance) {
    switch (importance) {
      case AndroidImportance.none:
        return Importance.none;
      case AndroidImportance.min:
        return Importance.min;
      case AndroidImportance.low:
        return Importance.low;
      case AndroidImportance.defaultImportance:
        return Importance.defaultImportance;
      case AndroidImportance.high:
        return Importance.high;
      case AndroidImportance.max:
        return Importance.max;
    }
  }

  /// Convert hex color string to Color
  Color? _hexToColor(String hex) {
    try {
      final hexColor = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
    _tokenController.close();
  }
}

/// Import for Color
class Color {
  final int value;
  const Color(this.value);
}
