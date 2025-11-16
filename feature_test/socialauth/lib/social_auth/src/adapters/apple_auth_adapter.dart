import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'base_auth_adapter.dart';
import '../core/auth_result.dart';
import '../core/social_provider.dart';
import '../core/social_auth_error.dart';
import '../core/logger.dart';

/// Apple Sign-In adapter
class AppleAuthAdapter extends BaseAuthAdapter {
  final List<AppleIDAuthorizationScopes> scopes;
  final String? redirectUri;
  final String? clientId;
  final String? nonce;

  AppleAuthAdapter({
    List<AppleIDAuthorizationScopes>? scopes,
    this.redirectUri,
    this.clientId,
    this.nonce,
    SocialAuthLogger? logger,
  })  : scopes = scopes ??
            [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
        super(
          provider: SocialProvider.apple,
          logger: logger,
        );

  @override
  bool isPlatformSupported() {
    if (kIsWeb) {
      // Apple Sign-In on web requires additional setup
      return redirectUri != null && clientId != null;
    }

    // iOS 13+ and macOS 10.15+
    if (Platform.isIOS || Platform.isMacOS) {
      return true;
    }

    // Android is supported with web authentication
    if (Platform.isAndroid) {
      return redirectUri != null && clientId != null;
    }

    return false;
  }

  @override
  Future<AuthResult> signIn({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    if (!isPlatformSupported()) {
      throw SocialAuthError.platformNotSupported(SocialProvider.apple);
    }

    try {
      logger.info('Starting Apple sign-in');

      final AuthorizationCredentialAppleID credential;

      if (kIsWeb || Platform.isAndroid) {
        // Use web authentication flow
        credential = await SignInWithApple.getAppleIDCredential(
          scopes: this.scopes,
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: clientId!,
            redirectUri: Uri.parse(redirectUri!),
          ),
          nonce: nonce,
        );
      } else {
        // Use native iOS/macOS flow
        credential = await SignInWithApple.getAppleIDCredential(
          scopes: this.scopes,
          nonce: nonce,
        );
      }

      // Build user name from given/family name
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
            .trim();
      }

      final user = SocialUser(
        id: credential.userIdentifier ?? '',
        email: credential.email,
        name: fullName,
        firstName: credential.givenName,
        lastName: credential.familyName,
        additionalInfo: {
          'realUserStatus': credential.state,
        },
      );

      final result = AuthResult(
        provider: SocialProvider.apple,
        idToken: credential.identityToken,
        authorizationCode: credential.authorizationCode,
        user: user,
        providerData: {
          'state': credential.state,
        },
      );

      logger.info('Apple sign-in successful: ${user.email ?? user.id}');

      // Important: Apple only provides user info on FIRST sign-in
      // Store this information immediately!
      if (credential.email != null || fullName != null) {
        logger.warning(
          'IMPORTANT: Apple user info received. Store it now! '
          'This data may not be available on subsequent sign-ins.',
        );
      }

      return result;
    } on SignInWithAppleAuthorizationException catch (e) {
      logger.error('Apple sign-in authorization error', e);

      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw SocialAuthError.userCancelled(SocialProvider.apple);
        case AuthorizationErrorCode.failed:
          throw SocialAuthError.providerError(
            SocialProvider.apple,
            'Authorization failed: ${e.message}',
            e,
          );
        case AuthorizationErrorCode.invalidResponse:
          throw SocialAuthError.providerError(
            SocialProvider.apple,
            'Invalid response from Apple',
            e,
          );
        case AuthorizationErrorCode.notHandled:
          throw SocialAuthError.providerError(
            SocialProvider.apple,
            'Authorization not handled',
            e,
          );
        case AuthorizationErrorCode.unknown:
          throw SocialAuthError.providerError(
            SocialProvider.apple,
            'Unknown error: ${e.message}',
            e,
          );
        default:
          throw SocialAuthError.providerError(
            SocialProvider.apple,
            e.message,
            e,
          );
      }
    } catch (e, stackTrace) {
      logger.error('Apple sign-in failed', e, stackTrace);
      throw SocialAuthError.providerError(
        SocialProvider.apple,
        e.toString(),
        e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    // Apple doesn't have a sign-out API
    // Clear local session only
    logger.info('Apple sign-out (local session cleared)');
  }

  @override
  Future<bool> isSignedIn() async {
    // Apple doesn't provide a way to check sign-in status
    // This needs to be tracked in your app
    return false;
  }

  /// Check if Sign in with Apple is available on this device
  static Future<bool> isAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      return false;
    }
  }
}
