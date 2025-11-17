import 'social_provider.dart';

/// Error codes for authentication failures
enum AuthErrorCode {
  /// User cancelled the authentication flow
  userCancelled,

  /// Network connection error
  networkError,

  /// Invalid email or password
  invalidCredentials,

  /// Email not confirmed
  emailNotConfirmed,

  /// User not found
  userNotFound,

  /// Email already in use
  emailAlreadyInUse,

  /// Weak password
  weakPassword,

  /// Missing required permissions
  missingPermissions,

  /// Platform not supported
  platformNotSupported,

  /// Provider-specific error
  providerError,

  /// Configuration error
  configurationError,

  /// Rate limit exceeded
  rateLimitExceeded,

  /// Invalid magic link
  invalidMagicLink,

  /// Session expired
  sessionExpired,

  /// Unknown error
  unknownError,
}

/// Represents an authentication error
class AuthError implements Exception {
  /// Error code
  final AuthErrorCode code;

  /// Human-readable error message
  final String message;

  /// Optional provider that caused the error
  final SocialProvider? provider;

  /// Optional stack trace
  final StackTrace? stackTrace;

  /// Original error object
  final Object? originalError;

  const AuthError({
    required this.code,
    required this.message,
    this.provider,
    this.stackTrace,
    this.originalError,
  });

  /// Create error for user cancellation
  factory AuthError.userCancelled([SocialProvider? provider]) {
    return AuthError(
      code: AuthErrorCode.userCancelled,
      message: 'Authentication was cancelled by the user',
      provider: provider,
    );
  }

  /// Create error for network issues
  factory AuthError.networkError([String? details]) {
    return AuthError(
      code: AuthErrorCode.networkError,
      message: details ?? 'Network connection error. Please check your internet connection.',
    );
  }

  /// Create error for invalid credentials
  factory AuthError.invalidCredentials() {
    return const AuthError(
      code: AuthErrorCode.invalidCredentials,
      message: 'Invalid email or password',
    );
  }

  /// Create error for unconfirmed email
  factory AuthError.emailNotConfirmed() {
    return const AuthError(
      code: AuthErrorCode.emailNotConfirmed,
      message: 'Please verify your email address before signing in',
    );
  }

  /// Create error for user not found
  factory AuthError.userNotFound() {
    return const AuthError(
      code: AuthErrorCode.userNotFound,
      message: 'No account found with this email address',
    );
  }

  /// Create error for email already in use
  factory AuthError.emailAlreadyInUse() {
    return const AuthError(
      code: AuthErrorCode.emailAlreadyInUse,
      message: 'An account with this email already exists',
    );
  }

  /// Create error for weak password
  factory AuthError.weakPassword([String? requirements]) {
    return AuthError(
      code: AuthErrorCode.weakPassword,
      message: requirements ?? 'Password does not meet security requirements',
    );
  }

  /// Create error for configuration issues
  factory AuthError.configurationError(String details) {
    return AuthError(
      code: AuthErrorCode.configurationError,
      message: 'Configuration error: $details',
    );
  }

  /// Create error for platform not supported
  factory AuthError.platformNotSupported(SocialProvider provider) {
    return AuthError(
      code: AuthErrorCode.platformNotSupported,
      message: '${provider.name} is not supported on this platform',
      provider: provider,
    );
  }

  /// Create error for rate limiting
  factory AuthError.rateLimitExceeded() {
    return const AuthError(
      code: AuthErrorCode.rateLimitExceeded,
      message: 'Too many attempts. Please try again later.',
    );
  }

  /// Create error for invalid magic link
  factory AuthError.invalidMagicLink() {
    return const AuthError(
      code: AuthErrorCode.invalidMagicLink,
      message: 'Invalid or expired magic link',
    );
  }

  /// Create error for expired session
  factory AuthError.sessionExpired() {
    return const AuthError(
      code: AuthErrorCode.sessionExpired,
      message: 'Your session has expired. Please sign in again.',
    );
  }

  /// Create error for provider-specific errors
  factory AuthError.providerError([String? details, SocialProvider? provider]) {
    return AuthError(
      code: AuthErrorCode.providerError,
      message: details ?? 'Provider authentication error',
      provider: provider,
    );
  }

  /// Create unknown error
  factory AuthError.unknownError([String? details]) {
    return AuthError(
      code: AuthErrorCode.unknownError,
      message: details ?? 'An unknown error occurred',
    );
  }

  /// Create error from exception
  factory AuthError.fromException(
    Object error, [
    StackTrace? stackTrace,
    SocialProvider? provider,
  ]) {
    return AuthError(
      code: AuthErrorCode.unknownError,
      message: error.toString(),
      provider: provider,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  @override
  String toString() {
    return 'AuthError(code: $code, message: $message, provider: ${provider?.name})';
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code.name,
      'message': message,
      'provider': provider?.id,
    };
  }
}
