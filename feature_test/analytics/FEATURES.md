# Analytics Module Features

Complete guide to all features and capabilities available in the Analytics & Logging module.

## Table of Contents

- [Analytics Tracking](#analytics-tracking)
- [Error Reporting](#error-reporting)
- [Privacy & Compliance](#privacy--compliance)
- [Multi-Provider Support](#multi-provider-support)
- [Session Management](#session-management)
- [User Context & Properties](#user-context--properties)
- [Breadcrumb Tracking](#breadcrumb-tracking)

---

## Analytics Tracking

Track user behavior, events, and interactions across your Flutter application.

### Event Tracking

Track custom events with parameters to understand user behavior.

**What you can do:**
- Log custom events with parameters
- Track user actions and interactions
- Monitor business metrics (purchases, conversions, etc.)
- A/B test tracking
- Funnel analysis
- Campaign tracking

**Event Types:**
- **Custom Events**: Any application-specific event
- **Screen Views**: Page/screen navigation tracking
- **User Actions**: Button clicks, form submissions, etc.

**Example - Custom Event:**
```dart
await analyticsManager.logEvent(
  AnalyticsEvent.custom(
    name: 'purchase_completed',
    parameters: {
      'amount': 99.99,
      'currency': 'USD',
      'item_count': 3,
      'payment_method': 'credit_card',
      'category': 'electronics',
    },
  ),
);
```

**Example - Screen View:**
```dart
await analyticsManager.logScreenView(
  screenName: 'ProductDetailsScreen',
  screenClass: 'ProductDetails',
);
```

**Example - User Action:**
```dart
await analyticsManager.logUserAction(
  action: 'add_to_cart',
  category: 'ecommerce',
  label: 'product_123',
  value: 49.99,
  additionalParameters: {
    'product_name': 'Wireless Headphones',
    'quantity': 2,
    'variant': 'black',
  },
);
```

---

### Use Cases

**E-commerce Applications:**
- Track product views, cart additions, purchases
- Monitor conversion funnels
- Analyze cart abandonment
- Track search queries and results
- Revenue tracking

**Content Apps:**
- Article/video views
- Content engagement (time spent, scroll depth)
- Share tracking
- Comment interactions
- Bookmark/favorite actions

**Gaming Apps:**
- Level completion
- Achievement unlocks
- In-app purchases
- Player progression
- Session length

**Social Apps:**
- Post creation/deletion
- Likes, comments, shares
- Friend/follow actions
- Message sending
- Profile updates

---

### Screen View Tracking

Automatically or manually track which screens users visit.

**What you can do:**
- Track screen navigation
- Measure time spent per screen
- Understand user flow
- Identify popular features
- Find navigation bottlenecks

**Manual Tracking:**
```dart
class ProductDetailsScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    analyticsManager.logScreenView(
      screenName: 'ProductDetails',
      screenClass: 'ProductDetailsScreen',
    );
  }
}
```

**With Parameters:**
```dart
await analyticsManager.logScreenView(
  screenName: 'ProductDetails',
  screenClass: 'ProductDetailsScreen',
  additionalParameters: {
    'product_id': '12345',
    'category': 'electronics',
    'source': 'search_results',
  },
);
```

---

## Error Reporting

Comprehensive error and crash reporting with context.

### Crash Reporting

Automatically capture and report app crashes.

**What you can do:**
- Automatic crash detection
- Full stack traces
- App state at crash time
- Device and OS information
- Crash-free user percentage
- Issue prioritization by impact

**Supported Providers:**
- Firebase Crashlytics
- Sentry

**Setup:**
```dart
final errorLogger = ErrorLogger(
  providers: [
    CrashlyticsProvider(),
    SentryProvider(dsn: 'YOUR_SENTRY_DSN'),
  ],
  privacyConfig: PrivacyConfig.fullConsent(),
);

await errorLogger.initialize();
```

**Fatal Error Reporting:**
```dart
try {
  await criticalOperation();
} catch (error, stackTrace) {
  await errorLogger.reportFatalError(
    error: error,
    stackTrace: stackTrace,
    message: 'Critical operation failed',
    tags: {
      'operation': 'data_sync',
      'severity': 'critical',
    },
    extra: {
      'user_id': currentUserId,
      'operation_type': 'sync',
      'retry_count': 3,
    },
  );
}
```

---

### Non-Fatal Error Reporting

Track handled errors that don't crash the app.

**What you can do:**
- Report caught exceptions
- Log error messages with context
- Track error frequency
- Associate errors with features
- Set custom severity levels
- Add additional metadata

**Severity Levels:**
- **Info**: Informational messages (not actual errors)
- **Warning**: Potential issues, degraded functionality
- **Error**: Handled errors that affect functionality
- **Fatal**: Critical crashes that terminate the app

**Example - Non-Fatal Error:**
```dart
try {
  final data = await fetchUserData();
} catch (error, stackTrace) {
  await errorLogger.reportError(
    error: error,
    stackTrace: stackTrace,
    message: 'Failed to fetch user data',
    severity: ErrorSeverity.error,
    tags: {
      'feature': 'user_profile',
      'api': 'user_data',
    },
    extra: {
      'user_id': userId,
      'retry_attempt': 1,
      'network_status': 'online',
    },
  );

  // Show error to user, use cached data, etc.
  return cachedData;
}
```

**Example - Warning:**
```dart
await errorLogger.reportError(
  error: Exception('API response time exceeded threshold'),
  message: 'Slow API response detected',
  severity: ErrorSeverity.warning,
  tags: {
    'api': 'products',
    'endpoint': '/api/v1/products',
  },
  extra: {
    'response_time_ms': 3500,
    'threshold_ms': 2000,
  },
);
```

---

### Error Context

Add rich context to errors for better debugging.

**What you can include:**
- User ID (with consent)
- App version and build number
- Device type and OS version
- Custom tags for categorization
- Additional data (JSON-serializable)
- Breadcrumbs (event trail)
- Network status
- Memory usage
- Custom context values

**Example with Full Context:**
```dart
final errorReport = ErrorReport.error(
  error: exception,
  stackTrace: stackTrace,
  message: 'Payment processing failed',
  userId: user.id,
  appContext: AppContext(
    appName: 'MyApp',
    appVersion: '2.1.0',
    buildNumber: '142',
    environment: 'production',
    platform: Platform.operatingSystem,
  ),
  tags: {
    'feature': 'checkout',
    'payment_provider': 'stripe',
    'payment_method': 'credit_card',
  },
  extra: {
    'order_id': orderId,
    'amount': amount,
    'currency': 'USD',
    'retry_count': retryCount,
    'network_available': isNetworkAvailable,
  },
);

await errorLogger.report(errorReport);
```

---

### Log Messages

Log informational messages alongside errors.

**What you can do:**
- Log info, warning, and error messages
- Track application flow
- Debug production issues
- Monitor system health
- Create searchable logs

**Example:**
```dart
// Info
await errorLogger.logInfo('User initiated checkout');

// Warning
await errorLogger.logWarning('API rate limit approaching');

// Error message (without exception)
await errorLogger.logMessage(
  'Database connection timeout',
  level: ErrorSeverity.error,
);
```

---

## Privacy & Compliance

GDPR and CCPA compliant privacy controls.

### Consent Management

Manage user consent for analytics and error reporting.

**What you can do:**
- Request analytics consent
- Request crash reporting consent
- Store consent preferences persistently
- Respect user privacy choices
- Comply with GDPR/CCPA
- Allow users to revoke consent
- Clear data on consent revocation

**Features:**
- Persistent storage (SharedPreferences)
- Granular consent (analytics vs crash reporting)
- Easy enable/disable
- Automatic data clearing
- Reset on user logout

**Example:**
```dart
import 'package:analytics/analytics_logging/services/consent_manager.dart';

// Initialize consent manager
final consentManager = ConsentManager();
await consentManager.initialize();

// Check consent status
final hasAnalyticsConsent = await consentManager.hasAnalyticsConsent();
final hasCrashConsent = await consentManager.hasCrashReportingConsent();

// Request consent (show dialog to user)
final userGrantedConsent = await showConsentDialog();

if (userGrantedConsent) {
  // Grant both consents
  await consentManager.grantConsent();

  // Enable services
  await analyticsManager.enable();
  await errorLogger.enable();
} else {
  // Revoke consents
  await consentManager.revokeConsent();

  // Disable services
  await analyticsManager.disable();
  await errorLogger.disable();
}

// On user logout, reset consent (if required by privacy policy)
await consentManager.clear();
```

---

### Privacy Configuration

Fine-grained control over data collection.

**Configuration Options:**
- **analyticsEnabled**: Enable/disable analytics tracking
- **crashReportingEnabled**: Enable/disable error reporting
- **personalizationEnabled**: Allow personalized features
- **adTrackingEnabled**: Allow advertising tracking
- **enableDebugLogging**: Verbose logging (dev only)

**Pre-configured Settings:**

```dart
// Full consent (all features)
const config = PrivacyConfig.fullConsent();

// Analytics only (no crash reporting)
const config = PrivacyConfig.analyticsOnly();

// Error reporting only (no analytics)
const config = PrivacyConfig.errorReportingOnly();

// Debug mode (everything enabled with logging)
const config = PrivacyConfig.debug();

// Custom configuration
const config = PrivacyConfig(
  analyticsEnabled: true,
  crashReportingEnabled: true,
  personalizationEnabled: false,
  adTrackingEnabled: false,
  enableDebugLogging: false,
);
```

---

### Data Minimization

Collect only necessary data to respect privacy.

**Best Practices:**

```dart
// ❌ Don't collect sensitive data
await analyticsManager.logEvent(
  AnalyticsEvent.custom(
    name: 'search',
    parameters: {
      'query': userSearchText,  // DON'T: Contains PII
      'email': userEmail,       // DON'T: PII
    },
  ),
);

// ✅ Do collect aggregated/anonymized data
await analyticsManager.logEvent(
  AnalyticsEvent.custom(
    name: 'search',
    parameters: {
      'results_count': 42,
      'category': 'electronics',
      'has_results': true,
    },
  ),
);
```

**Only set user data with consent:**
```dart
if (user.hasAnalyticsConsent) {
  await analyticsManager.setUser(user);
} else {
  // Only set anonymized ID
  await analyticsManager.setUserId(anonymizedUserId);
}
```

---

### Data Clearing

Clear user data on logout or consent revocation.

**Example:**
```dart
Future<void> handleUserLogout() async {
  // Clear analytics data
  await analyticsManager.reset();

  // Clear error reporting context
  await errorLogger.clearUser();

  // Optionally clear consent (if policy requires)
  await consentManager.clear();
}
```

---

## Multi-Provider Support

Use multiple analytics and error reporting providers simultaneously.

### Supported Analytics Providers

**Firebase Analytics:**
- Free, unlimited events
- Integration with Firebase ecosystem
- Google Analytics 4 integration
- Automatic mobile insights
- Audience building

**Future Providers:**
- Amplitude (coming soon)
- Mixpanel (coming soon)
- Segment (coming soon)
- Custom providers (extensible)

---

### Supported Error Providers

**Firebase Crashlytics:**
- Free crash reporting
- Real-time crash alerts
- Crash-free users metric
- Integration with Firebase
- Automatic symbolication

**Sentry:**
- Detailed error tracking
- Performance monitoring
- Release tracking
- Source maps support
- Issue assignment and workflow

---

### Provider Configuration

**Using Multiple Providers:**
```dart
// Analytics with Firebase
final analyticsManager = AnalyticsManager(
  providers: [
    FirebaseAnalyticsProvider(),
    // Add more providers as needed
  ],
);

// Error reporting with Crashlytics and Sentry
final errorLogger = ErrorLogger(
  providers: [
    CrashlyticsProvider(),
    SentryProvider(
      dsn: 'YOUR_SENTRY_DSN',
      environment: 'production',
    ),
  ],
);
```

**Provider-Specific Features:**
```dart
// Get Firebase-specific observer for navigation
final firebaseProvider =
    analyticsManager.getProvider<FirebaseAnalyticsProvider>();

if (firebaseProvider != null) {
  final observer = firebaseProvider.getNavigatorObserver();

  // Use in MaterialApp
  MaterialApp(
    navigatorObservers: [observer],
    // ...
  );
}

// Get Sentry provider for advanced features
final sentryProvider = errorLogger.getProvider<SentryProvider>();
if (sentryProvider != null) {
  // Use Sentry-specific features
}
```

---

## Session Management

Track user sessions and engagement.

### Session Tracking

**What you can track:**
- Session start/end times
- Session duration
- Sessions per user
- Average session length
- Engagement metrics

**Configuration:**
```dart
// Set session timeout (default: 30 minutes)
await analyticsManager.setSessionTimeout(
  Duration(minutes: 30),
);
```

**Session automatically tracks:**
- First open
- Session start
- Session end (after timeout)
- App foreground/background

---

## User Context & Properties

Associate analytics and errors with users.

### User Identification

**What you can do:**
- Set user ID
- Track user across sessions
- User-level metrics
- Cohort analysis
- User retention tracking

**Example:**
```dart
// Just set user ID
await analyticsManager.setUserId('user_12345');

// Full user with consent
final user = AnalyticsUser.withFullConsent(
  userId: 'user_12345',
  email: 'user@example.com',
  properties: {
    'name': 'John Doe',
    'signup_date': '2024-01-15',
  },
);

await analyticsManager.setUser(user);
await errorLogger.setUser(user);
```

---

### User Properties

Custom attributes for user segmentation.

**What you can track:**
- Subscription tier
- User type (free, premium, enterprise)
- Preferences
- Demographics (with consent)
- Account age
- Lifetime value

**Example:**
```dart
// Set individual property
await analyticsManager.setUserProperty(
  name: 'subscription_tier',
  value: 'premium',
);

await analyticsManager.setUserProperty(
  name: 'preferred_language',
  value: 'en',
);

// Include in user object
final user = AnalyticsUser.withFullConsent(
  userId: 'user_123',
  properties: {
    'subscription_tier': 'premium',
    'account_type': 'business',
    'signup_method': 'google',
    'onboarding_completed': 'true',
    'feature_flags': 'new_ui,beta_features',
  },
);

await analyticsManager.setUser(user);
```

---

## Breadcrumb Tracking

Track events leading up to errors.

### What are Breadcrumbs?

Breadcrumbs are a trail of events that show what the user did before an error occurred.

**What you can track:**
- User actions (button clicks, form submissions)
- Navigation (screen changes)
- Network requests
- State changes
- System events

**Benefits:**
- Reproduce errors more easily
- Understand user context
- Debug production issues
- Identify patterns in errors

**Example:**
```dart
// Track user action
await errorLogger.addBreadcrumb(
  message: 'User tapped checkout button',
  category: 'user_action',
  data: {
    'screen': 'cart',
    'items_count': 3,
    'total': 99.99,
  },
);

// Track navigation
await errorLogger.addBreadcrumb(
  message: 'Navigated to checkout screen',
  category: 'navigation',
  data: {
    'from': 'cart',
    'to': 'checkout',
  },
);

// Track network request
await errorLogger.addBreadcrumb(
  message: 'API request started',
  category: 'network',
  data: {
    'url': 'https://api.example.com/checkout',
    'method': 'POST',
  },
);

// Track state change
await errorLogger.addBreadcrumb(
  message: 'Payment processing started',
  category: 'state_change',
  data: {
    'payment_method': 'credit_card',
    'amount': 99.99,
  },
);

// When error occurs, breadcrumbs are automatically included
try {
  await processPayment();
} catch (error, stackTrace) {
  // This error report will include all breadcrumbs
  await errorLogger.reportError(
    error: error,
    stackTrace: stackTrace,
  );
}
```

**Breadcrumb Timeline Example:**
```
1. [user_action] User tapped checkout button (cart, 3 items, $99.99)
2. [navigation] Navigated to checkout screen (from cart)
3. [user_action] User entered payment details
4. [network] API request started (POST /checkout)
5. [state_change] Payment processing started (credit_card, $99.99)
6. [error] Payment processing failed (network timeout)
```

---

## Advanced Features

### Custom Context

Add custom data to all errors.

```dart
// Set global context
await errorLogger.setContext(
  key: 'app_theme',
  value: 'dark',
);

await errorLogger.setContext(
  key: 'feature_flags',
  value: ['new_checkout', 'beta_ui'],
);
```

---

### Tags

Categorize events and errors with tags.

```dart
// Set tags for filtering/searching
await errorLogger.setTags({
  'environment': 'production',
  'version': '2.1.0',
  'platform': 'android',
  'user_type': 'premium',
});

// Tags in error reports
await errorLogger.reportError(
  error: error,
  stackTrace: stackTrace,
  tags: {
    'feature': 'checkout',
    'payment_provider': 'stripe',
    'checkout_step': 'payment',
  },
);
```

---

### Cached Error Reporting

Handle offline scenarios gracefully.

```dart
// Errors are automatically cached when offline
await errorLogger.reportError(
  error: error,
  stackTrace: stackTrace,
);

// Manually send cached errors when back online
await errorLogger.sendCachedErrors();
```

---

## Performance Considerations

### Efficiency

- **Async Operations**: All tracking is asynchronous and non-blocking
- **Batching**: Events are batched before sending
- **Background Processing**: Network calls happen in background
- **Memory**: Minimal memory footprint
- **Battery**: Optimized for battery life

### Best Practices

```dart
// ✅ Fire and forget (don't await unless necessary)
analyticsManager.logEvent(event);  // Don't block UI

// ✅ Batch operations
final events = [event1, event2, event3];
await Future.wait(
  events.map((e) => analyticsManager.logEvent(e)),
);

// ❌ Don't track too frequently
// Avoid tracking every scroll event, for example
```

---

## Testing

### Mock Providers

Create mock providers for testing.

```dart
class MockAnalyticsProvider implements AnalyticsProvider {
  final List<AnalyticsEvent> events = [];

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    events.add(event);
  }

  // ... implement other methods
}

// Use in tests
void main() {
  test('logs event correctly', () async {
    final mockProvider = MockAnalyticsProvider();
    final manager = AnalyticsManager(providers: [mockProvider]);

    await manager.initialize();
    await manager.logEvent(
      AnalyticsEvent.custom(name: 'test'),
    );

    expect(mockProvider.events.length, 1);
    expect(mockProvider.events.first.name, 'test');
  });
}
```

---

## Summary

The Analytics module provides:

✅ **Event Tracking**: Custom events, screen views, user actions
✅ **Error Reporting**: Crash reports, non-fatal errors, context
✅ **Privacy Compliance**: GDPR/CCPA consent management
✅ **Multi-Provider**: Firebase, Sentry, extensible architecture
✅ **User Context**: User properties, identification, segmentation
✅ **Breadcrumbs**: Event trails for error reproduction
✅ **Session Tracking**: Automatic session management
✅ **Type Safety**: Strongly typed events and configurations
✅ **Testable**: Mock-friendly architecture
✅ **Production-Ready**: Battle-tested, performant, reliable

All designed to help you understand user behavior, catch errors early, and respect user privacy.
