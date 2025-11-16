import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'base_auth_adapter.dart';
import '../core/auth_result.dart';
import '../core/social_provider.dart';
import '../core/social_auth_error.dart';
import '../core/logger.dart';

/// Google Sign-In adapter
class GoogleAuthAdapter extends BaseAuthAdapter {
  final GoogleSignIn _googleSignIn;

  GoogleAuthAdapter({
    List<String>? scopes,
    String? hostedDomain,
    SocialAuthLogger? logger,
  })  : _googleSignIn = GoogleSignIn(
          scopes: scopes ??
              [
                'email',
                'profile',
              ],
          hostedDomain: hostedDomain,
        ),
        super(
          provider: SocialProvider.google,
          logger: logger,
        );

  @override
  bool isPlatformSupported() {
    // Google Sign-In works on all platforms
    return true;
  }

  @override
  Future<AuthResult> signIn({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      logger.info('Starting Google sign-in');

      // Sign out first to force account selection
      if (parameters?['forceAccountSelection'] == true) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        logger.warning('User cancelled Google sign-in');
        throw SocialAuthError.userCancelled(SocialProvider.google);
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final user = SocialUser(
        id: account.id,
        email: account.email,
        name: account.displayName,
        avatarUrl: account.photoUrl,
        additionalInfo: {
          'serverAuthCode': account.serverAuthCode,
        },
      );

      final result = AuthResult(
        provider: SocialProvider.google,
        accessToken: auth.accessToken,
        idToken: auth.idToken,
        authorizationCode: account.serverAuthCode,
        user: user,
        providerData: {
          'scopes': _googleSignIn.scopes,
        },
      );

      logger.info('Google sign-in successful: ${user.email}');
      return result;
    } on Exception catch (e, stackTrace) {
      logger.error('Google sign-in failed', e, stackTrace);

      if (e.toString().contains('sign_in_canceled')) {
        throw SocialAuthError.userCancelled(SocialProvider.google);
      } else if (e.toString().contains('network_error')) {
        throw SocialAuthError.networkError(SocialProvider.google, e);
      } else {
        throw SocialAuthError.providerError(
          SocialProvider.google,
          e.toString(),
          e,
        );
      }
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      logger.info('Google sign-out successful');
    } catch (e, stackTrace) {
      logger.error('Google sign-out failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Request additional scopes after initial sign-in
  Future<bool> requestScopes(List<String> scopes) async {
    try {
      return await _googleSignIn.requestScopes(scopes);
    } catch (e) {
      logger.error('Failed to request additional scopes', e);
      return false;
    }
  }
}
