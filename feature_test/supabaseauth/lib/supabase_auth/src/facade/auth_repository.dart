import 'dart:async';
import '../models/auth_result.dart';
import '../models/auth_error.dart';
import '../models/social_provider.dart';
import '../config/supabase_auth_config.dart';
import '../services/auth_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/token_storage.dart';

/// Facade for authentication operations with reactive state management
class AuthRepository {
  final AuthService _authService;
  final StreamController<AuthResult?> _authStateController;

  static AuthRepository? _instance;

  AuthRepository._internal(this._authService)
      : _authStateController = StreamController<AuthResult?>.broadcast() {
    // Initialize auth state stream
    _initAuthStateListener();
  }

  /// Get singleton instance
  static AuthRepository get instance {
    if (_instance == null) {
      throw AuthError.configurationError(
        'AuthRepository not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize the auth repository with configuration
  static Future<AuthRepository> initialize(
    SupabaseAuthConfig config, {
    TokenStorage? tokenStorage,
  }) async {
    final authService = SupabaseAuthService(
      config: config,
      tokenStorage: tokenStorage ?? (config.useSecureStorageForSession
          ? SecureTokenStorage()
          : MemoryTokenStorage()),
    );

    await authService.initialize();

    _instance = AuthRepository._internal(authService);

    // Emit initial auth state
    final session = await authService.getCurrentSession();
    _instance!._authStateController.add(session);

    return _instance!;
  }

  /// Stream of authentication state changes
  Stream<AuthResult?> authStateChanges() {
    return _authStateController.stream;
  }

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final result = await _authService.signUpWithEmail(
        email: email,
        password: password,
        metadata: metadata,
      );
      _authStateController.add(result);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _authStateController.add(result);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with magic link
  Future<AuthResult> signInWithMagicLink({
    required String email,
  }) async {
    try {
      final result = await _authService.signInWithMagicLink(email: email);
      // Don't update state for magic link, wait for verification
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with OAuth provider
  Future<AuthResult> signInWithOAuth(
    SocialProvider provider, {
    List<String>? scopes,
  }) async {
    try {
      final result = await _authService.signInWithOAuth(
        provider,
        scopes: scopes,
      );
      _authStateController.add(result);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _authStateController.add(null);
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    return _authService.sendPasswordResetEmail(email);
  }

  /// Get current session
  Future<AuthResult?> getCurrentSession() async {
    return _authService.getCurrentSession();
  }

  /// Refresh session
  Future<AuthResult> refreshSession() async {
    try {
      final result = await _authService.refreshSession();
      _authStateController.add(result);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if signed in
  Future<bool> isSignedIn() async {
    return _authService.isSignedIn();
  }

  /// Update user metadata
  Future<AuthResult> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final result = await _authService.updateUserMetadata(metadata);
      _authStateController.add(result);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP
  Future<AuthResult> verifyOtp({
    required String email,
    required String token,
    required String type,
  }) async {
    try {
      final result = await _authService.verifyOtp(
        email: email,
        token: token,
        type: type,
      );
      _authStateController.add(result);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  void _initAuthStateListener() {
    // Listen to Supabase auth state changes
    // This is a simplified version - in production, you'd listen to
    // Supabase's onAuthStateChange stream
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final session = await getCurrentSession();
        if (_authStateController.hasListener) {
          _authStateController.add(session);
        }
      } catch (e) {
        // Ignore errors in background check
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
