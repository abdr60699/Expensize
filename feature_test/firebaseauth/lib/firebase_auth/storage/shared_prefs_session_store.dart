import 'package:shared_preferences/shared_preferences.dart';
import 'token_store.dart';

/// Simple session storage using shared_preferences.
///
/// Use this for non-sensitive session data like last login time,
/// user preferences, etc. DO NOT use for tokens or credentials.
///
/// This is simpler and faster than secure storage but data is
/// stored unencrypted.
class SharedPrefsSessionStore implements ITokenStore {
  final SharedPreferences _prefs;

  SharedPrefsSessionStore(this._prefs);

  static const String _tokenPrefix = 'token_';
  static const String _sessionPrefix = 'session_';

  @override
  Future<void> writeToken(String key, String value) async {
    await _prefs.setString('$_tokenPrefix$key', value);
  }

  @override
  Future<String?> readToken(String key) async {
    return _prefs.getString('$_tokenPrefix$key');
  }

  @override
  Future<void> deleteToken(String key) async {
    await _prefs.remove('$_tokenPrefix$key');
  }

  @override
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_tokenPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  @override
  Future<bool> hasToken(String key) async {
    return _prefs.containsKey('$_tokenPrefix$key');
  }

  @override
  Future<void> writeSessionData(String key, String value) async {
    await _prefs.setString('$_sessionPrefix$key', value);
  }

  @override
  Future<String?> readSessionData(String key) async {
    return _prefs.getString('$_sessionPrefix$key');
  }

  @override
  Future<void> deleteSessionData(String key) async {
    await _prefs.remove('$_sessionPrefix$key');
  }

  @override
  Future<void> clearSessionData() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_sessionPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await clearAll();
    await clearSessionData();
  }

  /// Factory method to create instance
  static Future<SharedPrefsSessionStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsSessionStore(prefs);
  }
}
