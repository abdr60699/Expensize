import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import '../repository/auth_repository.dart';
import '../storage/token_store.dart';
import '../storage/secure_storage_token_store.dart';
import '../services/social_auth/google_signin_adapter.dart';
import '../services/social_auth/apple_signin_adapter.dart';
import '../services/social_auth/facebook_signin_adapter.dart';
import '../services/phone_auth_service.dart';

/// GetIt service locator registration for Firebase Auth Module
///
/// **Usage:**
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///
///   // Register auth module
///   await registerAuthModule();
///
///   runApp(MyApp());
/// }
///
/// // In your code
/// final authService = GetIt.I<AuthService>();
/// await authService.signInWithEmail(...);
/// ```

/// Register all auth module dependencies with GetIt
Future<void> registerAuthModule({
  GetIt? getIt,
}) async {
  final locator = getIt ?? GetIt.instance;

  // Register Firebase Auth instance as singleton
  locator.registerLazySingleton<fb.FirebaseAuth>(
    () => fb.FirebaseAuth.instance,
  );

  // Register Token Store
  locator.registerLazySingleton<ITokenStore>(
    () => SecureStorageTokenStore(),
  );

  // Register Social Auth Adapters
  locator.registerLazySingleton<GoogleSignInAdapter>(
    () => GoogleSignInAdapter(),
  );

  locator.registerLazySingleton<AppleSignInAdapter>(
    () => AppleSignInAdapter(),
  );

  locator.registerLazySingleton<FacebookSignInAdapter>(
    () => FacebookSignInAdapter(),
  );

  // Register Phone Auth Service
  locator.registerLazySingleton<PhoneAuthService>(
    () => PhoneAuthService(
      firebaseAuth: locator<fb.FirebaseAuth>(),
    ),
  );

  // Register Auth Repository
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseAuth: locator<fb.FirebaseAuth>(),
      tokenStore: locator<ITokenStore>(),
    ),
  );

  // Register Auth Service (Main API)
  locator.registerLazySingleton<AuthService>(
    () => AuthService(
      repository: locator<AuthRepository>(),
      googleSignIn: locator<GoogleSignInAdapter>(),
      appleSignIn: locator<AppleSignInAdapter>(),
      facebookSignIn: locator<FacebookSignInAdapter>(),
      phoneAuth: locator<PhoneAuthService>(),
    ),
  );
}

/// Unregister auth module (for testing or module cleanup)
void unregisterAuthModule({GetIt? getIt}) {
  final locator = getIt ?? GetIt.instance;

  // Dispose repository before unregistering
  if (locator.isRegistered<AuthRepository>()) {
    locator<AuthRepository>().dispose();
  }

  // Dispose auth service
  if (locator.isRegistered<AuthService>()) {
    locator<AuthService>().dispose();
  }

  // Unregister all
  locator.unregister<AuthService>();
  locator.unregister<AuthRepository>();
  locator.unregister<PhoneAuthService>();
  locator.unregister<FacebookSignInAdapter>();
  locator.unregister<AppleSignInAdapter>();
  locator.unregister<GoogleSignInAdapter>();
  locator.unregister<ITokenStore>();
  locator.unregister<fb.FirebaseAuth>();
}

/// Helper extension for GetIt
extension GetItAuthExtensions on GetIt {
  /// Get auth service
  AuthService get auth => this<AuthService>();

  /// Get auth repository
  AuthRepository get authRepository => this<AuthRepository>();

  /// Get current user
  UserModel? get currentUser => this<AuthRepository>().currentUser;
}

// Re-export GetIt for convenience
export 'package:get_it/get_it.dart';
export '../models/user_model.dart';
