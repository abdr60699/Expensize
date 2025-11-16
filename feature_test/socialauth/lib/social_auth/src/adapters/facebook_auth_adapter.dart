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

          final authResult = AuthResult(
            provider: SocialProvider.facebook,
            accessToken: accessToken.token,
            user: user,
            providerData: {
              'userId': accessToken.userId,
              'expires': accessToken.expires.toIso8601String(),
              'grantedPermissions': accessToken.grantedPermissions,
              'declinedPermissions': accessToken.declinedPermissions,
            },
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
    return accessToken != null && !accessToken.isExpired;
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
