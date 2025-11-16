# Analytics & Logging Module - Technical Specification

## Overview

Production-ready analytics and error reporting module providing a unified API for tracking events and capturing errors across multiple providers (Firebase Analytics, Sentry, Firebase Crashlytics).

## Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                        Application                           │
└───────────────────┬─────────────────────┬───────────────────┘
                    │                     │
         ┌──────────▼──────────┐ ┌───────▼──────────┐
         │  AnalyticsManager   │ │   ErrorLogger    │
         └──────────┬──────────┘ └───────┬──────────┘
                    │                     │
        ┌───────────┴────────┐    ┌──────┴────────┐
        │   PrivacyConfig    │    │ ConsentManager│
        └───────────┬────────┘    └──────┬────────┘
                    │                     │
    ┌───────────────┴──────────────────────────────────┐
    │             Provider Abstraction Layer            │
    ├─────────────────┬─────────────┬───────────────────┤
    │ AnalyticsProvider│             │ ErrorProvider     │
    └─────────────────┴─────────────┴───────────────────┘
                      │
       ┌──────────────┼──────────────┐
       │              │               │
┌──────▼──────┐ ┌────▼─────┐ ┌──────▼────────┐
│Firebase      │ │  Sentry  │ │ Crashlytics   │
│Analytics     │ │          │ │               │
└──────────────┘ └──────────┘ └───────────────┘
```

## Data Models

### AnalyticsEvent
Represents a user interaction or system event to be tracked.

**Properties:**
- `name` (String): Event identifier (max 40 chars, alphanumeric + underscore)
- `parameters` (Map<String, dynamic>?): Event data
- `timestamp` (DateTime): When event occurred
- `userId` (String?): Associated user ID
- `sessionId` (String?): Session identifier

**Factory Methods:**
- `screenView()`: Create screen view event
- `userAction()`: Create user interaction event
- `custom()`: Create custom event

**Validation:**
- Event name: 1-40 characters, starts with letter, alphanumeric + underscore only
- Parameter keys: 1-40 characters, alphanumeric + underscore only

### AnalyticsUser
Represents user identity and properties for analytics tracking.

**Properties:**
- `userId` (String?): Unique user identifier
- `properties` (Map<String, dynamic>?): User attributes
- `email` (String?): User email (PII - requires consent)
- `phoneNumber` (String?): Phone number (PII - requires consent)
- `name` (String?): User name (PII - requires consent)
- `hasAnalyticsConsent` (bool): Analytics consent granted
- `hasCrashReportingConsent` (bool): Error reporting consent granted
- `canSendPII` (bool): PII collection allowed

**Factory Methods:**
- `anonymous()`: Anonymous user with no data
- `withId()`: User with ID only (no PII)
- `withFullConsent()`: User with full consent and PII

**Methods:**
- `sanitized`: Returns version with PII removed
- `getAnalyticsProperties()`: Get properties for analytics providers
- `getErrorContextProperties()`: Get properties for error providers

### ErrorReport
Represents an error or crash to be reported.

**Properties:**
- `error` (dynamic): The error/exception object
- `stackTrace` (StackTrace?): Stack trace
- `severity` (ErrorSeverity): Severity level (info, warning, error, fatal, debug)
- `message` (String?): Human-readable description
- `tags` (Map<String, String>?): Categorization tags
- `extra` (Map<String, dynamic>?): Additional context
- `userId` (String?): Associated user
- `isFatal` (bool): Whether this caused a crash
- `timestamp` (DateTime): When error occurred
- `appContext` (AppContext?): Application state

**Factory Methods:**
- `fatal()`: Create fatal error report
- `error()`: Create non-fatal error
- `warning()`: Create warning
- `info()`: Create info message

### ErrorSeverity
Enumeration of error severity levels:
- `debug`: Debug information
- `info`: Informational message
- `warning`: Potential issue
- `error`: Recoverable error
- `fatal`: Critical crash

### PrivacyConfig
Configuration for privacy compliance and data collection.

**Properties:**
- `analyticsEnabled` (bool): Analytics collection allowed
- `errorReportingEnabled` (bool): Error reporting allowed
- `allowPII` (bool): PII collection permitted
- `collectDeviceInfo` (bool): Device data collection
- `collectLocationData` (bool): Location data collection
- `collectIPAddress` (bool): IP address collection
- `piiFieldsToFilter` (Set<String>): Fields to auto-filter
- `anonymizeUserIds` (bool): Hash user IDs
- `collectPerformanceMetrics` (bool): Performance monitoring
- `enableDebugLogging` (bool): Debug output

**Factory Methods:**
- `fullConsent()`: All features enabled
- `minimal()`: GDPR-strict mode (minimal data)
- `analyticsOnly()`: Analytics only, no errors
- `errorReportingOnly()`: Errors only, no analytics
- `debug()`: Development mode with full logging

**Methods:**
- `isPIIField()`: Check if field name is PII
- `filterPII()`: Remove PII from data map
- `anonymizeUserId()`: Hash user ID

### AppContext
Application state information for error reports.

**Properties:**
- `appVersion` (String?): Application version
- `buildNumber` (String?): Build number
- `environment` (String?): Environment (prod, staging, dev)
- `deviceInfo` (DeviceInfo?): Device details
- `currentScreen` (String?): Active screen/route
- `custom` (Map<String, dynamic>?): Custom context

### DeviceInfo
Device information for error context.

**Properties:**
- `os` (String?): Operating system
- `osVersion` (String?): OS version
- `model` (String?): Device model
- `manufacturer` (String?): Device manufacturer
- `isPhysicalDevice` (bool?): Physical vs emulator
- `screenSize` (String?): Screen dimensions
- `locale` (String?): Device locale

## Provider Interfaces

### AnalyticsProvider
Abstract interface for analytics implementations.

**Required Methods:**
- `initialize()`: Set up provider
- `logEvent()`: Track event
- `logScreenView()`: Track screen view
- `setUserProperties()`: Set user data
- `setUserProperty()`: Set single property
- `setUserId()`: Set user ID
- `resetAnalytics()`: Clear data
- `enable()`: Enable tracking
- `disable()`: Disable tracking
- `setSessionTimeout()`: Configure session
- `setMinimumSessionDuration()`: Set minimum session time
- `dispose()`: Cleanup

### ErrorProvider
Abstract interface for error reporting implementations.

**Required Methods:**
- `initialize()`: Set up provider
- `reportError()`: Report non-fatal error
- `reportFatalError()`: Report crash
- `logMessage()`: Log message
- `addBreadcrumb()`: Add breadcrumb trail
- `setUserContext()`: Set user data
- `setContext()`: Set custom context
- `setTags()`: Set tags
- `clearUserContext()`: Clear user
- `enable()`: Enable reporting
- `disable()`: Disable reporting
- `sendCachedErrors()`: Send queued errors
- `dispose()`: Cleanup

## Core Services

### AnalyticsManager
Unified manager for analytics tracking.

**Responsibilities:**
- Initialize analytics providers
- Route events to enabled providers
- Manage user properties
- Handle consent changes
- Provide provider-agnostic API

**Key Methods:**
- `initialize()`: Initialize all providers
- `logEvent()`: Track event
- `logScreenView()`: Track screen
- `logUserAction()`: Track user action
- `setUser()`: Set user context
- `setUserId()`: Set user ID
- `setUserProperty()`: Set user property
- `reset()`: Clear all data
- `enable()/disable()`: Toggle tracking
- `getProvider<T>()`: Access specific provider

### ErrorLogger
Unified logger for error and crash reporting.

**Responsibilities:**
- Initialize error providers
- Route errors to enabled providers
- Manage breadcrumbs
- Handle consent changes
- Set up global error handlers
- Provide provider-agnostic API

**Key Methods:**
- `initialize()`: Initialize all providers
- `reportError()`: Report non-fatal error
- `reportFatalError()`: Report crash
- `report()`: Report ErrorReport object
- `logMessage()/logInfo()/logWarning()`: Log messages
- `addBreadcrumb()`: Add breadcrumb
- `setUser()`: Set user context
- `setContext()`: Set context key
- `setTags()`: Set tags
- `clearUser()`: Clear user data
- `enable()/disable()`: Toggle reporting
- `sendCachedErrors()`: Flush queue
- `getProvider<T>()`: Access specific provider

### ConsentManager
Service for managing user consent preferences.

**Responsibilities:**
- Store consent preferences (persistent)
- Apply consent to managers
- Support GDPR/CCPA compliance
- Track consent timestamps
- Export consent data

**Key Methods:**
- `initialize()`: Load stored consent
- `hasAnalyticsConsent()`: Check analytics consent
- `hasCrashReportingConsent()`: Check error consent
- `hasPIIConsent()`: Check PII consent
- `requestConsent()`: Update consent
- `grantAllConsent()`: Grant all
- `revokeAllConsent()`: Revoke all
- `setAnalyticsConsent()`: Update analytics only
- `setCrashReportingConsent()`: Update errors only
- `setPIIConsent()`: Update PII only
- `clearConsent()`: Reset to defaults
- `getPrivacyConfig()`: Get current privacy config
- `exportConsentData()`: Export for GDPR

**Storage:**
- Uses `SharedPreferences` for persistence
- Opt-out model by default (consent assumed unless revoked)
- Opt-in model when `requireExplicitConsent: true`

## Provider Implementations

### FirebaseAnalyticsProvider
Implementation for Google Firebase Analytics.

**Features:**
- Event tracking
- Screen view tracking
- User properties
- Automatic session tracking
- Navigator observer for auto screen tracking

**Constraints:**
- Event names: 1-40 chars, alphanumeric + underscore
- Parameter keys: 1-40 chars, alphanumeric + underscore
- Parameter values: max 100 chars (strings)
- Max 25 user properties

### SentryProvider
Implementation for Sentry error tracking.

**Features:**
- Error and crash reporting
- Breadcrumb tracking
- Context and tags
- User tracking
- Performance monitoring (optional)
- Screenshot attachments

**Configuration:**
- DSN (required)
- Environment (production, staging, development)
- Traces sample rate (0.0-1.0)
- Send default PII (controlled by PrivacyConfig)

### CrashlyticsProvider
Implementation for Firebase Crashlytics.

**Features:**
- Crash reporting
- Non-fatal error reporting
- Custom keys (context)
- Logs/breadcrumbs
- User identification
- Automatic crash detection

**Global Handlers:**
- Sets up `FlutterError.onError` for Flutter errors
- Sets up `PlatformDispatcher.onError` for async errors

## Data Flow

### Event Tracking Flow

```
User Action
    ↓
logEvent(AnalyticsEvent)
    ↓
AnalyticsManager
    ↓
Privacy Check (PrivacyConfig)
    ↓
PII Filtering
    ↓
For each enabled provider:
    ↓
AnalyticsProvider.logEvent()
    ↓
Firebase Analytics / Other Provider
```

### Error Reporting Flow

```
Exception/Error
    ↓
reportError(error, stackTrace, ...)
    ↓
ErrorLogger
    ↓
Privacy Check (PrivacyConfig)
    ↓
PII Filtering
    ↓
Create ErrorReport
    ↓
For each enabled provider:
    ↓
ErrorProvider.reportError()
    ↓
Sentry / Crashlytics / Other Provider
```

### Consent Flow

```
User Grants/Revokes Consent
    ↓
ConsentManager.requestConsent()
    ↓
Store in SharedPreferences
    ↓
Update AnalyticsManager (enable/disable)
    ↓
Update ErrorLogger (enable/disable)
    ↓
Providers stop/start collection
```

## Privacy & Compliance

### PII Handling

**Automatic PII Filtering:**
- Filters fields: email, phone, name, address, ssn, password, token, api_key, etc.
- Applied when `allowPII: false`
- Can be customized via `piiFieldsToFilter` set

**User ID Anonymization:**
- Optional hashing of user IDs
- Enabled via `anonymizeUserIds: true`
- Simple hash (can be replaced with crypto hash)

### GDPR Compliance

**Consent Management:**
- Explicit consent tracking
- Timestamp recording
- Data export capability
- Consent revocation support

**Opt-in vs Opt-out:**
- Default: Opt-out (consent assumed)
- GDPR mode: Opt-in (`requireExplicitConsent: true`)

### CCPA Compliance

**Do Not Sell:**
- Disable analytics: `setAnalyticsConsent(false)`
- Disable errors: `setCrashReportingConsent(false)`

**Data Deletion:**
- `reset()`: Clears local data
- Backend deletion: must be handled server-side

## Testing Strategy

**Unit Tests:**
- Model serialization/deserialization
- Privacy config filtering
- Consent manager persistence
- Manager routing logic

**Integration Tests:**
- Provider initialization
- Event/error routing
- Consent application
- Cross-provider coordination

**Mock Providers:**
- In-memory event tracking
- Verification of calls
- No external dependencies

## Performance Considerations

**Async Operations:**
- All provider calls are async
- Non-blocking event logging
- Background error reporting

**Batching:**
- Providers handle their own batching
- Firebase: automatic batching
- Sentry: automatic batching

**Error Queuing:**
- Providers queue errors when offline
- Automatic retry on reconnect
- Crashlytics: queues until next launch

## Security

**Data Transmission:**
- HTTPS only (enforced by providers)
- Firebase: encrypted
- Sentry: encrypted

**Local Storage:**
- Consent: SharedPreferences (unencrypted)
- Error queue: Provider-managed (encrypted where supported)

**Sensitive Data:**
- Never log passwords, tokens, API keys
- Filter credit card numbers
- Mask PII in logs

## Limitations

**Firebase Analytics:**
- 500 distinct events per app
- 25 user properties per app
- 24-hour delay for initial data
- Quotas on free tier

**Sentry:**
- Rate limits on free tier
- Attachment size limits
- Performance monitoring may require paid plan

**Crashlytics:**
- Crash reports may be delayed up to 10 minutes
- Limited customization
- iOS symbolication requires setup

## Future Enhancements

**Potential Additions:**
- Mixpanel provider
- Amplitude provider
- Custom analytics backend provider
- Offline queue management
- Event validation
- A/B testing integration
- Remote config integration
- User segments

## Version History

- **1.0.0** (Current): Initial release with Firebase Analytics, Sentry, Crashlytics support
