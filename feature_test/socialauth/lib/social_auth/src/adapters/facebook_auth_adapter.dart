import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'base_auth_adapter.dart';
import '../core/auth_result.dart';
import '../core/social_provider.dart';
import '../core/social_auth_error.dart';
import '../core/logger.dart';

/// Facebook Login adapter
class FacebookAuthAdapter extends BaseAuthAdapter {
  final FacebookAuth _facebookAuth;
  final List<String> permissions;

  FacebookAuthAdapter({
    List<String>? permissions,
    SocialAuthLogger? logger,
  })  : _facebookAuth = FacebookAuth.instance,
        permissions = permissions ?? ['email', 'public_profile'],
        super(
          provider: SocialProvider.facebook,
          logger: logger,
        );

  @override
  bool isPlatformSupported() {
    // Facebook Auth works on all platforms
    return true;
  }

  @override
  Future<AuthResult> signIn({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      logger.info('Starting Facebook sign-in');

      final LoginResult result = await _facebookAuth.login(
        permissions: scopes ?? permissions,
      );

      switch (result.status) {
        case LoginStatus.success:
          final AccessToken? accessToken = result.accessToken;
          if (accessToken == null) {
            throw SocialAuthError.providerError(
              SocialProvider.facebook,
              'No access token received',
            );
          }

          // Get user data
          final userData = await _facebookAuth.getUserData(
            fields: "id,name,email,picture.width(200)",
          );

          final user = SocialUser(
            id: userData['id'] as String,
            email: userData['email'] as String?,
            name: userData['name'] as String?,
            avatarUrl: userData['picture']?['data']?['url'] as String?,
            additionalInfo: userData,
          );

          // Build provider data based on token type
          final providerData = <String, dynamic>{};

          // Try to cast to ClassicToken for additional info
          try {
            if (accessToken is ClassicToken) {
              providerData['userId'] = accessToken.userId;
              providerData['expires'] = accessToken.expires.toIso8601String();
              providerData['grantedPermissions'] = accessToken.grantedPermissions;
              providerData['declinedPermissions'] = accessToken.declinedPermissions;
            }
          } catch (e) {
            // If cast fails, continue without additional data
            logger.debug('Could not cast to ClassicToken: $e');
          }

          final authResult = AuthResult(
            provider: SocialProvider.facebook,
            accessToken: accessToken.tokenString,
            user: user,
            providerData: providerData.isEmpty ? null : providerData,
          );

          logger.info('Facebook sign-in successful: ${user.email}');
          return authResult;

        case LoginStatus.cancelled:
          logger.warning('User cancelled Facebook sign-in');
          throw SocialAuthError.userCancelled(SocialProvider.facebook);

        case LoginStatus.failed:
          logger.error('Facebook sign-in failed: ${result.message}');
          throw SocialAuthError.providerError(
            SocialProvider.facebook,
            result.message ?? 'Unknown error',
          );

        case LoginStatus.operationInProgress:
          throw SocialAuthError.providerError(
            SocialProvider.facebook,
            'Another login operation is in progress',
          );

        default:
          throw SocialAuthError.providerError(
            SocialProvider.facebook,
            'Unknown login status: ${result.status}',
          );
      }
    } catch (e, stackTrace) {
      if (e is SocialAuthError) rethrow;

      logger.error('Facebook sign-in failed', e, stackTrace);
      throw SocialAuthError.providerError(
        SocialProvider.facebook,
        e.toString(),
        e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _facebookAuth.logOut();
      logger.info('Facebook sign-out successful');
    } catch (e, stackTrace) {
      logger.error('Facebook sign-out failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    final accessToken = await _facebookAuth.accessToken;
    if (accessToken == null) return false;

    // Check if token is expired for ClassicToken
    if (accessToken is ClassicToken) {
      return !accessToken.isExpired;
    }

    // For other token types, assume valid if exists
    return true;
  }

  /// Get current access token
  Future<AccessToken?> getAccessToken() async {
    return await _facebookAuth.accessToken;
  }

  /// Request additional permissions
  Future<bool> requestPermissions(List<String> permissions) async {
    try {
      final result = await _facebookAuth.login(permissions: permissions);
      return result.status == LoginStatus.success;
    } catch (e) {
      logger.error('Failed to request Facebook permissions', e);
      return false;
    }
  }
}
