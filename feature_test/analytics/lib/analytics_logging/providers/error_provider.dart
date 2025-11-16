import '../models/error_report.dart';
import '../models/analytics_user.dart';

/// Abstract interface for error reporting providers
///
/// Implement this interface to create custom error reporting providers
/// (Sentry, Crashlytics, Bugsnag, etc.)
abstract class ErrorProvider {
  /// Provider name for identification
  String get name;

  /// Whether this provider is currently enabled
  bool get isEnabled;

  /// Initialize the error reporting provider
  ///
  /// Called once during app startup. Use this to configure
  /// the error reporting SDK and perform any required setup.
  ///
  /// Returns true if initialization was successful.
  Future<bool> initialize();

  /// Report an error
  ///
  /// [report] The error report to send
  ///
  /// Example:
  /// ```dart
  /// await provider.reportError(
  ///   ErrorReport.error(
  ///     error: exception,
  ///     stackTrace: stackTrace,
  ///     message: 'Payment processing failed',
  ///     tags: {'feature': 'checkout'},
  ///   ),
  /// );
  /// ```
  Future<void> reportError(ErrorReport report);

  /// Report a fatal error (crash)
  ///
  /// [report] The fatal error report
  ///
  /// Example:
  /// ```dart
  /// await provider.reportFatalError(
  ///   ErrorReport.fatal(
  ///     error: error,
  ///     stackTrace: stackTrace,
  ///     message: 'App crashed during startup',
  ///   ),
  /// );
  /// ```
  Future<void> reportFatalError(ErrorReport report);

  /// Log a message for debugging
  ///
  /// [message] The message to log
  /// [level] Severity level (info, warning, error, etc.)
  ///
  /// Example:
  /// ```dart
  /// await provider.logMessage(
  ///   'User initiated checkout',
  ///   level: ErrorSeverity.info,
  /// );
  /// ```
  Future<void> logMessage(String message, {ErrorSeverity? level});

  /// Add a breadcrumb (trail of events leading to an error)
  ///
  /// [message] The breadcrumb message
  /// [category] Optional category for the breadcrumb
  /// [data] Optional additional data
  ///
  /// Example:
  /// ```dart
  /// await provider.addBreadcrumb(
  ///   message: 'User clicked checkout button',
  ///   category: 'user_action',
  ///   data: {'cart_items': 3},
  /// );
  /// ```
  Future<void> addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  });

  /// Set user context for error reports
  ///
  /// [user] The user data to associate with errors
  ///
  /// Example:
  /// ```dart
  /// await provider.setUserContext(
  ///   AnalyticsUser.withId('user123'),
  /// );
  /// ```
  Future<void> setUserContext(AnalyticsUser user);

  /// Set custom context/tags for error reports
  ///
  /// [key] Context key
  /// [value] Context value
  ///
  /// Example:
  /// ```dart
  /// await provider.setContext(
  ///   key: 'subscription_tier',
  ///   value: 'premium',
  /// );
  /// ```
  Future<void> setContext({
    required String key,
    required dynamic value,
  });

  /// Set multiple tags at once
  ///
  /// [tags] Map of tag key-value pairs
  ///
  /// Example:
  /// ```dart
  /// await provider.setTags({
  ///   'environment': 'production',
  ///   'feature': 'checkout',
  /// });
  /// ```
  Future<void> setTags(Map<String, String> tags);

  /// Clear user context (for logout)
  ///
  /// Removes all user-specific data from error reports.
  Future<void> clearUserContext();

  /// Enable error reporting
  ///
  /// Used for consent management - re-enables error collection
  /// after user grants consent.
  Future<void> enable();

  /// Disable error reporting
  ///
  /// Used for consent management - stops all error collection
  /// when user revokes consent or opts out.
  Future<void> disable();

  /// Manually check for and send any cached errors
  ///
  /// Some providers cache errors for later sending. This forces
  /// an immediate check and send.
  Future<void> sendCachedErrors();

  /// Dispose and cleanup resources
  ///
  /// Called when the provider is no longer needed.
  Future<void> dispose();
}
