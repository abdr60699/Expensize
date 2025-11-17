import 'package:flutter_test/flutter_test.dart';
import '../core/analytics_manager.dart';
import '../models/analytics_event.dart';
import '../models/analytics_user.dart';
import '../models/privacy_config.dart';
import '../providers/analytics_provider.dart';

/// Mock analytics provider for testing
class MockAnalyticsProvider implements AnalyticsProvider {
  final List<String> loggedEvents = [];
  final List<String> loggedScreens = [];
  final Map<String, String> userProperties = {};
  String? userId;
  bool _isEnabled = true;
  bool _isInitialized = false;

  @override
  String get name => 'Mock Analytics';

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    loggedEvents.add(event.name);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    loggedScreens.add(screenName);
  }

  @override
  Future<void> setUserProperties(AnalyticsUser user) async {
    if (user.userId != null) userId = user.userId;
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    userProperties[name] = value;
  }

  @override
  Future<void> setUserId(String? userId) async {
    this.userId = userId;
  }

  @override
  Future<void> resetAnalytics() async {
    userId = null;
    userProperties.clear();
    loggedEvents.clear();
    loggedScreens.clear();
  }

  @override
  Future<void> enable() async {
    _isEnabled = true;
  }

  @override
  Future<void> disable() async {
    _isEnabled = false;
  }

  @override
  Future<void> setSessionTimeout(Duration duration) async {}

  @override
  Future<void> setMinimumSessionDuration(Duration duration) async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  group('AnalyticsManager', () {
    late MockAnalyticsProvider mockProvider;
    late AnalyticsManager manager;

    setUp(() {
      mockProvider = MockAnalyticsProvider();
      manager = AnalyticsManager(
        providers: [mockProvider],
        privacyConfig: PrivacyConfig.fullConsent(),
      );
    });

    test('initializes providers', () async {
      expect(manager.isInitialized, false);

      final result = await manager.initialize();

      expect(result, true);
      expect(manager.isInitialized, true);
    });

    test('logs events to providers', () async {
      await manager.initialize();

      final event = AnalyticsEvent.custom(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      await manager.logEvent(event);

      expect(mockProvider.loggedEvents, contains('test_event'));
    });

    test('logs screen views', () async {
      await manager.initialize();

      await manager.logScreenView(screenName: 'HomeScreen');

      expect(mockProvider.loggedScreens, contains('HomeScreen'));
    });

    test('logs user actions', () async {
      await manager.initialize();

      await manager.logUserAction(
        action: 'button_click',
        category: 'navigation',
      );

      expect(mockProvider.loggedEvents, contains('button_click'));
    });

    test('sets user properties', () async {
      await manager.initialize();

      final user = AnalyticsUser.withId('user123');
      await manager.setUser(user);

      expect(mockProvider.userId, 'user123');
      expect(manager.currentUser?.userId, 'user123');
    });

    test('sets user ID', () async {
      await manager.initialize();

      await manager.setUserId('user456');

      expect(mockProvider.userId, 'user456');
      expect(manager.currentUser?.userId, 'user456');
    });

    test('sets user property', () async {
      await manager.initialize();

      await manager.setUserProperty(
        name: 'subscription_tier',
        value: 'premium',
      );

      expect(mockProvider.userProperties['subscription_tier'], 'premium');
    });

    test('resets analytics', () async {
      await manager.initialize();

      await manager.setUserId('user123');
      await manager.logEvent(AnalyticsEvent.custom(name: 'test'));

      await manager.reset();

      expect(mockProvider.userId, null);
      expect(mockProvider.loggedEvents, isEmpty);
      expect(manager.currentUser, null);
    });

    test('respects privacy config', () async {
      final restrictedManager = AnalyticsManager(
        providers: [mockProvider],
        privacyConfig: PrivacyConfig.minimal(),
      );

      final initialized = await restrictedManager.initialize();

      expect(initialized, false);
      expect(restrictedManager.isInitialized, false);
    });

    test('enables and disables providers', () async {
      await manager.initialize();

      expect(mockProvider.isEnabled, true);

      await manager.disable();
      expect(mockProvider.isEnabled, false);

      await manager.enable();
      expect(mockProvider.isEnabled, true);
    });

    test('validates event names', () async {
      await manager.initialize();

      // Valid event name
      final validEvent = AnalyticsEvent.custom(name: 'valid_event_name');
      expect(validEvent.isValidEventName(), true);

      // Invalid event name (too long)
      final invalidEvent =
          AnalyticsEvent.custom(name: 'a' * 41); // 41 characters
      expect(invalidEvent.isValidEventName(), false);

      // Invalid event name (starts with number)
      final invalidEvent2 = AnalyticsEvent.custom(name: '1_invalid');
      expect(invalidEvent2.isValidEventName(), false);
    });

    test('sanitizes user data when PII not allowed', () async {
      final noPIIManager = AnalyticsManager(
        providers: [mockProvider],
        privacyConfig: const PrivacyConfig(allowPII: false),
      );

      await noPIIManager.initialize();

      final user = AnalyticsUser.withFullConsent(
        userId: 'user123',
        email: 'user@example.com',
        name: 'John Doe',
      );

      final sanitized = user.sanitized;

      expect(sanitized.userId, 'user123');
      expect(sanitized.email, null);
      expect(sanitized.name, null);
    });

    test('gets specific provider by type', () async {
      await manager.initialize();

      final provider = manager.getProvider<MockAnalyticsProvider>();

      expect(provider, isNotNull);
      expect(provider, equals(mockProvider));
    });

    test('disposes providers', () async {
      await manager.initialize();
      await manager.dispose();

      expect(manager.isInitialized, false);
      expect(manager.currentUser, null);
    });
  });

  group('AnalyticsEvent', () {
    test('creates screen view event', () {
      final event = AnalyticsEvent.screenView(
        screenName: 'HomeScreen',
        screenClass: 'HomePage',
      );

      expect(event.name, 'screen_view');
      expect(event.parameters?['screen_name'], 'HomeScreen');
      expect(event.parameters?['screen_class'], 'HomePage');
    });

    test('creates user action event', () {
      final event = AnalyticsEvent.userAction(
        action: 'button_click',
        category: 'navigation',
        label: 'home_to_profile',
      );

      expect(event.name, 'button_click');
      expect(event.parameters?['category'], 'navigation');
      expect(event.parameters?['label'], 'home_to_profile');
    });

    test('serializes to/from JSON', () {
      final event = AnalyticsEvent.custom(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      final json = event.toJson();
      final deserialized = AnalyticsEvent.fromJson(json);

      expect(deserialized.name, event.name);
      expect(deserialized.parameters, event.parameters);
    });
  });

  group('AnalyticsUser', () {
    test('creates anonymous user', () {
      final user = AnalyticsUser.anonymous();

      expect(user.userId, null);
      expect(user.hasAnalyticsConsent, true);
      expect(user.canSendPII, false);
    });

    test('creates user with ID only', () {
      final user = AnalyticsUser.withId('user123');

      expect(user.userId, 'user123');
      expect(user.email, null);
      expect(user.canSendPII, false);
    });

    test('creates user with full consent', () {
      final user = AnalyticsUser.withFullConsent(
        userId: 'user123',
        email: 'user@example.com',
        name: 'John Doe',
      );

      expect(user.userId, 'user123');
      expect(user.email, 'user@example.com');
      expect(user.name, 'John Doe');
      expect(user.canSendPII, true);
    });

    test('sanitizes PII data', () {
      final user = AnalyticsUser(
        userId: 'user123',
        email: 'user@example.com',
        name: 'John Doe',
        canSendPII: false,
      );

      final sanitized = user.sanitized;

      expect(sanitized.userId, 'user123');
      expect(sanitized.email, null);
      expect(sanitized.name, null);
    });

    test('exports analytics properties', () {
      final user = AnalyticsUser.withFullConsent(
        userId: 'user123',
        email: 'user@example.com',
        properties: {'subscription': 'premium'},
      );

      final props = user.getAnalyticsProperties();

      expect(props['user_id'], 'user123');
      expect(props['email'], 'user@example.com');
      expect(props['subscription'], 'premium');
    });

    test('serializes to/from JSON', () {
      final user = AnalyticsUser.withId('user123');

      final json = user.toJson();
      final deserialized = AnalyticsUser.fromJson(json);

      expect(deserialized.userId, user.userId);
      expect(deserialized.hasAnalyticsConsent, user.hasAnalyticsConsent);
    });
  });
}
