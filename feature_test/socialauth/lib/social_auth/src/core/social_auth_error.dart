import 'social_provider.dart';

/// Error codes for social authentication
enum SocialAuthErrorCode {
  userCancelled,
  networkError,
  invalidCredentials,
  missingPermissions,
  platformNotSupported,
  providerError,
  configurationError,
  unknownError,
}

/// Social authentication error
class SocialAuthError implements Exception {
  final SocialAuthErrorCode code;
  final String message;
  final SocialProvider? provider;
  final dynamic originalError;
  final StackTrace? stackTrace;

  SocialAuthError({
    required this.code,
    required this.message,
    this.provider,
    this.originalError,
    this.stackTrace,
  });

  factory SocialAuthError.userCancelled(SocialProvider provider) {
    return SocialAuthError(
      code: SocialAuthErrorCode.userCancelled,
      message: 'User cancelled the sign-in process',
      provider: provider,
    );
  }

  factory SocialAuthError.networkError(SocialProvider provider, [dynamic error]) {
    return SocialAuthError(
      code: SocialAuthErrorCode.networkError,
      message: 'Network error occurred during sign-in',
      provider: provider,
      originalError: error,
    );
  }

  factory SocialAuthError.platformNotSupported(SocialProvider provider) {
    return SocialAuthError(
      code: SocialAuthErrorCode.platformNotSupported,
      message: '${provider.name} sign-in is not supported on this platform',
      provider: provider,
    );
  }

  factory SocialAuthError.configurationError(
    SocialProvider provider,
    String details,
  ) {
    return SocialAuthError(
      code: SocialAuthErrorCode.configurationError,
      message: 'Configuration error: $details',
      provider: provider,
    );
  }

  factory SocialAuthError.providerError(
    SocialProvider provider,
    String details, [
    dynamic error,
  ]) {
    return SocialAuthError(
      code: SocialAuthErrorCode.providerError,
      message: 'Provider error: $details',
      provider: provider,
      originalError: error,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('SocialAuthError(');
    buffer.write('code: $code, ');
    buffer.write('message: $message');
    if (provider != null) {
      buffer.write(', provider: ${provider!.name}');
    }
    if (originalError != null) {
      buffer.write(', original: $originalError');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
