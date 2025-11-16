import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/app_lock_config.dart';
import 'models/lock_state.dart';
import 'models/pin_verify_result.dart';
import 'models/lock_events.dart';
import 'services/secure_storage_adapter.dart';
import 'services/settings_storage.dart';
import 'services/local_auth_service.dart';
import 'utils/crypto_utils.dart';
import 'utils/time_utils.dart';

/// High-level facade for app lock functionality
///
/// Provides a simple API for:
/// - Setting and verifying PINs
/// - Enabling/disabling biometric authentication
/// - Locking and unlocking the app
/// - Managing lock state and auto-lock behavior
/// - Handling failed attempts and lockouts
///
/// Example usage:
/// ```dart
/// final manager = AppLockManager(config: AppLockConfig());
/// await manager.initialize();
///
/// // Set PIN
/// await manager.setPin('1234');
///
/// // Verify PIN
/// final result = await manager.verifyPin('1234');
/// if (result.success) {
///   await manager.unlock();
/// }
/// ```
class AppLockManager {
  final AppLockConfig config;
  final SecureStorageAdapter _secureStorage;
  final SettingsStorage _settingsStorage;
  final LocalAuthService _localAuth;

  final _lockStateController = StreamController<LockState>.broadcast();
  final _lockEventsController = StreamController<LockEvent>.broadcast();

  LockState _currentState = LockState.unlocked();
  Timer? _autoLockTimer;
  bool _initialized = false;

  // Storage keys
  late final String _pinHashKey;
  late final String _pinSaltKey;
  late final String _biometricEnabledKey;
  late final String _failedAttemptsKey;
  late final String _lockoutExpiresKey;
  late final String _lastActivityKey;

  AppLockManager({
    required this.config,
    SecureStorageAdapter? secureAdapter,
    SettingsStorage? settingsStorage,
    LocalAuthService? localAuth,
  })  : _secureStorage = secureAdapter ?? FlutterSecureStorageAdapter(),
        _settingsStorage =
            settingsStorage ?? SharedPreferencesSettingsStorage(),
        _localAuth = localAuth ?? FlutterLocalAuthService() {
    _initializeKeys();
  }

  void _initializeKeys() {
    final prefix = config.secureStorageKeyPrefix;
    _pinHashKey = '${prefix}pin_hash';
    _pinSaltKey = '${prefix}pin_salt';
    _biometricEnabledKey = '${prefix}biometric_enabled';
    _failedAttemptsKey = '${prefix}failed_attempts';
    _lockoutExpiresKey = '${prefix}lockout_expires';
    _lastActivityKey = '${prefix}last_activity';
  }

  /// Initialize storage and services
  ///
  /// Must be called before using any other methods.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize settings storage if needed
    if (_settingsStorage is SharedPreferencesSettingsStorage) {
      await (_settingsStorage as SharedPreferencesSettingsStorage)
          .initialize();
    }

    // Load current lock state
    await _loadLockState();

    _initialized = true;

    // Start auto-lock timer if app was locked
    if (_currentState.locked) {
      _startAutoLockTimer();
    }
  }

  /// Loads lock state from storage
  Future<void> _loadLockState() async {
    try {
      // Check if locked out
      final lockoutExpiresStr = await _settingsStorage.read(_lockoutExpiresKey);
      final isLockedOut = lockoutExpiresStr != null &&
          DateTime.now()
              .isBefore(DateTime.parse(lockoutExpiresStr));

      // Get failed attempts
      final failedAttempts =
          await _settingsStorage.readInt(_failedAttemptsKey) ?? 0;

      // Determine if app should be locked
      final isEnabled = await isEnabled();
      final lastActivityStr = await _settingsStorage.read(_lastActivityKey);

      bool shouldBeLocked = isEnabled;
      if (lastActivityStr != null && isEnabled) {
        final lastActivity = DateTime.parse(lastActivityStr);
        final elapsed = DateTime.now().difference(lastActivity);
        shouldBeLocked = elapsed > config.autoLockTimeout;
      }

      _currentState = LockState(
        locked: shouldBeLocked,
        lockedAt: shouldBeLocked ? DateTime.now() : null,
        failedAttempts: failedAttempts,
        isLockedOut: isLockedOut,
        lockoutExpiresAt: lockoutExpiresStr != null
            ? DateTime.tryParse(lockoutExpiresStr)
            : null,
      );
    } catch (e) {
      debugPrint('Error loading lock state: $e');
      _currentState = LockState.unlocked();
    }
  }

  /// Returns true if app lock is enabled (PIN or biometric set)
  Future<bool> isEnabled() async {
    _ensureInitialized();

    try {
      final pinHash = await _secureStorage.readSecure(_pinHashKey);
      return pinHash != null && pinHash.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if enabled: $e');
      return false;
    }
  }

  /// Configure and set a new PIN
  ///
  /// [pin] - Plain-text PIN entered by user
  ///
  /// Returns true if PIN was set successfully
  Future<bool> setPin(String pin) async {
    _ensureInitialized();

    if (pin.length < config.pinMinLength) {
      debugPrint('PIN too short. Minimum length: ${config.pinMinLength}');
      return false;
    }

    try {
      // Generate salt and hash PIN
      final salt = CryptoUtils.generateSalt();
      final hash = CryptoUtils.deriveKeyFromPin(
        pin,
        salt,
        config.pbkdf2Iterations,
      );

      // Store securely
      await _secureStorage.writeSecure(_pinSaltKey, salt);
      await _secureStorage.writeSecure(_pinHashKey, hash);

      // Reset failed attempts
      await _settingsStorage.writeInt(_failedAttemptsKey, 0);

      // Unlock after setting PIN
      await unlock();

      // Emit event
      _lockEventsController.add(PinChangedEvent(isInitialSetup: true));

      return true;
    } catch (e) {
      debugPrint('Error setting PIN: $e');
      return false;
    }
  }

  /// Change PIN: verify oldPin then set newPin
  ///
  /// Returns true if PIN was changed successfully
  Future<bool> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    _ensureInitialized();

    // Verify old PIN first
    final verifyResult = await verifyPin(oldPin);
    if (!verifyResult.success) {
      return false;
    }

    // Set new PIN
    final success = await setPin(newPin);

    if (success) {
      _lockEventsController.add(PinChangedEvent(isInitialSetup: false));
    }

    return success;
  }

  /// Verify a PIN
  ///
  /// Returns PinVerifyResult with status and remaining attempts
  Future<PinVerifyResult> verifyPin(String pin) async {
    _ensureInitialized();

    // Check if locked out
    if (_currentState.isLockedOut && !_currentState.isLockoutExpired) {
      final remaining = _currentState.remainingLockoutDuration!;
      return PinVerifyResult.lockout(
        lockoutDuration: remaining,
        message:
            'Too many failed attempts. Try again in ${TimeUtils.formatRemainingTime(remaining)}.',
      );
    }

    // Clear lockout if expired
    if (_currentState.isLockedOut && _currentState.isLockoutExpired) {
      await _clearLockout();
    }

    try {
      // Get stored hash and salt
      final storedHash = await _secureStorage.readSecure(_pinHashKey);
      final salt = await _secureStorage.readSecure(_pinSaltKey);

      if (storedHash == null || salt == null) {
        return PinVerifyResult.failure(
          attemptsRemaining: config.maxAttempts,
          message: 'PIN not set',
        );
      }

      // Verify PIN
      final isValid = CryptoUtils.verifyPin(
        pin,
        salt,
        storedHash,
        config.pbkdf2Iterations,
      );

      if (isValid) {
        // Reset failed attempts on success
        await _settingsStorage.writeInt(_failedAttemptsKey, 0);
        _currentState = _currentState.copyWith(failedAttempts: 0);

        return PinVerifyResult.success();
      } else {
        // Increment failed attempts
        final newFailedAttempts = _currentState.failedAttempts + 1;
        await _settingsStorage.writeInt(_failedAttemptsKey, newFailedAttempts);

        _currentState = _currentState.copyWith(
          failedAttempts: newFailedAttempts,
        );

        // Check if should lock out
        if (newFailedAttempts >= config.maxAttempts) {
          await _lockout();

          _lockEventsController.add(
            LockoutEvent(duration: config.lockoutDuration),
          );

          return PinVerifyResult.lockout(
            lockoutDuration: config.lockoutDuration,
            message:
                'Too many failed attempts. Locked out for ${TimeUtils.formatRemainingTime(config.lockoutDuration)}.',
          );
        }

        final attemptsRemaining = config.maxAttempts - newFailedAttempts;

        _lockEventsController.add(
          UnlockFailedEvent(attemptsRemaining: attemptsRemaining),
        );

        return PinVerifyResult.failure(
          attemptsRemaining: attemptsRemaining,
          message:
              'Incorrect PIN. $attemptsRemaining ${attemptsRemaining == 1 ? 'attempt' : 'attempts'} remaining.',
        );
      }
    } catch (e) {
      debugPrint('Error verifying PIN: $e');
      return PinVerifyResult.failure(
        attemptsRemaining: 0,
        message: 'Verification error',
      );
    }
  }

  /// Enable biometric authentication
  ///
  /// Returns true if biometric was enabled successfully
  Future<bool> enableBiometric() async {
    _ensureInitialized();

    if (!config.allowBiometrics) {
      debugPrint('Biometrics not allowed by config');
      return false;
    }

    try {
      // Check if device supports biometrics
      final canCheck = await _localAuth.canCheckBiometrics();
      if (!canCheck) {
        debugPrint('Device does not support biometrics');
        return false;
      }

      // Test biometric authentication
      final authenticated = await _localAuth.authenticate(
        reason: 'Enable biometric authentication',
      );

      if (!authenticated) {
        debugPrint('Biometric authentication failed');
        return false;
      }

      // Store biometric enabled flag
      await _secureStorage.writeSecure(_biometricEnabledKey, 'true');

      _lockEventsController.add(BiometricSettingChangedEvent(enabled: true));

      return true;
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
      return false;
    }
  }

  /// Disable biometric authentication
  ///
  /// Returns true if biometric was disabled successfully
  Future<bool> disableBiometric() async {
    _ensureInitialized();

    try {
      await _secureStorage.deleteSecure(_biometricEnabledKey);

      _lockEventsController.add(BiometricSettingChangedEvent(enabled: false));

      return true;
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
      return false;
    }
  }

  /// Try biometric unlock
  ///
  /// Returns true if authentication succeeds, false otherwise
  Future<bool> authenticateBiometric() async {
    _ensureInitialized();

    // Check if biometric is enabled
    final biometricEnabled =
        await _secureStorage.readSecure(_biometricEnabledKey);
    if (biometricEnabled != 'true') {
      debugPrint('Biometric not enabled');
      return false;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        reason: 'Unlock app',
      );

      return authenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Lock the app immediately
  Future<void> lockNow() async {
    _ensureInitialized();

    if (_currentState.locked) return;

    _currentState = LockState.locked();
    _lockStateController.add(_currentState);
    _lockEventsController.add(AppLockedEvent(reason: 'manual'));

    _startAutoLockTimer();
  }

  /// Unlock the app programmatically
  ///
  /// Call this after successful PIN or biometric verification
  Future<void> unlock() async {
    _ensureInitialized();

    if (!_currentState.locked) return;

    _currentState = _currentState.copyWith(
      locked: false,
      lastUnlockedAt: DateTime.now(),
      failedAttempts: 0,
    );

    // Update last activity
    await _settingsStorage.write(
      _lastActivityKey,
      DateTime.now().toIso8601String(),
    );

    _lockStateController.add(_currentState);
    _lockEventsController.add(AppUnlockedEvent(method: 'pin'));

    _cancelAutoLockTimer();
    _startAutoLockTimer();
  }

  /// Check whether the app is currently locked
  Future<bool> isLocked() async {
    _ensureInitialized();
    return _currentState.locked;
  }

  /// Configure auto-lock timeout
  Future<void> setAutoLockTimeout(Duration timeout) async {
    _ensureInitialized();
    // Store in settings if needed for persistence
    _cancelAutoLockTimer();
    _startAutoLockTimer();
  }

  /// Reset lock state and remove secrets
  ///
  /// [keepConfig] - If true, keeps non-sensitive settings
  Future<void> reset({bool keepConfig = false}) async {
    _ensureInitialized();

    try {
      // Delete secure data
      await _secureStorage.deleteSecure(_pinHashKey);
      await _secureStorage.deleteSecure(_pinSaltKey);
      await _secureStorage.deleteSecure(_biometricEnabledKey);

      if (!keepConfig) {
        // Clear settings
        await _settingsStorage.delete(_failedAttemptsKey);
        await _settingsStorage.delete(_lockoutExpiresKey);
        await _settingsStorage.delete(_lastActivityKey);
      }

      _currentState = LockState.unlocked();
      _lockStateController.add(_currentState);

      _cancelAutoLockTimer();
    } catch (e) {
      debugPrint('Error resetting app lock: $e');
    }
  }

  /// Stream of lock state changes
  Stream<LockState> get onLockStateChanged => _lockStateController.stream;

  /// Stream of lock events (for analytics, logging, etc.)
  Stream<LockEvent> get onLockEvents => _lockEventsController.stream;

  /// Starts auto-lock timer
  void _startAutoLockTimer() {
    _cancelAutoLockTimer();

    _autoLockTimer = Timer(config.autoLockTimeout, () async {
      if (!_currentState.locked) {
        await lockNow();
        _lockEventsController.add(AppLockedEvent(reason: 'timeout'));
      }
    });
  }

  /// Cancels auto-lock timer
  void _cancelAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;
  }

  /// Locks out the user
  Future<void> _lockout() async {
    final lockoutExpires = DateTime.now().add(config.lockoutDuration);

    await _settingsStorage.write(
      _lockoutExpiresKey,
      lockoutExpires.toIso8601String(),
    );

    _currentState = _currentState.copyWith(
      isLockedOut: true,
      lockoutExpiresAt: lockoutExpires,
    );

    _lockStateController.add(_currentState);
  }

  /// Clears lockout state
  Future<void> _clearLockout() async {
    await _settingsStorage.delete(_lockoutExpiresKey);
    await _settingsStorage.writeInt(_failedAttemptsKey, 0);

    _currentState = _currentState.copyWith(
      isLockedOut: false,
      lockoutExpiresAt: null,
      failedAttempts: 0,
    );

    _lockStateController.add(_currentState);
  }

  /// Ensures manager is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AppLockManager not initialized. Call initialize() first.');
    }
  }

  /// Updates last activity timestamp (call on user interaction)
  Future<void> updateLastActivity() async {
    _ensureInitialized();

    await _settingsStorage.write(
      _lastActivityKey,
      DateTime.now().toIso8601String(),
    );

    // Restart auto-lock timer
    _startAutoLockTimer();
  }

  /// Disposes resources
  void dispose() {
    _cancelAutoLockTimer();
    _lockStateController.close();
    _lockEventsController.close();
  }
}
