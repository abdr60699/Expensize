import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/error_report.dart';
import '../models/analytics_user.dart';
import '../models/privacy_config.dart';
import 'error_provider.dart';

/// Sentry implementation of ErrorProvider
///
/// Provides error and crash reporting using Sentry.
/// Supports breadcrumbs, context, and user tracking.
class SentryProvider implements ErrorProvider {
  final String dsn;
  final String? environment;
  final double? tracesSampleRate;
  final PrivacyConfig _privacyConfig;
  bool _isEnabled = true;

  SentryProvider({
    required this.dsn,
    this.environment,
    this.tracesSampleRate,
    PrivacyConfig? privacyConfig,
  }) : _privacyConfig = privacyConfig ?? const PrivacyConfig();

  @override
  String get name => 'Sentry';

  @override
  bool get isEnabled => _isEnabled && _privacyConfig.errorReportingEnabled;

  @override
  Future<bool> initialize() async {
    if (dsn.isEmpty) {
      _debugLog('Sentry DSN not provided - skipping initialization');
      return false;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.environment = environment ?? 'production';
          options.tracesSampleRate = tracesSampleRate ?? 1.0;

          // Privacy settings
          options.sendDefaultPii = _privacyConfig.allowPII;
          options.enableAutoSessionTracking = true;

          // Performance monitoring
          options.enableAutoPerformanceTracing =
              _privacyConfig.collectPerformanceMetrics;

          // Debug settings
          options.debug = _privacyConfig.enableDebugLogging;

          // Attach stack traces
          options.attachStacktrace = true;

          // Filter events based on privacy config
          options.beforeSend = (event, {hint}) {
            if (!isEnabled) return null;
            return _filterEventForPrivacy(event);
          };

          options.beforeBreadcrumb = (breadcrumb, {hint}) {
            if (!isEnabled) return null;
            return breadcrumb;
          };
        },
      );

      _debugLog('Sentry initialized successfully');
      return true;
    } catch (e) {
      _debugLog('Failed to initialize Sentry: $e');
      return false;
    }
  }

  @override
  Future<void> reportError(ErrorReport report) async {
    if (!isEnabled) {
      _debugLog('Error reporting disabled - skipping error');
      return;
    }

    try {
      await Sentry.captureException(
        report.error,
        stackTrace: report.stackTrace,
        withScope: (scope) {
          _configureScopeForReport(scope, report);
        },
      );

      _debugLog('Reported error: ${report.getErrorMessage()}');
    } catch (e) {
      _debugLog('Failed to report error: $e');
    }
  }

  @override
  Future<void> reportFatalError(ErrorReport report) async {
    if (!isEnabled) {
      _debugLog('Error reporting disabled - skipping fatal error');
      return;
    }

    try {
      await Sentry.captureException(
        report.error,
        stackTrace: report.stackTrace,
        withScope: (scope) {
          _configureScopeForReport(scope, report);
          scope.level = SentryLevel.fatal;
        },
      );

      _debugLog('Reported fatal error: ${report.getErrorMessage()}');
    } catch (e) {
      _debugLog('Failed to report fatal error: $e');
    }
  }

  @override
  Future<void> logMessage(String message, {ErrorSeverity? level}) async {
    if (!isEnabled) return;

    try {
      await Sentry.captureMessage(
        message,
        level: _convertSeverityToSentryLevel(level ?? ErrorSeverity.info),
      );

      _debugLog('Logged message: $message');
    } catch (e) {
      _debugLog('Failed to log message: $e');
    }
  }

  @override
  Future<void> addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) async {
    if (!isEnabled) return;

    try {
      await Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          data: data != null ? _privacyConfig.filterPII(data) : null,
          timestamp: DateTime.now(),
        ),
      );

      _debugLog('Added breadcrumb: $message');
    } catch (e) {
      _debugLog('Failed to add breadcrumb: $e');
    }
  }

  @override
  Future<void> setUserContext(AnalyticsUser user) async {
    if (!isEnabled) return;

    try {
      // Get sanitized user data
      final sanitizedUser = _privacyConfig.allowPII ? user : user.sanitized;

      final sentryUser = SentryUser(
        id: _privacyConfig.anonymizeUserId(sanitizedUser.userId),
        email: _privacyConfig.allowPII ? sanitizedUser.email : null,
        username: _privacyConfig.allowPII ? sanitizedUser.name : null,
        data: sanitizedUser.getErrorContextProperties(),
      );

      await Sentry.configureScope((scope) {
        scope.setUser(sentryUser);
      });

      _debugLog('Set user context: ${sanitizedUser.userId}');
    } catch (e) {
      _debugLog('Failed to set user context: $e');
    }
  }

  @override
  Future<void> setContext({
    required String key,
    required dynamic value,
  }) async {
    if (!isEnabled) return;

    // Check if field is PII
    if (_privacyConfig.isPIIField(key) && !_privacyConfig.allowPII) {
      _debugLog('Skipping PII context: $key');
      return;
    }

    try {
      await Sentry.configureScope((scope) {
        scope.setContexts(key, value);
      });

      _debugLog('Set context: $key = $value');
    } catch (e) {
      _debugLog('Failed to set context: $e');
    }
  }

  @override
  Future<void> setTags(Map<String, String> tags) async {
    if (!isEnabled) return;

    try {
      await Sentry.configureScope((scope) {
        for (final entry in tags.entries) {
          scope.setTag(entry.key, entry.value);
        }
      });

      _debugLog('Set ${tags.length} tags');
    } catch (e) {
      _debugLog('Failed to set tags: $e');
    }
  }

  @override
  Future<void> clearUserContext() async {
    try {
      await Sentry.configureScope((scope) {
        scope.setUser(null);
      });

      _debugLog('Cleared user context');
    } catch (e) {
      _debugLog('Failed to clear user context: $e');
    }
  }

  @override
  Future<void> enable() async {
    _isEnabled = true;
    _debugLog('Error reporting enabled');
  }

  @override
  Future<void> disable() async {
    _isEnabled = false;
    _debugLog('Error reporting disabled');
  }

  @override
  Future<void> sendCachedErrors() async {
    try {
      // Sentry automatically sends cached errors on initialization
      // This is a no-op for Sentry
      _debugLog('Sentry automatically manages cached errors');
    } catch (e) {
      _debugLog('Failed to send cached errors: $e');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await Sentry.close();
      _debugLog('Sentry provider disposed');
    } catch (e) {
      _debugLog('Failed to dispose Sentry: $e');
    }
  }

  /// Configure Sentry scope with error report data
  void _configureScopeForReport(Scope scope, ErrorReport report) {
    // Set level
    scope.level = _convertSeverityToSentryLevel(report.severity);

    // Set tags
    if (report.tags != null) {
      for (final entry in report.tags!.entries) {
        scope.setTag(entry.key, entry.value);
      }
    }

    // Set extra context
    if (report.extra != null) {
      final filteredExtra = _privacyConfig.filterPII(report.extra!);
      for (final entry in filteredExtra.entries) {
        scope.setExtra(entry.key, entry.value);
      }
    }

    // Set app context
    if (report.appContext != null) {
      final context = report.appContext!;

      if (context.appVersion != null) {
        scope.setTag('app_version', context.appVersion!);
      }

      if (context.buildNumber != null) {
        scope.setTag('build_number', context.buildNumber!);
      }

      if (context.environment != null) {
        scope.setTag('environment', context.environment!);
      }

      if (context.currentScreen != null) {
        scope.setTag('current_screen', context.currentScreen!);
      }

      if (context.deviceInfo != null) {
        final device = context.deviceInfo!;
        if (device.os != null) scope.setTag('os', device.os!);
        if (device.osVersion != null) scope.setTag('os_version', device.osVersion!);
        if (device.model != null) scope.setTag('device_model', device.model!);
      }
    }
  }

  /// Convert ErrorSeverity to Sentry level
  SentryLevel _convertSeverityToSentryLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.debug:
        return SentryLevel.debug;
      case ErrorSeverity.info:
        return SentryLevel.info;
      case ErrorSeverity.warning:
        return SentryLevel.warning;
      case ErrorSeverity.error:
        return SentryLevel.error;
      case ErrorSeverity.fatal:
        return SentryLevel.fatal;
    }
  }

  /// Filter event for privacy compliance
  SentryEvent? _filterEventForPrivacy(SentryEvent event) {
    // If PII is not allowed, ensure no PII in event
    if (!_privacyConfig.allowPII) {
      // Clear potentially sensitive data
      return event.copyWith(
        user: event.user?.copyWith(
          email: null,
          username: null,
          ipAddress: null,
        ),
      );
    }

    return event;
  }

  void _debugLog(String message) {
    if (_privacyConfig.enableDebugLogging) {
      print('[Sentry] $message');
    }
  }
}
