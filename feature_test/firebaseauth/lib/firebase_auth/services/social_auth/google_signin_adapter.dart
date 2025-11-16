import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../errors/auth_error.dart';

/// Adapter for Google Sign-In
///
/// Handles Google OAuth flow and returns Firebase credentials.
class GoogleSignInAdapter {
  final GoogleSignIn _googleSignIn;

  GoogleSignInAdapter({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  /// Sign in with Google
  ///
  /// Returns a Firebase AuthCredential that can be used to sign in to Firebase.
  /// Throws [AuthError] if sign-in fails.
  Future<fb.AuthCredential> signIn() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw AuthError.custom(
          code: AuthErrorCode.unknown,
          message: 'Google sign-in was canceled',
          recoverySuggestion: 'Please try again',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return credential;
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError.fromException(e);
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Disconnect Google account
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Check if user is currently signed in to Google
  Future<bool> isSignedIn() async {
    return _googleSignIn.currentUser != null;
  }

  /// Get current Google user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
