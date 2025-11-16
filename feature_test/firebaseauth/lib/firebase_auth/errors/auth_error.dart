import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Normalized authentication error codes
enum AuthErrorCode {
  /// Email already in use
  emailAlreadyInUse,

  /// Invalid email format
  invalidEmail,

  /// Wrong password
  wrongPassword,

  /// User not found
  userNotFound,

  /// User disabled
  userDisabled,

  /// Too many requests
  tooManyRequests,

  /// Operation not allowed
  operationNotAllowed,

  /// Weak password
  weakPassword,

  /// Requires recent login
  requiresRecentLogin,

  /// Provider already linked
  providerAlreadyLinked,

  /// Credential already in use
  credentialAlreadyInUse,

  /// Invalid credential
  invalidCredential,

  /// Invalid verification code
  invalidVerificationCode,

  /// Invalid verification ID
  invalidVerificationId,

  /// Account exists with different credential
  accountExistsWithDifferentCredential,

  /// Network request failed
  networkRequestFailed,

  /// Phone number already exists
  phoneNumberAlreadyExists,

  /// Invalid phone number
  invalidPhoneNumber,

  /// Missing phone number
  missingPhoneNumber,

  /// Session expired
  sessionExpired,

  /// Quota exceeded
  quotaExceeded,

  /// Missing client identifier
  missingClientIdentifier,

  /// Captcha check failed
  captchaCheckFailed,

  /// App not authorized
  appNotAuthorized,

  /// Invalid API key
  invalidApiKey,

  /// User token expired
  userTokenExpired,

  /// Invalid user token
  invalidUserToken,

  /// Network error
  networkError,

  /// Web storage unsupported
  webStorageUnsupported,

  /// Unknown error
  unknown,
}

/// Authentication error with friendly message and recovery suggestions
class AuthError implements Exception {
  /// Error code
  final AuthErrorCode code;

  /// Technical error message
  final String message;

  /// User-friendly error message
  final String friendlyMessage;

  /// Suggested recovery action
  final String? recoverySuggestion;

  /// Whether the error is recoverable by user action
  final bool isRecoverable;

  /// Original exception (if any)
  final Object? originalException;

  const AuthError({
    required this.code,
    required this.message,
    required this.friendlyMessage,
    this.recoverySuggestion,
    this.isRecoverable = true,
    this.originalException,
  });

  /// Create AuthError from Firebase exception
  factory AuthError.fromFirebaseException(fb.FirebaseAuthException exception) {
    final code = _mapFirebaseErrorCode(exception.code);
    final mapping = _errorMappings[code] ?? _errorMappings[AuthErrorCode.unknown]!;

    return AuthError(
      code: code,
      message: exception.message ?? 'Unknown error',
      friendlyMessage: mapping['message'] as String,
      recoverySuggestion: mapping['recovery'] as String?,
      isRecoverable: mapping['recoverable'] as bool? ?? true,
      originalException: exception,
    );
  }

  /// Create AuthError from generic exception
  factory AuthError.fromException(Object exception) {
    if (exception is fb.FirebaseAuthException) {
      return AuthError.fromFirebaseException(exception);
    }

    return AuthError(
      code: AuthErrorCode.unknown,
      message: exception.toString(),
      friendlyMessage: 'An unexpected error occurred. Please try again.',
      recoverySuggestion: 'If the problem persists, please contact support.',
      isRecoverable: true,
      originalException: exception,
    );
  }

  /// Create a custom error
  factory AuthError.custom({
    required AuthErrorCode code,
    required String message,
    String? recoverySuggestion,
    bool isRecoverable = true,
  }) {
    final mapping = _errorMappings[code] ?? _errorMappings[AuthErrorCode.unknown]!;

    return AuthError(
      code: code,
      message: message,
      friendlyMessage: mapping['message'] as String,
      recoverySuggestion: recoverySuggestion ?? (mapping['recovery'] as String?),
      isRecoverable: isRecoverable,
    );
  }

  /// Map Firebase error code string to AuthErrorCode
  static AuthErrorCode _mapFirebaseErrorCode(String firebaseCode) {
    switch (firebaseCode) {
      case 'email-already-in-use':
        return AuthErrorCode.emailAlreadyInUse;
      case 'invalid-email':
        return AuthErrorCode.invalidEmail;
      case 'wrong-password':
        return AuthErrorCode.wrongPassword;
      case 'user-not-found':
        return AuthErrorCode.userNotFound;
      case 'user-disabled':
        return AuthErrorCode.userDisabled;
      case 'too-many-requests':
        return AuthErrorCode.tooManyRequests;
      case 'operation-not-allowed':
        return AuthErrorCode.operationNotAllowed;
      case 'weak-password':
        return AuthErrorCode.weakPassword;
      case 'requires-recent-login':
        return AuthErrorCode.requiresRecentLogin;
      case 'provider-already-linked':
        return AuthErrorCode.providerAlreadyLinked;
      case 'credential-already-in-use':
        return AuthErrorCode.credentialAlreadyInUse;
      case 'invalid-credential':
        return AuthErrorCode.invalidCredential;
      case 'invalid-verification-code':
        return AuthErrorCode.invalidVerificationCode;
      case 'invalid-verification-id':
        return AuthErrorCode.invalidVerificationId;
      case 'account-exists-with-different-credential':
        return AuthErrorCode.accountExistsWithDifferentCredential;
      case 'network-request-failed':
        return AuthErrorCode.networkRequestFailed;
      case 'phone-number-already-exists':
        return AuthErrorCode.phoneNumberAlreadyExists;
      case 'invalid-phone-number':
        return AuthErrorCode.invalidPhoneNumber;
      case 'missing-phone-number':
        return AuthErrorCode.missingPhoneNumber;
      case 'session-expired':
        return AuthErrorCode.sessionExpired;
      case 'quota-exceeded':
        return AuthErrorCode.quotaExceeded;
      case 'missing-client-identifier':
        return AuthErrorCode.missingClientIdentifier;
      case 'captcha-check-failed':
        return AuthErrorCode.captchaCheckFailed;
      case 'app-not-authorized':
        return AuthErrorCode.appNotAuthorized;
      case 'invalid-api-key':
        return AuthErrorCode.invalidApiKey;
      case 'user-token-expired':
        return AuthErrorCode.userTokenExpired;
      case 'invalid-user-token':
        return AuthErrorCode.invalidUserToken;
      case 'network-error':
        return AuthErrorCode.networkError;
      case 'web-storage-unsupported':
        return AuthErrorCode.webStorageUnsupported;
      default:
        return AuthErrorCode.unknown;
    }
  }

  /// Error mappings with friendly messages and recovery suggestions
  static const Map<AuthErrorCode, Map<String, dynamic>> _errorMappings = {
    AuthErrorCode.emailAlreadyInUse: {
      'message': 'This email is already registered.',
      'recovery': 'Try signing in or use a different email address.',
      'recoverable': true,
    },
    AuthErrorCode.invalidEmail: {
      'message': 'Invalid email address.',
      'recovery': 'Please enter a valid email address.',
      'recoverable': true,
    },
    AuthErrorCode.wrongPassword: {
      'message': 'Incorrect password.',
      'recovery': 'Check your password or use "Forgot Password" to reset it.',
      'recoverable': true,
    },
    AuthErrorCode.userNotFound: {
      'message': 'No account found with this email.',
      'recovery': 'Please sign up or check your email address.',
      'recoverable': true,
    },
    AuthErrorCode.userDisabled: {
      'message': 'This account has been disabled.',
      'recovery': 'Please contact support for assistance.',
      'recoverable': false,
    },
    AuthErrorCode.tooManyRequests: {
      'message': 'Too many attempts. Please try again later.',
      'recovery': 'Wait a few minutes before trying again.',
      'recoverable': true,
    },
    AuthErrorCode.operationNotAllowed: {
      'message': 'This sign-in method is not enabled.',
      'recovery': 'Please contact support.',
      'recoverable': false,
    },
    AuthErrorCode.weakPassword: {
      'message': 'Password is too weak.',
      'recovery': 'Use at least 6 characters with letters and numbers.',
      'recoverable': true,
    },
    AuthErrorCode.requiresRecentLogin: {
      'message': 'This operation requires recent authentication.',
      'recovery': 'Please sign out and sign in again.',
      'recoverable': true,
    },
    AuthErrorCode.providerAlreadyLinked: {
      'message': 'This account is already linked to this provider.',
      'recovery': null,
      'recoverable': true,
    },
    AuthErrorCode.credentialAlreadyInUse: {
      'message': 'This credential is already associated with another account.',
      'recovery': 'Sign in with the other account or unlink the credential.',
      'recoverable': true,
    },
    AuthErrorCode.invalidCredential: {
      'message': 'Invalid credentials.',
      'recovery': 'Please try signing in again.',
      'recoverable': true,
    },
    AuthErrorCode.invalidVerificationCode: {
      'message': 'Invalid verification code.',
      'recovery': 'Please check the code and try again.',
      'recoverable': true,
    },
    AuthErrorCode.invalidVerificationId: {
      'message': 'Verification session expired.',
      'recovery': 'Please request a new verification code.',
      'recoverable': true,
    },
    AuthErrorCode.accountExistsWithDifferentCredential: {
      'message': 'An account already exists with this email but different sign-in method.',
      'recovery': 'Sign in with your original method and link accounts in settings.',
      'recoverable': true,
    },
    AuthErrorCode.networkRequestFailed: {
      'message': 'Network connection failed.',
      'recovery': 'Check your internet connection and try again.',
      'recoverable': true,
    },
    AuthErrorCode.phoneNumberAlreadyExists: {
      'message': 'This phone number is already registered.',
      'recovery': 'Try signing in or use a different phone number.',
      'recoverable': true,
    },
    AuthErrorCode.invalidPhoneNumber: {
      'message': 'Invalid phone number.',
      'recovery': 'Please enter a valid phone number with country code.',
      'recoverable': true,
    },
    AuthErrorCode.missingPhoneNumber: {
      'message': 'Phone number is required.',
      'recovery': 'Please enter your phone number.',
      'recoverable': true,
    },
    AuthErrorCode.sessionExpired: {
      'message': 'Your session has expired.',
      'recovery': 'Please sign in again.',
      'recoverable': true,
    },
    AuthErrorCode.quotaExceeded: {
      'message': 'SMS quota exceeded.',
      'recovery': 'Please try again later.',
      'recoverable': true,
    },
    AuthErrorCode.captchaCheckFailed: {
      'message': 'reCAPTCHA verification failed.',
      'recovery': 'Please try again.',
      'recoverable': true,
    },
    AuthErrorCode.networkError: {
      'message': 'Network error occurred.',
      'recovery': 'Check your connection and try again.',
      'recoverable': true,
    },
    AuthErrorCode.unknown: {
      'message': 'An unexpected error occurred.',
      'recovery': 'Please try again. If the problem persists, contact support.',
      'recoverable': true,
    },
  };

  @override
  String toString() {
    return 'AuthError(code: $code, message: $friendlyMessage)';
  }
}
