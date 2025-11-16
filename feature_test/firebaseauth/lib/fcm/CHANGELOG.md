# Changelog

All notable changes to the FCM Notifications module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-13

### Added
- Initial release of FCM Notifications module
- Firebase Cloud Messaging integration
- Foreground notification handling
- Background notification handling
- Terminated state notification handling
- Topic subscription/unsubscription
- FCM token management and refresh
- Local notifications for foreground display
- Android notification channels
- iOS APNs integration
- Deep linking support
- Data payload handling
- Permission request (iOS)
- Analytics integration (optional)
- Badge management (iOS)
- Custom notification icons (Android)
- Custom notification colors (Android)
- Notification sound support
- Notification priority levels
- Background message handler
- Stream-based notification delivery
- Stream-based token updates

### Core Components
- `FCMService` - Main service for FCM operations
- `PushNotification` - Notification model
- `FCMConfig` - Configuration options
- Background message handler support
- Flutter local notifications integration

### Platform Support
- Android (API 21+)
- iOS (10.0+)
- Web (limited)
- macOS/Windows/Linux (experimental)

### Dependencies
- firebase_core: ^2.24.0
- firebase_messaging: ^14.7.0
- flutter_local_notifications: ^16.3.0
- firebase_analytics: ^10.7.0 (optional)

### Documentation
- Comprehensive README with setup guide
- Platform-specific configuration guides
- Integration checklist with 100+ items
- Example app with all features
- Server-side integration examples (Node.js, Python, REST)
- Security best practices
- Testing guide
- Troubleshooting section

### Features
- Subscribe and unsubscribe to topics
- Get and refresh FCM tokens
- Handle notifications in all app states
- Display notifications with custom UI
- Parse and handle deep links
- Track notification analytics
- Configure notification channels
- Customize notification appearance
- Handle permission requests
- Background message processing

## [Unreleased]

### Planned
- Multi-channel support (Android)
- Interactive notifications with actions
- Notification grouping
- Scheduled notifications
- A/B testing support
- Rich media notifications
- Notification history
- Do Not Disturb detection
- Battery optimization detection
- Advanced analytics
