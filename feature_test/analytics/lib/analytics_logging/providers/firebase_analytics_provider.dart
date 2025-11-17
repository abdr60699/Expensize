import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../models/analytics_event.dart';
import '../models/analytics_user.dart';
import '../models/privacy_config.dart';
import 'analytics_provider.dart';

/// Firebase Analytics implementation of AnalyticsProvider
///
/// Provides analytics tracking using Google Firebase Analytics.
/// Supports automatic screen tracking, custom events, and user properties.
class FirebaseAnalyticsProvider implements AnalyticsProvider {
  final FirebaseAnalytics _analytics;
  final PrivacyConfig _privacyConfig;
  bool _isEnabled = true;

  FirebaseAnalyticsProvider({
    FirebaseAnalytics? analytics,
    PrivacyConfig? privacyConfig,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _privacyConfig = privacyConfig ?? const PrivacyConfig();

  @override
  String get name => 'Firebase Analytics';

  @override
  bool get isEnabled => _isEnabled && _privacyConfig.analyticsEnabled;

  @override
  Future<bool> initialize() async {
    try {
      // Set analytics collection enabled based on privacy config
      await _analytics.setAnalyticsCollectionEnabled(
        _privacyConfig.analyticsEnabled,
      );

      // Set default event parameters if needed
      await _analytics.setDefaultEventParameters({
        'app_name': 'reusable_widgets',
      });

      _debugLog('Firebase Analytics initialized successfully');
      return true;
    } catch (e) {
      _debugLog('Failed to initialize Firebase Analytics: $e');
      return false;
    }
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!isEnabled) {
      _debugLog('Analytics disabled - skipping event: ${event.name}');
      return;
    }

    // Validate event name
    if (!event.isValidEventName()) {
      _debugLog('Invalid event name: ${event.name}');
      return;
    }

    // Validate parameter keys
    if (!event.hasValidParameterKeys()) {
      _debugLog('Invalid parameter keys in event: ${event.name}');
      return;
    }

    try {
      // Filter PII from parameters if needed
      final parameters = event.parameters != null
          ? _privacyConfig.filterPII(event.parameters!)
          : null;

      await _analytics.logEvent(
        name: event.name,
        parameters: parameters,
      );

      _debugLog('Logged event: ${event.name}');
    } catch (e) {
      _debugLog('Failed to log event ${event.name}: $e');
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!isEnabled) {
      _debugLog('Analytics disabled - skipping screen view: $screenName');
      return;
    }

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

      _debugLog('Logged screen view: $screenName');
    } catch (e) {
      _debugLog('Failed to log screen view $screenName: $e');
    }
  }

  @override
  Future<void> setUserProperties(AnalyticsUser user) async {
    if (!isEnabled) {
      _debugLog('Analytics disabled - skipping user properties');
      return;
    }

    try {
      // Get sanitized user data based on privacy config
      final sanitizedUser = _privacyConfig.allowPII ? user : user.sanitized;

      // Set user ID (anonymized if configured)
      if (sanitizedUser.userId != null) {
        final userId = _privacyConfig.anonymizeUserId(sanitizedUser.userId);
        await setUserId(userId);
      }

      // Set user properties
      final properties = sanitizedUser.getAnalyticsProperties();
      for (final entry in properties.entries) {
        if (entry.key != 'user_id') {
          await setUserProperty(
            name: entry.key,
            value: entry.value.toString(),
          );
        }
      }

      _debugLog('Set user properties for user: ${sanitizedUser.userId}');
    } catch (e) {
      _debugLog('Failed to set user properties: $e');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!isEnabled) return;

    // Check if field is PII
    if (_privacyConfig.isPIIField(name) && !_privacyConfig.allowPII) {
      _debugLog('Skipping PII field: $name');
      return;
    }

    try {
      await _analytics.setUserProperty(
        name: name,
        value: value,
      );

      _debugLog('Set user property: $name = $value');
    } catch (e) {
      _debugLog('Failed to set user property $name: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!isEnabled) return;

    try {
      final finalUserId = _privacyConfig.anonymizeUserId(userId);
      await _analytics.setUserId(id: finalUserId);

      _debugLog('Set user ID: $finalUserId');
    } catch (e) {
      _debugLog('Failed to set user ID: $e');
    }
  }

  @override
  Future<void> resetAnalytics() async {
    try {
      // Clear user ID
      await _analytics.setUserId(id: null);

      // Note: Firebase Analytics doesn't provide a direct way to clear
      // all user properties, but setting user ID to null is the primary
      // reset mechanism

      _debugLog('Reset analytics data');
    } catch (e) {
      _debugLog('Failed to reset analytics: $e');
    }
  }

  @override
  Future<void> enable() async {
    try {
      _isEnabled = true;
      await _analytics.setAnalyticsCollectionEnabled(true);
      _debugLog('Analytics enabled');
    } catch (e) {
      _debugLog('Failed to enable analytics: $e');
    }
  }

  @override
  Future<void> disable() async {
    try {
      _isEnabled = false;
      await _analytics.setAnalyticsCollectionEnabled(false);
      _debugLog('Analytics disabled');
    } catch (e) {
      _debugLog('Failed to disable analytics: $e');
    }
  }

  @override
  Future<void> setSessionTimeout(Duration duration) async {
    try {
      await _analytics.setSessionTimeoutDuration(duration);
      _debugLog('Set session timeout: ${duration.inMinutes} minutes');
    } catch (e) {
      _debugLog('Failed to set session timeout: $e');
    }
  }

  @override
  Future<void> setMinimumSessionDuration(Duration duration) async {
    // Firebase Analytics doesn't directly support this,
    // but we can set it via default event parameters
    try {
      _debugLog(
        'Note: Firebase Analytics handles minimum session duration automatically',
      );
    } catch (e) {
      _debugLog('Failed to set minimum session duration: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _debugLog('Firebase Analytics provider disposed');
  }

  /// Get FirebaseAnalytics instance for custom use
  FirebaseAnalytics get analytics => _analytics;

  /// Get FirebaseAnalyticsObserver for navigation tracking
  ///
  /// Use this with your navigation system:
  /// ```dart
  /// MaterialApp(
  ///   navigatorObservers: [
  ///     firebaseProvider.getNavigatorObserver(),
  ///   ],
  /// )
  /// ```
  FirebaseAnalyticsObserver getNavigatorObserver({
    String? Function(RouteSettings)? nameExtractor,
  }) {
    return FirebaseAnalyticsObserver(
      analytics: _analytics,
      nameExtractor: nameExtractor,
    );
  }

  void _debugLog(String message) {
    if (_privacyConfig.enableDebugLogging) {
      print('[FirebaseAnalytics] $message');
    }
  }
}
