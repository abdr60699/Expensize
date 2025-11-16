# Analytics & Logging Module

Production-ready analytics and error reporting for Flutter applications with privacy-first design and GDPR/CCPA compliance.

## Features

### Analytics Tracking
- **Unified API**: Single interface for multiple analytics providers
- **Event Tracking**: Custom events, screen views, user actions
- **User Properties**: Set user attributes and demographics
- **Session Management**: Automatic session tracking and timeouts
- **Multi-Provider Support**: Firebase Analytics, and extensible to others

### Error Reporting
- **Crash Reporting**: Automatic crash detection and reporting
- **Error Context**: Full stack traces with app context
- **Severity Levels**: Info, Warning, Error, Fatal
- **User Context**: Associate errors with user data (with consent)
- **Provider Support**: Firebase Crashlytics, Sentry

### Privacy & Compliance
- **Consent Management**: GDPR/CCPA compliant consent tracking
- **Privacy Controls**: Granular control over data collection
- **Opt-out Support**: Easy disable/enable functionality
- **Data Minimization**: Only collect necessary data
- **Debug Logging**: Optional verbose logging for development

### Architecture
- **Provider Pattern**: Swappable analytics and error reporting backends
- **Type Safety**: Strongly typed events and configurations
- **Async/Await**: Modern async API throughout
- **Testable**: Comprehensive test coverage
- **Modular**: Use only what you need

## Prerequisites

- Flutter SDK (>=3.4.1 <4.0.0)
- Dart SDK
- Firebase project (for Firebase Analytics/Crashlytics)
- Sentry account (optional, for Sentry integration)

## Installation

### 1. Navigate to the project directory

```bash
cd feature_test/analytics
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the demo application

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                                 # Demo application
└── analytics_logging/
    ├── analytics_logging.dart                # Main export file
    ├── core/
    │   ├── analytics_manager.dart            # Analytics coordinator
    │   ├── error_logger.dart                 # Error reporting coordinator
    │   └── analytics_config.dart             # Configuration models
    ├── models/
    │   ├── analytics_event.dart              # Event data model
    │   ├── analytics_user.dart               # User data model
    │   ├── error_report.dart                 # Error report model
    │   └── privacy_config.dart               # Privacy settings
    ├── providers/
    │   ├── analytics_provider.dart           # Analytics provider interface
    │   ├── error_provider.dart               # Error provider interface
    │   ├── firebase_analytics_provider.dart  # Firebase Analytics implementation
    │   ├── crashlytics_provider.dart         # Firebase Crashlytics implementation
    │   └── sentry_provider.dart              # Sentry implementation
    ├── services/
    │   └── consent_manager.dart              # Consent management service
    └── tests/
        ├── analytics_manager_test.dart       # Unit tests
        └── consent_manager_test.dart         # Unit tests
```

## Quick Start

### Initialize Analytics

```dart
import 'package:analytics/analytics_logging/analytics_logging.dart';

Future<void> setupAnalytics() async {
  // Create privacy configuration
  final privacyConfig = PrivacyConfig(
    analyticsEnabled: true,
    crashReportingEnabled: true,
    enableDebugLogging: true, // false in production
  );

  // Create analytics manager
  final analyticsManager = AnalyticsManager(
    providers: [
      FirebaseAnalyticsProvider(), // Requires firebase_core
    ],
    privacyConfig: privacyConfig,
  );

  // Initialize
  await analyticsManager.initialize();

  // Create error logger
  final errorLogger = ErrorLogger(
    providers: [
      CrashlyticsProvider(),
      // SentryProvider(dsn: 'YOUR_SENTRY_DSN'),
    ],
  );

  await errorLogger.initialize();
}
```

### Track Events

```dart
// Screen view
await analyticsManager.logScreenView(
  screenName: 'HomeScreen',
  screenClass: 'HomePage',
);

// Custom event
await analyticsManager.logEvent(
  AnalyticsEvent.custom(
    name: 'button_click',
    parameters: {
      'button_id': 'checkout',
      'screen': 'cart',
    },
  ),
);

// User action
await analyticsManager.logUserAction(
  action: 'purchase',
  category: 'ecommerce',
  value: 99.99,
  additionalParameters: {
    'currency': 'USD',
    'items': 3,
  },
);
```

### Set User Information

```dart
// Set user with full consent
final user = AnalyticsUser.withFullConsent(
  userId: 'user123',
  email: 'user@example.com',
  properties: {
    'subscription_tier': 'premium',
    'signup_date': '2024-01-01',
  },
);

await analyticsManager.setUser(user);

// Or just set user ID
await analyticsManager.setUserId('user123');

// Set user property
await analyticsManager.setUserProperty(
  name: 'language',
  value: 'en',
);
```

### Report Errors

```dart
try {
  // Your code that might throw
  await someRiskyOperation();
} catch (error, stackTrace) {
  // Report error
  await errorLogger.reportError(
    ErrorReport(
      error: error,
      stackTrace: stackTrace,
      appContext: AppContext(
        appName: 'MyApp',
        appVersion: '1.0.0',
        buildNumber: '42',
        environment: 'production',
        platform: 'iOS',
      ),
      severity: ErrorSeverity.error,
    ),
  );
}

// Log non-fatal error
await errorLogger.logError(
  message: 'Something went wrong',
  errorDetails: {'operation': 'data_sync'},
  severity: ErrorSeverity.warning,
);
```

### Manage Consent

```dart
// Initialize consent manager
final consentManager = ConsentManager();
await consentManager.initialize();

// Check consent status
final hasConsent = await consentManager.hasAnalyticsConsent();

// Grant consent
await consentManager.grantConsent();
await analyticsManager.enable();

// Revoke consent
await consentManager.revokeConsent();
await analyticsManager.disable();

// Reset on user logout
await analyticsManager.reset();
```

## Configuration

### Privacy Configuration

```dart
// Full consent (all features enabled)
const privacyConfig = PrivacyConfig.fullConsent();

// Analytics only (no crash reporting)
const privacyConfig = PrivacyConfig.analyticsOnly();

// Error reporting only (no analytics)
const privacyConfig = PrivacyConfig.errorReportingOnly();

// Debug mode
const privacyConfig = PrivacyConfig.debug();

// Custom configuration
const privacyConfig = PrivacyConfig(
  analyticsEnabled: true,
  crashReportingEnabled: true,
  personalizationEnabled: false,
  adTrackingEnabled: false,
  enableDebugLogging: true,
);
```

### Analytics Logging Configuration

```dart
// Development configuration
final config = AnalyticsLoggingConfig.debug(
  sentryDsn: 'YOUR_SENTRY_DSN',
  appContext: AppContext(
    appName: 'MyApp',
    appVersion: '1.0.0',
    environment: 'development',
  ),
);

// Production configuration
final config = AnalyticsLoggingConfig.production(
  privacyConfig: PrivacyConfig.fullConsent(),
  sentryDsn: 'YOUR_SENTRY_DSN',
  appContext: appContext,
);

// Custom configuration
final config = AnalyticsLoggingConfig(
  privacyConfig: privacyConfig,
  enableFirebaseAnalytics: true,
  enableSentry: true,
  sentryDsn: 'YOUR_SENTRY_DSN',
  sentryEnvironment: 'staging',
  sentryTracesSampleRate: 0.5,
  enableCrashlytics: true,
  sessionTimeout: Duration(minutes: 30),
);
```

## Demo Application

The demo app showcases all module capabilities with an interactive UI:

### Features
- **Overview Tab**: Module features, quick actions, and supported providers
- **Events Tab**: Pre-configured sample events and event types
- **Errors Tab**: Error reporting features and severity levels
- **Logs Tab**: Real-time activity logging

### Running the Demo

```bash
cd feature_test/analytics
flutter run
```

### Demo Actions

1. **Set User ID**: Create and set a demo user
2. **Log Custom Event**: Track a custom analytics event
3. **Simulate Error**: Test error reporting functionality
4. **Toggle Consent**: Test privacy consent management

## Event Types

### Screen View Events

```dart
final event = AnalyticsEvent.screenView(
  screenName: 'ProductDetails',
  screenClass: 'ProductPage',
  additionalParameters: {
    'product_id': '123',
    'category': 'electronics',
  },
);
```

### User Action Events

```dart
final event = AnalyticsEvent.userAction(
  action: 'add_to_cart',
  category: 'ecommerce',
  label: 'product_123',
  value: 49.99,
  additionalParameters: {
    'quantity': 2,
  },
);
```

### Custom Events

```dart
final event = AnalyticsEvent.custom(
  name: 'level_up',
  parameters: {
    'character': 'warrior',
    'level': 10,
    'experience': 5000,
  },
);
```

## Error Severity Levels

- **Info**: Informational messages, not errors
- **Warning**: Non-critical issues that should be monitored
- **Error**: Handled errors that affect functionality
- **Fatal**: Critical crashes that terminate the app

```dart
// Info
await errorLogger.logError(
  message: 'User completed tutorial',
  severity: ErrorSeverity.info,
);

// Warning
await errorLogger.logError(
  message: 'API response slow',
  severity: ErrorSeverity.warning,
);

// Error
await errorLogger.reportError(
  ErrorReport(
    error: exception,
    stackTrace: stackTrace,
    severity: ErrorSeverity.error,
  ),
);

// Fatal
await errorLogger.reportCrash(
  error: fatalError,
  stackTrace: stackTrace,
  appContext: appContext,
);
```

## Privacy Best Practices

### 1. Request Consent Before Tracking

```dart
// Show consent dialog to user
final userConsent = await showConsentDialog();

if (userConsent) {
  await consentManager.grantConsent();
  await analyticsManager.enable();
} else {
  await consentManager.revokeConsent();
  await analyticsManager.disable();
}
```

### 2. Respect User Preferences

```dart
// Check consent before setting PII
if (user.hasAnalyticsConsent) {
  await analyticsManager.setUser(user);
} else {
  // Only set anonymized data
  await analyticsManager.setUserId(anonymizedId);
}
```

### 3. Clear Data on Logout

```dart
Future<void> logout() async {
  // Clear analytics data
  await analyticsManager.reset();

  // Clear error reporting context
  await errorLogger.clearUser();

  // Clear consent (if required by your privacy policy)
  await consentManager.clear();
}
```

### 4. Minimize Data Collection

```dart
// Only collect necessary event parameters
await analyticsManager.logEvent(
  AnalyticsEvent.custom(
    name: 'search',
    parameters: {
      'results_count': 42,
      // Don't include: 'search_query': userInput
    },
  ),
);
```

## Firebase Setup

### 1. Add Firebase to your app

Follow the [FlutterFire documentation](https://firebase.flutter.dev/docs/overview) to:
- Create a Firebase project
- Add your Flutter app to Firebase
- Download and add configuration files

### 2. Initialize Firebase

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Then initialize analytics
  await setupAnalytics();

  runApp(MyApp());
}
```

## Sentry Setup

### 1. Get your Sentry DSN

Create a project on [sentry.io](https://sentry.io) and get your DSN.

### 2. Initialize Sentry

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = 'production';
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

### 3. Use Sentry Provider

```dart
final errorLogger = ErrorLogger(
  providers: [
    SentryProvider(
      dsn: 'YOUR_SENTRY_DSN',
      environment: 'production',
    ),
  ],
);
```

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsManager', () {
    test('initializes successfully', () async {
      final manager = AnalyticsManager(
        providers: [MockAnalyticsProvider()],
      );

      final result = await manager.initialize();
      expect(result, isTrue);
      expect(manager.isInitialized, isTrue);
    });

    test('logs events correctly', () async {
      final provider = MockAnalyticsProvider();
      final manager = AnalyticsManager(providers: [provider]);

      await manager.initialize();
      await manager.logEvent(
        AnalyticsEvent.custom(name: 'test_event'),
      );

      expect(provider.events, hasLength(1));
      expect(provider.events.first.name, 'test_event');
    });
  });
}
```

### Integration Tests

See `lib/analytics_logging/tests/` for comprehensive test examples.

## Troubleshooting

### Issue: Events not appearing in Firebase
**Solution**:
- Check that Firebase is properly initialized before analytics
- Verify debug logging is enabled to see event logs
- Firebase Analytics has a delay (up to 24 hours) before showing data
- Use Firebase DebugView for real-time debugging

### Issue: Crashes not reported
**Solution**:
- Ensure Crashlytics is enabled in Firebase console
- Check that error logger is initialized after Firebase
- Verify privacy consent is granted
- Test with a forced crash in debug mode

### Issue: Consent not persisting
**Solution**:
- Check that shared_preferences is properly configured
- Verify storage permissions on Android
- Clear app data and test again

### Issue: Sentry errors not uploading
**Solution**:
- Verify DSN is correct
- Check network connectivity
- Ensure Sentry is initialized before error reporting
- Check Sentry dashboard for quota limits

## Performance Considerations

1. **Batch Events**: Analytics providers automatically batch events
2. **Async Operations**: All analytics calls are async and non-blocking
3. **Network Efficiency**: Events are queued and sent in batches
4. **Memory**: Providers manage their own memory footprint
5. **Background**: Analytics work in background threads

## Dependencies

### Core Dependencies
- `firebase_core: ^2.24.2` - Firebase SDK initialization
- `firebase_analytics: ^10.8.0` - Firebase Analytics
- `firebase_crashlytics: ^3.4.9` - Firebase crash reporting
- `sentry_flutter: ^7.14.0` - Sentry error monitoring

### Supporting Dependencies
- `shared_preferences: ^2.2.2` - Consent storage
- `uuid: ^4.3.3` - UUID generation for sessions

## Examples

Complete examples are available in:
- `/lib/main.dart` - Interactive demo application
- `/lib/analytics_logging/tests/` - Unit test examples

## Roadmap

- [ ] Additional providers (Amplitude, Mixpanel, etc.)
- [ ] Automatic screen tracking
- [ ] Performance monitoring integration
- [ ] User journey tracking
- [ ] A/B testing integration
- [ ] Real-time dashboards

## Contributing

This module is part of the Expensize project. For contributions:

1. Follow existing patterns and architecture
2. Add tests for new features
3. Update documentation
4. Ensure privacy compliance

## License

This is a feature module for the Expensize application.

## Support

For issues or questions about this module, please refer to the main Expensize project documentation or open an issue in the repository.

---

**Built with privacy and compliance in mind**
