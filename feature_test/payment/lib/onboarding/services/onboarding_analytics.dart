/// Analytics tracking for onboarding events
///
/// Provides methods to track onboarding progress and completion.
/// Can be integrated with any analytics provider.
class OnboardingAnalytics {
  /// Callback for logging events
  /// If null, analytics tracking is disabled
  final void Function(String eventName, Map<String, dynamic>? parameters)?
      onLogEvent;

  /// Whether analytics is enabled
  bool get isEnabled => onLogEvent != null;

  const OnboardingAnalytics({this.onLogEvent});

  /// Track when onboarding is started
  void trackOnboardingStarted() {
    if (!isEnabled) return;

    onLogEvent!('onboarding_started', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track when a page is viewed
  void trackPageViewed(int pageIndex, String pageTitle) {
    if (!isEnabled) return;

    onLogEvent!('onboarding_page_viewed', {
      'page_index': pageIndex,
      'page_title': pageTitle,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track when onboarding is completed
  void trackOnboardingCompleted({
    required int totalPages,
    required Duration timeSpent,
  }) {
    if (!isEnabled) return;

    onLogEvent!('onboarding_completed', {
      'total_pages': totalPages,
      'time_spent_seconds': timeSpent.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track when onboarding is skipped
  void trackOnboardingSkipped({
    required int pageReached,
    required int totalPages,
  }) {
    if (!isEnabled) return;

    onLogEvent!('onboarding_skipped', {
      'page_reached': pageReached,
      'total_pages': totalPages,
      'completion_percentage': (pageReached / totalPages * 100).round(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track when user goes to next page
  void trackNextButtonClicked(int fromPage) {
    if (!isEnabled) return;

    onLogEvent!('onboarding_next_clicked', {
      'from_page': fromPage,
    });
  }

  /// Track when user goes to previous page
  void trackPreviousButtonClicked(int fromPage) {
    if (!isEnabled) return;

    onLogEvent!('onboarding_previous_clicked', {
      'from_page': fromPage,
    });
  }

  /// Track when user swipes between pages
  void trackPageSwiped(int fromPage, int toPage) {
    if (!isEnabled) return;

    onLogEvent!('onboarding_page_swiped', {
      'from_page': fromPage,
      'to_page': toPage,
      'direction': toPage > fromPage ? 'forward' : 'backward',
    });
  }

  /// Track custom onboarding event
  void trackCustomEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (!isEnabled) return;

    onLogEvent!('onboarding_$eventName', parameters);
  }
}

/// Helper to integrate with the analytics module
///
/// Example usage:
/// ```dart
/// final analytics = OnboardingAnalytics(
///   onLogEvent: (name, params) {
///     analyticsManager.logEvent(
///       AnalyticsEvent.custom(name: name, parameters: params),
///     );
///   },
/// );
/// ```
class AnalyticsIntegration {
  /// Create analytics integration from analytics manager
  ///
  /// Requires the analytics_logging module.
  static OnboardingAnalytics fromAnalyticsManager(dynamic analyticsManager) {
    return OnboardingAnalytics(
      onLogEvent: (name, params) {
        // This assumes the analytics_logging module is available
        // The actual implementation will depend on the module's API
        try {
          analyticsManager.logEvent(name: name, parameters: params);
        } catch (e) {
          // Silently fail if analytics module not available
          print('[OnboardingAnalytics] Failed to log event: $e');
        }
      },
    );
  }

  /// Create disabled analytics (no-op)
  static OnboardingAnalytics disabled() {
    return const OnboardingAnalytics(onLogEvent: null);
  }
}
