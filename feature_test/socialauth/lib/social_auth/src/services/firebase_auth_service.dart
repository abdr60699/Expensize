import 'package:firebase_auth/firebase_auth.dart';
import '../core/auth_service.dart';
import '../core/auth_result.dart';
import '../core/social_provider.dart';

/// Firebase Authentication Service
///
/// Example implementation of AuthService using Firebase Auth
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> authenticateWithProvider(
    AuthResult authResult,
  ) async {
    try {
      final UserCredential userCredential;

      switch (authResult.provider) {
        case SocialProvider.google:
          userCredential = await _signInWithGoogle(authResult);
          break;

        case SocialProvider.apple:
          userCredential = await _signInWithApple(authResult);
          break;

        case SocialProvider.facebook:
          userCredential = await _signInWithFacebook(authResult);
          break;
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null after authentication');
      }

      // Get Firebase ID token for your backend
      final idToken = await firebaseUser.getIdToken();

      return {
        'success': true,
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'photoURL': firebaseUser.photoURL,
        'idToken': idToken,
        'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
        'providerId': authResult.provider.id,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<UserCredential> _signInWithGoogle(AuthResult authResult) async {
    final credential = GoogleAuthProvider.credential(
      accessToken: authResult.accessToken,
      idToken: authResult.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> _signInWithApple(AuthResult authResult) async {
    final credential = OAuthProvider('apple.com').credential(
      idToken: authResult.idToken,
      accessToken: authResult.accessToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> _signInWithFacebook(AuthResult authResult) async {
    final credential = FacebookAuthProvider.credential(
      authResult.accessToken!,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
    };
  }

  /// Link additional social provider to existing Firebase account
  Future<Map<String, dynamic>> linkProvider(AuthResult authResult) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user logged in to link provider');
    }

    try {
      AuthCredential credential;

      switch (authResult.provider) {
        case SocialProvider.google:
          credential = GoogleAuthProvider.credential(
            accessToken: authResult.accessToken,
            idToken: authResult.idToken,
          );
          break;

        case SocialProvider.apple:
          credential = OAuthProvider('apple.com').credential(
            idToken: authResult.idToken,
            accessToken: authResult.accessToken,
          );
          break;

        case SocialProvider.facebook:
          credential = FacebookAuthProvider.credential(
            authResult.accessToken!,
          );
          break;
      }

      final userCredential = await user.linkWithCredential(credential);

      return {
        'success': true,
        'providerId': authResult.provider.id,
        'uid': userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        return {
          'success': false,
          'error': 'This account is already linked to another user',
          'code': 'credential-already-in-use',
        };
      }

      return {
        'success': false,
        'error': e.message ?? e.code,
        'code': e.code,
      };
    }
  }

  /// Unlink social provider from Firebase account
  Future<void> unlinkProvider(SocialProvider provider) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String providerId;
    switch (provider) {
      case SocialProvider.google:
        providerId = 'google.com';
        break;
      case SocialProvider.apple:
        providerId = 'apple.com';
        break;
      case SocialProvider.facebook:
        providerId = 'facebook.com';
        break;
    }

    await user.unlink(providerId);
  }
}
