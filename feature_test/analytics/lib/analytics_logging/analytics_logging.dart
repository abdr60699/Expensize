/// Analytics & Logging Module
///
/// Production-ready analytics and error reporting for Flutter apps.
///
/// Provides a unified API for tracking events and capturing errors across
/// multiple providers (Firebase Analytics, Sentry, Firebase Crashlytics).
///
/// ## Quick Start
///
/// ```dart
/// import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';
///
/// // Set up analytics
/// final analyticsManager = AnalyticsManager(
///   providers: [FirebaseAnalyticsProvider()],
/// );
/// await analyticsManager.initialize();
///
/// // Set up error logging
/// final errorLogger = ErrorLogger(
///   providers: [
///     SentryProvider(dsn: 'YOUR_DSN'),
///     CrashlyticsProvider(),
///   ],
/// );
/// await errorLogger.initialize();
///
/// // Track events
/// await analyticsManager.logEvent(
///   AnalyticsEvent.custom(name: 'purchase', parameters: {'amount': 99.99}),
/// );
///
/// // Report errors
/// await errorLogger.reportError(
///   error: error,
///   stackTrace: stackTrace,
/// );
/// ```
///
/// For detailed documentation, see README.md and SETUP_GUIDE.md.
library analytics_logging;

// Models
export 'models/analytics_event.dart';
export 'models/analytics_user.dart';
export 'models/error_report.dart';
export 'models/privacy_config.dart';

// Core
export 'core/analytics_manager.dart';
export 'core/error_logger.dart';
export 'core/analytics_config.dart';

// Provider Interfaces
export 'providers/analytics_provider.dart';
export 'providers/error_provider.dart';

// Provider Implementations
export 'providers/firebase_analytics_provider.dart';
export 'providers/sentry_provider.dart';
export 'providers/crashlytics_provider.dart';

// Services
export 'services/consent_manager.dart';
