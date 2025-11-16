import '../core/auth_result.dart';
import '../core/social_provider.dart';
import '../core/social_auth_error.dart';
import '../core/auth_service.dart';
import '../core/token_storage.dart';
import '../core/logger.dart';
import '../adapters/base_auth_adapter.dart';
import '../adapters/google_auth_adapter.dart';
import '../adapters/apple_auth_adapter.dart';
import '../adapters/facebook_auth_adapter.dart';

/// Main social authentication manager
class SocialAuthManager {
  final Map<SocialProvider, BaseAuthAdapter> _adapters = {};
  final AuthService? authService;
  final TokenStorage? tokenStorage;
  final SocialAuthLogger logger;

  SocialAuthManager({
    GoogleAuthAdapter? googleAdapter,
    AppleAuthAdapter? appleAdapter,
    FacebookAuthAdapter? facebookAdapter,
    this.authService,
    this.tokenStorage,
    SocialAuthLogger? logger,
  }) : logger = logger ?? const NoOpLogger() {
    // Register adapters
    if (googleAdapter != null) {
      _adapters[SocialProvider.google] = googleAdapter;
    }
    if (appleAdapter != null) {
      _adapters[SocialProvider.apple] = appleAdapter;
    }
    if (facebookAdapter != null) {
      _adapters[SocialProvider.facebook] = facebookAdapter;
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    return await _signInWithProvider(
      SocialProvider.google,
      scopes: scopes,
      parameters: parameters,
    );
  }

  /// Sign in with Apple
  Future<AuthResult> signInWithApple({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    return await _signInWithProvider(
      SocialProvider.apple,
      scopes: scopes,
      parameters: parameters,
    );
  }

  /// Sign in with Facebook
  Future<AuthResult> signInWithFacebook({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    return await _signInWithProvider(
      SocialProvider.facebook,
      scopes: scopes,
      parameters: parameters,
    );
  }

  /// Generic sign in with provider
  Future<AuthResult> _signInWithProvider(
    SocialProvider provider, {
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  }) async {
    final adapter = _adapters[provider];

    if (adapter == null) {
      throw SocialAuthError.configurationError(
        provider,
        'Adapter not configured for ${provider.name}',
      );
    }

    if (!adapter.isPlatformSupported()) {
      throw SocialAuthError.platformNotSupported(provider);
    }

    try {
      logger.info('Starting sign-in with ${provider.name}');

      // Sign in with provider
      final authResult = await adapter.signIn(
        scopes: scopes,
        parameters: parameters,
      );

      logger.info('Sign-in successful with ${provider.name}');

      // Authenticate with backend if provided
      if (authService != null) {
        logger.info('Authenticating with backend service');
        final backendResult =
            await authService!.authenticateWithProvider(authResult);

        // Store token if storage provided
        if (tokenStorage != null && backendResult['sessionToken'] != null) {
          await tokenStorage!.saveToken(
            'session_token',
            backendResult['sessionToken'],
          );
        }

        logger.info('Backend authentication successful');
      }

      return authResult;
    } catch (e, stackTrace) {
      logger.error('Sign-in failed with ${provider.name}', e, stackTrace);
      rethrow;
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      logger.info('Starting sign-out from all providers');

      // Sign out from all adapters
      for (final adapter in _adapters.values) {
        try {
          await adapter.signOut();
        } catch (e) {
          logger.error('Failed to sign out from ${adapter.provider.name}', e);
        }
      }

      // Sign out from backend
      if (authService != null) {
        try {
          await authService!.signOut();
        } catch (e) {
          logger.error('Failed to sign out from backend', e);
        }
      }

      // Clear stored tokens
      if (tokenStorage != null) {
        try {
          await tokenStorage!.deleteAll();
        } catch (e) {
          logger.error('Failed to clear stored tokens', e);
        }
      }

      logger.info('Sign-out completed');
    } catch (e, stackTrace) {
      logger.error('Sign-out failed', e, stackTrace);
      rethrow;
    }
  }

  /// Check if user is signed in with a provider
  Future<bool> isSignedIn(SocialProvider provider) async {
    final adapter = _adapters[provider];
    if (adapter == null) return false;

    try {
      return await adapter.isSignedIn();
    } catch (e) {
      logger.error('Failed to check sign-in status for ${provider.name}', e);
      return false;
    }
  }

  /// Check if provider is available on current platform
  bool isPlatformSupported(SocialProvider provider) {
    final adapter = _adapters[provider];
    if (adapter == null) return false;
    return adapter.isPlatformSupported();
  }

  /// Get list of configured providers
  List<SocialProvider> get configuredProviders => _adapters.keys.toList();

  /// Get list of available providers for current platform
  List<SocialProvider> get availableProviders {
    return _adapters.entries
        .where((entry) => entry.value.isPlatformSupported())
        .map((entry) => entry.key)
        .toList();
  }
}
