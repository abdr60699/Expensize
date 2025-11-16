# Supabase Authentication Module

A production-ready, reusable Flutter authentication module with Supabase backend supporting email/password, magic links, and OAuth providers (Google, Apple, Facebook, Twitter, GitHub).

## 📂 Module Structure

```
supabase_auth/
├── lib/
│   ├── src/
│   │   ├── models/             # Data models
│   │   │   ├── auth_result.dart
│   │   │   ├── auth_error.dart
│   │   │   └── social_provider.dart
│   │   ├── config/             # Configuration
│   │   │   └── supabase_auth_config.dart
│   │   ├── services/           # Auth services
│   │   │   ├── auth_service.dart
│   │   │   ├── supabase_auth_service.dart
│   │   │   └── token_storage.dart
│   │   ├── facade/             # Repository facade
│   │   │   └── auth_repository.dart
│   │   ├── widgets/            # Reusable UI screens
│   │   │   └── reusable_signin_screen.dart
│   │   └── utils/              # Validators
│   │       └── validators.dart
│   └── supabase_auth.dart      # Main entry point
├── test/                       # Unit and widget tests
├── example/                    # Example application
├── pubspec.yaml                # Dependencies
└── README.md                   # This file
```

## 🚀 Features

### Authentication Methods
- ✅ **Email/Password** - Traditional authentication
- ✅ **Magic Links** - Passwordless email authentication
- ✅ **OAuth Providers** - Google, Apple, Facebook, Twitter, GitHub
- ✅ **Password Reset** - Email-based password recovery
- ✅ **Email Verification** - Confirm user emails

### Security
- ✅ **Secure Token Storage** - flutter_secure_storage integration
- ✅ **Session Management** - Automatic token refresh
- ✅ **Password Validation** - Configurable strength requirements
- ✅ **Email Validation** - Client-side validation
- ✅ **Rate Limiting** - Error handling for rate limits

### Developer Experience
- ✅ **Reactive State** - Stream-based auth state changes
- ✅ **Type-Safe** - Full Dart null safety
- ✅ **Pluggable** - Interface-based architecture
- ✅ **Themeable** - Customizable UI components
- ✅ **Well-Documented** - Comprehensive inline docs
- ✅ **Tested** - Unit and widget tests included

## 📦 Installation

Add to your project's `pubspec.yaml`:

```yaml
dependencies:
  supabase_auth:
    path: ../modules/supabase_auth
```

Install dependencies:

```bash
flutter pub get
```

## 🔧 Quick Start

### 1. Set Up Supabase Project

1. Create a project at [supabase.com](https://supabase.com)
2. Enable Email authentication in Authentication → Settings
3. Configure OAuth providers (optional):
   - Go to Authentication → Providers
   - Enable Google, Apple, Facebook, etc.
   - Configure redirect URLs

### 2. Initialize in Your App

```dart
import 'package:supabase_auth/supabase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth repository
  await AuthRepository.initialize(
    SupabaseAuthConfig(
      supabaseUrl: 'YOUR_SUPABASE_URL',
      supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
      enabledProviders: [
        SocialProvider.google,
        SocialProvider.apple,
        SocialProvider.facebook,
      ],
      useSecureStorageForSession: true,
      redirectUrl: 'your-app://auth-callback',
    ),
  );

  runApp(MyApp());
}
```

### 3. Use Authentication

#### Listen to Auth State

```dart
StreamBuilder<AuthResult?>(
  stream: AuthRepository.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      // User is signed in
      return HomeScreen();
    } else {
      // User is not signed in
      return SignInScreen();
    }
  },
)
```

#### Sign Up with Email

```dart
try {
  final result = await AuthRepository.instance.signUpWithEmail(
    email: 'user@example.com',
    password: 'SecurePassword123!',
    metadata: {
      'name': 'John Doe',
    },
  );

  print('Signed up: ${result.user.email}');
} on AuthError catch (e) {
  print('Error: ${e.message}');
}
```

#### Sign In with Email

```dart
try {
  final result = await AuthRepository.instance.signInWithEmail(
    email: 'user@example.com',
    password: 'SecurePassword123!',
  );

  print('Signed in: ${result.user.email}');
} on AuthError catch (e) {
  print('Error: ${e.message}');
}
```

#### Sign In with OAuth

```dart
try {
  final result = await AuthRepository.instance.signInWithOAuth(
    SocialProvider.google,
  );

  print('Signed in with Google: ${result.user.email}');
} on AuthError catch (e) {
  print('Error: ${e.message}');
}
```

#### Magic Link

```dart
try {
  await AuthRepository.instance.signInWithMagicLink(
    email: 'user@example.com',
  );

  // Show message to check email
  print('Magic link sent! Check your email.');
} on AuthError catch (e) {
  print('Error: ${e.message}');
}
```

#### Sign Out

**Simple Sign Out:**
```dart
await AuthRepository.instance.signOut();
```

**With Error Handling:**
```dart
try {
  await AuthRepository.instance.signOut();
  // User signed out successfully
  // Auth state stream will automatically update
} catch (e) {
  print('Sign out error: $e');
}
```

**In a Button:**
```dart
ElevatedButton(
  onPressed: () async {
    await AuthRepository.instance.signOut();
    // Navigation handled by auth state stream
  },
  child: const Text('Sign Out'),
)
```

**With Loading State:**
```dart
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await AuthRepository.instance.signOut();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  },
)
```

### 4. Use Reusable UI

#### Sign In Screen

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ReusableSignInScreen(
      onSignedIn: (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
      onForgotPassword: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReusableForgotPasswordScreen(),
          ),
        );
      },
      onSignUpTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReusableSignUpScreen(),
          ),
        );
      },
    ),
  ),
);
```

#### Sign Up Screen

```dart
ReusableSignUpScreen(
  onSignedUp: (result) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created! Please check your email.'),
      ),
    );
  },
  onError: (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  },
  passwordRequirements: PasswordRequirements.secure,
  requireName: true,
  requireTermsAcceptance: true,
)
```

#### Forgot Password Screen

```dart
ReusableForgotPasswordScreen(
  onEmailSent: () {
    // Show success message
  },
  onError: (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  },
  onBackToSignIn: () {
    Navigator.pop(context);
  },
)
```

#### Protected Routes with Auth Guard

```dart
// Wrap protected content with ReusableAuthGuard
ReusableAuthGuard(
  child: HomeScreen(),
  unauthenticatedWidget: ReusableSignInScreen(
    onSignedIn: (result) {
      // Auth guard will automatically show HomeScreen
    },
  ),
)

// Or with custom unauthenticated screen
ReusableAuthGuard(
  child: ProtectedScreen(),
  onUnauthenticated: () {
    Navigator.pushNamed(context, '/login');
  },
)
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_REDIRECT_URL=your-app://auth-callback
```

Load with:

```dart
final config = SupabaseAuthConfig.fromEnvironment(
  env: dotenv.env,
  enabledProviders: [SocialProvider.google, SocialProvider.apple],
);
```

### Password Requirements

```dart
SupabaseAuthConfig(
  // ...
  passwordRequirements: PasswordRequirements(
    minLength: 10,
    requireUppercase: true,
    requireDigit: true,
    requireSpecialChar: true,
  ),
)
```

### Custom Token Storage

```dart
class MyTokenStorage implements TokenStorage {
  // Implement interface methods
}

await AuthRepository.initialize(
  config,
  tokenStorage: MyTokenStorage(),
);
```

## 🏗️ Platform Setup

### Android

1. Add internet permission in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

2. For OAuth deep links, add intent filter:

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="your-app" android:host="auth-callback" />
</intent-filter>
```

### iOS

1. Add URL scheme in `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>your-app</string>
    </array>
  </dict>
</array>
```

2. For Apple Sign-In, enable capability in Xcode

## 🔐 Security Best Practices

1. **Never commit credentials** - Use environment variables
2. **Use secure storage** - Enable `useSecureStorageForSession: true`
3. **Validate on server** - Client validation is not enough
4. **Use HTTPS** - Always use HTTPS in production
5. **Implement rate limiting** - Protect against brute force
6. **Enable email confirmation** - Set `requireEmailConfirmation: true`
7. **Use strong passwords** - Configure password requirements
8. **Rotate keys** - Regularly update Supabase keys

## 🧪 Testing

Run tests:

```bash
cd modules/supabase_auth
flutter test
```

## 📖 API Reference

### AuthRepository

| Method | Description | Returns |
|--------|-------------|---------|
| `initialize(config)` | Initialize the repository | `Future<AuthRepository>` |
| `authStateChanges()` | Stream of auth state changes | `Stream<AuthResult?>` |
| `signUpWithEmail()` | Sign up with email/password | `Future<AuthResult>` |
| `signInWithEmail()` | Sign in with email/password | `Future<AuthResult>` |
| `signInWithMagicLink()` | Send magic link email | `Future<AuthResult>` |
| `signInWithOAuth()` | Sign in with OAuth provider | `Future<AuthResult>` |
| **`signOut()`** | **Sign out current user & clear session** | `Future<void>` |
| `sendPasswordResetEmail()` | Send password reset email | `Future<void>` |
| `getCurrentSession()` | Get current session | `Future<AuthResult?>` |
| `refreshSession()` | Refresh auth tokens | `Future<AuthResult>` |
| `isSignedIn()` | Check if user is signed in | `Future<bool>` |
| `updateUserMetadata()` | Update user metadata | `Future<AuthResult>` |
| `verifyOtp()` | Verify OTP code | `Future<AuthResult>` |

### Models

#### AuthResult

```dart
class AuthResult {
  final String provider;
  final AuthUser user;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final Map<String, dynamic>? providerData;
}
```

#### AuthUser

```dart
class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final DateTime? confirmedAt;
  final Map<String, dynamic>? metadata;
}
```

#### AuthError

```dart
class AuthError {
  final AuthErrorCode code;
  final String message;
  final SocialProvider? provider;
}
```

## 🔄 Migration Guide

### Adding a New Provider (e.g., Twitter)

1. Add provider to Supabase dashboard
2. Enable in config:
```dart
enabledProviders: [
  // ...
  SocialProvider.twitter,
],
```

3. Provider is automatically supported!

### Switching to Custom Backend

Replace `SupabaseAuthService` with your own implementation:

```dart
class MyAuthService implements AuthService {
  // Implement all interface methods
  // Point to your custom API
}

final authService = MyAuthService();
_instance = AuthRepository._internal(authService);
```

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](../README.md) for guidelines.

## 📞 Support

For issues and questions:
- Check this README
- See [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- Open an issue in the repository

## ✅ Integration Checklist

- [ ] Create Supabase project
- [ ] Configure authentication providers
- [ ] Add environment variables
- [ ] Update Android/iOS configurations
- [ ] Initialize AuthRepository in main.dart
- [ ] Implement auth state listener
- [ ] Add sign-in/sign-up screens
- [ ] Test all auth flows
- [ ] Enable secure token storage
- [ ] Configure password requirements
- [ ] Set up deep linking for OAuth
- [ ] Test on physical devices
- [ ] Review security best practices
