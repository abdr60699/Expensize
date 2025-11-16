import 'package:flutter/foundation.dart';
import '../models/error_report.dart';
import '../models/analytics_user.dart';
import '../models/privacy_config.dart';
import '../providers/error_provider.dart';

/// Unified error logger
///
/// Provides a single API for reporting errors and crashes across multiple providers.
/// Manages provider lifecycle, consent, privacy settings, and breadcrumb tracking.
///
/// Example:
/// ```dart
/// final errorLogger = ErrorLogger(
///   providers: [SentryProvider(dsn: '...'), CrashlyticsProvider()],
///   privacyConfig: PrivacyConfig.fullConsent(),
/// );
///
/// await errorLogger.initialize();
///
/// // Report errors
/// try {
///   // risky operation
/// } catch (error, stackTrace) {
///   await errorLogger.reportError(
///     error: error,
///     stackTrace: stackTrace,
///     tags: {'feature': 'checkout'},
///   );
/// }
///
/// // Add breadcrumbs
/// await errorLogger.addBreadcrumb('User clicked checkout button');
/// ```
class ErrorLogger {
  final List<ErrorProvider> _providers;
  final PrivacyConfig privacyConfig;
  final AppContext? defaultAppContext;
  bool _isInitialized = false;
  AnalyticsUser? _currentUser;

  ErrorLogger({
    required List<ErrorProvider> providers,
    PrivacyConfig? privacyConfig,
    this.defaultAppContext,
  })  : _providers = providers,
        privacyConfig = privacyConfig ?? const PrivacyConfig();

  /// Whether error logger is initialized
  bool get isInitialized => _isInitialized;

  /// Currently set user (if any)
  AnalyticsUser? get currentUser => _currentUser;

  /// List of enabled providers
  List<ErrorProvider> get enabledProviders =>
      _providers.where((p) => p.isEnabled).toList();

  /// Initialize all error providers
  ///
  /// Call this once during app startup, after Firebase.initializeApp()
  /// if using Crashlytics.
  ///
  /// Returns true if at least one provider initialized successfully.
  Future<bool> initialize() async {
    if (_isInitialized) {
      _debugLog('Error logger already initialized');
      return true;
    }

    if (!privacyConfig.errorReportingEnabled) {
      _debugLog('Error reporting disabled by privacy config');
      return false;
    }

    if (_providers.isEmpty) {
      _debugLog('No error providers configured');
      return false;
    }

    _debugLog('Initializing ${_providers.length} error provider(s)...');

    final results = await Future.wait(
      _providers.map((provider) => provider.initialize()),
    );

    final successCount = results.where((r) => r).length;
    _isInitialized = successCount > 0;

    _debugLog('Initialized $successCount/${_providers.length} provider(s)');

    // Set up global error handlers in release mode
    if (_isInitialized && kReleaseMode) {
      _setupGlobalErrorHandlers();
    }

    return _isInitialized;
  }

  /// Report a non-fatal error
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await processPayment();
  /// } catch (error, stackTrace) {
  ///   await errorLogger.reportError(
  ///     error: error,
  ///     stackTrace: stackTrace,
  ///     message: 'Payment processing failed',
  ///     tags: {'feature': 'checkout', 'payment_method': 'card'},
  ///     extra: {'order_id': '12345'},
  ///   );
  /// }
  /// ```
  Future<void> reportError({
    required dynamic error,
    StackTrace? stackTrace,
    String? message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
    ErrorSeverity severity = ErrorSeverity.error,
  }) async {
    if (!_isInitialized || !privacyConfig.errorReportingEnabled) {
      _debugLog('Error reporting not available - skipping error');
      return;
    }

    final report = ErrorReport.error(
      error: error,
      stackTrace: stackTrace,
      message: message,
      tags: tags,
      extra: extra,
      userId: _currentUser?.userId,
      appContext: defaultAppContext,
    ).copyWith(severity: severity);

    _debugLog('Reporting error: ${report.getErrorMessage()}');

    await Future.wait(
      enabledProviders.map((provider) => provider.reportError(report)),
    );
  }

  /// Report a fatal error (crash)
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.reportFatalError(
  ///   error: error,
  ///   stackTrace: stackTrace,
  ///   message: 'App crashed during startup',
  ///   tags: {'crash_type': 'startup'},
  /// );
  /// ```
  Future<void> reportFatalError({
    required dynamic error,
    StackTrace? stackTrace,
    String? message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isInitialized || !privacyConfig.errorReportingEnabled) {
      _debugLog('Error reporting not available - skipping fatal error');
      return;
    }

    final report = ErrorReport.fatal(
      error: error,
      stackTrace: stackTrace,
      message: message,
      tags: tags,
      extra: extra,
      userId: _currentUser?.userId,
      appContext: defaultAppContext,
    );

    _debugLog('Reporting fatal error: ${report.getErrorMessage()}');

    await Future.wait(
      enabledProviders.map((provider) => provider.reportFatalError(report)),
    );
  }

  /// Report an error from an ErrorReport object
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.report(
  ///   ErrorReport.error(
  ///     error: exception,
  ///     stackTrace: stackTrace,
  ///     message: 'Custom error',
  ///   ),
  /// );
  /// ```
  Future<void> report(ErrorReport report) async {
    if (!_isInitialized || !privacyConfig.errorReportingEnabled) {
      _debugLog('Error reporting not available');
      return;
    }

    _debugLog('Reporting: ${report.getErrorMessage()}');

    if (report.isFatal) {
      await Future.wait(
        enabledProviders.map((provider) => provider.reportFatalError(report)),
      );
    } else {
      await Future.wait(
        enabledProviders.map((provider) => provider.reportError(report)),
      );
    }
  }

  /// Log a message
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.logMessage(
  ///   'User initiated checkout',
  ///   level: ErrorSeverity.info,
  /// );
  /// ```
  Future<void> logMessage(String message, {ErrorSeverity? level}) async {
    if (!_isInitialized || !privacyConfig.errorReportingEnabled) {
      return;
    }

    _debugLog('Logging message: $message');

    await Future.wait(
      enabledProviders.map(
        (provider) => provider.logMessage(message, level: level),
      ),
    );
  }

  /// Log an info message
  Future<void> logInfo(String message) async {
    await logMessage(message, level: ErrorSeverity.info);
  }

  /// Log a warning message
  Future<void> logWarning(String message) async {
    await logMessage(message, level: ErrorSeverity.warning);
  }

  /// Add a breadcrumb (trail of events)
  ///
  /// Breadcrumbs help understand what led to an error.
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.addBreadcrumb(
  ///   message: 'User clicked checkout button',
  ///   category: 'user_action',
  ///   data: {'cart_items': 3, 'total': 99.99},
  /// );
  /// ```
  Future<void> addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized || !privacyConfig.errorReportingEnabled) {
      return;
    }

    _debugLog('Adding breadcrumb: $message');

    await Future.wait(
      enabledProviders.map(
        (provider) => provider.addBreadcrumb(
          message: message,
          category: category,
          data: data,
        ),
      ),
    );
  }

  /// Set the current user context
  ///
  /// Associates errors with a specific user.
  /// Respects privacy settings and consent.
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.setUser(
  ///   AnalyticsUser.withId('user123'),
  /// );
  /// ```
  Future<void> setUser(AnalyticsUser user) async {
    if (!_isInitialized) {
      _debugLog('Error logger not initialized - skipping set user');
      return;
    }

    _currentUser = user;

    // Only set user context if crash reporting consent is granted
    if (!user.hasCrashReportingConsent ||
        !privacyConfig.errorReportingEnabled) {
      _debugLog('Crash reporting consent not granted - skipping set user');
      return;
    }

    _debugLog('Setting user context: ${user.userId}');

    await Future.wait(
      enabledProviders.map((provider) => provider.setUserContext(user)),
    );
  }

  /// Set custom context
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.setContext(
  ///   key: 'subscription_tier',
  ///   value: 'premium',
  /// );
  /// ```
  Future<void> setContext({
    required String key,
    required dynamic value,
  }) async {
    if (!_isInitialized || !privacyConfig.errorReportingEnabled) {
      return;
    }

    _debugLog('Setting context: $key = $value');

    await Future.wait(
      enabledProviders.map(
        (provider) => provider.setContext(key: key, value: value),
      ),
    );
  }

  /// Set multiple tags at once
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.setTags({
  ///   'environment': 'production',
  ///   'feature': 'checkout',
  ///   'version': '1.2.3',
  /// });
  /// ```
  Future<void> setTags(Map<String, String> tags) async {
    if (!_isInitialized || !privacyConfig.errorReportingEnabled) {
      return;
    }

    _debugLog('Setting ${tags.length} tags');

    await Future.wait(
      enabledProviders.map((provider) => provider.setTags(tags)),
    );
  }

  /// Clear user context (for logout)
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.clearUser();
  /// ```
  Future<void> clearUser() async {
    if (!_isInitialized) {
      return;
    }

    _debugLog('Clearing user context');

    _currentUser = null;

    await Future.wait(
      enabledProviders.map((provider) => provider.clearUserContext()),
    );
  }

  /// Enable error reporting
  ///
  /// Re-enables error reporting after user grants consent.
  Future<void> enable() async {
    if (!_isInitialized) {
      _debugLog('Error logger not initialized - skipping enable');
      return;
    }

    _debugLog('Enabling error reporting');

    await Future.wait(
      _providers.map((provider) => provider.enable()),
    );
  }

  /// Disable error reporting
  ///
  /// Disables error reporting when user revokes consent.
  Future<void> disable() async {
    if (!_isInitialized) {
      _debugLog('Error logger not initialized - skipping disable');
      return;
    }

    _debugLog('Disabling error reporting');

    await Future.wait(
      _providers.map((provider) => provider.disable()),
    );
  }

  /// Send any cached errors
  ///
  /// Forces immediate sending of cached error reports.
  Future<void> sendCachedErrors() async {
    if (!_isInitialized) return;

    _debugLog('Sending cached errors');

    await Future.wait(
      enabledProviders.map((provider) => provider.sendCachedErrors()),
    );
  }

  /// Get a specific provider by type
  ///
  /// Example:
  /// ```dart
  /// final sentryProvider = errorLogger.getProvider<SentryProvider>();
  /// if (sentryProvider != null) {
  ///   // Use Sentry-specific features
  /// }
  /// ```
  T? getProvider<T extends ErrorProvider>() {
    try {
      return _providers.whereType<T>().first;
    } catch (e) {
      return null;
    }
  }

  /// Set up global error handlers
  ///
  /// Automatically captures uncaught errors and Flutter framework errors.
  void _setupGlobalErrorHandlers() {
    // Note: Individual providers (like Crashlytics) set up their own
    // global handlers. This is a placeholder for additional handling.
    _debugLog('Global error handlers configured');
  }

  /// Dispose all providers and cleanup resources
  ///
  /// Call this when the app is shutting down.
  Future<void> dispose() async {
    _debugLog('Disposing error logger');

    await Future.wait(
      _providers.map((provider) => provider.dispose()),
    );

    _isInitialized = false;
    _currentUser = null;
  }

  void _debugLog(String message) {
    if (privacyConfig.enableDebugLogging) {
      print('[ErrorLogger] $message');
    }
  }
}
