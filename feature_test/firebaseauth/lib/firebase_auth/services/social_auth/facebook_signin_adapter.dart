import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../errors/auth_error.dart';

/// Adapter for Facebook Login
///
/// Handles Facebook OAuth flow and returns Firebase credentials.
class FacebookSignInAdapter {
  final FacebookAuth _facebookAuth;

  FacebookSignInAdapter({FacebookAuth? facebookAuth})
      : _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  /// Sign in with Facebook
  ///
  /// Returns a Firebase AuthCredential that can be used to sign in to Firebase.
  /// Throws [AuthError] if sign-in fails.
  Future<fb.AuthCredential> signIn() async {
    try {
      // Trigger the Facebook authentication flow
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = result.accessToken!;

        // Create a credential from the access token
        final credential =
            fb.FacebookAuthProvider.credential(accessToken.tokenString);

        return credential;
      } else if (result.status == LoginStatus.cancelled) {
        throw AuthError.custom(
          code: AuthErrorCode.unknown,
          message: 'Facebook sign-in was canceled',
          recoverySuggestion: 'Please try again',
        );
      } else {
        throw AuthError.custom(
          code: AuthErrorCode.unknown,
          message: result.message ?? 'Facebook sign-in failed',
          recoverySuggestion: 'Please try again or use a different method',
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError.fromException(e);
    }
  }

  /// Sign out from Facebook
  Future<void> signOut() async {
    try {
      await _facebookAuth.logOut();
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Get current access token
  Future<AccessToken?> get accessToken async {
    try {
      return await _facebookAuth.accessToken;
    } catch (e) {
      return null;
    }
  }

  /// Get user data from Facebook
  ///
  /// Returns user data including id, name, email, picture, etc.
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      return await _facebookAuth.getUserData(
        fields: 'id,name,email,picture.width(200)',
      );
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Check if user is logged in to Facebook
  Future<bool> get isLoggedIn async {
    final token = await accessToken;
    return token != null;
  }
}
