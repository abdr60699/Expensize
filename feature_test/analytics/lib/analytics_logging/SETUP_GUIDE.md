# Analytics & Logging Module - Setup Guide

Complete step-by-step guide for setting up the Analytics & Logging module in your Flutter app.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Analytics Setup](#firebase-analytics-setup)
3. [Firebase Crashlytics Setup](#firebase-crashlytics-setup)
4. [Sentry Setup](#sentry-setup)
5. [Integration](#integration)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### 1. Add Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase Core (required for Firebase providers)
  firebase_core: ^4.2.1

  # Firebase Analytics (optional - only if using Firebase Analytics)
  firebase_analytics: ^11.0.0

  # Firebase Crashlytics (optional - only if using Crashlytics)
  firebase_crashlytics: ^4.0.0

  # Sentry (optional - only if using Sentry)
  sentry_flutter: ^7.0.0

  # For consent management
  shared_preferences: ^2.2.2
```

Run:
```bash
flutter pub get
```

---

## Firebase Analytics Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name and follow the setup wizard
4. Enable Google Analytics when prompted

### Step 2: Register Your App

#### For Android:

1. In Firebase Console, click "Add app" → Android
2. Enter your Android package name (from `android/app/build.gradle`)
   ```gradle
   defaultConfig {
       applicationId "com.example.yourapp"  // ← This is your package name
   }
   ```
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
   apply plugin: 'com.android.application'
   apply plugin: 'com.google.gms.google-services'  // ← Add this

   dependencies {
       // Firebase dependencies are auto-added by FlutterFire
   }
   ```

#### For iOS:

1. In Firebase Console, click "Add app" → iOS
2. Enter your iOS Bundle ID (from `ios/Runner.xcodeproj`)
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Runner folder (check "Copy items if needed")

### Step 3: Initialize Firebase

In your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}
```

### Step 4: Initialize Firebase Analytics

```dart
import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';

final analyticsManager = AnalyticsManager(
  providers: [
    FirebaseAnalyticsProvider(),
  ],
);

await analyticsManager.initialize();
```

### Step 5: Test Firebase Analytics

```dart
// Log a test event
await analyticsManager.logEvent(
  AnalyticsEvent.custom(name: 'test_event'),
);
```

Check Firebase Console → Analytics → Events (data may take 24 hours to appear initially).

---

## Firebase Crashlytics Setup

### Step 1: Enable Crashlytics in Firebase Console

1. Go to Firebase Console → Crashlytics
2. Click "Enable Crashlytics"

### Step 2: Configure Android

Update `android/app/build.gradle`:

```gradle
plugins {
    id 'com.android.application'
    id 'com.google.gms.google-services'
    id 'com.google.firebase.crashlytics'  // ← Add this
}

dependencies {
    // Crashlytics dependencies are auto-added by FlutterFire
}
```

Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'  // ← Add this
    }
}
```

### Step 3: Configure iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure `GoogleService-Info.plist` is added to your project

### Step 4: Initialize Crashlytics

```dart
import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';

final errorLogger = ErrorLogger(
  providers: [
    CrashlyticsProvider(),
  ],
);

await errorLogger.initialize();
```

### Step 5: Test Crashlytics

```dart
// Test crash (debug mode only)
final crashlyticsProvider = errorLogger.getProvider<CrashlyticsProvider>();
if (crashlyticsProvider != null && kDebugMode) {
  await crashlyticsProvider.testCrash();
}

// Or report a test error
await errorLogger.reportError(
  error: 'Test error',
  stackTrace: StackTrace.current,
  message: 'Testing Crashlytics integration',
);
```

Check Firebase Console → Crashlytics → Crashes (within a few minutes).

---

## Sentry Setup

### Step 1: Create Sentry Account

1. Go to [sentry.io](https://sentry.io/)
2. Sign up for a free account
3. Create a new project (select Flutter)
4. Copy your DSN (Data Source Name)

### Step 2: Initialize Sentry

```dart
import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';

final errorLogger = ErrorLogger(
  providers: [
    SentryProvider(
      dsn: 'YOUR_SENTRY_DSN_HERE',
      environment: 'production',
      tracesSampleRate: 0.2,  // Sample 20% for performance monitoring
    ),
  ],
);

await errorLogger.initialize();
```

### Step 3: Configure Sentry (Optional)

For advanced configuration, you can access Sentry features directly:

```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN';
    options.tracesSampleRate = 1.0;
    options.attachScreenshot = true;
    options.attachViewHierarchy = true;
  },
  appRunner: () => runApp(MyApp()),
);
```

### Step 4: Test Sentry

```dart
// Report a test error
await errorLogger.reportError(
  error: Exception('Test exception'),
  stackTrace: StackTrace.current,
  message: 'Testing Sentry integration',
  tags: {'test': 'true'},
);
```

Check Sentry Dashboard → Issues (appears immediately).

---

## Integration

### Complete Integration Example

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';

// Global instances
late final AnalyticsManager analyticsManager;
late final ErrorLogger errorLogger;
late final ConsentManager consentManager;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up analytics
  analyticsManager = AnalyticsManager(
    providers: [
      FirebaseAnalyticsProvider(),
    ],
    privacyConfig: PrivacyConfig.fullConsent(),
  );

  // Set up error logging
  errorLogger = ErrorLogger(
    providers: [
      SentryProvider(
        dsn: 'YOUR_SENTRY_DSN',
        environment: 'production',
      ),
      CrashlyticsProvider(),
    ],
    privacyConfig: PrivacyConfig.fullConsent(),
    defaultAppContext: AppContext(
      appVersion: '1.0.0',
      buildNumber: '1',
      environment: 'production',
    ),
  );

  // Initialize
  await analyticsManager.initialize();
  await errorLogger.initialize();

  // Set up consent management
  consentManager = ConsentManager(
    analyticsManager: analyticsManager,
    errorLogger: errorLogger,
  );
  await consentManager.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get Firebase Analytics observer for automatic screen tracking
    final firebaseProvider = analyticsManager.getProvider<FirebaseAnalyticsProvider>();

    return MaterialApp(
      title: 'My App',
      navigatorObservers: [
        if (firebaseProvider != null)
          firebaseProvider.getNavigatorObserver(),
      ],
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _trackScreenView();
  }

  Future<void> _trackScreenView() async {
    await analyticsManager.logScreenView(
      screenName: 'HomePage',
      screenClass: 'HomeScreen',
    );
  }

  Future<void> _handleButtonClick() async {
    // Add breadcrumb
    await errorLogger.addBreadcrumb(
      message: 'User clicked action button',
      category: 'user_action',
    );

    // Track event
    await analyticsManager.logUserAction(
      action: 'button_click',
      category: 'homepage',
      label: 'action_button',
    );

    try {
      // Perform action
      await performAction();
    } catch (error, stackTrace) {
      // Report error
      await errorLogger.reportError(
        error: error,
        stackTrace: stackTrace,
        message: 'Action failed',
        tags: {'screen': 'home'},
      );

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed. We\'ve been notified.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleButtonClick,
          child: Text('Perform Action'),
        ),
      ),
    );
  }

  Future<void> performAction() async {
    // Your action logic
  }
}
```

---

## Testing

### 1. Test Analytics Events

```dart
// Enable debug logging
final analyticsManager = AnalyticsManager(
  providers: [FirebaseAnalyticsProvider()],
  privacyConfig: PrivacyConfig.debug(),
);

// Log test events
await analyticsManager.logEvent(
  AnalyticsEvent.custom(
    name: 'test_event',
    parameters: {'test': true},
  ),
);
```

Check logs for `[FirebaseAnalytics] Logged event: test_event`.

### 2. Test Error Reporting

```dart
// Enable debug logging
final errorLogger = ErrorLogger(
  providers: [
    SentryProvider(dsn: 'YOUR_DSN'),
    CrashlyticsProvider(),
  ],
  privacyConfig: PrivacyConfig.debug(),
);

// Report test error
await errorLogger.reportError(
  error: Exception('Test error'),
  stackTrace: StackTrace.current,
);
```

Check Sentry and Crashlytics dashboards.

### 3. Test Consent Management

```dart
// Test consent changes
await consentManager.revokeAllConsent();
print('Analytics enabled: ${await consentManager.hasAnalyticsConsent()}');
// Should print: false

await consentManager.grantAllConsent();
print('Analytics enabled: ${await consentManager.hasAnalyticsConsent()}');
// Should print: true
```

---

## Troubleshooting

### Firebase Analytics Not Working

**Issue:** Events not appearing in Firebase Console

**Solutions:**
1. Wait 24 hours for initial data processing
2. Check `google-services.json` / `GoogleService-Info.plist` is in correct location
3. Verify package name/bundle ID matches Firebase project
4. Enable debug logging:
   ```dart
   privacyConfig: PrivacyConfig.debug()
   ```
5. Check Android logs:
   ```bash
   adb logcat | grep -i "firebase"
   ```

### Firebase Crashlytics Not Working

**Issue:** Crashes not appearing in Crashlytics

**Solutions:**
1. Ensure Crashlytics is enabled in Firebase Console
2. Check gradle plugins are applied correctly
3. Crashes may take 5-10 minutes to appear
4. Test with a forced crash:
   ```dart
   await crashlyticsProvider.testCrash();
   ```
5. Check for unsent reports:
   ```dart
   final hasUnsent = await crashlyticsProvider.checkForUnsentReports();
   if (hasUnsent) {
     await crashlyticsProvider.sendCachedErrors();
   }
   ```

### Sentry Not Working

**Issue:** Errors not appearing in Sentry

**Solutions:**
1. Verify DSN is correct
2. Check internet connectivity
3. Enable debug logging in Sentry:
   ```dart
   SentryProvider(
     dsn: 'YOUR_DSN',
     privacyConfig: PrivacyConfig.debug(),
   )
   ```
4. Check Sentry rate limits (free tier has limits)
5. Verify firewall/network isn't blocking sentry.io

### Build Errors (Android)

**Issue:** `Could not find com.google.gms:google-services`

**Solution:**
Update `android/build.gradle`:
```gradle
buildscript {
    repositories {
        google()  // ← Ensure this is present
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()  // ← Ensure this is present
        mavenCentral()
    }
}
```

**Issue:** `Execution failed for task ':app:processDebugGoogleServices'`

**Solution:**
- Verify `google-services.json` is in `android/app/`
- Verify package name in `google-services.json` matches `android/app/build.gradle`

### iOS Build Errors

**Issue:** `GoogleService-Info.plist not found`

**Solution:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Drag `GoogleService-Info.plist` into Runner folder
3. Ensure "Copy items if needed" is checked
4. Verify it appears in "Copy Bundle Resources" build phase

---

## Production Checklist

Before releasing to production:

- [ ] Firebase project configured for production
- [ ] Analytics enabled and tested
- [ ] Crashlytics enabled and tested
- [ ] Sentry DSN configured (if using)
- [ ] Privacy config set appropriately for your region
- [ ] Consent management implemented
- [ ] PII filtering enabled
- [ ] User IDs anonymized (if required)
- [ ] Debug logging disabled
- [ ] Tested on both Android and iOS
- [ ] Verified GDPR/CCPA compliance
- [ ] Privacy policy updated

---

## Next Steps

- Read [README.md](README.md) for usage examples
- Read [SPECIFICATION.md](SPECIFICATION.md) for technical details
- Implement consent UI for your users
- Set up privacy policy
- Configure provider-specific features

## Support

For issues or questions:
1. Check this guide and README.md
2. Review provider documentation:
   - [Firebase Analytics](https://firebase.google.com/docs/analytics)
   - [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
   - [Sentry](https://docs.sentry.io/platforms/flutter/)
3. Check module tests for examples
