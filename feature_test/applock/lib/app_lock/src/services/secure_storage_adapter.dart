import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Low-level wrapper around flutter_secure_storage for storing sensitive data
///
/// This adapter provides a consistent interface for secure storage operations
/// and allows for easy mocking in tests.
abstract class SecureStorageAdapter {
  /// Writes a secure value to storage
  Future<void> writeSecure(String key, String value);

  /// Reads a secure value from storage
  ///
  /// Returns null if key doesn't exist
  Future<String?> readSecure(String key);

  /// Deletes a secure value from storage
  Future<void> deleteSecure(String key);

  /// Deletes all secure values from storage
  ///
  /// Use with caution - this will remove all stored data
  Future<void> deleteAll();

  /// Checks if a key exists in secure storage
  Future<bool> containsKey(String key);
}

/// Concrete implementation using flutter_secure_storage
///
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (AndroidKeyStore)
class FlutterSecureStorageAdapter implements SecureStorageAdapter {
  final FlutterSecureStorage _storage;

  FlutterSecureStorageAdapter({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                // Use AES encryption for Android
                // Requires Android API 23+
              ),
              iOptions: IOSOptions(
                // Use kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                // This means data is only accessible when device is unlocked
                // and won't be backed up to iCloud
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<void> writeSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to write secure data: $e');
    }
  }

  @override
  Future<String?> readSecure(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to read secure data: $e');
    }
  }

  @override
  Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete secure data: $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to delete all secure data: $e');
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to check key existence: $e');
    }
  }
}

/// Exception thrown when secure storage operations fail
class SecureStorageException implements Exception {
  final String message;

  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}
