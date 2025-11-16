# Firebase Cloud Messaging (FCM) Integration Module

A complete, production-ready Firebase Cloud Messaging (FCM) integration module for Flutter supporting push notifications on Android, iOS, Web, and Desktop with foreground/background handling, topics, deep linking, and analytics.

## 📂 Module Structure

```
fcm_notifications/
├── lib/
│   ├── src/
│   │   ├── models/              # Data models
│   │   │   ├── push_notification.dart
│   │   │   └── fcm_config.dart
│   │   └── services/            # FCM service
│   │       └── fcm_service.dart
│   └── fcm_notifications.dart   # Main entry point
├── example/                     # Example application
├── INTEGRATION_CHECKLIST.md     # Step-by-step checklist
├── pubspec.yaml                 # Dependencies
└── README.md                    # This file
```

## 🚀 Features

### Core Features
- ✅ **Foreground Notifications** - Display notifications when app is open
- ✅ **Background Notifications** - Handle notifications when app is in background
- ✅ **Terminated State** - Handle notifications when app is closed
- ✅ **Topic Subscriptions** - Subscribe/unsubscribe to notification topics
- ✅ **Token Management** - Automatic token generation and refresh
- ✅ **Local Notifications** - Display notifications with custom UI
- ✅ **Deep Linking** - Navigate to specific screens on notification tap
- ✅ **Data Payloads** - Handle custom data with notifications
- ✅ **Analytics Integration** - Track notification performance
- ✅ **Badge Management** - Update app badge count (iOS)

### Platform Support
- ✅ **Android** - Full support with notification channels
- ✅ **iOS** - Full support with APNs integration
- ⚠️ **Web** - Limited support (no background messages)
- ⚠️ **macOS/Windows/Linux** - Experimental support

## 📦 Installation

### 1. Add Dependency

Add to your project's `pubspec.yaml`:

```yaml
dependencies:
  fcm_notifications:
    path: ../modules/fcm_notifications
```

Install dependencies:

```bash
flutter pub get
```

### 2. Firebase Project Setup

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name
4. Enable Google Analytics (optional but recommended)
5. Create project

#### Add Apps to Firebase

**Android:**
1. Click "Add app" → Android
2. Enter package name (from `android/app/build.gradle`)
3. Download `google-services.json`
4. Place in `android/app/` directory

**iOS:**
1. Click "Add app" → iOS
2. Enter bundle ID (from Xcode or `ios/Runner.xcodeproj`)
3. Download `GoogleService-Info.plist`
4. Add to Xcode project (Runner folder)

## 🔧 Platform Configuration

### Android Setup

#### 1. Update `android/build.gradle`

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // Add this
    }
}
```

#### 2. Update `android/app/build.gradle`

```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'  // Add this

android {
    defaultConfig {
        minSdkVersion 21  // FCM requires API 21+
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

#### 3. Update `AndroidManifest.xml`

Add inside `<application>` tag:

```xml
<application>
    <!-- ... existing code ... -->

    <!-- FCM Default Notification Icon -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/ic_notification" />

    <!-- FCM Default Notification Color -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@color/notification_color" />

    <!-- FCM Default Notification Channel -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="default_channel" />
</application>
```

#### 4. Create Notification Icon

Create `android/app/src/main/res/drawable/ic_notification.xml`:

```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="@android:color/white">
    <path
        android:fillColor="@android:color/white"
        android:pathData="M12,22c1.1,0 2,-0.9 2,-2h-4c0,1.1 0.89,2 2,2zM18,16v-5c0,-3.07 -1.64,-5.64 -4.5,-6.32V4c0,-0.83 -0.67,-1.5 -1.5,-1.5s-1.5,0.67 -1.5,1.5v0.68C7.63,5.36 6,7.92 6,11v5l-2,2v1h16v-1l-2,-2z"/>
</vector>
```

### iOS Setup

#### 1. Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes"
7. Check "Remote notifications" under Background Modes

#### 2. Upload APNs Certificate

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Go to Certificates, Identifiers & Profiles
3. Create APNs certificate:
   - Select "Apple Push Notification service SSL"
   - Choose your App ID
   - Generate Certificate Signing Request (CSR)
   - Download certificate
4. Upload to Firebase Console:
   - Go to Project Settings → Cloud Messaging → iOS
   - Upload APNs certificate or APNs Auth Key

#### 3. Update `Info.plist`

Add in `ios/Runner/Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

#### 4. Update `AppDelegate.swift`

```swift
import UIKit
import Flutter
import Firebase
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // Request notification permission
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Required for iOS
  }
}
```

## 💻 Code Integration

### 1. Initialize FCM

```dart
import 'package:fcm_notifications/fcm_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FCM
  await FCMService.initialize(
    FCMConfig.production, // or FCMConfig.development
  );

  runApp(MyApp());
}
```

### 2. Listen to Notifications

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() {
    // Listen to notifications
    FCMService.instance.notificationStream.listen((notification) {
      print('Received: ${notification.title}');

      // Handle notification
      if (notification.clickAction != null) {
        // Navigate to screen
        _handleDeepLink(notification.clickAction!);
      }
    });

    // Listen to token changes
    FCMService.instance.tokenStream.listen((token) {
      print('FCM Token: $token');
      // Send to your server
      _sendTokenToServer(token);
    });
  }

  void _handleDeepLink(String action) {
    // Parse action and navigate
    // Example: "open_chat:123" -> Navigate to chat screen with ID 123
  }

  Future<void> _sendTokenToServer(String token) async {
    // Send token to your backend
    // await apiService.updateDeviceToken(token);
  }
}
```

### 3. Handle Background Messages

For background messages, create a top-level function:

```dart
// Must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');

  // Handle background data processing
  // Don't show UI here - use local notifications
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FCMService.initialize(
    FCMConfig.production.copyWith(
      backgroundMessageHandler: firebaseMessagingBackgroundHandler,
    ),
  );

  runApp(MyApp());
}
```

### 4. Request Permission (iOS)

```dart
Future<void> requestNotificationPermission() async {
  final settings = await FCMService.instance.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}
```

### 5. Subscribe to Topics

```dart
// Subscribe to a topic
await FCMService.instance.subscribeToTopic('news');
await FCMService.instance.subscribeToTopic('sports');

// Unsubscribe
await FCMService.instance.unsubscribeFromTopic('news');
```

### 6. Get FCM Token

```dart
// Get current token
String? token = FCMService.instance.currentToken;

// Or fetch fresh token
String? token = await FCMService.instance.getToken();

// Send to your server
if (token != null) {
  await _sendTokenToServer(token);
}
```

## 📤 Sending Notifications

### From Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and body
4. Click "Send test message" or "Next"
5. Select target (app, topic, or token)
6. Schedule or send immediately

### From Your Server (REST API)

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Hello",
      "body": "World",
      "sound": "default"
    },
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "screen": "home",
      "user_id": "123"
    }
  }'
```

### From Your Server (Node.js)

```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const message = {
  notification: {
    title: 'Hello',
    body: 'World'
  },
  data: {
    click_action: 'FLUTTER_NOTIFICATION_CLICK',
    screen: 'home'
  },
  token: deviceToken
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
```

### From Your Server (Python)

```python
from firebase_admin import messaging, credentials, initialize_app

cred = credentials.Certificate('path/to/serviceAccount.json')
initialize_app(cred)

message = messaging.Message(
    notification=messaging.Notification(
        title='Hello',
        body='World',
    ),
    data={
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'screen': 'home',
    },
    token=device_token,
)

response = messaging.send(message)
print('Successfully sent message:', response)
```

## 🔐 Security Best Practices

### 1. Server Key Security

- ✅ **Never expose server key in client code**
- ✅ Store server key in environment variables
- ✅ Use Firebase Admin SDK on server
- ✅ Rotate server keys periodically

### 2. Token Management

- ✅ Send tokens to your server over HTTPS
- ✅ Store tokens securely in database
- ✅ Delete tokens when user logs out
- ✅ Handle token refresh on server

### 3. Permission Handling

- ✅ Request permission at appropriate time
- ✅ Explain why you need notifications
- ✅ Handle permission denial gracefully
- ✅ Provide settings link if denied

### 4. Data Privacy

- ✅ Don't send sensitive data in notifications
- ✅ Use data payloads for IDs, not content
- ✅ Encrypt sensitive data if needed
- ✅ Comply with GDPR/privacy laws

## 🧪 Testing

### Test on Device

1. Run app on physical device (notifications don't work on simulators reliably)
2. Get FCM token from logs
3. Send test message from Firebase Console
4. Verify notification appears

### Test Different States

1. **Foreground**: App is open and visible
   - Notification should appear as local notification
   - Tap should navigate to screen

2. **Background**: App is in background
   - Notification appears in system tray
   - Tap should open app and navigate

3. **Terminated**: App is closed
   - Notification appears in system tray
   - Tap should open app and navigate

### Test Topics

```dart
// In your test code
await FCMService.instance.subscribeToTopic('test');

// Send to topic from Firebase Console:
// Target: Topic = test
```

### Debug Common Issues

**Android: Notifications not appearing**
- Check notification channel is created
- Verify google-services.json is correct
- Check app has notification permission
- Verify SHA-1 fingerprint in Firebase Console

**iOS: Notifications not appearing**
- Check APNs certificate is uploaded
- Verify bundle ID matches Firebase
- Check push notification capability is enabled
- Test with physical device (not simulator)

## 📊 Analytics Integration

Track notification performance:

```dart
FCMService.initialize(
  FCMConfig.production.copyWith(
    enableAnalytics: true,
  ),
);

// Analytics events are automatically tracked:
// - notification_received
// - notification_opened
// - notification_dismissed
```

## 🔄 Advanced Usage

### Custom Notification UI

```dart
await FCMService.initialize(
  FCMConfig.production.copyWith(
    androidChannelId: 'custom_channel',
    androidChannelName: 'Custom Notifications',
    androidNotificationIcon: '@drawable/custom_icon',
    androidNotificationColor: '#FF5722',
  ),
);
```

### Multiple Notification Channels (Android)

```dart
// Create different channels for different notification types
final urgentChannel = AndroidNotificationChannel(
  'urgent_channel',
  'Urgent Notifications',
  importance: Importance.max,
  sound: RawResourceAndroidNotificationSound('urgent_sound'),
);

final promotionsChannel = AndroidNotificationChannel(
  'promotions_channel',
  'Promotions',
  importance: Importance.low,
);
```

### Deep Linking

```dart
FCMService.instance.notificationStream.listen((notification) {
  if (notification.clickAction != null) {
    final uri = Uri.parse(notification.clickAction!);

    switch (uri.scheme) {
      case 'myapp':
        if (uri.host == 'chat') {
          final chatId = uri.queryParameters['id'];
          Navigator.pushNamed(context, '/chat', arguments: chatId);
        }
        break;
    }
  }
});
```

### Notification Grouping (Android)

```dart
// Send from server with same group_key
{
  "notification": {
    "title": "New Message",
    "body": "You have 3 new messages"
  },
  "data": {
    "group_key": "messages"
  }
}
```

## 📱 Platform-Specific Notes

### Android

- **Min SDK**: 21 (Android 5.0)
- **Notification Channels**: Required for Android 8.0+
- **Background Restrictions**: May affect delivery on some devices
- **Battery Optimization**: Users can disable for your app

### iOS

- **Min iOS**: 10.0
- **APNs**: Required for notifications
- **Provisional Authorization**: iOS 12+ can request provisional permission
- **Critical Alerts**: Requires special entitlement from Apple

### Web

- **Limited Support**: No background message handling
- **Service Worker**: Required for web notifications
- **HTTPS**: Required for web notifications
- **Browser Compatibility**: Check browser support

### Desktop (Experimental)

- **macOS**: Limited support via flutter_local_notifications
- **Windows**: Experimental support
- **Linux**: Limited support

## ⚠️ Common Pitfalls

1. **Forgetting Background Handler**
   - Must be top-level function
   - Must be annotated with `@pragma('vm:entry-point')`

2. **iOS Simulator**
   - Notifications don't work reliably on simulator
   - Always test on physical device

3. **Token Not Sent to Server**
   - Token can change
   - Listen to token refresh events
   - Update server when token changes

4. **Permission Not Requested**
   - iOS requires explicit permission request
   - Android 13+ requires runtime permission

5. **Notification Not Showing**
   - Check notification channel (Android)
   - Verify foreground notification settings
   - Check app is not in Do Not Disturb

## 🔗 Related Documentation

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [APNs Overview](https://developer.apple.com/documentation/usernotifications)

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## 🆘 Troubleshooting

See [INTEGRATION_CHECKLIST.md](INTEGRATION_CHECKLIST.md) for step-by-step troubleshooting.

For common issues:
- Check Firebase Console for errors
- Verify app configuration in Firebase
- Test with Firebase Console test messages
- Check device notification settings
- Review platform-specific setup steps
