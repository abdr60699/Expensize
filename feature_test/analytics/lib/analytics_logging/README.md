# Analytics & Logging Module

Production-ready, reusable analytics and error reporting module for Flutter apps. Provides a unified API for tracking analytics and capturing errors/crashes across multiple providers.

## Features

- **Unified API** - Single interface for analytics and error reporting
- **Multiple Providers** - Support for Firebase Analytics, Sentry, and Firebase Crashlytics
- **Privacy-Aware** - Built-in PII handling and GDPR/CCPA compliance
- **Configurable** - Enable/disable specific providers at runtime
- **Consent Management** - User consent tracking with persistent storage
- **Type-Safe** - Full null-safety and strong typing
- **Production-Ready** - Comprehensive error handling and logging
- **Easy Integration** - Drop-in module with minimal setup

## Supported Providers

### Analytics
- **Firebase Analytics** - Google's analytics platform for mobile apps

### Error Reporting
- **Sentry** - Real-time error tracking and performance monitoring
- **Firebase Crashlytics** - Google's crash reporting solution

## Quick Start

### 1. Installation

Import the module in your code:

```dart
import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';
```

### 2. Initialize Firebase (if using Firebase providers)

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}
```

### 3. Set Up Analytics & Error Reporting

```dart
import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';

// Create analytics manager
final analyticsManager = AnalyticsManager(
  providers: [
    FirebaseAnalyticsProvider(),
  ],
  privacyConfig: PrivacyConfig.fullConsent(),
);

// Create error logger
final errorLogger = ErrorLogger(
  providers: [
    SentryProvider(dsn: 'YOUR_SENTRY_DSN'),
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
```

### 4. Track Events

```dart
// Log a custom event
await analyticsManager.logEvent(
  AnalyticsEvent.custom(
    name: 'purchase_completed',
    parameters: {
      'transaction_id': 'TXN123',
      'amount': 99.99,
      'currency': 'USD',
      'items': ['item1', 'item2'],
    },
  ),
);

// Log a screen view
await analyticsManager.logScreenView(
  screenName: 'HomeScreen',
  screenClass: 'HomePage',
);

// Log a user action
await analyticsManager.logUserAction(
  action: 'button_click',
  category: 'navigation',
  label: 'home_to_profile',
);
```

### 5. Report Errors

```dart
// Report a non-fatal error
try {
  await riskyOperation();
} catch (error, stackTrace) {
  await errorLogger.reportError(
    error: error,
    stackTrace: stackTrace,
    message: 'Operation failed',
    tags: {'feature': 'checkout'},
    extra: {'order_id': '12345'},
  );
}

// Report a fatal error
await errorLogger.reportFatalError(
  error: criticalError,
  stackTrace: stackTrace,
  message: 'Critical failure',
);

// Add breadcrumbs (trail of events)
await errorLogger.addBreadcrumb(
  message: 'User clicked checkout button',
  category: 'user_action',
  data: {'cart_items': 3},
);

// Log messages
await errorLogger.logInfo('User initiated checkout');
await errorLogger.logWarning('Low inventory for product');
```

### 6. Set User Context

```dart
// Set user for analytics
await analyticsManager.setUser(
  AnalyticsUser.withId('user123'),
);

// Set user for error reporting
await errorLogger.setUser(
  AnalyticsUser.withId('user123'),
);

// Set user with PII (requires consent)
await analyticsManager.setUser(
  AnalyticsUser.withFullConsent(
    userId: 'user123',
    email: 'user@example.com',
    name: 'John Doe',
    properties: {'subscription': 'premium'},
  ),
);
```

## Privacy & Consent Management

The module includes built-in privacy and consent management to help with GDPR, CCPA, and other privacy regulations.

### Privacy Configurations

```dart
// Full consent (all features enabled)
final fullConsent = PrivacyConfig.fullConsent();

// Minimal data collection (GDPR-strict)
final minimal = PrivacyConfig.minimal();

// Analytics only (no error reporting)
final analyticsOnly = PrivacyConfig.analyticsOnly();

// Error reporting only (no analytics)
final errorsOnly = PrivacyConfig.errorReportingOnly();

// Debug mode (all logging enabled)
final debug = PrivacyConfig.debug();

// Custom configuration
final custom = PrivacyConfig(
  analyticsEnabled: true,
  errorReportingEnabled: true,
  allowPII: false,  // No personally identifiable information
  collectDeviceInfo: true,
  collectLocationData: false,
  anonymizeUserIds: true,
);
```

### Consent Manager

Use `ConsentManager` to handle user consent preferences:

```dart
final consentManager = ConsentManager(
  analyticsManager: analyticsManager,
  errorLogger: errorLogger,
);

await consentManager.initialize();

// Request consent from user
await consentManager.requestConsent(
  analyticsConsent: true,
  crashReportingConsent: true,
  piiConsent: false,
);

// Check consent status
final hasAnalyticsConsent = await consentManager.hasAnalyticsConsent();
final hasCrashConsent = await consentManager.hasCrashReportingConsent();
final hasPIIConsent = await consentManager.hasPIIConsent();

// Update individual consents
await consentManager.setAnalyticsConsent(false);  // User opts out
await consentManager.setPIIConsent(true);  // User grants PII

// Grant/revoke all
await consentManager.grantAllConsent();
await consentManager.revokeAllConsent();

// Export consent data (GDPR data export)
final consentData = await consentManager.exportConsentData();
```

## Advanced Usage

### Automatic Screen Tracking (Firebase Analytics)

For automatic screen tracking with navigation:

```dart
final firebaseProvider = analyticsManager.getProvider<FirebaseAnalyticsProvider>();

MaterialApp(
  navigatorObservers: [
    if (firebaseProvider != null)
      firebaseProvider.getNavigatorObserver(),
  ],
  // ...
);
```

### Custom Tags and Context

```dart
// Set custom tags for error reports
await errorLogger.setTags({
  'environment': 'production',
  'feature': 'checkout',
  'version': '1.2.3',
});

// Set custom context
await errorLogger.setContext(
  key: 'subscription_tier',
  value: 'premium',
);
```

### Session Management

```dart
// Set session timeout
await analyticsManager.setSessionTimeout(Duration(minutes: 30));

// Reset analytics on logout
await analyticsManager.reset();
await errorLogger.clearUser();
```

### Accessing Provider-Specific Features

```dart
// Get specific provider
final sentryProvider = errorLogger.getProvider<SentryProvider>();
if (sentryProvider != null) {
  // Use Sentry-specific features
}

final crashlyticsProvider = errorLogger.getProvider<CrashlyticsProvider>();
if (crashlyticsProvider != null) {
  // Check for unsent reports
  final hasUnsent = await crashlyticsProvider.checkForUnsentReports();

  // Test crash (debug only)
  await crashlyticsProvider.testCrash();
}
```

## Configuration Examples

### Development Configuration

```dart
final config = AnalyticsLoggingConfig.debug(
  sentryDsn: 'YOUR_SENTRY_DSN',
  appContext: AppContext(
    appVersion: '1.0.0-dev',
    environment: 'development',
  ),
);
```

### Production Configuration

```dart
final config = AnalyticsLoggingConfig.production(
  privacyConfig: PrivacyConfig(
    analyticsEnabled: true,
    errorReportingEnabled: true,
    allowPII: false,  // No PII in production without consent
    anonymizeUserIds: true,
  ),
  sentryDsn: 'YOUR_SENTRY_DSN',
  appContext: AppContext(
    appVersion: '1.0.0',
    buildNumber: '42',
    environment: 'production',
  ),
);
```

## Best Practices

### 1. Initialize Early

Initialize analytics and error reporting as early as possible in your app lifecycle:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize analytics & error logging
  await analyticsManager.initialize();
  await errorLogger.initialize();

  runApp(MyApp());
}
```

### 2. Handle Consent Before Collecting Data

Always check user consent before enabling analytics:

```dart
final consentManager = ConsentManager(
  analyticsManager: analyticsManager,
  errorLogger: errorLogger,
  requireExplicitConsent: true,  // GDPR mode
);

await consentManager.initialize();

// Show consent dialog to user...
// Then update consent
await consentManager.requestConsent(
  analyticsConsent: userAccepted,
  crashReportingConsent: userAccepted,
);
```

### 3. Add Breadcrumbs for Context

Add breadcrumbs to track user journey before errors:

```dart
await errorLogger.addBreadcrumb(
  message: 'User viewed product details',
  category: 'navigation',
  data: {'product_id': '123'},
);

await errorLogger.addBreadcrumb(
  message: 'User added to cart',
  category: 'user_action',
);

// If error occurs, breadcrumbs will be attached
```

### 4. Use Tags for Filtering

Use consistent tags to filter and group errors:

```dart
await errorLogger.setTags({
  'feature': 'checkout',
  'payment_provider': 'stripe',
  'user_type': 'premium',
});
```

### 5. Sanitize Sensitive Data

Never log sensitive information:

```dart
// BAD - includes sensitive data
await errorLogger.reportError(
  error: error,
  extra: {
    'credit_card': '4111111111111111',  // Don't do this!
    'password': 'secret123',  // Don't do this!
  },
);

// GOOD - sanitized data
await errorLogger.reportError(
  error: error,
  extra: {
    'payment_method': 'credit_card',
    'last_four': '1111',
  },
);
```

### 6. Clean Up on Logout

Clear user data when user logs out:

```dart
Future<void> logout() async {
  // Clear user context
  await analyticsManager.reset();
  await errorLogger.clearUser();

  // Optionally revoke consent
  await consentManager.revokeAllConsent();
}
```

## Error Severity Levels

```dart
// Info - informational message
await errorLogger.logMessage(
  'User completed tutorial',
  level: ErrorSeverity.info,
);

// Warning - potential issue
await errorLogger.reportError(
  error: 'Low disk space',
  severity: ErrorSeverity.warning,
);

// Error - recoverable error
await errorLogger.reportError(
  error: exception,
  severity: ErrorSeverity.error,
);

// Fatal - crash
await errorLogger.reportFatalError(
  error: criticalError,
);
```

## Testing

Run tests for the module:

```bash
flutter test lib/features/analytics_logging/tests/
```

## Dependencies

Required dependencies (add to `pubspec.yaml`):

```yaml
dependencies:
  # Firebase (if using Firebase providers)
  firebase_core: ^4.2.1
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0

  # Sentry (if using Sentry)
  sentry_flutter: ^7.0.0

  # For consent management
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
```

## License

This module is part of the reusable_widgets project.

## Support

For setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md).

For complete technical specification, see [SPECIFICATION.md](SPECIFICATION.md).
