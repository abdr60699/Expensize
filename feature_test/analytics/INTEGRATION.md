# Integration Guide

How to integrate the Analytics & Logging module into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Basic Integration](#basic-integration)
- [Advanced Integration](#advanced-integration)
- [Firebase Integration](#firebase-integration)
- [Sentry Integration](#sentry-integration)
- [Navigation Tracking](#navigation-tracking)
- [Best Practices](#best-practices)
- [Migration Guide](#migration-guide)

---

## Prerequisites

### Required Dependencies

Your Flutter project needs:
- **Flutter SDK**: >=3.4.1 <4.0.0
- **Dart SDK**: >=3.4.1
- **Firebase project** (for Firebase Analytics/Crashlytics)
- **Sentry account** (optional, for Sentry integration)

### Optional Requirements

- Internet connection for cloud features
- Google Play Services (Android) for Firebase
- APNs certificate (iOS) for push notifications (if using Firebase)

---

## Installation

### Step 1: Copy Module to Your Project

Copy the analytics directory into your project:

```bash
# If using as a package
cp -r feature_test/analytics /path/to/your/project/packages/analytics

# OR include in your lib directory
cp -r feature_test/analytics/lib/analytics_logging /path/to/your/project/lib/
```

### Step 2: Add Dependencies

Add to your `pubspec.yaml`:

#### Option A: As a local package

```yaml
dependencies:
  analytics:
    path: ./packages/analytics
```

#### Option B: Inline (copy to lib/)

```yaml
dependencies:
  # Core Firebase (if using Firebase providers)
  firebase_core: ^2.24.2
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9

  # Sentry (if using Sentry)
  sentry_flutter: ^7.14.0

  # Storage for consent
  shared_preferences: ^2.2.2

  # UUID generation
  uuid: ^4.3.3
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

---

## Basic Integration

### Minimal Integration (5 minutes)

Create a simple wrapper service in your app:

```dart
// lib/services/analytics_service.dart
import 'package:analytics/analytics_logging/analytics_logging.dart';

class AppAnalyticsService {
  static final AppAnalyticsService _instance = AppAnalyticsService._internal();
  factory AppAnalyticsService() => _instance;
  AppAnalyticsService._internal();

  late AnalyticsManager _analytics;
  late ErrorLogger _errorLogger;
  late ConsentManager _consentManager;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize consent manager
    _consentManager = ConsentManager();
    await _consentManager.initialize();

    // Check consent
    final hasConsent = await _consentManager.hasAnalyticsConsent();

    // Create privacy config based on consent
    final privacyConfig = hasConsent
        ? PrivacyConfig.fullConsent()
        : PrivacyConfig(
            analyticsEnabled: false,
            crashReportingEnabled: false,
          );

    // Setup analytics
    _analytics = AnalyticsManager(
      providers: [
        FirebaseAnalyticsProvider(),
      ],
      privacyConfig: privacyConfig,
    );
    await _analytics.initialize();

    // Setup error logging
    _errorLogger = ErrorLogger(
      providers: [
        CrashlyticsProvider(),
      ],
      privacyConfig: privacyConfig,
    );
    await _errorLogger.initialize();

    _initialized = true;
  }

  // Convenient getters
  AnalyticsManager get analytics => _analytics;
  ErrorLogger get errorLogger => _errorLogger;
  ConsentManager get consent => _consentManager;
}
```

### Initialize in main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize analytics
  await AppAnalyticsService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomeScreen(),
    );
  }
}
```

### Use in Screens

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _analytics = AppAnalyticsService().analytics;

  @override
  void initState() {
    super.initState();
    _trackScreenView();
  }

  Future<void> _trackScreenView() async {
    await _analytics.logScreenView(
      screenName: 'Home',
      screenClass: 'HomeScreen',
    );
  }

  Future<void> _handleButtonClick() async {
    // Track user action
    await _analytics.logUserAction(
      action: 'button_click',
      category: 'navigation',
      label: 'home_to_details',
    );

    // Navigate
    Navigator.push(context, ...);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleButtonClick,
          child: Text('Go to Details'),
        ),
      ),
    );
  }
}
```

---

## Advanced Integration

### Full-Featured Integration

Create a comprehensive analytics service with all features:

```dart
// lib/services/analytics_service.dart
import 'package:flutter/foundation.dart';
import 'package:analytics/analytics_logging/analytics_logging.dart';

class AppAnalyticsService {
  static final AppAnalyticsService _instance = AppAnalyticsService._internal();
  factory AppAnalyticsService() => _instance;
  AppAnalyticsService._internal();

  late AnalyticsManager _analytics;
  late ErrorLogger _errorLogger;
  late ConsentManager _consentManager;
  bool _initialized = false;

  // Configuration
  static const String _sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize consent manager
    _consentManager = ConsentManager();
    await _consentManager.initialize();

    // Get consent status
    final hasAnalyticsConsent = await _consentManager.hasAnalyticsConsent();
    final hasCrashConsent = await _consentManager.hasCrashReportingConsent();

    // Create privacy config
    final privacyConfig = PrivacyConfig(
      analyticsEnabled: hasAnalyticsConsent,
      crashReportingEnabled: hasCrashConsent,
      enableDebugLogging: kDebugMode,
    );

    // Setup analytics with multiple providers
    _analytics = AnalyticsManager(
      providers: [
        FirebaseAnalyticsProvider(),
        // Add more providers as needed
      ],
      privacyConfig: privacyConfig,
    );
    await _analytics.initialize();

    // Setup error logging with multiple providers
    final errorProviders = <ErrorProvider>[
      CrashlyticsProvider(),
    ];

    // Add Sentry if DSN is available
    if (_sentryDsn.isNotEmpty) {
      errorProviders.add(
        SentryProvider(
          dsn: _sentryDsn,
          environment: kReleaseMode ? 'production' : 'development',
        ),
      );
    }

    _errorLogger = ErrorLogger(
      providers: errorProviders,
      privacyConfig: privacyConfig,
      defaultAppContext: AppContext(
        appName: 'MyApp',
        appVersion: '1.0.0',
        buildNumber: '1',
        environment: kReleaseMode ? 'production' : 'development',
        platform: defaultTargetPlatform.name,
      ),
    );
    await _errorLogger.initialize();

    // Set session timeout
    await _analytics.setSessionTimeout(Duration(minutes: 30));

    _initialized = true;
  }

  // ==================== Analytics Methods ====================

  /// Track screen view
  Future<void> trackScreen(String screenName, {String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Track custom event
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      AnalyticsEvent.custom(
        name: name,
        parameters: parameters,
      ),
    );
  }

  /// Track user action
  Future<void> trackAction(
    String action, {
    String? category,
    String? label,
    dynamic value,
    Map<String, dynamic>? params,
  }) async {
    await _analytics.logUserAction(
      action: action,
      category: category,
      label: label,
      value: value,
      additionalParameters: params,
    );
  }

  /// Track purchase
  Future<void> trackPurchase({
    required double amount,
    required String currency,
    required String transactionId,
    List<Map<String, dynamic>>? items,
  }) async {
    await _analytics.logEvent(
      AnalyticsEvent.custom(
        name: 'purchase',
        parameters: {
          'value': amount,
          'currency': currency,
          'transaction_id': transactionId,
          if (items != null) 'items': items,
        },
      ),
    );
  }

  // ==================== User Methods ====================

  /// Set current user
  Future<void> setUser(AnalyticsUser user) async {
    await _analytics.setUser(user);
    await _errorLogger.setUser(user);
  }

  /// Set user ID only
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(userId);
  }

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ==================== Error Methods ====================

  /// Report error
  Future<void> reportError(
    dynamic error, {
    StackTrace? stackTrace,
    String? message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
    ErrorSeverity severity = ErrorSeverity.error,
  }) async {
    await _errorLogger.reportError(
      error: error,
      stackTrace: stackTrace,
      message: message,
      tags: tags,
      extra: extra,
      severity: severity,
    );
  }

  /// Add breadcrumb
  Future<void> addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) async {
    await _errorLogger.addBreadcrumb(
      message: message,
      category: category,
      data: data,
    );
  }

  // ==================== Consent Methods ====================

  /// Request consent from user
  Future<bool> requestConsent() async {
    // Show consent dialog to user
    // Return true if granted, false if denied
    return false; // Implement your consent UI
  }

  /// Grant consent
  Future<void> grantConsent() async {
    await _consentManager.grantConsent();
    await _analytics.enable();
    await _errorLogger.enable();
  }

  /// Revoke consent
  Future<void> revokeConsent() async {
    await _consentManager.revokeConsent();
    await _analytics.disable();
    await _errorLogger.disable();
    await reset();
  }

  /// Check consent status
  Future<bool> hasConsent() async {
    return await _consentManager.hasAnalyticsConsent();
  }

  // ==================== Lifecycle Methods ====================

  /// Reset all data (on logout)
  Future<void> reset() async {
    await _analytics.reset();
    await _errorLogger.clearUser();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _analytics.dispose();
    await _errorLogger.dispose();
    _initialized = false;
  }

  // Getters
  AnalyticsManager get analytics => _analytics;
  ErrorLogger get errorLogger => _errorLogger;
  ConsentManager get consent => _consentManager;
  bool get isInitialized => _initialized;
}
```

---

## Firebase Integration

### Step 1: Setup Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing
3. Add your Flutter app (iOS and/or Android)
4. Download configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

### Step 2: Install FlutterFire CLI

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Link your app to Firebase project
- Enable required Firebase services

### Step 3: Initialize Firebase

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

  // Then initialize analytics
  await AppAnalyticsService().initialize();

  runApp(MyApp());
}
```

### Step 4: Enable Analytics & Crashlytics

In Firebase Console:
1. Go to Analytics → Enable Google Analytics
2. Go to Crashlytics → Enable Crashlytics
3. Wait for first data (can take 24 hours for Analytics)

### Step 5: Test Firebase Integration

**Enable Debug Mode (Analytics):**

```bash
# Android
adb shell setprop debug.firebase.analytics.app YOUR_PACKAGE_NAME

# iOS (in Xcode)
# Add to scheme: -FIRDebugEnabled
```

**View Analytics Events:**
- Go to Firebase Console → Analytics → DebugView
- Use your app
- See events in real-time

**Test Crashlytics:**
```dart
// Force a crash to test
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

FloatingActionButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash(); // Test crash
  },
  child: Text('Test Crash'),
);
```

---

## Sentry Integration

### Step 1: Create Sentry Project

1. Go to [sentry.io](https://sentry.io)
2. Create account or sign in
3. Create new project (Flutter)
4. Copy your DSN

### Step 2: Configure Sentry

```dart
// Option A: Environment variable
// Run with: flutter run --dart-define=SENTRY_DSN=your_dsn_here

// Option B: Secure storage or config file
// lib/config/sentry_config.dart
class SentryConfig {
  static const String dsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
}
```

### Step 3: Initialize Sentry (Optional Global Setup)

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = 0.2; // 20% of transactions
      options.beforeSend = (event, hint) {
        // Optional: filter or modify events
        return event;
      };
    },
    appRunner: () async {
      // Your app initialization
      await Firebase.initializeApp(...);
      await AppAnalyticsService().initialize();
      runApp(MyApp());
    },
  );
}
```

### Step 4: Use Sentry Provider

```dart
final errorLogger = ErrorLogger(
  providers: [
    SentryProvider(
      dsn: SentryConfig.dsn,
      environment: kReleaseMode ? 'production' : 'development',
    ),
  ],
);
```

---

## Navigation Tracking

### Automatic Screen Tracking with Firebase

```dart
// lib/main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class MyApp extends StatelessWidget {
  // Get Firebase Analytics observer
  final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(
    analytics: FirebaseAnalytics.instance,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // Add observer for automatic screen tracking
      navigatorObservers: [_observer],
      routes: {
        '/': (context) => HomeScreen(),
        '/details': (context) => DetailsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
```

### Manual Screen Tracking

```dart
// Use in every screen's initState
class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    AppAnalyticsService().trackScreen('Product');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

### Named Routes Tracking

```dart
// lib/utils/analytics_route_observer.dart
import 'package:flutter/material.dart';

class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _trackScreen(route.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) {
      _trackScreen(previousRoute.settings.name);
    }
  }

  void _trackScreen(String? routeName) {
    if (routeName != null) {
      AppAnalyticsService().trackScreen(routeName);
    }
  }
}

// Use in MaterialApp
MaterialApp(
  navigatorObservers: [
    AnalyticsRouteObserver(),
  ],
);
```

---

## Best Practices

### 1. Initialize Early

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase first
  await Firebase.initializeApp(...);

  // 2. Then analytics
  await AppAnalyticsService().initialize();

  // 3. Then run app
  runApp(MyApp());
}
```

### 2. Handle Errors Globally

```dart
Future<void> main() async {
  // ... initialization

  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    AppAnalyticsService().reportError(
      details.exception,
      stackTrace: details.stack,
      message: details.summary.toString(),
      tags: {'error_type': 'flutter_error'},
    );
  };

  // Catch async errors
  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) {
      AppAnalyticsService().reportError(
        error,
        stackTrace: stackTrace,
        message: 'Uncaught async error',
        tags: {'error_type': 'async_error'},
      );
    },
  );
}
```

### 3. Fire and Forget Analytics

```dart
// ✅ Don't await analytics calls (non-blocking)
void onButtonPressed() {
  AppAnalyticsService().trackAction('button_click');
  // Continue with UI logic
  navigateToNextScreen();
}

// ❌ Don't block UI
Future<void> onButtonPressed() async {
  await AppAnalyticsService().trackAction('button_click'); // Blocks!
  navigateToNextScreen();
}
```

### 4. Add Context to Errors

```dart
// Always add relevant context
try {
  await processPayment(orderId);
} catch (error, stackTrace) {
  await AppAnalyticsService().reportError(
    error,
    stackTrace: stackTrace,
    tags: {
      'feature': 'checkout',
      'payment_step': 'processing',
    },
    extra: {
      'order_id': orderId,
      'amount': orderAmount,
      'retry_count': retryCount,
    },
  );
}
```

### 5. Use Breadcrumbs

```dart
class CheckoutFlow {
  final _analytics = AppAnalyticsService();

  Future<void> processCheckout() async {
    await _analytics.addBreadcrumb('Started checkout flow');

    await _analytics.addBreadcrumb(
      'Validating cart',
      data: {'items': cartItems.length},
    );

    try {
      await validateCart();
      await _analytics.addBreadcrumb('Cart validated');

      await _analytics.addBreadcrumb('Processing payment');
      await processPayment();

      await _analytics.addBreadcrumb('Payment successful');
    } catch (error, stackTrace) {
      // Error report will include all breadcrumbs
      await _analytics.reportError(error, stackTrace: stackTrace);
    }
  }
}
```

### 6. Request Consent

```dart
class OnboardingScreen extends StatelessWidget {
  Future<void> _showConsentDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help us improve'),
        content: Text(
          'We use analytics to improve your experience. '
          'Your data is anonymous and secure.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Decline'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Accept'),
          ),
        ],
      ),
    );

    if (result == true) {
      await AppAnalyticsService().grantConsent();
    } else {
      await AppAnalyticsService().revokeConsent();
    }
  }
}
```

### 7. Reset on Logout

```dart
Future<void> logout() async {
  // Clear analytics data
  await AppAnalyticsService().reset();

  // Clear app data
  await clearUserData();

  // Navigate to login
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

## Migration Guide

### From Direct Firebase Analytics

**Before:**
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

await analytics.logEvent(
  name: 'purchase',
  parameters: {'amount': 99.99},
);

await analytics.setUserId(id: userId);
```

**After:**
```dart
import 'package:analytics/analytics_logging/analytics_logging.dart';

await AppAnalyticsService().trackEvent(
  'purchase',
  parameters: {'amount': 99.99},
);

await AppAnalyticsService().setUserId(userId);
// Added: Multi-provider, consent, privacy
```

### From Direct Crashlytics

**Before:**
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Error message',
);
```

**After:**
```dart
await AppAnalyticsService().reportError(
  error,
  stackTrace: stackTrace,
  message: 'Error message',
);
// Added: Multi-provider, tags, extra data
```

---

## Integration Checklist

- [ ] Copy analytics module to your project
- [ ] Add dependencies to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Setup Firebase project (if using Firebase)
- [ ] Download Firebase config files
- [ ] Run `flutterfire configure`
- [ ] Setup Sentry project (if using Sentry)
- [ ] Create AppAnalyticsService wrapper
- [ ] Initialize in main.dart
- [ ] Setup global error handlers
- [ ] Add navigation observers
- [ ] Implement consent flow
- [ ] Track screen views
- [ ] Test analytics events
- [ ] Test error reporting
- [ ] Test consent management

---

## Support

For integration issues:
1. Check the [SETUP.md](./SETUP.md) for configuration details
2. Review [FEATURES.md](./FEATURES.md) for feature documentation
3. See example implementations in `/lib/main.dart`
4. Check Firebase/Sentry documentation
5. Open an issue in the repository

---

**Ready to track analytics and errors in your app!**
