/// Token service for managing authentication tokens
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing authentication tokens
class TokenService {
  static const _accessTokenKey = 'api_access_token';
  static const _refreshTokenKey = 'api_refresh_token';
  static const _tokenTypeKey = 'api_token_type';
  static const _expiryKey = 'api_token_expiry';

  final FlutterSecureStorage _storage;

  TokenService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save token type (e.g., "Bearer")
  Future<void> saveTokenType(String type) async {
    await _storage.write(key: _tokenTypeKey, value: type);
  }

  /// Get token type
  Future<String?> getTokenType() async {
    return await _storage.read(key: _tokenTypeKey);
  }

  /// Save token expiry timestamp
  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _storage.write(key: _expiryKey, value: expiry.toIso8601String());
  }

  /// Get token expiry
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _storage.read(key: _expiryKey);
    if (expiryStr == null) return null;
    return DateTime.parse(expiryStr);
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;

    // Consider token expired if less than 5 minutes remaining
    final now = DateTime.now();
    final buffer = const Duration(minutes: 5);

    return now.isAfter(expiry.subtract(buffer));
  }

  /// Save all tokens at once
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String tokenType = 'Bearer',
    DateTime? expiry,
  }) async {
    await saveAccessToken(accessToken);
    await saveTokenType(tokenType);

    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }

    if (expiry != null) {
      await saveTokenExpiry(expiry);
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _expiryKey);
  }

  /// Check if user is authenticated (has valid access token)
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Get full authorization header value
  Future<String?> getAuthorizationHeader() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final tokenType = await getTokenType() ?? 'Bearer';
    return '$tokenType $token';
  }
}
