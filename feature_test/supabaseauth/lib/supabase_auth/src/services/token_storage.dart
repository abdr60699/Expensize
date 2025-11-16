/// Interface for secure token storage
abstract class TokenStorage {
  /// Save a token with a key
  Future<void> saveToken(String key, String value);

  /// Retrieve a token by key
  Future<String?> getToken(String key);

  /// Delete a token by key
  Future<void> deleteToken(String key);

  /// Delete all stored tokens
  Future<void> deleteAll();

  /// Check if a token exists
  Future<bool> hasToken(String key);
}

/// Implementation using flutter_secure_storage
class SecureTokenStorage implements TokenStorage {
  static const String _prefix = 'supabase_auth_';

  @override
  Future<void> saveToken(String key, String value) async {
    try {
      // In a real implementation, use flutter_secure_storage
      // For now, this is a placeholder
      // await _storage.write(key: '$_prefix$key', value: value);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  @override
  Future<String?> getToken(String key) async {
    try {
      // In a real implementation, use flutter_secure_storage
      // return await _storage.read(key: '$_prefix$key');
      return null;
    } catch (e) {
      throw Exception('Failed to read token: $e');
    }
  }

  @override
  Future<void> deleteToken(String key) async {
    try {
      // In a real implementation, use flutter_secure_storage
      // await _storage.delete(key: '$_prefix$key');
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      // In a real implementation, delete all keys with prefix
      // await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to delete all tokens: $e');
    }
  }

  @override
  Future<bool> hasToken(String key) async {
    try {
      // In a real implementation, check if key exists
      // return await _storage.containsKey(key: '$_prefix$key');
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// In-memory token storage (for testing or when secure storage is not available)
class MemoryTokenStorage implements TokenStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getToken(String key) async {
    return _storage[key];
  }

  @override
  Future<void> deleteToken(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<bool> hasToken(String key) async {
    return _storage.containsKey(key);
  }
}
