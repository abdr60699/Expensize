# Supabase Authentication Module

Production-ready Supabase authentication module for Flutter with email/password, magic link, OAuth, and comprehensive session management.

## Features

### 🔐 Authentication Methods

- **Email & Password** - Traditional authentication with secure password hashing
- **Magic Link** - Passwordless authentication via one-time email links
- **OAuth Providers** - Google, Apple, Facebook, GitHub, Twitter social sign-in
- **Phone (SMS)** - SMS OTP authentication (via Supabase)

### 🔒 Security

- Secure token storage using `flutter_secure_storage`
- Automatic session management and refresh
- Row-level security (RLS) support
- PKCE flow for enhanced security
- Token encryption at rest

### 🎯 Key Capabilities

- Email verification
- Password reset flows
- User metadata management
- Session persistence
- Reusable UI widgets
- Comprehensive error handling

## Quick Start

### 1. Installation

```yaml
dependencies:
  supabase_flutter: ^2.10.3
  flutter_secure_storage: ^9.2.4
```

### 2. Setup Supabase Project

1. Create project at https://supabase.com
2. Get credentials from Project Settings > API:
   - Project URL
   - Anon/Public Key
3. Enable auth providers in Authentication > Providers

### 3. Basic Usage

```dart
import 'package:supabaseauth/supabase_auth/supabase_auth.dart';

// Configure
final config = SupabaseAuthConfig(
  supabaseUrl: 'https://xxxxx.supabase.co',
  supabaseAnonKey: 'your-anon-key',
  redirectUrl: 'your-app://auth-callback',
  useSecureStorageForSession: true,
);

// Initialize
final authService = SupabaseAuthService(
  config: config,
  tokenStorage: SecureTokenStorage(),
);
await authService.initialize();

// Create repository
final authRepo = AuthRepository(authService: authService);

// Sign up
final result = await authRepo.signUpWithEmail(
  email: 'user@example.com',
  password: 'secure-password',
);

// Sign in
final session = await authRepo.signInWithEmail(
  email: 'user@example.com',
  password: 'secure-password',
);

// Magic link
await authRepo.signInWithMagicLink(email: 'user@example.com');

// OAuth
final oauthResult = await authRepo.signInWithOAuth(SocialProvider.google);

// Sign out
await authRepo.signOut();
```

## Configuration

### Environment Setup

```dart
final config = SupabaseAuthConfig(
  supabaseUrl: 'YOUR_PROJECT_URL',
  supabaseAnonKey: 'YOUR_ANON_KEY',
  redirectUrl: 'your-app://auth-callback',  // For OAuth/magic links
  useSecureStorageForSession: true,
);
```

### OAuth Providers

Enable providers in Supabase Dashboard:
- Authentication > Providers
- Configure each provider (Google, Apple, Facebook, etc.)
- Add OAuth credentials and callback URLs

## API Reference

### AuthRepository

Main interface for authentication operations.

**Methods:**
- `signUpWithEmail(email, password, metadata)` - Create new account
- `signInWithEmail(email, password)` - Sign in with credentials
- `signInWithMagicLink(email)` - Send magic link to email
- `signInWithOAuth(provider, scopes)` - OAuth sign-in
- `sendPasswordResetEmail(email)` - Send password reset email
- `verifyOtp(email, token, type)` - Verify OTP token
- `updateUserMetadata(metadata)` - Update user profile
- `refreshSession()` - Refresh access token
- `getCurrentSession()` - Get current session
- `signOut()` - Sign out user
- `isSignedIn()` - Check sign-in status

### AuthResult

Contains authentication result data.

**Properties:**
- `provider` - Authentication provider used
- `user` - User information (AuthUser)
- `accessToken` - JWT access token
- `refreshToken` - Refresh token
- `expiresAt` - Token expiration time
- `providerData` - Provider-specific metadata
- `timestamp` - Result timestamp

### AuthUser

User profile information.

**Properties:**
- `id` - Unique user ID
- `email` - User email address
- `name` - Display name
- `avatarUrl` - Profile picture URL
- `confirmedAt` - Email confirmation timestamp
- `metadata` - Custom user metadata

## Reusable Widgets

### ReusableSignInScreen

Pre-built sign-in screen with email/password.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReusableSignInScreen(
      authRepository: authRepo,
      onSuccess: (result) {
        // Handle successful sign-in
      },
      showSocialSignIn: true,
    ),
  ),
);
```

### ReusableSignUpScreen

Pre-built sign-up screen.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReusableSignUpScreen(
      authRepository: authRepo,
      onSuccess: (result) {
        // Handle successful sign-up
      },
    ),
  ),
);
```

### ReusableForgotPassword

Password reset screen.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReusableForgotPassword(
      authRepository: authRepo,
    ),
  ),
);
```

### ReusableAuthGuard

Protect routes requiring authentication.

```dart
ReusableAuthGuard(
  authRepository: authRepo,
  authenticatedChild: HomeScreen(),
  unauthenticatedChild: SignInScreen(),
)
```

## Example App

Run the included demo:

```bash
cd /home/user/Expensize/feature_test/supabaseauth
flutter pub get
flutter run
```

The demo shows:
- Email/password authentication
- Magic link flow
- OAuth with 5 providers
- Session management
- User profile display

## Platform Support

| Platform | Email/Password | Magic Link | OAuth | Phone |
|----------|---------------|------------|-------|-------|
| Android  | ✅            | ✅         | ✅    | ✅    |
| iOS      | ✅            | ✅         | ✅    | ✅    |
| Web      | ✅            | ✅         | ✅    | ✅    |
| macOS    | ✅            | ✅         | ✅    | ✅    |
| Linux    | ✅            | ✅         | ✅    | ✅    |
| Windows  | ✅            | ✅         | ✅    | ✅    |

## Error Handling

```dart
try {
  final result = await authRepo.signInWithEmail(
    email: email,
    password: password,
  );
} on AuthError catch (e) {
  switch (e.code) {
    case AuthErrorCode.invalidCredentials:
      print('Invalid email or password');
      break;
    case AuthErrorCode.emailNotConfirmed:
      print('Please verify your email');
      break;
    case AuthErrorCode.userNotFound:
      print('User does not exist');
      break;
    case AuthErrorCode.networkError:
      print('Network error: ${e.message}');
      break;
    default:
      print('Error: ${e.message}');
  }
}
```

## Security Best Practices

### ✅ DO
- Store tokens securely using `flutter_secure_storage`
- Enable Row Level Security (RLS) in Supabase
- Validate tokens on backend
- Use HTTPS for all requests
- Implement proper session management
- Enable email verification
- Use strong password requirements

### ❌ DON'T
- Store credentials in plain text
- Commit API keys to version control
- Trust client-side authentication alone
- Use weak passwords
- Share tokens between apps
- Disable email verification in production

## Troubleshooting

**Supabase not initialized**
- Ensure you call `await authService.initialize()` before using
- Check credentials are correct (URL and anon key)

**OAuth redirect fails**
- Configure redirect URL in Supabase Dashboard
- Match redirect URL in app deep linking
- Check OAuth provider configuration

**Magic link not working**
- Verify email template is enabled in Supabase
- Check spam folder
- Confirm redirect URL is configured

**Session expires immediately**
- Check token refresh is enabled
- Verify system clock is accurate
- Ensure secure storage is working

## License

MIT License - See LICENSE file

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Authentication Guide](https://supabase.com/docs/guides/auth)

---

**Last Updated**: November 16, 2025
**Version**: 1.0.0
**Flutter SDK**: 3.4.1+
**Supabase Flutter**: 2.10.3
