import 'package:local_auth/local_auth.dart';

/// Wrapper around local_auth for biometric authentication
///
/// Provides a clean interface for checking biometric availability
/// and performing biometric authentication.
abstract class LocalAuthService {
  /// Checks if the device supports biometric authentication
  Future<bool> canCheckBiometrics();

  /// Performs biometric authentication
  ///
  /// [reason] - Localized string shown to user explaining why auth is needed
  ///
  /// Returns true if authentication succeeds, false otherwise
  Future<bool> authenticate({required String reason});

  /// Gets list of available biometric types on device
  ///
  /// Returns list of BiometricType (fingerprint, face, iris)
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Checks if device has biometrics enrolled
  Future<bool> isDeviceSupported();
}

/// Implementation using local_auth package
class FlutterLocalAuthService implements LocalAuthService {
  final LocalAuthentication _localAuth;

  FlutterLocalAuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      throw LocalAuthException('Failed to check biometrics availability: $e');
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      // Check if device supports biometrics
      final canAuthenticate = await canCheckBiometrics();
      if (!canAuthenticate) {
        return false;
      }

      // Perform authentication
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true, // Don't cancel on app background
          biometricOnly: true, // Only use biometrics, not device PIN
          sensitiveTransaction: true, // Require auth for each transaction
          useErrorDialogs: true, // Show error dialogs to user
        ),
      );
    } on LocalAuthException {
      rethrow;
    } catch (e) {
      throw LocalAuthException('Authentication failed: $e');
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      throw LocalAuthException('Failed to get available biometrics: $e');
    }
  }

  @override
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      throw LocalAuthException('Failed to check device support: $e');
    }
  }
}

/// Exception thrown when biometric operations fail
class LocalAuthException implements Exception {
  final String message;

  LocalAuthException(this.message);

  @override
  String toString() => 'LocalAuthException: $message';
}
