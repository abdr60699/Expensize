# Firebase Auth Module - Testing Guide

## Overview

This is a production-ready Firebase Authentication module for Flutter with comprehensive features including email/password auth, social sign-in, phone verification, and Firebase Cloud Messaging (FCM).

## Features Implemented

- ✅ **Email/Password Auth** - Sign up, sign in, password reset, email verification
- ✅ **Social Sign-In** - Google, Facebook, Apple authentication
- ✅ **Phone OTP** - Phone number verification with SMS OTP
- ✅ **Anonymous Auth** - Guest user support
- ✅ **Account Linking** - Link/unlink multiple auth providers
- ✅ **Secure Storage** - Token storage using flutter_secure_storage
- ✅ **FCM Integration** - Firebase Cloud Messaging for push notifications
- ✅ **Riverpod Support** - State management with Riverpod 3.0
- ✅ **GetIt Support** - Dependency injection alternative
- ✅ **UI Kit** - Pre-built sign-in screens and widgets

## Dependencies (Latest Versions)

```yaml
dependencies:
  # Firebase
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  firebase_messaging: ^16.0.4

  # Social Auth
  google_sign_in: ^7.2.0
  flutter_facebook_auth: ^7.1.2
  sign_in_with_apple: ^7.0.1

  # Storage
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.3

  # State Management
  flutter_riverpod: ^3.0.3
  get_it: ^9.0.5

  # Notifications
  flutter_local_notifications: ^19.5.0
```

## Firebase Project Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name (e.g., "expensize-test")
4. Enable/disable Google Analytics (optional)
5. Click "Create project"

### Step 2: Add Firebase to Your Flutter App

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Navigate to your project
cd C:\Abdul\StudioProjects\expensize\feature_test\firebaseauth

# Configure Firebase
flutterfire configure

# Follow the prompts:
# - Select your Firebase project
# - Select platforms (Android, iOS, Web, macOS)
# - This will generate firebase_options.dart automatically
```

#### Option B: Manual Setup

**Android:**
1. In Firebase Console, click "Android" icon
2. Enter Android package name: `com.example.firebaseauth`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`
5. Update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```
6. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 23  // Firebase Auth requires min SDK 23
    }
}
```

**iOS:**
1. In Firebase Console, click "iOS" icon
2. Enter iOS bundle ID: `com.example.firebaseauth`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Runner folder
6. Ensure it's added to target

**Web:**
1. In Firebase Console, click "Web" icon
2. Register web app
3. Copy configuration
4. Update `web/index.html` with Firebase config

### Step 3: Enable Authentication Methods

In Firebase Console > Authentication > Sign-in method:

1. **Email/Password**
   - Click "Email/Password"
   - Toggle "Enable"
   - Click "Save"

2. **Google**
   - Click "Google"
   - Toggle "Enable"
   - Enter project support email
   - Click "Save"

3. **Facebook**
   - Create Facebook App at [Facebook Developers](https://developers.facebook.com/)
   - Get App ID and App Secret
   - In Firebase Console, click "Facebook"
   - Toggle "Enable"
   - Enter App ID and App Secret
   - Click "Save"
   - Configure OAuth redirect URI in Facebook app

4. **Apple**
   - Click "Apple"
   - Toggle "Enable"
   - Configure Service IDs in Apple Developer Console
   - Click "Save"

5. **Phone**
   - Click "Phone"
   - Toggle "Enable"
   - Configure reCAPTCHA (for web)
   - Click "Save"

6. **Anonymous**
   - Click "Anonymous"
   - Toggle "Enable"
   - Click "Save"

## Platform-Specific Configuration

### Android Configuration

**1. Update `android/app/build.gradle`:**
```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 23
        targetSdkVersion 34
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

**2. For Google Sign-In, get SHA-1 certificate:**
```bash
cd android
./gradlew signingReport
```
Copy SHA-1 and add to Firebase Console > Project Settings > Your apps > Android app

**3. For Facebook Auth, update `android/app/src/main/res/values/strings.xml`:**
```xml
<resources>
    <string name="app_name">Firebase Auth</string>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
    <string name="facebook_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
</resources>
```

**4. Update `android/app/src/main/AndroidManifest.xml`:**
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- Facebook -->
        <meta-data
            android:name="com.facebook.sdk.ApplicationId"
            android:value="@string/facebook_app_id"/>
        <meta-data
            android:name="com.facebook.sdk.ClientToken"
            android:value="@string/facebook_client_token"/>
    </application>
</manifest>
```

### iOS Configuration

**1. Update `ios/Runner/Info.plist`:**
```xml
<dict>
    <!-- Google Sign-In -->
    <key>GIDClientID</key>
    <string>YOUR_IOS_CLIENT_ID</string>

    <!-- URL Schemes -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>fbYOUR_FACEBOOK_APP_ID</string>
            </array>
        </dict>
    </array>

    <!-- Facebook -->
    <key>FacebookAppID</key>
    <string>YOUR_FACEBOOK_APP_ID</string>
    <key>FacebookClientToken</key>
    <string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
    <key>FacebookDisplayName</key>
    <string>Firebase Auth</string>

    <!-- Apple Sign In -->
    <key>Sign in with Apple</key>
    <string>Enable Apple Sign In</string>
</dict>
```

**2. Enable capabilities in Xcode:**
- Open `ios/Runner.xcworkspace`
- Select Runner > Signing & Capabilities
- Add "Sign in with Apple" capability

**3. Update minimum iOS version in `ios/Podfile`:**
```ruby
platform :ios, '13.0'
```

## Installation & Running

### 1. Install Dependencies

```bash
cd C:\Abdul\StudioProjects\expensize\feature_test\firebaseauth
flutter pub get
```

### 2. Run the App

```bash
# For Android
flutter run

# For iOS (requires Mac)
flutter run

# For Web
flutter run -d chrome

# List available devices
flutter devices
```

## Testing Checklist

### ✅ Email/Password Authentication
- [ ] Sign up with email and password
- [ ] Validation for invalid emails
- [ ] Validation for weak passwords
- [ ] Sign in with email/password
- [ ] Error handling for wrong credentials
- [ ] Send password reset email
- [ ] Send email verification
- [ ] Email verified status updates

### ✅ Google Sign-In
- [ ] Google Sign-In button appears
- [ ] Opens Google account picker
- [ ] Signs in successfully
- [ ] User data populated (email, name, photo)
- [ ] Can sign out and sign in again

### ✅ Facebook Sign-In
- [ ] Facebook Sign-In button appears
- [ ] Opens Facebook login
- [ ] Signs in successfully
- [ ] User data populated
- [ ] Can sign out and sign in again

### ✅ Apple Sign-In (iOS/macOS only)
- [ ] Apple Sign-In button appears
- [ ] Opens Apple ID prompt
- [ ] Signs in successfully
- [ ] User data populated
- [ ] Can sign out and sign in again

### ✅ Phone Authentication
- [ ] Enter phone number
- [ ] Receives SMS OTP
- [ ] Verify OTP code
- [ ] Signs in successfully
- [ ] Error handling for invalid OTP

### ✅ Anonymous Authentication
- [ ] Can sign in anonymously
- [ ] Anonymous user ID generated
- [ ] Can later link with email/social

### ✅ Account Linking
- [ ] Link Google to existing account
- [ ] Link Facebook to existing account
- [ ] Link Apple to existing account
- [ ] Unlink provider (when >1 provider)
- [ ] Cannot unlink last provider
- [ ] Error handling for account conflicts

### ✅ Session Management
- [ ] User persists after app restart
- [ ] Sign out works correctly
- [ ] Token refresh works
- [ ] Auth state stream updates

### ✅ Firebase Cloud Messaging (FCM)
- [ ] FCM token generated
- [ ] Foreground notification handling
- [ ] Background notification handling
- [ ] Notification taps navigate correctly

## Manual Test Scenarios

### Scenario 1: Email Sign-Up Flow
1. Launch app
2. Tap "Sign up with Email"
3. Enter email: `test@example.com`
4. Enter password: `Test123!`
5. Tap "Sign Up"
6. Should navigate to home screen
7. Check email for verification

### Scenario 2: Google Sign-In
1. Launch app
2. Tap "Sign in with Google"
3. Select Google account
4. Grant permissions
5. Should navigate to home screen
6. Verify user data displayed

### Scenario 3: Account Linking
1. Sign in with email
2. Navigate to "Manage Linked Accounts"
3. Tap "Link" on Google
4. Complete Google OAuth
5. Should show "Google linked!"
6. Verify Google appears as linked

### Scenario 4: Phone Verification
1. Tap "Sign in with Phone"
2. Enter phone number with country code
3. Tap "Send Code"
4. Enter OTP received via SMS
5. Tap "Verify"
6. Should navigate to home screen

### Scenario 5: Password Reset
1. On sign-in screen, tap "Forgot Password?"
2. Enter email address
3. Tap "Send Reset Link"
4. Check email for reset link
5. Click link and set new password
6. Sign in with new password

## Troubleshooting

### Issue: "Firebase not configured" error
**Solution**:
- Run `flutterfire configure`
- Or manually add `google-services.json` and `GoogleService-Info.plist`
- Ensure `firebase_options.dart` exists

### Issue: Google Sign-In not working (Android)
**Solution**:
- Add SHA-1 certificate to Firebase Console
- Run `cd android && ./gradlew signingReport`
- Add all SHA-1 fingerprints to Firebase

### Issue: Facebook Login fails
**Solution**:
- Verify App ID and App Secret are correct
- Add OAuth redirect URI to Facebook app
- Check Facebook app is in live mode
- Ensure package name matches

### Issue: Apple Sign-In not available (iOS)
**Solution**:
- Enable "Sign in with Apple" capability in Xcode
- Verify bundle ID matches
- Ensure iOS 13+ deployment target
- Check Apple Developer account setup

### Issue: Phone Auth not working
**Solution**:
- Verify phone number format (+countrycode...)
- Check Firebase Console > Authentication > Sign-in > Phone is enabled
- For web, configure reCAPTCHA
- Check SMS quota in Firebase

### Issue: FCM notifications not received
**Solution**:
- Verify FCM is enabled in Firebase Console
- Check notification permissions granted
- For iOS, configure APNs certificates
- For Android, verify google-services.json
- Test with Firebase Console > Cloud Messaging > Send test message

## Architecture Overview

```
lib/
├── firebase_auth/
│   ├── firebase_auth.dart           # Main export file
│   ├── services/
│   │   ├── auth_service.dart        # Main auth service
│   │   ├── phone_auth_service.dart  # Phone OTP
│   │   └── social_auth/
│   │       ├── google_signin_adapter.dart
│   │       ├── facebook_signin_adapter.dart
│   │       └── apple_signin_adapter.dart
│   ├── repository/
│   │   └── auth_repository.dart     # Firebase Auth wrapper
│   ├── models/
│   │   ├── user_model.dart
│   │   └── auth_result.dart
│   ├── providers/
│   │   ├── auth_providers.dart      # Riverpod providers
│   │   └── getit_registration.dart  # GetIt DI
│   ├── storage/
│   │   ├── secure_storage_token_store.dart
│   │   └── shared_prefs_session_store.dart
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── sign_in_screen.dart
│   │   │   └── phone_signin_screen.dart
│   │   └── widgets/
│   │       ├── social_signin_buttons.dart
│   │       └── auth_text_field.dart
│   └── errors/
│       └── auth_error.dart
├── fcm/
│   ├── fcm_notifications.dart       # Main FCM export
│   └── src/
│       ├── services/fcm_service.dart
│       └── models/
│           ├── push_notification.dart
│           └── fcm_config.dart
└── main.dart
```

## Integration into Main App

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      home: authState.when(
        data: (user) => user != null ? HomeScreen() : SignInScreen(),
        loading: () => LoadingScreen(),
        error: (e, s) => ErrorScreen(error: e),
      ),
    );
  }
}
```

## Code Quality

### Run Tests
```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

### Run Analysis
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Security Considerations

### ✅ Implemented Security Features
- Secure token storage using flutter_secure_storage
- Platform-specific encryption (Keychain/KeyStore)
- Automatic token refresh
- Proper error handling
- Input validation
- OAuth 2.0 flows
- Firebase Security Rules (configure in Firebase Console)

### ⚠️ Important Security Notes
- Never commit `google-services.json` or `GoogleService-Info.plist` to public repos
- Use environment variables for sensitive config in CI/CD
- Configure Firebase Security Rules for Firestore/Storage
- Enable App Check for additional security
- Implement rate limiting for authentication
- Monitor authentication logs in Firebase Console

## Next Steps

1. **Run the app** on your local machine with Flutter
2. **Set up Firebase project** following steps above
3. **Test all auth methods** using the checklist
4. **Configure FCM** for push notifications
5. **Integrate** into main Expensize app
6. **Configure** Firebase Security Rules
7. **Test** on multiple devices and platforms

## Support Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Package Documentation](lib/firebase_auth/README.md)
- [FCM Documentation](lib/fcm/README.md)

---

**Status**: ✅ Ready for testing (requires Firebase project setup)
**Last Updated**: November 16, 2025
**Flutter SDK**: 3.4.1+
**Firebase**: Latest versions
