import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../repository/auth_repository.dart';
import '../storage/token_store.dart';
import '../storage/secure_storage_token_store.dart';

/// Riverpod providers for Firebase Auth Module
///
/// **Usage:**
/// ```dart
/// // In main.dart
/// runApp(
///   ProviderScope(
///     child: MyApp(),
///   ),
/// );
///
/// // In widget
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authService = ref.read(authServiceProvider);
///     final user = ref.watch(currentUserProvider);
///
///     // Use authService and user
///   }
/// }
/// ```

// =============================================================================
// CORE PROVIDERS
// =============================================================================

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

/// Token store provider (Secure Storage)
final tokenStoreProvider = Provider<ITokenStore>((ref) {
  return SecureStorageTokenStore();
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: ref.read(firebaseAuthProvider),
    tokenStore: ref.read(tokenStoreProvider),
  );
});

/// Auth service provider (Main API)
///
/// This is the primary provider you'll use for authentication operations.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    repository: ref.read(authRepositoryProvider),
  );
});

// =============================================================================
// STATE PROVIDERS
// =============================================================================

/// Stream provider for auth state changes
///
/// Emits [UserModel?] whenever auth state changes.
/// - User signed in: emits UserModel
/// - User signed out: emits null
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Current user provider (cached)
///
/// Returns the currently signed-in user or null.
/// This is synchronous and uses cached data.
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Is authenticated provider
///
/// Returns true if a user is signed in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Is anonymous provider
///
/// Returns true if current user is anonymous.
final isAnonymousProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAnonymous ?? false;
});

/// Is email verified provider
///
/// Returns true if current user's email is verified.
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

/// Needs email verification provider
///
/// Returns true if user is signed in with email but not verified.
final needsEmailVerificationProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  if (user.email == null) return false;
  return !user.emailVerified;
});

// =============================================================================
// HELPER PROVIDERS
// =============================================================================

/// ID token provider
///
/// Returns Firebase ID token for API calls.
/// Automatically refreshed by Firebase SDK.
final idTokenProvider = FutureProvider<String?>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return await repository.getIdToken();
});

/// Force refresh ID token provider
///
/// Use this when you need a fresh token.
final refreshedIdTokenProvider = FutureProvider<String?>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return await repository.getIdToken(forceRefresh: true);
});

// =============================================================================
// FAMILY PROVIDERS (for specific use cases)
// =============================================================================

/// Provider to check if a specific provider is linked
///
/// Usage: `ref.watch(hasProviderFamily('google.com'))`
final hasProviderFamily = Provider.family<bool, String>((ref, providerId) {
  final user = ref.watch(currentUserProvider);
  return user?.hasProvider(providerId) ?? false;
});

// =============================================================================
// CONVENIENCE EXTENSIONS
// =============================================================================

/// Extension on WidgetRef for easy access to auth
extension AuthRefExtensions on WidgetRef {
  /// Get auth service
  AuthService get auth => read(authServiceProvider);

  /// Get current user
  UserModel? get currentUser => watch(currentUserProvider);

  /// Check if authenticated
  bool get isAuthenticated => watch(isAuthenticatedProvider);

  /// Check if anonymous
  bool get isAnonymous => watch(isAnonymousProvider);

  /// Check if email verified
  bool get isEmailVerified => watch(isEmailVerifiedProvider);

  /// Get ID token
  Future<String?> getIdToken() async {
    return await read(authRepositoryProvider).getIdToken();
  }
}
