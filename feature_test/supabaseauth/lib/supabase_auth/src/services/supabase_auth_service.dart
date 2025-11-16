import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/auth_result.dart';
import '../models/auth_error.dart';
import '../models/social_provider.dart';
import '../config/supabase_auth_config.dart';
import 'auth_service.dart';
import 'token_storage.dart';

/// Implementation of [AuthService] using Supabase as the backend
class SupabaseAuthService implements AuthService {
  final SupabaseAuthConfig config;
  final TokenStorage? tokenStorage;
  supabase.SupabaseClient? _client;

  SupabaseAuthService({
    required this.config,
    this.tokenStorage,
  });

  /// Initialize Supabase client
  Future<void> initialize() async {
    try {
      await supabase.Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
        authOptions: supabase.FlutterAuthClientOptions(
          authFlowType: supabase.AuthFlowType.pkce,
        ),
      );
      _client = supabase.Supabase.instance.client;
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  supabase.SupabaseClient get client {
    if (_client == null) {
      throw AuthError.configurationError(
        'Supabase client not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      if (response.user == null) {
        throw AuthError.unknownError;
      }

      return _mapAuthResponse(response);
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthError.invalidCredentials();
      }

      final result = _mapAuthResponse(response);

      // Store session if secure storage is enabled
      if (config.useSecureStorageForSession && tokenStorage != null) {
        await _storeSession(result);
      }

      return result;
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<AuthResult> signInWithMagicLink({
    required String email,
  }) async {
    try {
      await client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: config.redirectUrl,
      );

      // Magic link sends email but doesn't return session immediately
      // Return a pending result
      return AuthResult(
        provider: 'magiclink',
        user: AuthUser(
          id: 'pending',
          email: email,
        ),
        timestamp: DateTime.now(),
      );
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<AuthResult> signInWithOAuth(
    SocialProvider provider, {
    List<String>? scopes,
  }) async {
    try {
      // Map provider to Supabase provider
      final supabaseProvider = _mapProvider(provider);

      final response = await client.auth.signInWithOAuth(
        supabaseProvider,
        redirectTo: config.redirectUrl,
        scopes: scopes?.join(' '),
      );

      if (!response) {
        throw AuthError.userCancelled(provider);
      }

      // OAuth flow redirects externally, session will be available after redirect
      // For now, return a pending result
      final session = client.auth.currentSession;
      if (session?.user != null) {
        return _mapSessionToResult(session!, provider.id);
      }

      throw AuthError.providerError;
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e, provider);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace, provider);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();

      // Clear stored tokens
      if (tokenStorage != null) {
        await tokenStorage!.deleteAll();
      }
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: config.redirectUrl,
      );
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<AuthResult?> getCurrentSession() async {
    try {
      final session = client.auth.currentSession;
      if (session == null || session.user == null) {
        return null;
      }

      return _mapSessionToResult(session, 'session');
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<AuthResult> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();

      if (response.user == null) {
        throw AuthError.sessionExpired();
      }

      final result = _mapAuthResponse(response);

      // Update stored session
      if (config.useSecureStorageForSession && tokenStorage != null) {
        await _storeSession(result);
      }

      return result;
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final session = client.auth.currentSession;
      return session?.user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthResult> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await client.auth.updateUser(
        supabase.UserAttributes(data: metadata),
      );

      if (response.user == null) {
        throw AuthError.unknownError;
      }

      return _mapUserResponse(response);
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String email,
    required String token,
    required String type,
  }) async {
    try {
      final response = await client.auth.verifyOTP(
        email: email,
        token: token,
        type: _mapOtpType(type),
      );

      if (response.user == null) {
        throw AuthError.invalidMagicLink();
      }

      return _mapAuthResponse(response);
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e, stackTrace) {
      throw AuthError.fromException(e, stackTrace);
    }
  }

  // Helper methods

  AuthResult _mapAuthResponse(supabase.AuthResponse response) {
    return AuthResult(
      provider: response.session?.user.appMetadata['provider']?.toString() ??
          'email',
      user: _mapUser(response.user!),
      accessToken: response.session?.accessToken,
      refreshToken: response.session?.refreshToken,
      expiresAt: response.session?.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              response.session!.expiresAt! * 1000)
          : null,
      providerData: response.session?.user.userMetadata,
      timestamp: DateTime.now(),
    );
  }

  AuthResult _mapUserResponse(supabase.UserResponse response) {
    return AuthResult(
      provider: response.user?.appMetadata['provider']?.toString() ?? 'email',
      user: _mapUser(response.user!),
      timestamp: DateTime.now(),
    );
  }

  AuthResult _mapSessionToResult(supabase.Session session, String provider) {
    return AuthResult(
      provider: provider,
      user: _mapUser(session.user),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null,
      providerData: session.user.userMetadata,
      timestamp: DateTime.now(),
    );
  }

  AuthUser _mapUser(supabase.User user) {
    return AuthUser(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['name']?.toString() ??
          user.userMetadata?['full_name']?.toString(),
      avatarUrl: user.userMetadata?['avatar_url']?.toString() ??
          user.userMetadata?['picture']?.toString(),
      confirmedAt: user.confirmedAt != null
          ? DateTime.parse(user.confirmedAt!)
          : null,
      metadata: user.userMetadata,
    );
  }

  supabase.OAuthProvider _mapProvider(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return supabase.OAuthProvider.google;
      case SocialProvider.apple:
        return supabase.OAuthProvider.apple;
      case SocialProvider.facebook:
        return supabase.OAuthProvider.facebook;
      case SocialProvider.twitter:
        return supabase.OAuthProvider.twitter;
      case SocialProvider.github:
        return supabase.OAuthProvider.github;
    }
  }

  supabase.OtpType _mapOtpType(String type) {
    switch (type.toLowerCase()) {
      case 'magiclink':
        return supabase.OtpType.magiclink;
      case 'email':
        return supabase.OtpType.email;
      case 'sms':
        return supabase.OtpType.sms;
      default:
        return supabase.OtpType.magiclink;
    }
  }

  AuthError _mapSupabaseError(
    supabase.AuthException error, [
    SocialProvider? provider,
  ]) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid') && message.contains('credential')) {
      return AuthError.invalidCredentials();
    } else if (message.contains('email') && message.contains('not')) {
      return AuthError.emailNotConfirmed();
    } else if (message.contains('user') && message.contains('not found')) {
      return AuthError.userNotFound();
    } else if (message.contains('already') && message.contains('registered')) {
      return AuthError.emailAlreadyInUse();
    } else if (message.contains('password') && message.contains('weak')) {
      return AuthError.weakPassword();
    } else if (message.contains('rate') || message.contains('limit')) {
      return AuthError.rateLimitExceeded();
    } else if (message.contains('network') || message.contains('connection')) {
      return AuthError.networkError(error.message);
    }

    return AuthError(
      code: AuthErrorCode.unknownError,
      message: error.message,
      provider: provider,
      originalError: error,
    );
  }

  Future<void> _storeSession(AuthResult result) async {
    if (tokenStorage == null) return;

    if (result.accessToken != null) {
      await tokenStorage!.saveToken('access_token', result.accessToken!);
    }
    if (result.refreshToken != null) {
      await tokenStorage!.saveToken('refresh_token', result.refreshToken!);
    }
  }
}
