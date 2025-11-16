import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../models/error_report.dart';
import '../models/analytics_user.dart';
import '../models/privacy_config.dart';
import 'error_provider.dart';

/// Firebase Crashlytics implementation of ErrorProvider
///
/// Provides crash reporting using Google Firebase Crashlytics.
/// Supports custom keys, logs, and user tracking.
class CrashlyticsProvider implements ErrorProvider {
  final FirebaseCrashlytics _crashlytics;
  final PrivacyConfig _privacyConfig;
  bool _isEnabled = true;

  CrashlyticsProvider({
    FirebaseCrashlytics? crashlytics,
    PrivacyConfig? privacyConfig,
  })  : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _privacyConfig = privacyConfig ?? const PrivacyConfig();

  @override
  String get name => 'Firebase Crashlytics';

  @override
  bool get isEnabled => _isEnabled && _privacyConfig.errorReportingEnabled;

  @override
  Future<bool> initialize() async {
    try {
      // Set crash collection enabled based on privacy config
      await _crashlytics.setCrashlyticsCollectionEnabled(
        _privacyConfig.errorReportingEnabled,
      );

      // Enable crash reporting in release mode
      if (kReleaseMode) {
        // Set up Flutter error handler
        FlutterError.onError = (errorDetails) {
          if (isEnabled) {
            _crashlytics.recordFlutterFatalError(errorDetails);
          }
        };

        // Set up Platform dispatcher error handler (async errors)
        PlatformDispatcher.instance.onError = (error, stack) {
          if (isEnabled) {
            _crashlytics.recordError(error, stack, fatal: true);
          }
          return true;
        };
      }

      _debugLog('Firebase Crashlytics initialized successfully');
      return true;
    } catch (e) {
      _debugLog('Failed to initialize Firebase Crashlytics: $e');
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
      // Set custom keys for context
      await _setCustomKeysForReport(report);

      // Record the error
      await _crashlytics.recordError(
        report.error,
        report.stackTrace,
        reason: report.message,
        fatal: report.isFatal,
        information: report.extra?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
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
      // Set custom keys for context
      await _setCustomKeysForReport(report);

      // Record as fatal error
      await _crashlytics.recordError(
        report.error,
        report.stackTrace,
        reason: report.message,
        fatal: true,
        information: report.extra?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
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
      final prefix = level != null ? '[${level.name.toUpperCase()}] ' : '';
      await _crashlytics.log('$prefix$message');

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
      final breadcrumbMessage = category != null ? '[$category] $message' : message;
      await _crashlytics.log(breadcrumbMessage);

      // Add data as custom keys if provided
      if (data != null) {
        final filteredData = _privacyConfig.filterPII(data);
        for (final entry in filteredData.entries) {
          if (!_privacyConfig.isPIIField(entry.key) || _privacyConfig.allowPII) {
            await _crashlytics.setCustomKey(entry.key, entry.value);
          }
        }
      }

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

      // Set user identifier
      if (sanitizedUser.userId != null) {
        final userId = _privacyConfig.anonymizeUserId(sanitizedUser.userId);
        await _crashlytics.setUserIdentifier(userId ?? '');
      }

      // Set user properties as custom keys
      final properties = sanitizedUser.getErrorContextProperties();
      for (final entry in properties.entries) {
        if (entry.key != 'id') {
          await setContext(key: entry.key, value: entry.value);
        }
      }

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
      await _crashlytics.setCustomKey(key, value);
      _debugLog('Set context: $key = $value');
    } catch (e) {
      _debugLog('Failed to set context: $e');
    }
  }

  @override
  Future<void> setTags(Map<String, String> tags) async {
    if (!isEnabled) return;

    try {
      for (final entry in tags.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }

      _debugLog('Set ${tags.length} tags');
    } catch (e) {
      _debugLog('Failed to set tags: $e');
    }
  }

  @override
  Future<void> clearUserContext() async {
    try {
      await _crashlytics.setUserIdentifier('');
      _debugLog('Cleared user context');
    } catch (e) {
      _debugLog('Failed to clear user context: $e');
    }
  }

  @override
  Future<void> enable() async {
    try {
      _isEnabled = true;
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      _debugLog('Error reporting enabled');
    } catch (e) {
      _debugLog('Failed to enable error reporting: $e');
    }
  }

  @override
  Future<void> disable() async {
    try {
      _isEnabled = false;
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
      _debugLog('Error reporting disabled');
    } catch (e) {
      _debugLog('Failed to disable error reporting: $e');
    }
  }

  @override
  Future<void> sendCachedErrors() async {
    try {
      await _crashlytics.sendUnsentReports();
      _debugLog('Sent cached error reports');
    } catch (e) {
      _debugLog('Failed to send cached errors: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _debugLog('Firebase Crashlytics provider disposed');
  }

  /// Set custom keys for error report
  Future<void> _setCustomKeysForReport(ErrorReport report) async {
    try {
      // Set severity
      await _crashlytics.setCustomKey('severity', report.severity.name);

      // Set tags
      if (report.tags != null) {
        for (final entry in report.tags!.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      // Set extra context (filtered for PII)
      if (report.extra != null) {
        final filteredExtra = _privacyConfig.filterPII(report.extra!);
        for (final entry in filteredExtra.entries) {
          if (!_privacyConfig.isPIIField(entry.key) || _privacyConfig.allowPII) {
            await _crashlytics.setCustomKey(entry.key, entry.value);
          }
        }
      }

      // Set app context
      if (report.appContext != null) {
        final context = report.appContext!;

        if (context.appVersion != null) {
          await _crashlytics.setCustomKey('app_version', context.appVersion!);
        }

        if (context.buildNumber != null) {
          await _crashlytics.setCustomKey('build_number', context.buildNumber!);
        }

        if (context.environment != null) {
          await _crashlytics.setCustomKey('environment', context.environment!);
        }

        if (context.currentScreen != null) {
          await _crashlytics.setCustomKey('current_screen', context.currentScreen!);
        }

        if (context.deviceInfo != null && _privacyConfig.collectDeviceInfo) {
          final device = context.deviceInfo!;
          if (device.os != null) {
            await _crashlytics.setCustomKey('device_os', device.os!);
          }
          if (device.osVersion != null) {
            await _crashlytics.setCustomKey('device_os_version', device.osVersion!);
          }
          if (device.model != null) {
            await _crashlytics.setCustomKey('device_model', device.model!);
          }
        }
      }
    } catch (e) {
      _debugLog('Failed to set custom keys: $e');
    }
  }

  /// Get FirebaseCrashlytics instance for custom use
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Check if there are unsent reports
  Future<bool> checkForUnsentReports() async {
    try {
      return await _crashlytics.checkForUnsentReports();
    } catch (e) {
      _debugLog('Failed to check for unsent reports: $e');
      return false;
    }
  }

  /// Delete unsent reports
  Future<void> deleteUnsentReports() async {
    try {
      await _crashlytics.deleteUnsentReports();
      _debugLog('Deleted unsent reports');
    } catch (e) {
      _debugLog('Failed to delete unsent reports: $e');
    }
  }

  /// Test crash (for testing Crashlytics integration)
  /// WARNING: Only use in development/testing!
  Future<void> testCrash() async {
    if (kDebugMode) {
      await _crashlytics.crash();
    } else {
      _debugLog('Test crash only available in debug mode');
    }
  }

  void _debugLog(String message) {
    if (_privacyConfig.enableDebugLogging) {
      print('[Crashlytics] $message');
    }
  }
}
