import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../errors/auth_error.dart';

/// Adapter for Sign in with Apple
///
/// Handles Apple OAuth flow and returns Firebase credentials.
/// Only available on iOS 13+, macOS 10.15+, and web.
class AppleSignInAdapter {
  /// Check if Sign in with Apple is available on this platform
  static bool get isAvailable {
    if (Platform.isIOS) {
      return true; // Available on iOS 13+
    } else if (Platform.isMacOS) {
      return true; // Available on macOS 10.15+
    }
    return false; // Web support requires additional setup
  }

  /// Sign in with Apple
  ///
  /// Returns a Firebase AuthCredential that can be used to sign in to Firebase.
  /// Throws [AuthError] if sign-in fails or is not available.
  Future<fb.AuthCredential> signIn() async {
    if (!isAvailable) {
      throw AuthError.custom(
        code: AuthErrorCode.operationNotAllowed,
        message: 'Sign in with Apple is not available on this platform',
        recoverySuggestion: 'Use a different sign-in method',
        isRecoverable: true,
      );
    }

    try {
      // Request credential from Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // Optional: provide web auth configuration for web support
        // webAuthenticationOptions: WebAuthenticationOptions(
        //   clientId: 'your.bundle.id',
        //   redirectUri: Uri.parse('https://your-domain.com/callbacks/apple'),
        // ),
      );

      // Create OAuth credential for Firebase
      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return oauthCredential;
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        if (e.code == AuthorizationErrorCode.canceled) {
          throw AuthError.custom(
            code: AuthErrorCode.unknown,
            message: 'Apple sign-in was canceled',
            recoverySuggestion: 'Please try again',
          );
        }
      }
      throw AuthError.fromException(e);
    }
  }

  /// Get OAuth provider for Apple
  ///
  /// Useful for linking/unlinking providers
  static fb.OAuthProvider getProvider() {
    return fb.OAuthProvider('apple.com');
  }

  /// Create Apple credential from token
  static fb.AuthCredential createCredential({
    required String idToken,
    String? accessToken,
  }) {
    return fb.OAuthProvider('apple.com').credential(
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
