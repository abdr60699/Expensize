import 'user_model.dart';
import '../errors/auth_error.dart';

/// Result wrapper for authentication operations.
///
/// Provides a type-safe way to handle success/failure states
/// without throwing exceptions in the happy path.
class AuthResult {
  /// The user if operation succeeded
  final UserModel? user;

  /// Error if operation failed
  final AuthError? error;

  /// Whether the operation succeeded
  bool get isSuccess => error == null && user != null;

  /// Whether the operation failed
  bool get isFailure => error != null;

  /// Whether the operation requires additional action (e.g., email verification)
  final bool requiresVerification;

  /// Additional metadata about the operation
  final Map<String, dynamic>? metadata;

  const AuthResult._({
    this.user,
    this.error,
    this.requiresVerification = false,
    this.metadata,
  });

  /// Create a successful result
  factory AuthResult.success(
    UserModel user, {
    bool requiresVerification = false,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResult._(
      user: user,
      requiresVerification: requiresVerification,
      metadata: metadata,
    );
  }

  /// Create a failed result
  factory AuthResult.failure(
    AuthError error, {
    Map<String, dynamic>? metadata,
  }) {
    return AuthResult._(
      error: error,
      metadata: metadata,
    );
  }

  /// Execute callback if successful
  AuthResult onSuccess(void Function(UserModel user) callback) {
    if (isSuccess && user != null) {
      callback(user!);
    }
    return this;
  }

  /// Execute callback if failed
  AuthResult onFailure(void Function(AuthError error) callback) {
    if (isFailure && error != null) {
      callback(error!);
    }
    return this;
  }

  /// Transform user if successful
  AuthResult map(UserModel Function(UserModel user) transform) {
    if (isSuccess && user != null) {
      return AuthResult.success(
        transform(user!),
        requiresVerification: requiresVerification,
        metadata: metadata,
      );
    }
    return this;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'AuthResult.success(user: ${user?.uid})';
    }
    return 'AuthResult.failure(error: ${error?.code})';
  }
}
