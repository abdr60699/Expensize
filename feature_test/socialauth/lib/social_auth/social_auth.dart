/// Flutter Social Authentication Module
///
/// Production-ready social sign-in supporting Google, Apple, and Facebook
library social_auth;

// Core exports
export 'src/core/social_provider.dart';
export 'src/core/auth_result.dart';
export 'src/core/social_auth_error.dart';
export 'src/core/auth_service.dart';
export 'src/core/token_storage.dart';
export 'src/core/logger.dart';

// Adapters
export 'src/adapters/base_auth_adapter.dart';
export 'src/adapters/google_auth_adapter.dart';
export 'src/adapters/apple_auth_adapter.dart';
export 'src/adapters/facebook_auth_adapter.dart';

// Services
export 'src/services/social_auth_manager.dart';
export 'src/services/firebase_auth_service.dart';
export 'src/services/rest_api_auth_service.dart';

// Widgets
export 'src/widgets/social_sign_in_button.dart';
export 'src/widgets/social_sign_in_row.dart';

import 'src/core/auth_result.dart';
import 'src/core/social_provider.dart';
import 'src/core/auth_service.dart';
import 'src/core/token_storage.dart';
import 'src/core/logger.dart';
import 'src/adapters/google_auth_adapter.dart';
import 'src/adapters/apple_auth_adapter.dart';
import 'src/adapters/facebook_auth_adapter.dart';
import 'src/services/social_auth_manager.dart';

/// Main facade for social authentication
///
/// Usage:
/// ```dart
/// // Initialize
/// final socialAuth = SocialAuth(
///   authService: FirebaseAuthService(),
///   logger: ConsoleLogger(),
/// );
///
/// // Sign in
/// final result = await socialAuth.signInWithGoogle();
/// print('Signed in as: ${result.user.email}');
///
/// // Sign out
/// await socialAuth.signOut();
/// ```
class SocialAuth {
  static SocialAuth? _instance;
  final SocialAuthManager _manager;

  SocialAuth._internal(this._manager);

  /// Create SocialAuth instance
  factory SocialAuth({
    AuthService? authService,
    TokenStorage? tokenStorage,
    SocialAuthLogger? logger,
    // Google configuration
    bool enableGoogle = true,
    List<String>? googleScopes,
    String? googleHostedDomain,
    // Apple configuration
    bool enableApple = true,
    String? appleRedirectUri,
    String? appleClientId,
    // Facebook configuration
    bool enableFacebook = true,
    List<String>? facebookPermissions,
  }) {
    final manager = SocialAuthManager(
      googleAdapter: enableGoogle
          ? GoogleAuthAdapter(
              scopes: googleScopes,
              hostedDomain: googleHostedDomain,
              logger: logger,
            )
          : null,
      appleAdapter: enableApple
          ? AppleAuthAdapter(
              redirectUri: appleRedirectUri,
              clientId: appleClientId,
              logger: logger,
            )
          : null,
      facebookAdapter: enableFacebook
          ? FacebookAuthAdapter(
              permissions: facebookPermissions,
              logger: logger,
            )
          : null,
      authService: authService,
      tokenStorage: tokenStorage,
      logger: logger,
    );

    return SocialAuth._internal(manager);
  }

  /// Get singleton instance (must call initialize first)
  static SocialAuth get instance {
    if (_instance == null) {
      throw StateError(
        'SocialAuth has not been initialized. '
        'Call SocialAuth.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize singleton instance
  static SocialAuth initialize({
    AuthService? authService,
    TokenStorage? tokenStorage,
    SocialAuthLogger? logger,
    bool enableGoogle = true,
    List<String>? googleScopes,
    String? googleHostedDomain,
    bool enableApple = true,
    String? appleRedirectUri,
    String? appleClientId,
    bool enableFacebook = true,
    List<String>? facebookPermissions,
  }) {
    _instance = SocialAuth(
      authService: authService,
      tokenStorage: tokenStorage,
      logger: logger,
      enableGoogle: enableGoogle,
      googleScopes: googleScopes,
      googleHostedDomain: googleHostedDomain,
      enableApple: enableApple,
      appleRedirectUri: appleRedirectUri,
      appleClientId: appleClientId,
      enableFacebook: enableFacebook,
      facebookPermissions: facebookPermissions,
    );
    return _instance!;
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    return await _manager.signInWithGoogle(
      scopes: scopes,
      parameters: parameters,
    );
  }

  /// Sign in with Apple
  Future<AuthResult> signInWithApple({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    return await _manager.signInWithApple(
      scopes: scopes,
      parameters: parameters,
    );
  }

  /// Sign in with Facebook
  Future<AuthResult> signInWithFacebook({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    return await _manager.signInWithFacebook(
      scopes: scopes,
      parameters: parameters,
    );
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    await _manager.signOut();
  }

  /// Check if user is signed in with a provider
  Future<bool> isSignedIn(SocialProvider provider) async {
    return await _manager.isSignedIn(provider);
  }

  /// Check if provider is available on current platform
  bool isPlatformSupported(SocialProvider provider) {
    return _manager.isPlatformSupported(provider);
  }

  /// Get list of configured providers
  List<SocialProvider> get configuredProviders =>
      _manager.configuredProviders;

  /// Get list of available providers for current platform
  List<SocialProvider> get availableProviders => _manager.availableProviders;
}
