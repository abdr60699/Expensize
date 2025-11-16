import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_store.dart';

/// Secure token storage implementation using flutter_secure_storage.
///
/// Uses platform secure storage (Keychain on iOS, KeyStore on Android,
/// libsecret on Linux, Credential Manager on Windows).
///
/// Suitable for storing sensitive data like tokens and credentials.
class SecureStorageTokenStore implements ITokenStore {
  final FlutterSecureStorage _secureStorage;
  final FlutterSecureStorage _sessionStorage;

  SecureStorageTokenStore({
    FlutterSecureStorage? secureStorage,
    FlutterSecureStorage? sessionStorage,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            ),
        _sessionStorage = sessionStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  static const String _tokenPrefix = 'token_';
  static const String _sessionPrefix = 'session_';

  @override
  Future<void> writeToken(String key, String value) async {
    try {
      await _secureStorage.write(key: '$_tokenPrefix$key', value: value);
    } catch (e) {
      throw StorageException('Failed to write token: $e');
    }
  }

  @override
  Future<String?> readToken(String key) async {
    try {
      return await _secureStorage.read(key: '$_tokenPrefix$key');
    } catch (e) {
      throw StorageException('Failed to read token: $e');
    }
  }

  @override
  Future<void> deleteToken(String key) async {
    try {
      await _secureStorage.delete(key: '$_tokenPrefix$key');
    } catch (e) {
      throw StorageException('Failed to delete token: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      // Delete all token keys
      final all = await _secureStorage.readAll();
      for (final key in all.keys) {
        if (key.startsWith(_tokenPrefix)) {
          await _secureStorage.delete(key: key);
        }
      }
    } catch (e) {
      throw StorageException('Failed to clear all tokens: $e');
    }
  }

  @override
  Future<bool> hasToken(String key) async {
    try {
      final value = await _secureStorage.read(key: '$_tokenPrefix$key');
      return value != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> writeSessionData(String key, String value) async {
    try {
      await _sessionStorage.write(key: '$_sessionPrefix$key', value: value);
    } catch (e) {
      throw StorageException('Failed to write session data: $e');
    }
  }

  @override
  Future<String?> readSessionData(String key) async {
    try {
      return await _sessionStorage.read(key: '$_sessionPrefix$key');
    } catch (e) {
      throw StorageException('Failed to read session data: $e');
    }
  }

  @override
  Future<void> deleteSessionData(String key) async {
    try {
      await _sessionStorage.delete(key: '$_sessionPrefix$key');
    } catch (e) {
      throw StorageException('Failed to delete session data: $e');
    }
  }

  @override
  Future<void> clearSessionData() async {
    try {
      final all = await _sessionStorage.readAll();
      for (final key in all.keys) {
        if (key.startsWith(_sessionPrefix)) {
          await _sessionStorage.delete(key: key);
        }
      }
    } catch (e) {
      throw StorageException('Failed to clear session data: $e');
    }
  }

  /// Clear all data (tokens and session)
  Future<void> clearAllData() async {
    await clearAll();
    await clearSessionData();
  }
}

/// Exception thrown by storage operations
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
