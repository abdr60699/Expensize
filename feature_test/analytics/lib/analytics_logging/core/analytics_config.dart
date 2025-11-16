import '../models/privacy_config.dart';
import '../models/error_report.dart';

/// Configuration for the analytics and logging module
///
/// Consolidates all configuration needed to set up analytics and error reporting.
class AnalyticsLoggingConfig {
  /// Privacy configuration
  final PrivacyConfig privacyConfig;

  /// Firebase Analytics enabled
  final bool enableFirebaseAnalytics;

  /// Sentry enabled
  final bool enableSentry;

  /// Sentry DSN (required if enableSentry is true)
  final String? sentryDsn;

  /// Sentry environment (e.g., 'production', 'staging', 'development')
  final String? sentryEnvironment;

  /// Sentry traces sample rate (0.0 to 1.0)
  final double? sentryTracesSampleRate;

  /// Firebase Crashlytics enabled
  final bool enableCrashlytics;

  /// Default app context for error reports
  final AppContext? defaultAppContext;

  /// Session timeout duration
  final Duration? sessionTimeout;

  const AnalyticsLoggingConfig({
    this.privacyConfig = const PrivacyConfig(),
    this.enableFirebaseAnalytics = true,
    this.enableSentry = false,
    this.sentryDsn,
    this.sentryEnvironment,
    this.sentryTracesSampleRate,
    this.enableCrashlytics = true,
    this.defaultAppContext,
    this.sessionTimeout,
  });

  /// Create config for development/debug
  factory AnalyticsLoggingConfig.debug({
    String? sentryDsn,
    AppContext? appContext,
  }) {
    return AnalyticsLoggingConfig(
      privacyConfig: PrivacyConfig.debug(),
      enableFirebaseAnalytics: true,
      enableSentry: sentryDsn != null,
      sentryDsn: sentryDsn,
      sentryEnvironment: 'development',
      sentryTracesSampleRate: 1.0,
      enableCrashlytics: true,
      defaultAppContext: appContext,
    );
  }

  /// Create config for production
  factory AnalyticsLoggingConfig.production({
    required PrivacyConfig privacyConfig,
    String? sentryDsn,
    AppContext? appContext,
  }) {
    return AnalyticsLoggingConfig(
      privacyConfig: privacyConfig,
      enableFirebaseAnalytics: true,
      enableSentry: sentryDsn != null,
      sentryDsn: sentryDsn,
      sentryEnvironment: 'production',
      sentryTracesSampleRate: 0.2, // Sample 20% in production
      enableCrashlytics: true,
      defaultAppContext: appContext,
    );
  }

  /// Create minimal config (analytics only, no error reporting)
  factory AnalyticsLoggingConfig.analyticsOnly() {
    return const AnalyticsLoggingConfig(
      privacyConfig: PrivacyConfig.analyticsOnly(),
      enableFirebaseAnalytics: true,
      enableSentry: false,
      enableCrashlytics: false,
    );
  }

  /// Create minimal config (error reporting only, no analytics)
  factory AnalyticsLoggingConfig.errorReportingOnly({
    String? sentryDsn,
    AppContext? appContext,
  }) {
    return AnalyticsLoggingConfig(
      privacyConfig: const PrivacyConfig.errorReportingOnly(),
      enableFirebaseAnalytics: false,
      enableSentry: sentryDsn != null,
      sentryDsn: sentryDsn,
      sentryEnvironment: 'production',
      enableCrashlytics: true,
      defaultAppContext: appContext,
    );
  }

  /// Validate configuration
  bool validate() {
    // If Sentry is enabled, DSN must be provided
    if (enableSentry && (sentryDsn == null || sentryDsn!.isEmpty)) {
      return false;
    }

    // At least one provider should be enabled
    if (!enableFirebaseAnalytics && !enableSentry && !enableCrashlytics) {
      return false;
    }

    return true;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (enableSentry && (sentryDsn == null || sentryDsn!.isEmpty)) {
      errors.add('Sentry DSN is required when Sentry is enabled');
    }

    if (!enableFirebaseAnalytics && !enableSentry && !enableCrashlytics) {
      errors.add('At least one provider must be enabled');
    }

    return errors;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'privacy_config': privacyConfig.toJson(),
      'enable_firebase_analytics': enableFirebaseAnalytics,
      'enable_sentry': enableSentry,
      'sentry_dsn': sentryDsn,
      'sentry_environment': sentryEnvironment,
      'sentry_traces_sample_rate': sentryTracesSampleRate,
      'enable_crashlytics': enableCrashlytics,
      'default_app_context': defaultAppContext?.toJson(),
      'session_timeout_minutes': sessionTimeout?.inMinutes,
    };
  }

  /// Create from JSON
  factory AnalyticsLoggingConfig.fromJson(Map<String, dynamic> json) {
    return AnalyticsLoggingConfig(
      privacyConfig: json['privacy_config'] != null
          ? PrivacyConfig.fromJson(
              json['privacy_config'] as Map<String, dynamic>)
          : const PrivacyConfig(),
      enableFirebaseAnalytics:
          json['enable_firebase_analytics'] as bool? ?? true,
      enableSentry: json['enable_sentry'] as bool? ?? false,
      sentryDsn: json['sentry_dsn'] as String?,
      sentryEnvironment: json['sentry_environment'] as String?,
      sentryTracesSampleRate: json['sentry_traces_sample_rate'] as double?,
      enableCrashlytics: json['enable_crashlytics'] as bool? ?? true,
      defaultAppContext: json['default_app_context'] != null
          ? AppContext.fromJson(
              json['default_app_context'] as Map<String, dynamic>)
          : null,
      sessionTimeout: json['session_timeout_minutes'] != null
          ? Duration(minutes: json['session_timeout_minutes'] as int)
          : null,
    );
  }

  /// Create a copy with modified fields
  AnalyticsLoggingConfig copyWith({
    PrivacyConfig? privacyConfig,
    bool? enableFirebaseAnalytics,
    bool? enableSentry,
    String? sentryDsn,
    String? sentryEnvironment,
    double? sentryTracesSampleRate,
    bool? enableCrashlytics,
    AppContext? defaultAppContext,
    Duration? sessionTimeout,
  }) {
    return AnalyticsLoggingConfig(
      privacyConfig: privacyConfig ?? this.privacyConfig,
      enableFirebaseAnalytics:
          enableFirebaseAnalytics ?? this.enableFirebaseAnalytics,
      enableSentry: enableSentry ?? this.enableSentry,
      sentryDsn: sentryDsn ?? this.sentryDsn,
      sentryEnvironment: sentryEnvironment ?? this.sentryEnvironment,
      sentryTracesSampleRate:
          sentryTracesSampleRate ?? this.sentryTracesSampleRate,
      enableCrashlytics: enableCrashlytics ?? this.enableCrashlytics,
      defaultAppContext: defaultAppContext ?? this.defaultAppContext,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
    );
  }

  @override
  String toString() {
    return 'AnalyticsLoggingConfig(firebase: $enableFirebaseAnalytics, sentry: $enableSentry, crashlytics: $enableCrashlytics)';
  }
}
