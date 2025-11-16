import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing onboarding state and persistence
///
/// Tracks whether the user has completed onboarding and provides
/// utilities for checking and resetting onboarding state.
class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyOnboardingCompletedAt = 'onboarding_completed_at';
  static const String _keyOnboardingVersion = 'onboarding_version';
  static const String _keyOnboardingSkipped = 'onboarding_skipped';
  static const String _keyLastPageReached = 'onboarding_last_page';

  final String? version;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  OnboardingService({this.version});

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service
  ///
  /// Must be called before using other methods.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Check if onboarding has been completed
  ///
  /// Returns true if the user has completed onboarding.
  /// If [version] is provided in constructor, checks if the completed
  /// version matches the current version.
  Future<bool> isOnboardingCompleted() async {
    _ensureInitialized();

    final completed = _prefs!.getBool(_keyOnboardingCompleted) ?? false;

    // If no version tracking, just return completion status
    if (version == null) return completed;

    // If version tracking enabled, check if versions match
    if (!completed) return false;

    final completedVersion = _prefs!.getString(_keyOnboardingVersion);
    return completedVersion == version;
  }

  /// Check if user should see onboarding
  ///
  /// Returns true if onboarding should be shown.
  /// This is the inverse of [isOnboardingCompleted].
  Future<bool> shouldShowOnboarding() async {
    return !(await isOnboardingCompleted());
  }

  /// Mark onboarding as completed
  ///
  /// [pageReached] - Optional: The last page number reached
  Future<void> completeOnboarding({int? pageReached}) async {
    _ensureInitialized();

    await _prefs!.setBool(_keyOnboardingCompleted, true);
    await _prefs!.setInt(
      _keyOnboardingCompletedAt,
      DateTime.now().millisecondsSinceEpoch,
    );

    if (version != null) {
      await _prefs!.setString(_keyOnboardingVersion, version!);
    }

    if (pageReached != null) {
      await _prefs!.setInt(_keyLastPageReached, pageReached);
    }

    // Clear skipped flag if it was set
    await _prefs!.remove(_keyOnboardingSkipped);
  }

  /// Mark onboarding as skipped
  ///
  /// Different from completion - tracks that user explicitly skipped.
  Future<void> skipOnboarding({int? pageReached}) async {
    _ensureInitialized();

    await _prefs!.setBool(_keyOnboardingSkipped, true);
    await _prefs!.setBool(_keyOnboardingCompleted, true);
    await _prefs!.setInt(
      _keyOnboardingCompletedAt,
      DateTime.now().millisecondsSinceEpoch,
    );

    if (version != null) {
      await _prefs!.setString(_keyOnboardingVersion, version!);
    }

    if (pageReached != null) {
      await _prefs!.setInt(_keyLastPageReached, pageReached);
    }
  }

  /// Check if onboarding was skipped (vs completed)
  Future<bool> wasOnboardingSkipped() async {
    _ensureInitialized();
    return _prefs!.getBool(_keyOnboardingSkipped) ?? false;
  }

  /// Get the timestamp when onboarding was completed
  Future<DateTime?> getCompletedAt() async {
    _ensureInitialized();

    final timestamp = _prefs!.getInt(_keyOnboardingCompletedAt);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Get the version of onboarding that was completed
  Future<String?> getCompletedVersion() async {
    _ensureInitialized();
    return _prefs!.getString(_keyOnboardingVersion);
  }

  /// Get the last page number reached
  Future<int?> getLastPageReached() async {
    _ensureInitialized();
    return _prefs!.getInt(_keyLastPageReached);
  }

  /// Reset onboarding state
  ///
  /// Clears all onboarding data, forcing it to show again.
  /// Useful for testing or allowing users to replay onboarding.
  Future<void> resetOnboarding() async {
    _ensureInitialized();

    await _prefs!.remove(_keyOnboardingCompleted);
    await _prefs!.remove(_keyOnboardingCompletedAt);
    await _prefs!.remove(_keyOnboardingVersion);
    await _prefs!.remove(_keyOnboardingSkipped);
    await _prefs!.remove(_keyLastPageReached);
  }

  /// Check if onboarding version has changed
  ///
  /// Returns true if the stored version differs from current version.
  /// Useful for showing onboarding again when major changes occur.
  Future<bool> hasVersionChanged() async {
    if (version == null) return false;

    _ensureInitialized();

    final completedVersion = _prefs!.getString(_keyOnboardingVersion);
    if (completedVersion == null) return false;

    return completedVersion != version;
  }

  /// Get all onboarding data as a map (for debugging/export)
  Future<Map<String, dynamic>> getOnboardingData() async {
    _ensureInitialized();

    return {
      'completed': await isOnboardingCompleted(),
      'completed_at': (await getCompletedAt())?.toIso8601String(),
      'version': await getCompletedVersion(),
      'skipped': await wasOnboardingSkipped(),
      'last_page': await getLastPageReached(),
      'current_version': version,
      'version_changed': await hasVersionChanged(),
    };
  }

  /// Update last page reached without completing onboarding
  ///
  /// Useful for tracking progress through onboarding.
  Future<void> updateLastPage(int pageIndex) async {
    _ensureInitialized();
    await _prefs!.setInt(_keyLastPageReached, pageIndex);
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'OnboardingService not initialized. Call initialize() first.',
      );
    }
  }

  @override
  String toString() {
    return 'OnboardingService(version: $version, initialized: $_isInitialized)';
  }
}
