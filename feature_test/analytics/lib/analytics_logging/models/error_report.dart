import 'package:flutter/foundation.dart';

/// Severity level for error reports
enum ErrorSeverity {
  /// Informational message (not an error)
  info,

  /// Warning that doesn't break functionality
  warning,

  /// Error that impacts functionality but app can continue
  error,

  /// Critical error that may crash the app
  fatal,

  /// Debug-level information (development only)
  debug;

  /// Convert to Sentry level string
  String toSentryLevel() {
    switch (this) {
      case ErrorSeverity.info:
        return 'info';
      case ErrorSeverity.warning:
        return 'warning';
      case ErrorSeverity.error:
        return 'error';
      case ErrorSeverity.fatal:
        return 'fatal';
      case ErrorSeverity.debug:
        return 'debug';
    }
  }
}

/// Data model representing an error or crash report
///
/// Used to capture errors, exceptions, and crashes for reporting
/// to error tracking services (Sentry, Crashlytics).
class ErrorReport {
  /// The error/exception object
  final dynamic error;

  /// Stack trace associated with the error
  final StackTrace? stackTrace;

  /// Severity level of the error
  final ErrorSeverity severity;

  /// Human-readable message describing the error
  final String? message;

  /// Context/tags to help categorize and filter errors
  /// Example: {'feature': 'checkout', 'payment_method': 'credit_card'}
  final Map<String, String>? tags;

  /// Additional context data (can be any structure)
  /// Example: {'user_action': 'submit_payment', 'cart_items': 3}
  final Map<String, dynamic>? extra;

  /// User ID associated with this error (for user impact tracking)
  final String? userId;

  /// Whether this error was fatal (caused a crash)
  final bool isFatal;

  /// Timestamp when the error occurred
  final DateTime timestamp;

  /// Application context when error occurred
  final AppContext? appContext;

  /// Whether this error has been handled by the app
  final bool isHandled;

  const ErrorReport({
    required this.error,
    this.stackTrace,
    this.severity = ErrorSeverity.error,
    this.message,
    this.tags,
    this.extra,
    this.userId,
    this.isFatal = false,
    DateTime? timestamp,
    this.appContext,
    this.isHandled = true,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a fatal error report (for crashes)
  factory ErrorReport.fatal({
    required dynamic error,
    StackTrace? stackTrace,
    String? message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
    String? userId,
    AppContext? appContext,
  }) {
    return ErrorReport(
      error: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.fatal,
      message: message,
      tags: tags,
      extra: extra,
      userId: userId,
      isFatal: true,
      appContext: appContext,
      isHandled: false,
    );
  }

  /// Create a non-fatal error report
  factory ErrorReport.error({
    required dynamic error,
    StackTrace? stackTrace,
    String? message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
    String? userId,
    AppContext? appContext,
  }) {
    return ErrorReport(
      error: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.error,
      message: message,
      tags: tags,
      extra: extra,
      userId: userId,
      isFatal: false,
      appContext: appContext,
      isHandled: true,
    );
  }

  /// Create a warning report
  factory ErrorReport.warning({
    required String message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
    String? userId,
    AppContext? appContext,
  }) {
    return ErrorReport(
      error: message,
      severity: ErrorSeverity.warning,
      message: message,
      tags: tags,
      extra: extra,
      userId: userId,
      isFatal: false,
      appContext: appContext,
      isHandled: true,
    );
  }

  /// Create an info report
  factory ErrorReport.info({
    required String message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
    String? userId,
    AppContext? appContext,
  }) {
    return ErrorReport(
      error: message,
      severity: ErrorSeverity.info,
      message: message,
      tags: tags,
      extra: extra,
      userId: userId,
      isFatal: false,
      appContext: appContext,
      isHandled: true,
    );
  }

  /// Get error message (from message field or error object)
  String getErrorMessage() {
    if (message != null && message!.isNotEmpty) return message!;
    if (error != null) return error.toString();
    return 'Unknown error';
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'error': error?.toString(),
      'stack_trace': stackTrace?.toString(),
      'severity': severity.name,
      'message': message,
      'tags': tags,
      'extra': extra,
      'user_id': userId,
      'is_fatal': isFatal,
      'timestamp': timestamp.toIso8601String(),
      'app_context': appContext?.toJson(),
      'is_handled': isHandled,
    };
  }

  /// Create from JSON
  factory ErrorReport.fromJson(Map<String, dynamic> json) {
    return ErrorReport(
      error: json['error'],
      stackTrace: json['stack_trace'] != null
          ? StackTrace.fromString(json['stack_trace'] as String)
          : null,
      severity: ErrorSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ErrorSeverity.error,
      ),
      message: json['message'] as String?,
      tags: (json['tags'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      extra: json['extra'] as Map<String, dynamic>?,
      userId: json['user_id'] as String?,
      isFatal: json['is_fatal'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
      appContext: json['app_context'] != null
          ? AppContext.fromJson(json['app_context'] as Map<String, dynamic>)
          : null,
      isHandled: json['is_handled'] as bool? ?? true,
    );
  }

  /// Create a copy with modified fields
  ErrorReport copyWith({
    dynamic error,
    StackTrace? stackTrace,
    ErrorSeverity? severity,
    String? message,
    Map<String, String>? tags,
    Map<String, dynamic>? extra,
    String? userId,
    bool? isFatal,
    DateTime? timestamp,
    AppContext? appContext,
    bool? isHandled,
  }) {
    return ErrorReport(
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      tags: tags ?? this.tags,
      extra: extra ?? this.extra,
      userId: userId ?? this.userId,
      isFatal: isFatal ?? this.isFatal,
      timestamp: timestamp ?? this.timestamp,
      appContext: appContext ?? this.appContext,
      isHandled: isHandled ?? this.isHandled,
    );
  }

  @override
  String toString() {
    return 'ErrorReport(severity: $severity, message: ${getErrorMessage()}, isFatal: $isFatal)';
  }
}

/// Application context information for error reports
class AppContext {
  /// App version (e.g., '1.2.3')
  final String? appVersion;

  /// Build number (e.g., '42')
  final String? buildNumber;

  /// Environment (e.g., 'production', 'staging', 'development')
  final String? environment;

  /// Device information
  final DeviceInfo? deviceInfo;

  /// Current screen/route
  final String? currentScreen;

  /// Additional custom context
  final Map<String, dynamic>? custom;

  const AppContext({
    this.appVersion,
    this.buildNumber,
    this.environment,
    this.deviceInfo,
    this.currentScreen,
    this.custom,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (appVersion != null) 'app_version': appVersion,
      if (buildNumber != null) 'build_number': buildNumber,
      if (environment != null) 'environment': environment,
      if (deviceInfo != null) 'device_info': deviceInfo!.toJson(),
      if (currentScreen != null) 'current_screen': currentScreen,
      if (custom != null) 'custom': custom,
    };
  }

  /// Create from JSON
  factory AppContext.fromJson(Map<String, dynamic> json) {
    return AppContext(
      appVersion: json['app_version'] as String?,
      buildNumber: json['build_number'] as String?,
      environment: json['environment'] as String?,
      deviceInfo: json['device_info'] != null
          ? DeviceInfo.fromJson(json['device_info'] as Map<String, dynamic>)
          : null,
      currentScreen: json['current_screen'] as String?,
      custom: json['custom'] as Map<String, dynamic>?,
    );
  }
}

/// Device information for error context
class DeviceInfo {
  /// Operating system (e.g., 'iOS', 'Android')
  final String? os;

  /// OS version (e.g., '14.5', '11.0')
  final String? osVersion;

  /// Device model (e.g., 'iPhone 12', 'Pixel 5')
  final String? model;

  /// Device manufacturer
  final String? manufacturer;

  /// Whether device is a physical device (vs emulator/simulator)
  final bool? isPhysicalDevice;

  /// Screen size
  final String? screenSize;

  /// Device locale
  final String? locale;

  const DeviceInfo({
    this.os,
    this.osVersion,
    this.model,
    this.manufacturer,
    this.isPhysicalDevice,
    this.screenSize,
    this.locale,
  });

  /// Create DeviceInfo from platform (use device_info_plus package)
  factory DeviceInfo.fromPlatform() {
    // This is a placeholder - actual implementation would use device_info_plus
    return DeviceInfo(
      os: defaultTargetPlatform.name,
      isPhysicalDevice: !kIsWeb,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (os != null) 'os': os,
      if (osVersion != null) 'os_version': osVersion,
      if (model != null) 'model': model,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (isPhysicalDevice != null) 'is_physical_device': isPhysicalDevice,
      if (screenSize != null) 'screen_size': screenSize,
      if (locale != null) 'locale': locale,
    };
  }

  /// Create from JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      os: json['os'] as String?,
      osVersion: json['os_version'] as String?,
      model: json['model'] as String?,
      manufacturer: json['manufacturer'] as String?,
      isPhysicalDevice: json['is_physical_device'] as bool?,
      screenSize: json['screen_size'] as String?,
      locale: json['locale'] as String?,
    );
  }
}
