# Setup Guide

Complete guide to setting up the Analytics & Logging module from scratch.

## Table of Contents

- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Firebase Setup](#firebase-setup)
- [Sentry Setup](#sentry-setup)
- [Platform Configuration](#platform-configuration)
- [Testing & Verification](#testing--verification)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

Get up and running in 5 minutes:

```bash
# 1. Navigate to the module
cd feature_test/analytics

# 2. Install dependencies
flutter pub get

# 3. Initialize Firebase (required for Firebase providers)
flutterfire configure

# 4. Run the demo app
flutter run
```

---

## Detailed Setup

### Step 1: System Requirements

Verify you have the required tools:

```bash
# Check Flutter version
flutter --version
# Required: Flutter >=3.4.1

# Check Dart version
dart --version
# Required: Dart >=3.4.1

# Verify Flutter doctor
flutter doctor
# Ensure no critical issues
```

### Step 2: Clone or Copy Module

```bash
# Clone the entire repository
git clone <repository-url>
cd expensize/feature_test/analytics

# OR copy just the analytics module
cp -r /path/to/analytics /your/project/location
```

### Step 3: Install Dependencies

```bash
cd feature_test/analytics
flutter pub get
```

This installs:
- `firebase_core` - Firebase SDK
- `firebase_analytics` - Firebase Analytics
- `firebase_crashlytics` - Firebase Crashlytics
- `sentry_flutter` - Sentry error monitoring
- `shared_preferences` - Consent storage
- `uuid` - UUID generation

---

## Firebase Setup

### Option 1: Automatic Setup (Recommended)

#### 1. Install FlutterFire CLI

```bash
# Install globally
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

#### 2. Login to Firebase

```bash
# Login to your Google account
firebase login

# If firebase command not found, install Firebase CLI:
npm install -g firebase-tools
```

#### 3. Configure Firebase

```bash
# From your project root
flutterfire configure
```

This command will:
1. Show your Firebase projects
2. Let you select or create a project
3. Select platforms (iOS, Android, Web)
4. Register your app with Firebase
5. Download configuration files
6. Generate `firebase_options.dart`
7. Enable required services

**Follow the prompts:**
```
? Select a Firebase project to configure your Flutter application with
  > my-app-project (my-app-12345)
    [CREATE NEW PROJECT]

? Which platforms should your configuration support?
  ✓ android
  ✓ ios
  ✓ web

✓ Firebase configuration file lib/firebase_options.dart generated successfully
```

#### 4. Enable Firebase Services

In [Firebase Console](https://console.firebase.google.com):

**Enable Analytics:**
1. Select your project
2. Click "Analytics" in left menu
3. Click "Get Started"
4. Follow the setup wizard
5. Wait for initialization (can take a few minutes)

**Enable Crashlytics:**
1. Click "Crashlytics" in left menu
2. Click "Get Started"
3. Follow the setup wizard
4. Crashlytics will start collecting after first app launch

---

### Option 2: Manual Setup

#### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name
4. Enable Google Analytics (recommended)
5. Select Analytics account or create new
6. Click "Create project"

#### 2. Add Android App

1. Click "Add app" → Android icon
2. Enter Android package name (from `android/app/build.gradle`)
   ```gradle
   applicationId "com.example.myapp"
   ```
3. (Optional) Enter app nickname
4. (Optional) Enter SHA-1 (for Firebase Auth)
5. Click "Register app"
6. Download `google-services.json`
7. Place in `android/app/google-services.json`

**Update android/build.gradle:**
```gradle
buildscript {
  dependencies {
    // ... other dependencies
    classpath 'com.google.gms:google-services:4.4.0'
  }
}
```

**Update android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    // ... other dependencies
}
```

#### 3. Add iOS App

1. Click "Add app" → iOS icon
2. Enter iOS bundle ID (from `ios/Runner.xcodeproj`)
3. (Optional) Enter app nickname
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Open `ios/Runner.xcworkspace` in Xcode
7. Drag `GoogleService-Info.plist` into Runner folder
8. Ensure "Copy items if needed" is checked
9. Select Runner target

**Update ios/Podfile:**
```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Add Firebase pods
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
end
```

**Install pods:**
```bash
cd ios
pod install
cd ..
```

#### 4. Initialize Firebase in Code

```dart
// lib/main.dart
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
```

---

## Sentry Setup

### 1. Create Sentry Account

1. Go to [sentry.io](https://sentry.io)
2. Sign up or log in
3. Click "Create Project"
4. Select "Flutter" as platform
5. Name your project
6. Click "Create Project"

### 2. Get Your DSN

After creating project:
1. Copy the DSN (looks like: `https://xxx@xxx.ingest.sentry.io/xxx`)
2. Save it securely (don't commit to git!)

### 3. Configure DSN

**Option A: Environment Variables (Recommended)**

Create `.env` file (add to `.gitignore`!):
```bash
SENTRY_DSN=https://your-dsn-here@sentry.io/project-id
```

Use in code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
```

**Option B: Build-time Variable**

Run with:
```bash
flutter run --dart-define=SENTRY_DSN=your_dsn_here
```

Access in code:
```dart
const sentryDsn = String.fromEnvironment('SENTRY_DSN');
```

**Option C: Config File (Not Recommended)**

Only for testing:
```dart
// lib/config/sentry_config.dart
class SentryConfig {
  static const String dsn = 'YOUR_DSN_HERE'; // DON'T commit this!
}
```

### 4. Initialize Sentry

**Option A: Global Initialization (Recommended)**

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment = kReleaseMode ? 'production' : 'development';

      // Performance monitoring (optional)
      options.tracesSampleRate = 0.2; // 20% of transactions

      // Set release version
      options.release = 'my-app@1.0.0+1';

      // Enable debug logging in debug mode
      options.debug = kDebugMode;

      // Filter sensitive data
      options.beforeSend = (event, hint) {
        // Remove sensitive data if needed
        return event;
      };
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(...);
      runApp(MyApp());
    },
  );
}
```

**Option B: Use Sentry Provider Only**

```dart
// In your analytics service
final errorLogger = ErrorLogger(
  providers: [
    SentryProvider(
      dsn: sentryDsn,
      environment: kReleaseMode ? 'production' : 'development',
    ),
  ],
);
```

### 5. Verify Sentry Setup

**Test Error:**
```dart
// Trigger a test error
FloatingActionButton(
  onPressed: () {
    throw Exception('Test Sentry error');
  },
  child: Text('Test Sentry'),
);
```

**Check Sentry Dashboard:**
1. Go to sentry.io
2. Select your project
3. Click "Issues"
4. You should see the test error

---

## Platform Configuration

### Android Configuration

#### 1. Update build.gradle

```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.yourcompany.yourapp"
        minSdkVersion 21  // Required
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"

        multiDexEnabled true  // Required for Firebase
    }

    buildTypes {
        release {
            // Crashlytics symbol upload (optional)
            firebaseCrashlytics {
                nativeSymbolUploadEnabled true
                unstrippedNativeLibsDir 'build/intermediates/merged_native_libs/release/out/lib'
            }

            minifyEnabled true
            shrinkResources true
        }
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-crashlytics'
}
```

#### 2. Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- For analytics and error reporting -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application>
        <!-- ... -->
    </application>
</manifest>
```

#### 3. ProGuard Rules (if minifying)

```proguard
# android/app/proguard-rules.pro

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Sentry
-keepattributes LineNumberTable,SourceFile
-dontwarn org.slf4j.**
```

---

### iOS Configuration

#### 1. Update Podfile

```ruby
# ios/Podfile
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Firebase pods (if not using FlutterFire)
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

#### 2. Install Pods

```bash
cd ios
pod install
cd ..
```

#### 3. Update Info.plist (if needed)

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- ... other keys -->

    <!-- Optional: Disable automatic screen tracking -->
    <key>FirebaseAutomaticScreenReportingEnabled</key>
    <false/>
</dict>
```

#### 4. Upload Debug Symbols to Crashlytics

Add build phase in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Select Runner target
4. Click "Build Phases"
5. Click "+" → "New Run Script Phase"
6. Add script:
```bash
"${PODS_ROOT}/FirebaseCrashlytics/run"
```
7. Add input files:
```
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
```

---

### Web Configuration

Limited support for web:

```html
<!-- web/index.html -->
<head>
    <!-- Firebase SDK -->
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-analytics-compat.js"></script>

    <!-- Firebase configuration -->
    <script>
        const firebaseConfig = {
            apiKey: "YOUR_API_KEY",
            authDomain: "YOUR_AUTH_DOMAIN",
            projectId: "YOUR_PROJECT_ID",
            storageBucket: "YOUR_STORAGE_BUCKET",
            messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
            appId: "YOUR_APP_ID",
            measurementId: "YOUR_MEASUREMENT_ID"
        };
        firebase.initializeApp(firebaseConfig);
    </script>
</head>
```

---

## Testing & Verification

### 1. Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test
```

### 2. Run Demo App

```bash
flutter run
```

**Test features:**
- Set user ID
- Log events
- Simulate errors
- Grant/revoke consent

### 3. Verify Firebase Analytics

**Enable Debug Mode:**

**Android:**
```bash
# Enable debug mode
adb shell setprop debug.firebase.analytics.app YOUR_PACKAGE_NAME

# Disable debug mode
adb shell setprop debug.firebase.analytics.app .none.
```

**iOS:**
In Xcode, edit scheme:
1. Product → Scheme → Edit Scheme
2. Run → Arguments
3. Add to "Arguments Passed On Launch":
   ```
   -FIRDebugEnabled
   ```

**View Events:**
1. Go to Firebase Console
2. Analytics → DebugView
3. Use your app
4. See events in real-time

### 4. Verify Crashlytics

**Force Test Crash:**
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Add test button
FloatingActionButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();
  },
  child: Icon(Icons.bug_report),
);
```

**Check Crashlytics Dashboard:**
1. Run app with test crash
2. Crash the app
3. Restart app (required for upload)
4. Wait 5-10 minutes
5. Check Firebase Console → Crashlytics
6. You should see the test crash

**Non-fatal Error:**
```dart
try {
  throw Exception('Test non-fatal error');
} catch (error, stackTrace) {
  await AppAnalyticsService().reportError(
    error,
    stackTrace: stackTrace,
  );
}
```

### 5. Verify Sentry

**Test Error:**
```dart
FloatingActionButton(
  onPressed: () {
    AppAnalyticsService().reportError(
      Exception('Test Sentry error'),
      message: 'Testing Sentry integration',
      tags: {'test': 'true'},
    );
  },
);
```

**Check Sentry:**
1. Go to sentry.io
2. Select project
3. Click "Issues"
4. See the test error

### 6. Verify Consent

```dart
// Test consent flow
final consent = AppAnalyticsService().consent;

// Should be false initially
final hasConsent = await consent.hasAnalyticsConsent();
print('Has consent: $hasConsent');

// Grant consent
await consent.grantConsent();

// Should be true now
final newStatus = await consent.hasAnalyticsConsent();
print('New status: $newStatus');

// Revoke consent
await consent.revokeConsent();
```

---

## Troubleshooting

### Firebase Issues

#### Issue: "Firebase not initialized"

**Error:** `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution:**
```dart
// Ensure Firebase.initializeApp is called before any Firebase usage
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Then initialize analytics
  await AppAnalyticsService().initialize();

  runApp(MyApp());
}
```

---

#### Issue: "Analytics events not showing"

**Possible causes:**
1. Debug mode not enabled
2. Events take 24-48 hours to appear in Analytics
3. App not properly registered

**Solution:**
```bash
# Enable debug mode
adb shell setprop debug.firebase.analytics.app YOUR_PACKAGE

# Use DebugView for real-time events
# Firebase Console → Analytics → DebugView
```

---

#### Issue: "Crashlytics crashes not appearing"

**Possible causes:**
1. App needs to be restarted after crash
2. Symbols not uploaded (iOS)
3. Debug symbols not available

**Solution:**
1. Crash the app
2. Restart the app (required to upload crash)
3. Wait 5-10 minutes
4. Check Crashlytics dashboard

**For iOS:**
- Ensure upload symbols build phase is added
- Check build logs for symbol upload confirmation

---

#### Issue: "google-services.json not found"

**Error:** `File google-services.json is missing`

**Solution:**
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`
3. Verify path is correct
4. Run `flutter clean && flutter pub get`

---

### Sentry Issues

#### Issue: "Events not appearing in Sentry"

**Possible causes:**
1. Invalid DSN
2. Network issues
3. Sentry not initialized

**Solution:**
```dart
// Verify DSN
print('Sentry DSN: $sentryDsn'); // Should not be empty

// Check Sentry initialization
import 'package:sentry_flutter/sentry_flutter.dart';

if (kDebugMode) {
  print('Sentry initialized: ${Sentry.isEnabled}');
}

// Test with a simple error
await Sentry.captureException(Exception('Test'));
```

---

#### Issue: "Sentry capturing too many events"

**Solution:**
```dart
// Adjust sample rate
SentryFlutter.init(
  (options) {
    options.tracesSampleRate = 0.1; // 10% of transactions
    options.sampleRate = 0.5; // 50% of errors

    // Filter events
    options.beforeSend = (event, hint) {
      // Don't send debug errors
      if (kDebugMode) return null;

      // Filter out specific errors
      if (event.message?.contains('ignore') == true) {
        return null;
      }

      return event;
    };
  },
);
```

---

### Consent Issues

#### Issue: "Consent not persisting"

**Error:** Consent resets after app restart

**Solution:**
```dart
// Verify SharedPreferences is working
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
final hasConsent = prefs.getBool('analytics_consent');
print('Stored consent: $hasConsent');

// Ensure ConsentManager is initialized
final consent = ConsentManager();
await consent.initialize();
```

---

#### Issue: "Events still tracked after revoking consent"

**Solution:**
```dart
// Ensure disable is called after revoke
await consentManager.revokeConsent();
await analyticsManager.disable();
await errorLogger.disable();

// Also reset analytics
await analyticsManager.reset();
await errorLogger.clearUser();
```

---

### Performance Issues

#### Issue: "Analytics slowing down app"

**Solution:**
```dart
// Don't await analytics calls
// ✅ Good (non-blocking)
void trackEvent() {
  analyticsManager.logEvent(event); // Fire and forget
}

// ❌ Bad (blocks UI)
Future<void> trackEvent() async {
  await analyticsManager.logEvent(event); // Waits for completion
}
```

---

#### Issue: "Too many network requests"

**Solution:**
- Events are automatically batched by providers
- Firebase batches events every 60 seconds or 100 events
- Sentry batches by default
- Don't manually batch unless needed

---

## Setup Checklist

### Firebase Setup
- [ ] Flutter SDK >=3.4.1 installed
- [ ] Firebase project created
- [ ] FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
- [ ] Ran `flutterfire configure`
- [ ] `firebase_options.dart` generated
- [ ] Analytics enabled in Firebase Console
- [ ] Crashlytics enabled in Firebase Console
- [ ] Android google-services.json in place
- [ ] iOS GoogleService-Info.plist in place
- [ ] Firebase initialized in main.dart

### Sentry Setup (Optional)
- [ ] Sentry account created
- [ ] Sentry project created
- [ ] DSN copied and stored securely
- [ ] Sentry initialized in code
- [ ] Environment variables configured

### Platform Setup
- [ ] Android minSdkVersion set to 21+
- [ ] Android google-services plugin added
- [ ] iOS Podfile updated
- [ ] iOS pods installed
- [ ] iOS debug symbols upload configured

### Code Setup
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Analytics service created
- [ ] Firebase initialized in main.dart
- [ ] Analytics manager initialized
- [ ] Error logger initialized
- [ ] Consent manager initialized
- [ ] Global error handlers added

### Testing
- [ ] Demo app runs
- [ ] Firebase debug mode enabled
- [ ] Analytics events visible in DebugView
- [ ] Test crash reported to Crashlytics
- [ ] Test error reported to Sentry (if using)
- [ ] Consent flow tested

---

## Next Steps

1. ✅ Complete setup (you're here)
2. 📖 Read [FEATURES.md](./FEATURES.md) for capabilities
3. 🔧 Read [INTEGRATION.md](./INTEGRATION.md) for integration guide
4. 💻 Review demo app in `/lib/main.dart`
5. 🚀 Start tracking events in your app!

---

## Getting Help

If you encounter issues:

1. Check this troubleshooting guide
2. Review [Firebase documentation](https://firebase.google.com/docs/flutter/setup)
3. Review [Sentry documentation](https://docs.sentry.io/platforms/flutter/)
4. Check [FlutterFire documentation](https://firebase.flutter.dev)
5. Enable debug logging in your app
6. Open an issue in the repository

---

**Setup complete! You're ready to track analytics and monitor errors.**
