# Setup Guide

Complete setup instructions for social authentication from scratch.

## Table of Contents

- [Module Structure](#module-structure)
- [Dependencies](#dependencies)
- [Provider Setup](#provider-setup)
- [Platform Configuration](#platform-configuration)
- [Module Initialization](#module-initialization)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Production Checklist](#production-checklist)

---

## Module Structure

### Directory Organization

```
lib/social_auth/
├── social_auth.dart              # Main facade
├── social_auth_exports.dart      # All exports
│
└── src/
    ├── adapters/                 # 🔌 Provider Adapters
    │   ├── base_auth_adapter.dart        # Abstract interface
    │   ├── google_auth_adapter.dart      # Google implementation
    │   ├── apple_auth_adapter.dart       # Apple implementation
    │   └── facebook_auth_adapter.dart    # Facebook implementation
    │
    ├── core/                     # 🔧 Core Types
    │   ├── social_provider.dart          # Provider enum
    │   ├── auth_result.dart              # Result model
    │   ├── social_auth_error.dart        # Error types
    │   ├── auth_service.dart             # Backend interface
    │   ├── token_storage.dart            # Storage interface
    │   └── logger.dart                   # Logging interface
    │
    ├── services/                 # 🔐 Backend Services
    │   ├── social_auth_manager.dart      # Main manager
    │   ├── firebase_auth_service.dart    # Firebase integration
    │   └── rest_api_auth_service.dart    # REST API integration
    │
    └── widgets/                  # 🎨 UI Components
        ├── social_sign_in_button.dart    # Single button
        └── social_sign_in_row.dart       # Button row
```

---

## Dependencies

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Social Authentication
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.5
  flutter_facebook_auth: ^7.1.1

  # Security
  flutter_secure_storage: ^9.2.4

  # Optional - Firebase Integration
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4

  # Optional - REST API
  http: ^1.2.2
```

### Install

```bash
flutter pub get
```

---

## Provider Setup

### Google Sign-In Setup

#### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable Google+ API

#### 2. Configure OAuth Consent Screen

1. Go to APIs & Services → OAuth consent screen
2. Choose User Type (External for public apps)
3. Fill in app information:
   - App name
   - User support email
   - Developer contact
4. Add scopes (email, profile)
5. Save

#### 3. Create OAuth Credentials

**For Android:**

1. APIs & Services → Credentials → Create Credentials → OAuth client ID
2. Select "Android"
3. Get SHA-1 fingerprint:

```bash
cd android
./gradlew signingReport
```

Copy SHA-1 from debug or release variant.

4. Enter package name (from AndroidManifest.xml)
5. Paste SHA-1 fingerprint
6. Create

**For iOS:**

1. Create Credentials → OAuth client ID
2. Select "iOS"
3. Enter Bundle ID (from Xcode)
4. Create
5. Download `GoogleService-Info.plist`

**For Web:**

1. Create Credentials → OAuth client ID
2. Select "Web application"
3. Add authorized origins and redirect URIs
4. Create

---

### Apple Sign-In Setup

#### 1. Apple Developer Account

Requirements:
- Apple Developer Program membership ($99/year)
- App ID configured

#### 2. Enable Sign in with Apple

1. Go to [Apple Developer](https://developer.apple.com/)
2. Certificates, IDs & Profiles → Identifiers
3. Select your App ID
4. Enable "Sign in with Apple"
5. Save

#### 3. Configure Services ID (for Web/Android)

1. Create new Identifier → Services IDs
2. Enter identifier and description
3. Enable "Sign in with Apple"
4. Configure:
   - Domains: yourapp.com
   - Return URLs: https://yourapp.com/auth/callback
5. Save

#### 4. Create Key (Optional, for backend)

1. Certificates, IDs & Profiles → Keys
2. Create new key
3. Enable "Sign in with Apple"
4. Download .p8 key file (save securely!)

---

### Facebook Login Setup

#### 1. Create Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. My Apps → Create App
3. Choose app type (Consumer)
4. Enter display name
5. Create App ID

#### 2. Configure Facebook Login

1. Dashboard → Add Product → Facebook Login → Set Up
2. Choose platform (iOS/Android/Web)
3. Follow platform-specific instructions

#### 3. Get App ID and Client Token

1. Settings → Basic
2. Copy:
   - App ID
   - Client Token (show and copy)

#### 4. Configure Platform Settings

**iOS:**
- Settings → Basic → Add Platform → iOS
- Enter Bundle ID
- Enable Single Sign On

**Android:**
- Settings → Basic → Add Platform → Android
- Enter package name
- Enter class name (MainActivity)
- Add key hashes:

```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

Password: `android`

---

## Platform Configuration

### iOS Configuration

#### 1. Google Sign-In

**Info.plist** (`ios/Runner/Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Get from GoogleService-Info.plist: REVERSED_CLIENT_ID -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>

<key>GIDClientID</key>
<!-- Get from GoogleService-Info.plist: CLIENT_ID -->
<string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>
```

#### 2. Apple Sign-In

**Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Select Runner target
3. Signing & Capabilities → + Capability
4. Add "Sign in with Apple"

**Info.plist:**

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    </array>
  </dict>
</array>
```

#### 3. Facebook Login

**Info.plist:**

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR-APP-ID</string>
    </array>
  </dict>
</array>

<key>FacebookAppID</key>
<string>YOUR-APP-ID</string>
<key>FacebookDisplayName</key>
<string>Your App Name</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
</array>
```

---

### Android Configuration

#### 1. Google Sign-In

**android/app/build.gradle:**

```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

**Add SHA-1 to Firebase Console:**

```bash
cd android
./gradlew signingReport
```

Copy SHA-1 and add to Firebase Console → Project Settings → Your apps → SHA certificate fingerprints

#### 2. Apple Sign-In

No additional setup (uses web flow)

#### 3. Facebook Login

**android/app/src/main/res/values/strings.xml:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Your App</string>
    <string name="facebook_app_id">YOUR-APP-ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR-APP-ID</string>
    <string name="facebook_client_token">YOUR-CLIENT-TOKEN</string>
</resources>
```

**AndroidManifest.xml:**

```xml
<application>
    <!-- Other elements -->

    <meta-data
        android:name="com.facebook.sdk.ApplicationId"
        android:value="@string/facebook_app_id"/>

    <meta-data
        android:name="com.facebook.sdk.ClientToken"
        android:value="@string/facebook_client_token"/>

    <activity
        android:name="com.facebook.FacebookActivity"
        android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
        android:label="@string/app_name" />

    <activity
        android:name="com.facebook.CustomTabActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="@string/fb_login_protocol_scheme" />
        </intent-filter>
    </activity>
</application>
```

---

## Module Initialization

### Basic Initialization

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'social_auth/social_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final socialAuth = SocialAuth(
    tokenStorage: SecureTokenStorage(),
    logger: ConsoleLogger(),
    enableGoogle: true,
    enableApple: true,
    enableFacebook: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(socialAuth: socialAuth),
    );
  }
}
```

### With Firebase

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final socialAuth = SocialAuth(
    authService: FirebaseAuthService(),
    tokenStorage: SecureTokenStorage(),
    logger: ConsoleLogger(),
  );

  // ...
}
```

---

## Testing

### Test Google Sign-In

```dart
Future<void> testGoogle() async {
  print('=== Testing Google Sign-In ===');

  final socialAuth = SocialAuth(
    tokenStorage: SecureTokenStorage(),
    enableGoogle: true,
  );

  final result = await socialAuth.signInWithGoogle();

  if (result.isSuccess) {
    print('✅ Sign-in successful');
    print('   Email: ${result.user.email}');
    print('   Name: ${result.user.displayName}');
  } else {
    print('❌ Sign-in failed: ${result.error?.message}');
  }
}
```

### Test Apple Sign-In

```dart
Future<void> testApple() async {
  print('=== Testing Apple Sign-In ===');

  // Check availability
  final available = await AppleAuthAdapter.isAvailable();
  print('Apple Sign-In available: $available');

  if (!available) {
    print('⚠️  Apple Sign-In not available on this platform');
    return;
  }

  final socialAuth = SocialAuth(
    tokenStorage: SecureTokenStorage(),
    enableApple: true,
  );

  final result = await socialAuth.signInWithApple();

  if (result.isSuccess) {
    print('✅ Sign-in successful');
    print('   Email: ${result.user.email}');
    print('   Name: ${result.user.displayName}');
  } else {
    print('❌ Sign-in failed: ${result.error?.message}');
  }
}
```

### Test Facebook Login

```dart
Future<void> testFacebook() async {
  print('=== Testing Facebook Login ===');

  final socialAuth = SocialAuth(
    tokenStorage: SecureTokenStorage(),
    enableFacebook: true,
  );

  final result = await socialAuth.signInWithFacebook(
    permissions: ['email', 'public_profile'],
  );

  if (result.isSuccess) {
    print('✅ Sign-in successful');
    print('   Email: ${result.user.email}');
    print('   Name: ${result.user.displayName}');
  } else {
    print('❌ Sign-in failed: ${result.error?.message}');
  }
}
```

---

## Troubleshooting

### Google Sign-In Issues

#### ❌ "Sign in failed" (Android)

**Cause:** SHA-1 fingerprint not added or incorrect.

**Fix:**
```bash
cd android
./gradlew signingReport
```

Add SHA-1 to Firebase Console → Project Settings

---

#### ❌ "DEVELOPER_ERROR" (Android)

**Cause:** Wrong package name or SHA-1.

**Fix:**
1. Verify package name matches
2. Verify SHA-1 is correct
3. Download new `google-services.json`
4. Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

---

#### ❌ "The given clientID is invalid" (iOS)

**Cause:** Wrong CLIENT_ID in Info.plist.

**Fix:**
1. Open `GoogleService-Info.plist`
2. Copy `CLIENT_ID` value
3. Update `Info.plist`:

```xml
<key>GIDClientID</key>
<string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>
```

---

### Apple Sign-In Issues

#### ❌ "Apple Sign-In not available"

**Cause:** Not available on Android < 13 or unsupported platform.

**Fix:**
Check availability:
```dart
if (await AppleAuthAdapter.isAvailable()) {
  // Show Apple Sign-In button
} else {
  // Hide Apple Sign-In button
}
```

---

#### ❌ "Sign in with Apple failed" (iOS)

**Cause:** Capability not enabled in Xcode.

**Fix:**
1. Open `ios/Runner.xcworkspace`
2. Runner target → Signing & Capabilities
3. Add "Sign in with Apple" capability

---

#### ❌ "Invalid Services ID"

**Cause:** Services ID not configured for web/Android.

**Fix:**
1. Apple Developer → Identifiers → Services IDs
2. Configure domains and return URLs
3. Enable "Sign in with Apple"

---

### Facebook Login Issues

#### ❌ "App not setup: This app is not set up"

**Cause:** App ID not configured or wrong.

**Fix:**
1. Verify App ID in Facebook Developer Console
2. Update `strings.xml` (Android) or `Info.plist` (iOS)
3. Rebuild app

---

#### ❌ "Invalid key hash" (Android)

**Cause:** Key hash not added to Facebook Console.

**Fix:**
Generate key hash:
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

Add to Facebook Console → Settings → Basic → Android

---

#### ❌ "Can't load URL: The domain is not allowed"

**Cause:** App domain not whitelisted.

**Fix:**
1. Facebook Console → Settings → Basic → Add Platform
2. Enter site URL
3. Save changes

---

### General Issues

#### ❌ "flutter_secure_storage: read failed"

**Cause:** Keychain/KeyStore access denied.

**Fix (iOS):**
Add Keychain Sharing capability in Xcode

**Fix (Android):**
No action needed (should work automatically)

---

#### ❌ "PlatformException: sign_in_failed"

**Cause:** Generic sign-in failure.

**Fix:**
1. Check internet connection
2. Verify provider credentials
3. Check platform configuration
4. Review error logs for details

---

## Production Checklist

### Google Sign-In
- [ ] Create production OAuth client IDs
- [ ] Add release SHA-1 fingerprint
- [ ] Configure OAuth consent screen
- [ ] Test on physical devices
- [ ] Verify scopes are minimal
- [ ] Test account selection
- [ ] Test sign-out flow

### Apple Sign-In
- [ ] Enable capability in App Store Connect
- [ ] Configure Services ID (if using web)
- [ ] Test on physical iOS device
- [ ] Test email relay feature
- [ ] Handle first-time user data
- [ ] Test sign-out flow

### Facebook Login
- [ ] Submit app for review (if needed)
- [ ] Add privacy policy URL
- [ ] Configure production key hash
- [ ] Request necessary permissions
- [ ] Test on physical devices
- [ ] Verify data access
- [ ] Test sign-out flow

### Security
- [ ] Use secure token storage
- [ ] Enable HTTPS only
- [ ] Implement token expiration
- [ ] Add rate limiting
- [ ] Log auth events
- [ ] Handle token refresh
- [ ] Test error scenarios

### General
- [ ] Test all sign-in flows
- [ ] Test sign-out
- [ ] Test account linking
- [ ] Test error handling
- [ ] Add analytics
- [ ] Test on iOS and Android
- [ ] Performance testing
- [ ] User acceptance testing

---

**Setup complete! Ready for production!**
