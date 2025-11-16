import 'package:shared_preferences/shared_preferences.dart';
import '../models/privacy_config.dart';
import '../core/analytics_manager.dart';
import '../core/error_logger.dart';

/// Consent manager for handling user privacy preferences
///
/// Manages user consent for analytics and error reporting.
/// Persists consent preferences and updates providers accordingly.
///
/// Example:
/// ```dart
/// final consentManager = ConsentManager(
///   analyticsManager: analyticsManager,
///   errorLogger: errorLogger,
/// );
///
/// await consentManager.initialize();
///
/// // Request consent
/// await consentManager.requestConsent(
///   analyticsConsent: true,
///   crashReportingConsent: true,
/// );
///
/// // Check consent status
/// final hasConsent = await consentManager.hasAnalyticsConsent();
/// ```
class ConsentManager {
  static const String _keyAnalyticsConsent = 'analytics_consent';
  static const String _keyCrashReportingConsent = 'crash_reporting_consent';
  static const String _keyPIIConsent = 'pii_consent';
  static const String _keyConsentTimestamp = 'consent_timestamp';

  final AnalyticsManager? analyticsManager;
  final ErrorLogger? errorLogger;
  final bool requireExplicitConsent;

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  ConsentManager({
    this.analyticsManager,
    this.errorLogger,
    this.requireExplicitConsent = false,
  });

  /// Whether consent manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the consent manager
  ///
  /// Loads stored consent preferences.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;

    // Apply stored consent to managers
    await _applyStoredConsent();
  }

  /// Check if user has granted analytics consent
  Future<bool> hasAnalyticsConsent() async {
    _ensureInitialized();

    // If explicit consent is required and not given, return false
    if (requireExplicitConsent) {
      return _prefs!.getBool(_keyAnalyticsConsent) ?? false;
    }

    // Otherwise, default to true (opt-out model)
    return _prefs!.getBool(_keyAnalyticsConsent) ?? true;
  }

  /// Check if user has granted crash reporting consent
  Future<bool> hasCrashReportingConsent() async {
    _ensureInitialized();

    if (requireExplicitConsent) {
      return _prefs!.getBool(_keyCrashReportingConsent) ?? false;
    }

    return _prefs!.getBool(_keyCrashReportingConsent) ?? true;
  }

  /// Check if user has granted PII collection consent
  Future<bool> hasPIIConsent() async {
    _ensureInitialized();

    // PII always requires explicit consent
    return _prefs!.getBool(_keyPIIConsent) ?? false;
  }

  /// Get timestamp of when consent was last updated
  Future<DateTime?> getConsentTimestamp() async {
    _ensureInitialized();

    final timestamp = _prefs!.getInt(_keyConsentTimestamp);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Request/update user consent
  ///
  /// Example:
  /// ```dart
  /// await consentManager.requestConsent(
  ///   analyticsConsent: true,
  ///   crashReportingConsent: true,
  ///   piiConsent: false,
  /// );
  /// ```
  Future<void> requestConsent({
    required bool analyticsConsent,
    required bool crashReportingConsent,
    bool piiConsent = false,
  }) async {
    _ensureInitialized();

    // Store consent preferences
    await _prefs!.setBool(_keyAnalyticsConsent, analyticsConsent);
    await _prefs!.setBool(_keyCrashReportingConsent, crashReportingConsent);
    await _prefs!.setBool(_keyPIIConsent, piiConsent);
    await _prefs!.setInt(
      _keyConsentTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );

    // Apply consent to managers
    await _applyConsent(
      analyticsConsent: analyticsConsent,
      crashReportingConsent: crashReportingConsent,
      piiConsent: piiConsent,
    );

    _debugLog(
      'Consent updated: analytics=$analyticsConsent, '
      'crashReporting=$crashReportingConsent, pii=$piiConsent',
    );
  }

  /// Grant all consents (full consent)
  ///
  /// Example:
  /// ```dart
  /// await consentManager.grantAllConsent();
  /// ```
  Future<void> grantAllConsent() async {
    await requestConsent(
      analyticsConsent: true,
      crashReportingConsent: true,
      piiConsent: true,
    );
  }

  /// Revoke all consents (complete opt-out)
  ///
  /// Example:
  /// ```dart
  /// await consentManager.revokeAllConsent();
  /// ```
  Future<void> revokeAllConsent() async {
    await requestConsent(
      analyticsConsent: false,
      crashReportingConsent: false,
      piiConsent: false,
    );
  }

  /// Update analytics consent only
  Future<void> setAnalyticsConsent(bool enabled) async {
    final crashConsent = await hasCrashReportingConsent();
    final piiConsent = await hasPIIConsent();

    await requestConsent(
      analyticsConsent: enabled,
      crashReportingConsent: crashConsent,
      piiConsent: piiConsent,
    );
  }

  /// Update crash reporting consent only
  Future<void> setCrashReportingConsent(bool enabled) async {
    final analyticsConsent = await hasAnalyticsConsent();
    final piiConsent = await hasPIIConsent();

    await requestConsent(
      analyticsConsent: analyticsConsent,
      crashReportingConsent: enabled,
      piiConsent: piiConsent,
    );
  }

  /// Update PII consent only
  Future<void> setPIIConsent(bool enabled) async {
    final analyticsConsent = await hasAnalyticsConsent();
    final crashConsent = await hasCrashReportingConsent();

    await requestConsent(
      analyticsConsent: analyticsConsent,
      crashReportingConsent: crashConsent,
      piiConsent: enabled,
    );
  }

  /// Check if consent has been explicitly set by user
  Future<bool> hasExplicitConsent() async {
    _ensureInitialized();
    return _prefs!.containsKey(_keyConsentTimestamp);
  }

  /// Clear all stored consent (reset to defaults)
  Future<void> clearConsent() async {
    _ensureInitialized();

    await _prefs!.remove(_keyAnalyticsConsent);
    await _prefs!.remove(_keyCrashReportingConsent);
    await _prefs!.remove(_keyPIIConsent);
    await _prefs!.remove(_keyConsentTimestamp);

    _debugLog('Consent cleared');

    // Apply default consent
    await _applyStoredConsent();
  }

  /// Get current privacy config based on consent
  Future<PrivacyConfig> getPrivacyConfig() async {
    final analyticsConsent = await hasAnalyticsConsent();
    final crashConsent = await hasCrashReportingConsent();
    final piiConsent = await hasPIIConsent();

    return PrivacyConfig(
      analyticsEnabled: analyticsConsent,
      errorReportingEnabled: crashConsent,
      allowPII: piiConsent,
    );
  }

  /// Apply stored consent to managers
  Future<void> _applyStoredConsent() async {
    final analyticsConsent = await hasAnalyticsConsent();
    final crashConsent = await hasCrashReportingConsent();
    final piiConsent = await hasPIIConsent();

    await _applyConsent(
      analyticsConsent: analyticsConsent,
      crashReportingConsent: crashConsent,
      piiConsent: piiConsent,
    );
  }

  /// Apply consent to managers
  Future<void> _applyConsent({
    required bool analyticsConsent,
    required bool crashReportingConsent,
    required bool piiConsent,
  }) async {
    // Update analytics manager
    if (analyticsManager != null) {
      if (analyticsConsent) {
        await analyticsManager!.enable();
      } else {
        await analyticsManager!.disable();
      }
    }

    // Update error logger
    if (errorLogger != null) {
      if (crashReportingConsent) {
        await errorLogger!.enable();
      } else {
        await errorLogger!.disable();
      }
    }
  }

  /// Ensure manager is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('ConsentManager not initialized. Call initialize() first.');
    }
  }

  void _debugLog(String message) {
    print('[ConsentManager] $message');
  }

  /// Export consent data (for GDPR data export requests)
  Future<Map<String, dynamic>> exportConsentData() async {
    _ensureInitialized();

    return {
      'analytics_consent': await hasAnalyticsConsent(),
      'crash_reporting_consent': await hasCrashReportingConsent(),
      'pii_consent': await hasPIIConsent(),
      'consent_timestamp': (await getConsentTimestamp())?.toIso8601String(),
      'explicit_consent_given': await hasExplicitConsent(),
    };
  }
}
