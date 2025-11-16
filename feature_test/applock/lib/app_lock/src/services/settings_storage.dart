import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper for non-sensitive settings storage
///
/// This stores configuration and non-secret data that doesn't require
/// encryption. Uses SharedPreferences for simplicity and compatibility.
abstract class SettingsStorage {
  /// Writes a value to settings storage
  Future<void> write(String key, String value);

  /// Reads a value from settings storage
  ///
  /// Returns null if key doesn't exist
  Future<String?> read(String key);

  /// Writes an integer value
  Future<void> writeInt(String key, int value);

  /// Reads an integer value
  Future<int?> readInt(String key);

  /// Writes a boolean value
  Future<void> writeBool(String key, bool value);

  /// Reads a boolean value
  Future<bool?> readBool(String key);

  /// Deletes a value from settings storage
  Future<void> delete(String key);

  /// Clears all settings storage
  Future<void> clear();

  /// Checks if a key exists
  Future<bool> containsKey(String key);
}

/// Implementation using SharedPreferences
///
/// This is suitable for storing non-sensitive configuration data like:
/// - Failed attempt counts
/// - Lockout timestamps
/// - Auto-lock timeout settings
/// - UI preferences
class SharedPreferencesSettingsStorage implements SettingsStorage {
  SharedPreferences? _prefs;

  /// Initializes the storage
  ///
  /// Must be called before using any other methods
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw SettingsStorageException(
        'SettingsStorage not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _preferences.setString(key, value);
    } catch (e) {
      throw SettingsStorageException('Failed to write setting: $e');
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return _preferences.getString(key);
    } catch (e) {
      throw SettingsStorageException('Failed to read setting: $e');
    }
  }

  @override
  Future<void> writeInt(String key, int value) async {
    try {
      await _preferences.setInt(key, value);
    } catch (e) {
      throw SettingsStorageException('Failed to write int setting: $e');
    }
  }

  @override
  Future<int?> readInt(String key) async {
    try {
      return _preferences.getInt(key);
    } catch (e) {
      throw SettingsStorageException('Failed to read int setting: $e');
    }
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    try {
      await _preferences.setBool(key, value);
    } catch (e) {
      throw SettingsStorageException('Failed to write bool setting: $e');
    }
  }

  @override
  Future<bool?> readBool(String key) async {
    try {
      return _preferences.getBool(key);
    } catch (e) {
      throw SettingsStorageException('Failed to read bool setting: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _preferences.remove(key);
    } catch (e) {
      throw SettingsStorageException('Failed to delete setting: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _preferences.clear();
    } catch (e) {
      throw SettingsStorageException('Failed to clear settings: $e');
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _preferences.containsKey(key);
    } catch (e) {
      throw SettingsStorageException('Failed to check key existence: $e');
    }
  }
}

/// Exception thrown when settings storage operations fail
class SettingsStorageException implements Exception {
  final String message;

  SettingsStorageException(this.message);

  @override
  String toString() => 'SettingsStorageException: $message';
}
