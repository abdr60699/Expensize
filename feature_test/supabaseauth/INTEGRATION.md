# Integration Guide

How to integrate Supabase authentication into any Flutter application.

## Quick Start (5 Minutes)

### 1. Add Dependency

```yaml
dependencies:
  supabase_flutter: ^2.10.3
  flutter_secure_storage: ^9.2.4
```

### 2. Copy Module

```bash
cp -r feature_test/supabaseauth/lib/supabase_auth /path/to/your/project/lib/
```

### 3. Initialize

```dart
import 'package:supabaseauth/supabase_auth/supabase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = SupabaseAuthConfig(
    supabaseUrl: 'https://xxxxx.supabase.co',
    supabaseAnonKey: 'your-anon-key',
    redirectUrl: 'myapp://auth-callback',
  );

  final authService = SupabaseAuthService(
    config: config,
    tokenStorage: SecureTokenStorage(),
  );
  await authService.initialize();

  runApp(MyApp(authService: authService));
}
```

### 4. Use Auth Repository

```dart
class LoginScreen extends StatelessWidget {
  final authRepo = AuthRepository(authService: authService);

  Future<void> signIn() async {
    final session = await authRepo.signInWithEmail(
      email: 'user@example.com',
      password: 'password',
    );

    if (session.user != null) {
      navigateToHome();
    }
  }
}
```

## Complete Integration

### With State Management (Riverpod)

```dart
// providers.dart
final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService(
    config: SupabaseAuthConfig(...),
    tokenStorage: SecureTokenStorage(),
  );
});

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
  );
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Usage
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        if (state.session != null) {
          return HomeScreen();
        }
        return LoginScreen();
      },
      loading: () => SplashScreen(),
      error: (_, __) => ErrorScreen(),
    );
  }
}
```

### Deep Linking (OAuth/Magic Link)

#### iOS Setup

**Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

#### Android Setup

**AndroidManifest.xml:**
```xml
<activity android:name=".MainActivity">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="myapp" android:host="auth-callback" />
  </intent-filter>
</activity>
```

### Pre-Built UI Screens

```dart
import 'package:supabaseauth/supabase_auth/supabase_auth.dart';

// Sign-in screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReusableSignInScreen(
      authRepository: authRepo,
      onSignInSuccess: () => Navigator.pushReplacement(...),
    ),
  ),
);

// Sign-up screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReusableSignUpScreen(
      authRepository: authRepo,
      onSignUpSuccess: () => showVerificationDialog(),
    ),
  ),
);

// Forgot password
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReusableForgotPasswordScreen(
      authRepository: authRepo,
    ),
  ),
);
```

## Integration Checklist

- [ ] Create Supabase project
- [ ] Get project URL and anon key
- [ ] Add dependencies
- [ ] Copy module files
- [ ] Initialize auth service
- [ ] Configure deep linking
- [ ] Enable auth providers in Supabase
- [ ] Test sign-up flow
- [ ] Test sign-in flow
- [ ] Test OAuth flow

**Ready to integrate Supabase auth!**
