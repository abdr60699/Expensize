import '../core/auth_result.dart';
import '../core/social_provider.dart';
import '../core/logger.dart';

/// Base adapter interface for social authentication providers
abstract class BaseAuthAdapter {
  final SocialProvider provider;
  final SocialAuthLogger logger;

  BaseAuthAdapter({
    required this.provider,
    SocialAuthLogger? logger,
  }) : logger = logger ?? const NoOpLogger();

  /// Check if this provider is available on the current platform
  bool isPlatformSupported();

  /// Sign in with this provider
  Future<AuthResult> signIn({
    List<String>? scopes,
    Map<String, dynamic>? parameters,
  });

  /// Sign out from this provider
  Future<void> signOut();

  /// Check if user is currently signed in
  Future<bool> isSignedIn();
}
