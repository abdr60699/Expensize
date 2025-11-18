# Setup Guide

Complete setup instructions for Firebase Auth & FCM from scratch.

## Table of Contents

- [Module Structure](#module-structure)
- [Firebase Project Setup](#firebase-project-setup)
- [Platform Configuration](#platform-configuration)
- [Dependencies](#dependencies)
- [Firebase Auth Setup](#firebase-auth-setup)
- [FCM Setup](#fcm-setup)
- [Configuration](#configuration)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## Module Structure

### Directory Organization

This module has **TWO independent sub-modules**:

```
firebaseauth/
│
├── lib/
│   │
│   ├── firebase_auth/                    # 🔐 AUTHENTICATION MODULE
│   │   ├── firebase_auth.dart            # Main export
│   │   │
│   │   ├── services/                     # Core Services
│   │   │   ├── firebase_auth_service.dart
│   │   │   ├── phone_auth_service.dart
│   │   │   └── social_auth/              # Social Sign-In
│   │   │       ├── google_signin_adapter.dart
│   │   │       ├── apple_signin_adapter.dart
│   │   │       └── facebook_signin_adapter.dart
│   │   │
│   │   ├── repository/                   # Firebase Wrapper
│   │   │   └── auth_repository.dart
│   │   │
│   │   ├── providers/                    # State Management
│   │   │   ├── riverpod/
│   │   │   │   └── auth_provider.dart    # For Riverpod apps
│   │   │   └── getit/
│   │   │       └── auth_service_locator.dart  # For GetIt apps
│   │   │
│   │   ├── ui/                           # Pre-built UI
│   │   │   ├── screens/                  # Full Screens
│   │   │   │   ├── sign_in_screen.dart
│   │   │   │   └── phone_signin_screen.dart
│   │   │   └── widgets/                  # Reusable Widgets
│   │   │       ├── auth_text_field.dart
│   │   │       └── social_sign_in_button.dart
│   │   │
│   │   ├── models/                       # Data Models
│   │   │   ├── user_model.dart
│   │   │   └── auth_result.dart
│   │   │
│   │   ├── storage/                      # Token Storage
│   │   │   ├── token_store.dart          # Abstract interface
│   │   │   ├── secure_storage_impl.dart  # Production (Keychain)
│   │   │   └── shared_prefs_impl.dart    # Development
│   │   │
│   │   ├── errors/                       # Error Handling
│   │   │   └── auth_error.dart
│   │   │
│   │   └── utils/                        # Utilities
│   │       ├── validators.dart           # Email/password validation
│   │       └── constants.dart            # Error messages, regex
│   │
│   └── fcm/                              # 📲 PUSH NOTIFICATIONS MODULE
│       ├── fcm_notifications.dart        # Main export
│       └── src/
│           ├── services/
│           │   └── fcm_service.dart      # Core FCM service
│           └── models/
│               ├── push_notification.dart
│               └── fcm_config.dart
│
├── example/
│   └── main.dart                         # Demo app
│
└── pubspec.yaml                          # Dependencies
```

### Key Components Explained

#### **services/** Directory
- **firebase_auth_service.dart**: Email/password, anonymous auth, account linking
- **phone_auth_service.dart**: SMS OTP verification
- **social_auth/**: Adapters for Google, Apple, Facebook (plug-and-play)

#### **providers/** Directory
Choose ONE based on your app's state management:
- **riverpod/**: Use if your app uses Riverpod
- **getit/**: Use if your app uses GetIt/Provider

#### **ui/** Directory
Pre-built components you can use directly:
- **screens/**: Ready-to-use sign-in pages
- **widgets/**: Form fields, buttons (customizable)

#### **storage/** Directory
Token persistence strategies:
- **secure_storage_impl.dart**: Production (uses Keychain/KeyStore)
- **shared_prefs_impl.dart**: Development/testing only

---

## Firebase Project Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name
4. Enable Google Analytics (optional)
5. Click "Create project"

---

### 2. Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable sign-in methods:
   - ✅ Email/Password
   - ✅ Phone (optional)
   - ✅ Google (optional)
   - ✅ Apple (iOS only, optional)
   - ✅ Facebook (optional)
   - ✅ Anonymous (optional)

---

### 3. Enable Cloud Messaging (for FCM)

1. In Firebase Console, go to **Cloud Messaging**
2. Note your **Server Key** (for backend)
3. For iOS:
   - Upload APNs certificate or key
   - Enable "Cloud Messaging API"

---

### 4. Add Apps to Firebase

#### Android

1. Click "Add app" → Android
2. Enter package name (e.g., `com.yourapp.name`)
3. Download `google-services.json`
4. Place in `android/app/`

#### iOS

1. Click "Add app" → iOS
2. Enter bundle ID (e.g., `com.yourapp.name`)
3. Download `GoogleService-Info.plist`
4. Add to Xcode project (Runner → Runner folder)

---

## Platform Configuration

### Android Setup

#### 1. Add google-services.json

Place downloaded file:
```
android/
  app/
    google-services.json  ← Here
```

#### 2. Update build.gradle Files

**android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

**android/app/build.gradle:**
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'  // Add this
}

android {
    defaultConfig {
        minSdkVersion 21  // Minimum for FCM
    }
}
```

#### 3. AndroidManifest.xml

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />

    <application>
        <!-- ... existing config ... -->

        <!-- FCM Service (for background notifications) -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Notification icon metadata -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />

        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />

        <!-- Notification channel (optional) -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="default_channel" />
    </application>
</manifest>
```

#### 4. Add Notification Icon

Create `android/app/src/main/res/drawable/ic_notification.xml`:
```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path
        android:fillColor="@android:color/white"
        android:pathData="M12,22c1.1,0 2,-0.9 2,-2h-4c0,1.1 0.89,2 2,2zM18,16v-5c0,-3.07 -1.64,-5.64 -4.5,-6.32V4c0,-0.83 -0.67,-1.5 -1.5,-1.5s-1.5,0.67 -1.5,1.5v0.68C7.63,5.36 6,7.92 6,11v5l-2,2v1h16v-1l-2,-2z"/>
</vector>
```

Create `android/app/src/main/res/values/colors.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#FF5722</color>
</resources>
```

---

### iOS Setup

#### 1. Add GoogleService-Info.plist

1. Open Xcode
2. Right-click "Runner" folder
3. "Add Files to Runner..."
4. Select `GoogleService-Info.plist`
5. ✅ Check "Copy items if needed"
6. ✅ Select "Runner" target

#### 2. Update Info.plist

**ios/Runner/Info.plist:**
```xml
<dict>
    <!-- Existing keys... -->

    <!-- URL Schemes for Google Sign-In -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- Get this from GoogleService-Info.plist REVERSED_CLIENT_ID -->
                <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
            </array>
        </dict>
    </array>

    <!-- Google Sign-In -->
    <key>GIDClientID</key>
    <string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>

    <!-- Push Notifications -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>

    <!-- Face ID (optional) -->
    <key>NSFaceIDUsageDescription</key>
    <string>We use Face ID to secure your account</string>
</dict>
```

#### 3. Enable Push Notifications Capability

1. Open Xcode
2. Select "Runner" project
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" → Enable "Remote notifications"

#### 4. Upload APNs Certificate/Key

**Option A: APNs Key (Recommended)**
1. Go to [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
2. Create new key with "Apple Push Notifications service"
3. Download .p8 key file
4. In Firebase Console → Project Settings → Cloud Messaging
5. Upload APNs key with Team ID and Key ID

**Option B: APNs Certificate**
1. Generate CSR in Keychain Access
2. Create certificate in Apple Developer
3. Download and install certificate
4. Export .p12 from Keychain
5. Upload to Firebase Console

---

## Dependencies

### pubspec.yaml

The module's `pubspec.yaml` already includes:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase Core
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4

  # FCM
  firebase_messaging: ^15.2.1
  flutter_local_notifications: ^18.0.1

  # Social Sign-In
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.5
  flutter_facebook_auth: ^7.1.1

  # Storage
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.3

  # State Management (optional)
  flutter_riverpod: ^2.6.1
  get_it: ^8.0.3
```

### Install Dependencies

```bash
cd feature_test/firebaseauth
flutter pub get
```

---

## Firebase Auth Setup

### 1. Initialize Firebase

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
```

### 2. Generate firebase_options.dart

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate configuration
flutterfire configure
```

This creates `lib/firebase_options.dart` automatically.

---

### 3. Configure Auth Service

```dart
// lib/services/auth_service.dart
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

class AuthService {
  final _authService = FirebaseAuthService();
  final _tokenStore = SecureStorageTokenStore();

  // Email & Password
  Future<AuthResult> signUp(String email, String password) async {
    return await _authService.signUpWithEmail(
      email: email,
      password: password,
    );
  }

  Future<AuthResult> signIn(String email, String password) async {
    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
      final token = await _authService.getIdToken();
      if (token != null) {
        await _tokenStore.saveToken(token);
      }
    }

    return result;
  }

  // Social Sign-In
  Future<AuthResult> signInWithGoogle() async {
    return await GoogleSignInAdapter().signIn();
  }

  // Auth State
  Stream<UserModel?> get authStateChanges =>
      _authService.authStateChanges;

  Future<void> signOut() async {
    await _authService.signOut();
    await _tokenStore.deleteToken();
  }
}
```

---

## FCM Setup

### 1. Initialize FCM Service

```dart
// lib/main.dart
import 'package:firebaseauth/fcm/fcm_notifications.dart';

late FCMService fcmService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM
  fcmService = await FCMService.initialize(
    FCMConfig(
      androidChannelId: 'default_channel',
      androidChannelName: 'Default Notifications',
      androidChannelDescription: 'General app notifications',
      androidImportance: AndroidImportance.high,
      showForegroundNotifications: true,
      requestPermissionOnInit: true,
      enableAlert: true,
      enableBadge: true,
      enableSound: true,
    ),
  );

  runApp(MyApp());
}
```

---

### 2. Setup Notification Listeners

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFCMListeners();
  }

  void _setupFCMListeners() {
    // Listen to notifications
    fcmService.notificationStream.listen((notification) {
      print('📬 Notification: ${notification.title}');
      print('   Body: ${notification.body}');
      print('   Data: ${notification.data}');

      // Handle notification routing
      _handleNotificationTap(notification);
    });

    // Listen to token updates
    fcmService.tokenStream.listen((token) {
      print('🔑 FCM Token: $token');
      _sendTokenToBackend(token);
    });
  }

  void _handleNotificationTap(PushNotification notification) {
    // Route based on notification data
    if (notification.data.containsKey('route')) {
      // Navigate to specific screen
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    // Send token to your backend for targeted notifications
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}
```

---

### 3. Background Message Handler (Optional)

For processing notifications when app is terminated:

```dart
// lib/main.dart
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Background message: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  fcmService = await FCMService.initialize(FCMConfig(...));

  runApp(MyApp());
}
```

---

## Configuration

### AppLockConfig Options

```dart
final config = FCMConfig(
  // Android Configuration
  androidChannelId: 'high_priority',           // Notification channel ID
  androidChannelName: 'Important Notifications', // User-visible name
  androidChannelDescription: 'Critical updates',  // User-visible description
  androidImportance: AndroidImportance.high,    // Notification importance
  androidSound: 'notification_sound',           // Custom sound (res/raw/)
  androidNotificationIcon: '@drawable/ic_notification', // Icon
  androidNotificationColor: '#FF5722',          // Icon tint color

  // iOS Configuration
  enableAlert: true,                            // Show alert
  enableBadge: true,                            // Update badge
  enableSound: true,                            // Play sound
  requestPermissionOnInit: true,                // Auto-request permission

  // General
  showForegroundNotifications: true,            // Show when app is open
);
```

---

## Testing

### Test Email Authentication

```dart
void testEmailAuth() async {
  final authService = FirebaseAuthService();

  // 1. Sign up
  final signUpResult = await authService.signUpWithEmail(
    email: 'test@example.com',
    password: 'Test123!',
  );

  print('Sign up: ${signUpResult.success}');
  print('User: ${signUpResult.user?.email}');

  // 2. Sign in
  final signInResult = await authService.signInWithEmail(
    email: 'test@example.com',
    password: 'Test123!',
  );

  print('Sign in: ${signInResult.success}');

  // 3. Get token
  final token = await authService.getIdToken();
  print('Token: $token');

  // 4. Sign out
  await authService.signOut();
}
```

---

### Test FCM Notifications

#### From Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Click "Send test message"
5. Enter FCM token (get from `fcmService.getToken()`)
6. Click "Test"

#### Verify in Logs

```dart
void testFCM() async {
  // Get token
  final token = await fcmService.getToken();
  print('🔑 FCM Token: $token');

  // Listen to notifications
  fcmService.notificationStream.listen((notification) {
    print('✅ Received: ${notification.title}');
  });

  // Test topic subscription
  await fcmService.subscribeToTopic('test_topic');
  print('📮 Subscribed to test_topic');

  // Send notification from Firebase Console to 'test_topic'
}
```

---

### Test Social Sign-In

#### Google Sign-In

1. Enable in Firebase Console
2. Add SHA-1 fingerprint (Android)
3. Test:
```dart
final result = await GoogleSignInAdapter().signIn();
print('Google sign-in: ${result.success}');
```

#### Apple Sign-In (iOS only)

1. Enable in Firebase Console
2. Configure Apple Services ID
3. Test:
```dart
final result = await AppleSignInAdapter().signIn();
print('Apple sign-in: ${result.success}');
```

---

## Troubleshooting

### Firebase Auth Issues

#### ❌ "No user found for that email"

**Cause:** User doesn't exist
**Fix:** Use `signUpWithEmail` first, or handle error in UI

---

#### ❌ "The password is invalid"

**Cause:** Wrong password
**Fix:** Implement password reset flow:
```dart
await authService.sendPasswordResetEmail('user@example.com');
```

---

#### ❌ "The email address is badly formatted"

**Cause:** Invalid email format
**Fix:** Use built-in validator:
```dart
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

final error = Validators.validateEmail(email);
if (error != null) {
  print('Invalid email: $error');
}
```

---

#### ❌ "An account already exists with a different credential"

**Cause:** Email already linked to another provider
**Fix:** Implement account linking:
```dart
// Get providers for email
final providers = await authService.fetchSignInMethodsForEmail(email);

// Sign in with existing provider first
// Then link new credential
final credential = ... // Get credential from new provider
await authService.linkWithCredential(credential);
```

---

#### ❌ "We have blocked all requests from this device"

**Cause:** Too many failed sign-in attempts
**Fix:** Wait or enable Firebase App Check

---

### FCM Issues

#### ❌ "Notifications not received on iOS"

**Possible causes:**
1. APNs certificate not uploaded
2. Missing capabilities in Xcode
3. Permission not granted

**Fix:**
```dart
// Check permission
final settings = await fcmService.requestPermission();
print('Permission: ${settings.authorizationStatus}');

// Verify token
final token = await fcmService.getToken();
print('FCM Token: $token');
```

---

#### ❌ "Notifications not shown in foreground (Android)"

**Cause:** `showForegroundNotifications` is false
**Fix:**
```dart
final config = FCMConfig(
  showForegroundNotifications: true,  // Enable this
);
```

---

#### ❌ "Custom notification sound not playing (Android)"

**Cause:** Sound file not in `res/raw/`
**Fix:**
1. Add `notification_sound.mp3` to `android/app/src/main/res/raw/`
2. Reference without extension:
```dart
final config = FCMConfig(
  androidSound: 'notification_sound',  // No .mp3
);
```

---

#### ❌ "Notification icon is white square (Android)"

**Cause:** Icon not transparent or wrong format
**Fix:**
1. Use vector drawable (XML)
2. Make background transparent
3. Use white foreground color
4. Place in `res/drawable/ic_notification.xml`

---

#### ❌ "Token null on iOS simulator"

**Cause:** iOS simulator doesn't support APNs
**Fix:** Test on real device

---

### Google Sign-In Issues

#### ❌ "Sign in failed" (Android)

**Cause:** Missing SHA-1 fingerprint
**Fix:**
```bash
# Get SHA-1
cd android
./gradlew signingReport

# Add to Firebase Console → Project Settings → Your apps → SHA fingerprints
```

---

#### ❌ "DEVELOPER_ERROR" (Android)

**Cause:** Wrong `google-services.json`
**Fix:**
1. Download correct file from Firebase Console
2. Replace `android/app/google-services.json`
3. Rebuild: `flutter clean && flutter build`

---

#### ❌ "The given clientID is invalid" (iOS)

**Cause:** Wrong `GIDClientID` in Info.plist
**Fix:**
1. Open `GoogleService-Info.plist`
2. Copy `CLIENT_ID` value
3. Update `Info.plist`:
```xml
<key>GIDClientID</key>
<string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>
```

---

### Build Issues

#### ❌ "Duplicate class found" (Android)

**Cause:** Conflicting Firebase dependencies
**Fix:**
```gradle
// android/app/build.gradle
dependencies {
    // Remove duplicate Firebase dependencies
    // Keep only what's needed
}
```

---

#### ❌ "Could not find firebase_options.dart"

**Cause:** FlutterFire not configured
**Fix:**
```bash
flutterfire configure
```

---

#### ❌ "MissingPluginException"

**Cause:** Hot reload after adding plugin
**Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

---

### Token Storage Issues

#### ❌ "PlatformException: read_failed" (iOS)

**Cause:** Keychain access error
**Fix:**
1. Add Keychain Sharing capability in Xcode
2. Or use SharedPreferences for development:
```dart
final tokenStore = SharedPrefsTokenStore();  // For development only
```

---

## Environment-Specific Setup

### Development

```dart
final authService = FirebaseAuthService();
final tokenStore = SharedPrefsTokenStore();  // Easier debugging
```

### Production

```dart
final authService = FirebaseAuthService();
final tokenStore = SecureStorageTokenStore();  // Secure storage
```

---

## Setup Checklist

### Firebase Auth
- [ ] Create Firebase project
- [ ] Enable authentication methods
- [ ] Add Android app (google-services.json)
- [ ] Add iOS app (GoogleService-Info.plist)
- [ ] Configure Android build.gradle
- [ ] Configure iOS Info.plist
- [ ] Generate firebase_options.dart
- [ ] Initialize Firebase in main.dart
- [ ] Test email sign-up
- [ ] Test email sign-in
- [ ] Test token retrieval
- [ ] Setup token storage

### FCM
- [ ] Enable Cloud Messaging
- [ ] Upload APNs certificate/key (iOS)
- [ ] Add notification icon (Android)
- [ ] Configure AndroidManifest.xml
- [ ] Enable push notifications capability (iOS)
- [ ] Initialize FCM service
- [ ] Setup notification listeners
- [ ] Test foreground notification
- [ ] Test background notification
- [ ] Test topic subscription
- [ ] Send test notification from Firebase Console

### Social Sign-In (Optional)
- [ ] Enable Google Sign-In in Firebase
- [ ] Add SHA-1 fingerprint (Android)
- [ ] Configure URL schemes (iOS)
- [ ] Test Google sign-in
- [ ] Enable Apple Sign-In (iOS)
- [ ] Configure Services ID
- [ ] Test Apple sign-in
- [ ] Enable Facebook Login
- [ ] Configure Facebook App ID
- [ ] Test Facebook sign-in

---

**Setup complete! Ready to authenticate users and send push notifications.**
