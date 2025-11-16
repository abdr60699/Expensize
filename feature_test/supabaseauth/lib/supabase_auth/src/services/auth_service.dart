import '../models/auth_result.dart';
import '../models/auth_error.dart';
import '../models/social_provider.dart';

/// Abstract interface for authentication services
abstract class AuthService {
  /// Sign up with email and password
  ///
  /// [email] - User's email address
  /// [password] - User's password
  /// [metadata] - Optional additional user data
  ///
  /// Returns [AuthResult] on success
  /// Throws [AuthError] on failure
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  });

  /// Sign in with email and password
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns [AuthResult] on success
  /// Throws [AuthError] on failure
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with magic link (passwordless)
  ///
  /// [email] - User's email address to send magic link
  ///
  /// Returns [AuthResult] on success
  /// Throws [AuthError] on failure
  Future<AuthResult> signInWithMagicLink({
    required String email,
  });

  /// Sign in with OAuth provider (Google, Apple, Facebook, etc.)
  ///
  /// [provider] - The social provider to use
  /// [scopes] - Optional OAuth scopes
  ///
  /// Returns [AuthResult] on success
  /// Throws [AuthError] on failure
  Future<AuthResult> signInWithOAuth(
    SocialProvider provider, {
    List<String>? scopes,
  });

  /// Sign out the current user
  ///
  /// Throws [AuthError] on failure
  Future<void> signOut();

  /// Send password reset email
  ///
  /// [email] - Email address to send reset link
  ///
  /// Throws [AuthError] on failure
  Future<void> sendPasswordResetEmail(String email);

  /// Get the current user session
  ///
  /// Returns [AuthResult] if session exists, null otherwise
  /// Throws [AuthError] on failure
  Future<AuthResult?> getCurrentSession();

  /// Refresh the current session
  ///
  /// Returns new [AuthResult] with refreshed tokens
  /// Throws [AuthError] on failure
  Future<AuthResult> refreshSession();

  /// Check if user is currently signed in
  Future<bool> isSignedIn();

  /// Update user metadata
  ///
  /// [metadata] - User data to update
  ///
  /// Returns updated [AuthResult]
  /// Throws [AuthError] on failure
  Future<AuthResult> updateUserMetadata(Map<String, dynamic> metadata);

  /// Verify OTP (one-time password)
  ///
  /// [email] - User's email
  /// [token] - OTP token
  /// [type] - Type of OTP (magiclink, email, sms)
  ///
  /// Returns [AuthResult] on success
  /// Throws [AuthError] on failure
  Future<AuthResult> verifyOtp({
    required String email,
    required String token,
    required String type,
  });
}
