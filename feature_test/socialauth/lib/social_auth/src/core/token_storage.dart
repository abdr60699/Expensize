/// Interface for secure token storage
///
/// Use flutter_secure_storage for implementation
abstract class TokenStorage {
  /// Save token securely
  Future<void> saveToken(String key, String value);

  /// Read token
  Future<String?> readToken(String key);

  /// Delete token
  Future<void> deleteToken(String key);

  /// Delete all tokens
  Future<void> deleteAll();

  /// Check if token exists
  Future<bool> hasToken(String key);
}

/// Default implementation using flutter_secure_storage
class SecureTokenStorage implements TokenStorage {
  // Note: Requires flutter_secure_storage package
  // Import and initialize in implementation
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> readToken(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> hasToken(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}

// Mock implementation for flutter_secure_storage import
class FlutterSecureStorage {
  const FlutterSecureStorage();

  Future<void> write({required String key, required String value}) async {
    // Actual implementation will use flutter_secure_storage package
  }

  Future<String?> read({required String key}) async {
    return null;
  }

  Future<void> delete({required String key}) async {}

  Future<void> deleteAll() async {}
}
