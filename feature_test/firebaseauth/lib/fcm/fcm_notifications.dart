library fcm_notifications;

// Export models
export 'src/models/push_notification.dart';
export 'src/models/fcm_config.dart';

// Export services
export 'src/services/fcm_service.dart';

// Export Firebase dependencies (convenience)
// Hide BackgroundMessageHandler to avoid ambiguous export with fcm_config.dart
export 'package:firebase_messaging/firebase_messaging.dart' hide BackgroundMessageHandler;
