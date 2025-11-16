import '../models/analytics_event.dart';
import '../models/analytics_user.dart';
import '../models/privacy_config.dart';
import '../providers/analytics_provider.dart';

/// Unified analytics manager
///
/// Provides a single API for tracking analytics across multiple providers.
/// Manages provider lifecycle, consent, and privacy settings.
///
/// Example:
/// ```dart
/// final manager = AnalyticsManager(
///   providers: [FirebaseAnalyticsProvider()],
///   privacyConfig: PrivacyConfig.fullConsent(),
/// );
///
/// await manager.initialize();
///
/// // Track events
/// await manager.logEvent(
///   AnalyticsEvent.custom(
///     name: 'purchase_completed',
///     parameters: {'amount': 99.99},
///   ),
/// );
///
/// // Set user
/// await manager.setUser(
///   AnalyticsUser.withId('user123'),
/// );
/// ```
class AnalyticsManager {
  final List<AnalyticsProvider> _providers;
  final PrivacyConfig privacyConfig;
  bool _isInitialized = false;
  AnalyticsUser? _currentUser;

  AnalyticsManager({
    required List<AnalyticsProvider> providers,
    PrivacyConfig? privacyConfig,
  })  : _providers = providers,
        privacyConfig = privacyConfig ?? const PrivacyConfig();

  /// Whether analytics manager is initialized
  bool get isInitialized => _isInitialized;

  /// Currently set user (if any)
  AnalyticsUser? get currentUser => _currentUser;

  /// List of enabled providers
  List<AnalyticsProvider> get enabledProviders =>
      _providers.where((p) => p.isEnabled).toList();

  /// Initialize all analytics providers
  ///
  /// Call this once during app startup, after Firebase.initializeApp()
  /// if using Firebase Analytics.
  ///
  /// Returns true if at least one provider initialized successfully.
  Future<bool> initialize() async {
    if (_isInitialized) {
      _debugLog('Analytics already initialized');
      return true;
    }

    if (!privacyConfig.analyticsEnabled) {
      _debugLog('Analytics disabled by privacy config');
      return false;
    }

    if (_providers.isEmpty) {
      _debugLog('No analytics providers configured');
      return false;
    }

    _debugLog('Initializing ${_providers.length} analytics provider(s)...');

    final results = await Future.wait(
      _providers.map((provider) => provider.initialize()),
    );

    final successCount = results.where((r) => r).length;
    _isInitialized = successCount > 0;

    _debugLog('Initialized $successCount/${_providers.length} provider(s)');

    return _isInitialized;
  }

  /// Log an analytics event
  ///
  /// Sends the event to all enabled providers.
  ///
  /// Example:
  /// ```dart
  /// await manager.logEvent(
  ///   AnalyticsEvent.custom(
  ///     name: 'button_click',
  ///     parameters: {'button_id': 'checkout'},
  ///   ),
  /// );
  /// ```
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!_isInitialized || !privacyConfig.analyticsEnabled) {
      _debugLog('Analytics not available - skipping event: ${event.name}');
      return;
    }

    _debugLog('Logging event: ${event.name}');

    await Future.wait(
      enabledProviders.map((provider) => provider.logEvent(event)),
    );
  }

  /// Log a screen view event
  ///
  /// Convenience method for tracking screen/page views.
  ///
  /// Example:
  /// ```dart
  /// await manager.logScreenView(
  ///   screenName: 'HomeScreen',
  ///   screenClass: 'HomePage',
  /// );
  /// ```
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isInitialized || !privacyConfig.analyticsEnabled) {
      _debugLog('Analytics not available - skipping screen view: $screenName');
      return;
    }

    _debugLog('Logging screen view: $screenName');

    await Future.wait(
      enabledProviders.map(
        (provider) => provider.logScreenView(
          screenName: screenName,
          screenClass: screenClass,
        ),
      ),
    );
  }

  /// Log a user action event
  ///
  /// Convenience method for tracking user interactions.
  ///
  /// Example:
  /// ```dart
  /// await manager.logUserAction(
  ///   action: 'button_click',
  ///   category: 'navigation',
  ///   label: 'checkout',
  /// );
  /// ```
  Future<void> logUserAction({
    required String action,
    String? category,
    String? label,
    dynamic value,
    Map<String, dynamic>? additionalParameters,
  }) async {
    final event = AnalyticsEvent.userAction(
      action: action,
      category: category,
      label: label,
      value: value,
      additionalParameters: additionalParameters,
    );

    await logEvent(event);
  }

  /// Set the current user
  ///
  /// Sets user properties across all enabled providers.
  /// Respects privacy settings and consent.
  ///
  /// Example:
  /// ```dart
  /// await manager.setUser(
  ///   AnalyticsUser.withFullConsent(
  ///     userId: 'user123',
  ///     email: 'user@example.com',
  ///     properties: {'subscription': 'premium'},
  ///   ),
  /// );
  /// ```
  Future<void> setUser(AnalyticsUser user) async {
    if (!_isInitialized) {
      _debugLog('Analytics not initialized - skipping set user');
      return;
    }

    _currentUser = user;

    // Only set user properties if analytics consent is granted
    if (!user.hasAnalyticsConsent || !privacyConfig.analyticsEnabled) {
      _debugLog('Analytics consent not granted - skipping set user');
      return;
    }

    _debugLog('Setting user: ${user.userId}');

    await Future.wait(
      enabledProviders.map((provider) => provider.setUserProperties(user)),
    );
  }

  /// Set the user ID
  ///
  /// Convenience method to set just the user ID.
  ///
  /// Example:
  /// ```dart
  /// await manager.setUserId('user123');
  /// ```
  Future<void> setUserId(String? userId) async {
    if (!_isInitialized || !privacyConfig.analyticsEnabled) {
      _debugLog('Analytics not available - skipping set user ID');
      return;
    }

    _debugLog('Setting user ID: $userId');

    await Future.wait(
      enabledProviders.map((provider) => provider.setUserId(userId)),
    );

    // Update current user
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(userId: userId);
    } else {
      _currentUser = AnalyticsUser.withId(userId ?? '');
    }
  }

  /// Set a user property
  ///
  /// Example:
  /// ```dart
  /// await manager.setUserProperty(
  ///   name: 'subscription_tier',
  ///   value: 'premium',
  /// );
  /// ```
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_isInitialized || !privacyConfig.analyticsEnabled) {
      _debugLog('Analytics not available - skipping set user property');
      return;
    }

    _debugLog('Setting user property: $name = $value');

    await Future.wait(
      enabledProviders.map(
        (provider) => provider.setUserProperty(name: name, value: value),
      ),
    );
  }

  /// Reset all analytics data
  ///
  /// Clears user ID, user properties, and cached data.
  /// Call this on user logout.
  ///
  /// Example:
  /// ```dart
  /// await manager.reset();
  /// ```
  Future<void> reset() async {
    if (!_isInitialized) {
      _debugLog('Analytics not initialized - skipping reset');
      return;
    }

    _debugLog('Resetting analytics');

    _currentUser = null;

    await Future.wait(
      _providers.map((provider) => provider.resetAnalytics()),
    );
  }

  /// Enable analytics collection
  ///
  /// Re-enables analytics after user grants consent.
  /// Updates all providers.
  Future<void> enable() async {
    if (!_isInitialized) {
      _debugLog('Analytics not initialized - skipping enable');
      return;
    }

    _debugLog('Enabling analytics');

    await Future.wait(
      _providers.map((provider) => provider.enable()),
    );
  }

  /// Disable analytics collection
  ///
  /// Disables analytics when user revokes consent.
  /// Updates all providers.
  Future<void> disable() async {
    if (!_isInitialized) {
      _debugLog('Analytics not initialized - skipping disable');
      return;
    }

    _debugLog('Disabling analytics');

    await Future.wait(
      _providers.map((provider) => provider.disable()),
    );
  }

  /// Set session timeout
  ///
  /// Example:
  /// ```dart
  /// await manager.setSessionTimeout(Duration(minutes: 30));
  /// ```
  Future<void> setSessionTimeout(Duration duration) async {
    if (!_isInitialized) return;

    await Future.wait(
      enabledProviders.map((provider) => provider.setSessionTimeout(duration)),
    );
  }

  /// Get a specific provider by type
  ///
  /// Example:
  /// ```dart
  /// final firebaseProvider = manager.getProvider<FirebaseAnalyticsProvider>();
  /// if (firebaseProvider != null) {
  ///   // Use Firebase-specific features
  ///   final observer = firebaseProvider.getNavigatorObserver();
  /// }
  /// ```
  T? getProvider<T extends AnalyticsProvider>() {
    try {
      return _providers.whereType<T>().first;
    } catch (e) {
      return null;
    }
  }

  /// Dispose all providers and cleanup resources
  ///
  /// Call this when the app is shutting down.
  Future<void> dispose() async {
    _debugLog('Disposing analytics manager');

    await Future.wait(
      _providers.map((provider) => provider.dispose()),
    );

    _isInitialized = false;
    _currentUser = null;
  }

  void _debugLog(String message) {
    if (privacyConfig.enableDebugLogging) {
      print('[AnalyticsManager] $message');
    }
  }
}
