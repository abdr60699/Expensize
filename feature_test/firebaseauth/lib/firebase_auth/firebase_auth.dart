/// Firebase Auth Module
///
/// A complete, production-ready Firebase Authentication module for Flutter.
///
/// **Features:**
/// - Email/Password authentication
/// - Phone OTP verification
/// - Social sign-in (Google, Apple, Facebook)
/// - Anonymous sign-in
/// - Account linking/unlinking
/// - Email verification & password reset
/// - Secure token storage
/// - Riverpod & GetIt support
///
/// **Quick Start (Riverpod):**
/// ```dart
/// import 'package:flutter_riverpod/flutter_riverpod.dart';
/// import 'features/firebase_auth/firebase_auth.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   runApp(ProviderScope(child: MyApp()));
/// }
///
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authService = ref.read(authServiceProvider);
///     final user = ref.watch(currentUserProvider);
///
///     // Use authService for auth operations
///     // Use user for current user state
///   }
/// }
/// ```
///
/// **Quick Start (GetIt):**
/// ```dart
/// import 'package:get_it/get_it.dart';
/// import 'features/firebase_auth/firebase_auth.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   await registerAuthModule();
///   runApp(MyApp());
/// }
///
/// class MyScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final authService = GetIt.I<AuthService>();
///
///     // Use authService for auth operations
///   }
/// }
/// ```
library firebase_auth_module;

// Core models
export 'models/user_model.dart';
export 'models/auth_result.dart';

// Errors
export 'errors/auth_error.dart';

// Services
export 'services/auth_service.dart';
export 'services/phone_auth_service.dart';
export 'services/social_auth/google_signin_adapter.dart';
export 'services/social_auth/apple_signin_adapter.dart';
export 'services/social_auth/facebook_signin_adapter.dart';

// Repository
export 'repository/auth_repository.dart';

// Storage
export 'storage/token_store.dart';
export 'storage/secure_storage_token_store.dart';
export 'storage/shared_prefs_session_store.dart';

// Providers (Riverpod)
export 'providers/auth_providers.dart';

// Providers (GetIt)
export 'providers/getit_registration.dart';

// Utils
export 'utils/validators.dart';
export 'utils/auth_constants.dart';

// UI
export 'ui/auth_ui_kit.dart';
export 'ui/screens/sign_in_screen.dart';
export 'ui/screens/phone_signin_screen.dart';

// Firebase dependencies (re-export for convenience)
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart' hide User, AuthProvider;
