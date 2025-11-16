import '../models/analytics_event.dart';
import '../models/analytics_user.dart';

/// Abstract interface for analytics providers
///
/// Implement this interface to create custom analytics providers
/// (Firebase Analytics, Mixpanel, Amplitude, etc.)
abstract class AnalyticsProvider {
  /// Provider name for identification
  String get name;

  /// Whether this provider is currently enabled
  bool get isEnabled;

  /// Initialize the analytics provider
  ///
  /// Called once during app startup. Use this to configure
  /// the analytics SDK and perform any required setup.
  ///
  /// Returns true if initialization was successful.
  Future<bool> initialize();

  /// Log an analytics event
  ///
  /// [event] The event to track
  ///
  /// Example:
  /// ```dart
  /// await provider.logEvent(
  ///   AnalyticsEvent.custom(
  ///     name: 'purchase_completed',
  ///     parameters: {'amount': 99.99, 'currency': 'USD'},
  ///   ),
  /// );
  /// ```
  Future<void> logEvent(AnalyticsEvent event);

  /// Log a screen view event
  ///
  /// [screenName] Name of the screen/page
  /// [screenClass] Optional class/type of the screen
  ///
  /// Example:
  /// ```dart
  /// await provider.logScreenView(
  ///   screenName: 'HomeScreen',
  ///   screenClass: 'HomePage',
  /// );
  /// ```
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  /// Set user properties
  ///
  /// [user] The user data to set (includes consent and PII handling)
  ///
  /// Example:
  /// ```dart
  /// await provider.setUserProperties(
  ///   AnalyticsUser.withId('user123'),
  /// );
  /// ```
  Future<void> setUserProperties(AnalyticsUser user);

  /// Set a specific user property
  ///
  /// [name] Property name
  /// [value] Property value
  ///
  /// Example:
  /// ```dart
  /// await provider.setUserProperty(
  ///   name: 'subscription_tier',
  ///   value: 'premium',
  /// );
  /// ```
  Future<void> setUserProperty({
    required String name,
    required String value,
  });

  /// Set the user ID
  ///
  /// [userId] Unique identifier for the user (or null to clear)
  ///
  /// Example:
  /// ```dart
  /// await provider.setUserId('user123');
  /// ```
  Future<void> setUserId(String? userId);

  /// Reset all analytics data (for logout)
  ///
  /// Clears user properties, user ID, and any cached data.
  ///
  /// Example:
  /// ```dart
  /// await provider.resetAnalytics();
  /// ```
  Future<void> resetAnalytics();

  /// Enable analytics collection
  ///
  /// Used for consent management - re-enables collection
  /// after user grants consent.
  Future<void> enable();

  /// Disable analytics collection
  ///
  /// Used for consent management - stops all data collection
  /// when user revokes consent or opts out.
  Future<void> disable();

  /// Set session timeout duration
  ///
  /// [duration] How long before a session expires
  ///
  /// Example:
  /// ```dart
  /// await provider.setSessionTimeout(Duration(minutes: 30));
  /// ```
  Future<void> setSessionTimeout(Duration duration);

  /// Set the minimum engagement time for a session
  ///
  /// [duration] Minimum time for session to be counted
  Future<void> setMinimumSessionDuration(Duration duration);

  /// Dispose and cleanup resources
  ///
  /// Called when the provider is no longer needed.
  Future<void> dispose();
}
