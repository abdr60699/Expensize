import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/consent_manager.dart';
import '../core/analytics_manager.dart';
import '../core/error_logger.dart';
import 'analytics_manager_test.dart'; // For MockAnalyticsProvider

/// Mock error provider for testing
class MockErrorProvider {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void enable() => _isEnabled = true;
  void disable() => _isEnabled = false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConsentManager', () {
    late ConsentManager consentManager;

    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});

      consentManager = ConsentManager();
      await consentManager.initialize();
    });

    test('initializes successfully', () async {
      expect(consentManager.isInitialized, true);
    });

    test('throws when not initialized', () {
      final uninitializedManager = ConsentManager();

      expect(
        () => uninitializedManager.hasAnalyticsConsent(),
        throwsStateError,
      );
    });

    test('defaults to opt-out model (consent granted by default)', () async {
      final hasAnalyticsConsent = await consentManager.hasAnalyticsConsent();
      final hasCrashConsent =
          await consentManager.hasCrashReportingConsent();

      expect(hasAnalyticsConsent, true);
      expect(hasCrashConsent, true);
    });

    test('requires explicit consent when configured', () async {
      SharedPreferences.setMockInitialValues({});
      final explicitConsentManager = ConsentManager(
        requireExplicitConsent: true,
      );
      await explicitConsentManager.initialize();

      final hasAnalyticsConsent =
          await explicitConsentManager.hasAnalyticsConsent();
      final hasCrashConsent =
          await explicitConsentManager.hasCrashReportingConsent();

      expect(hasAnalyticsConsent, false);
      expect(hasCrashConsent, false);
    });

    test('PII consent always requires explicit opt-in', () async {
      final hasPIIConsent = await consentManager.hasPIIConsent();

      expect(hasPIIConsent, false);
    });

    test('stores and retrieves consent preferences', () async {
      await consentManager.requestConsent(
        analyticsConsent: true,
        crashReportingConsent: false,
        piiConsent: true,
      );

      expect(await consentManager.hasAnalyticsConsent(), true);
      expect(await consentManager.hasCrashReportingConsent(), false);
      expect(await consentManager.hasPIIConsent(), true);
    });

    test('stores consent timestamp', () async {
      final beforeConsent = DateTime.now();

      await consentManager.requestConsent(
        analyticsConsent: true,
        crashReportingConsent: true,
      );

      final timestamp = await consentManager.getConsentTimestamp();

      expect(timestamp, isNotNull);
      expect(timestamp!.isAfter(beforeConsent), true);
    });

    test('tracks explicit consent', () async {
      // Initially no explicit consent
      expect(await consentManager.hasExplicitConsent(), false);

      // After requesting consent
      await consentManager.requestConsent(
        analyticsConsent: true,
        crashReportingConsent: true,
      );

      expect(await consentManager.hasExplicitConsent(), true);
    });

    test('grants all consent', () async {
      await consentManager.grantAllConsent();

      expect(await consentManager.hasAnalyticsConsent(), true);
      expect(await consentManager.hasCrashReportingConsent(), true);
      expect(await consentManager.hasPIIConsent(), true);
    });

    test('revokes all consent', () async {
      await consentManager.revokeAllConsent();

      expect(await consentManager.hasAnalyticsConsent(), false);
      expect(await consentManager.hasCrashReportingConsent(), false);
      expect(await consentManager.hasPIIConsent(), false);
    });

    test('updates individual consent settings', () async {
      await consentManager.grantAllConsent();

      // Update only analytics consent
      await consentManager.setAnalyticsConsent(false);

      expect(await consentManager.hasAnalyticsConsent(), false);
      expect(await consentManager.hasCrashReportingConsent(), true);
      expect(await consentManager.hasPIIConsent(), true);
    });

    test('clears stored consent', () async {
      await consentManager.requestConsent(
        analyticsConsent: false,
        crashReportingConsent: false,
      );

      await consentManager.clearConsent();

      // Should return to defaults (opt-out model = granted)
      expect(await consentManager.hasAnalyticsConsent(), true);
      expect(await consentManager.hasCrashReportingConsent(), true);
      expect(await consentManager.hasExplicitConsent(), false);
    });

    test('generates privacy config from consent', () async {
      await consentManager.requestConsent(
        analyticsConsent: true,
        crashReportingConsent: false,
        piiConsent: true,
      );

      final privacyConfig = await consentManager.getPrivacyConfig();

      expect(privacyConfig.analyticsEnabled, true);
      expect(privacyConfig.errorReportingEnabled, false);
      expect(privacyConfig.allowPII, true);
    });

    test('exports consent data for GDPR', () async {
      await consentManager.requestConsent(
        analyticsConsent: true,
        crashReportingConsent: true,
        piiConsent: false,
      );

      final exportData = await consentManager.exportConsentData();

      expect(exportData['analytics_consent'], true);
      expect(exportData['crash_reporting_consent'], true);
      expect(exportData['pii_consent'], false);
      expect(exportData['consent_timestamp'], isNotNull);
      expect(exportData['explicit_consent_given'], true);
    });

    test('applies consent to analytics manager', () async {
      final mockProvider = MockAnalyticsProvider();
      final analyticsManager = AnalyticsManager(
        providers: [mockProvider],
      );
      await analyticsManager.initialize();

      final managerConsentManager = ConsentManager(
        analyticsManager: analyticsManager,
      );
      await managerConsentManager.initialize();

      // Initially enabled
      expect(mockProvider.isEnabled, true);

      // Revoke consent
      await managerConsentManager.setAnalyticsConsent(false);

      // Should be disabled
      expect(mockProvider.isEnabled, false);

      // Grant consent again
      await managerConsentManager.setAnalyticsConsent(true);

      // Should be enabled
      expect(mockProvider.isEnabled, true);
    });

    test('persists consent across sessions', () async {
      // First session
      await consentManager.requestConsent(
        analyticsConsent: false,
        crashReportingConsent: true,
        piiConsent: true,
      );

      // Simulate new session by creating new ConsentManager
      final newSessionManager = ConsentManager();
      await newSessionManager.initialize();

      expect(await newSessionManager.hasAnalyticsConsent(), false);
      expect(await newSessionManager.hasCrashReportingConsent(), true);
      expect(await newSessionManager.hasPIIConsent(), true);
    });
  });
}
