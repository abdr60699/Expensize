/// Interface for secure token and session storage.
///
/// Implementations should handle secure storage of authentication tokens,
/// session metadata, and user preferences.
abstract class ITokenStore {
  /// Store a token securely
  Future<void> writeToken(String key, String value);

  /// Retrieve a stored token
  Future<String?> readToken(String key);

  /// Delete a specific token
  Future<void> deleteToken(String key);

  /// Clear all stored tokens
  Future<void> clearAll();

  /// Check if a token exists
  Future<bool> hasToken(String key);

  /// Store session metadata (e.g., last login time, user ID)
  Future<void> writeSessionData(String key, String value);

  /// Retrieve session metadata
  Future<String?> readSessionData(String key);

  /// Delete session metadata
  Future<void> deleteSessionData(String key);

  /// Clear all session data
  Future<void> clearSessionData();
}

/// Common storage keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String lastLoginTime = 'last_login_time';
  static const String biometricEnabled = 'biometric_enabled';
  static const String sessionId = 'session_id';
  static const String fcmToken = 'fcm_token';
}
