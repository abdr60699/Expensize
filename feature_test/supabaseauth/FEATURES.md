# Supabase Authentication Features

Complete guide to Supabase authentication with email, magic link, and OAuth capabilities.

## Table of Contents

- [Module Overview](#module-overview)
- [Folder Structure](#folder-structure)
- [Core Features](#core-features)
- [Authentication Methods](#authentication-methods)
- [Session Management](#session-management)
- [Use Cases](#use-cases)
- [Feature Matrix](#feature-matrix)

---

## Module Overview

Production-ready Supabase authentication module supporting:
- **Email & Password** authentication
- **Magic Link** passwordless authentication
- **OAuth** providers (Google, Apple, Facebook, GitHub, Twitter)
- **Phone (SMS)** authentication
- **Session management** with automatic refresh
- **Secure token storage** (Keychain/KeyStore)

**Backend:** Powered by Supabase (PostgreSQL + Auth API)

---

## Folder Structure

### Directory Tree

```
lib/supabase_auth/
├── supabase_auth.dart          # Main export file
│
└── src/
    │
    ├── config/                 # ⚙️ Configuration
    │   └── supabase_auth_config.dart
    │       - Supabase URL and keys
    │       - Redirect URLs
    │       - Storage settings
    │
    ├── models/                 # 📦 Data Models
    │   ├── auth_result.dart            # Auth result model
    │   ├── auth_error.dart             # Error types
    │   └── social_provider.dart        # OAuth providers
    │
    ├── services/               # 🔐 Core Services
    │   ├── auth_service.dart            # Abstract service
    │   ├── supabase_auth_service.dart   # Supabase implementation
    │   └── token_storage.dart           # Secure storage
    │
    ├── facade/                 # 🎭 Repository Pattern
    │   └── auth_repository.dart         # Main auth facade
    │
    ├── utils/                  # 🛠️ Utilities
    │   └── validators.dart              # Email/password validators
    │
    └── widgets/                # 🎨 UI Components
        ├── reusable_signin_screen.dart  # Sign-in UI
        ├── reusable_signup_screen.dart  # Sign-up UI
        ├── reusable_forgot_password.dart # Reset password UI
        └── reusable_auth_guard.dart     # Route protection
```

### Key Components

**config/**
- Supabase project configuration
- URL and API keys
- Redirect URLs for OAuth

**models/**
- Auth result data structures
- Error categorization
- Provider enums

**services/**
- Supabase Auth API integration
- Token storage abstraction
- Session management

**facade/**
- Repository pattern implementation
- Simplified API surface
- Business logic layer

**widgets/**
- Pre-built auth screens
- Customizable UI components
- Auth guards for routes

---

## Core Features

### 1. Unified Auth Repository

Single interface for all authentication methods:

```dart
import 'package:supabaseauth/supabase_auth/supabase_auth.dart';

final config = SupabaseAuthConfig(
  supabaseUrl: 'https://xxxxx.supabase.co',
  supabaseAnonKey: 'your-anon-key',
  redirectUrl: 'myapp://auth-callback',
  useSecureStorageForSession: true,
);

final authService = SupabaseAuthService(
  config: config,
  tokenStorage: SecureTokenStorage(),
);
await authService.initialize();

final authRepo = AuthRepository(authService: authService);

// All auth methods through one interface
await authRepo.signUpWithEmail(email, password);
await authRepo.signInWithEmail(email, password);
await authRepo.signInWithMagicLink(email);
await authRepo.signInWithOAuth(SocialProvider.google);
```

---

### 2. Secure Token Storage

Tokens stored securely in platform keychains:

```dart
final tokenStorage = SecureTokenStorage();

// Automatically stores tokens after auth
final session = await authRepo.signInWithEmail(email, password);

// Retrieve session
final currentSession = await authRepo.getCurrentSession();
print('Access token: ${currentSession?.accessToken}');

// Manual token operations
await tokenStorage.saveToken('access_token', session.accessToken);
final token = await tokenStorage.getToken('access_token');
await tokenStorage.deleteToken('access_token');
```

**Security Features:**
- iOS: Keychain storage
- Android: KeyStore with encryption
- Automatic encryption
- Biometric protection (optional)

---

### 3. Automatic Session Refresh

```dart
// Sessions refresh automatically before expiration
final session = await authRepo.getCurrentSession();

if (session != null) {
  print('Session valid until: ${session.expiresAt}');

  // Manual refresh if needed
  final newSession = await authRepo.refreshSession();
  print('New token: ${newSession.accessToken}');
}
```

**Refresh Logic:**
- Automatic refresh before expiration
- Background token renewal
- Seamless user experience
- Error recovery

---

### 4. Auth State Management

```dart
// Listen to auth state changes
authService.authStateChanges.listen((event) {
  if (event.event == 'SIGNED_IN') {
    print('User signed in: ${event.session?.user.email}');
    navigateToHome();
  } else if (event.event == 'SIGNED_OUT') {
    print('User signed out');
    navigateToLogin();
  } else if (event.event == 'TOKEN_REFRESHED') {
    print('Token refreshed');
  }
});
```

**Events:**
- SIGNED_IN
- SIGNED_OUT
- TOKEN_REFRESHED
- USER_UPDATED
- PASSWORD_RECOVERY

---

### 5. Comprehensive Error Handling

```dart
try {
  final result = await authRepo.signInWithEmail(email, password);
} on AuthError catch (e) {
  switch (e.code) {
    case 'invalid_credentials':
      showError('Invalid email or password');
      break;
    case 'email_not_confirmed':
      showError('Please verify your email first');
      break;
    case 'user_not_found':
      showError('No account found with this email');
      break;
    default:
      showError(e.message);
  }
}
```

**Error Categories:**
- Invalid credentials
- Email not confirmed
- User not found
- Network errors
- Rate limiting
- Provider errors

---

## Authentication Methods

### 1. Email & Password

```dart
// Sign up
final result = await authRepo.signUpWithEmail(
  email: 'user@example.com',
  password: 'SecurePass123!',
  metadata: {
    'name': 'John Doe',
    'age': 30,
  },
);

if (result.user != null) {
  print('Account created: ${result.user!.email}');
  print('Please verify your email');
}

// Sign in
final session = await authRepo.signInWithEmail(
  email: 'user@example.com',
  password: 'SecurePass123!',
);

print('Signed in: ${session.user.email}');
print('Access token: ${session.accessToken}');
```

**Features:**
- Secure password hashing (bcrypt)
- Email verification required
- Password strength validation
- Metadata support

---

### 2. Magic Link (Passwordless)

```dart
// Send magic link
await authRepo.signInWithMagicLink(
  email: 'user@example.com',
);

print('Magic link sent! Check your email.');

// Link is automatically handled when user clicks
// Deep linking configured in app
```

**How It Works:**
1. User enters email
2. Magic link sent to email
3. User clicks link in email
4. App opens with auth token
5. User signed in automatically

**Benefits:**
- No password to remember
- Secure one-time links
- Great UX
- Reduces support tickets

---

### 3. OAuth Providers

#### Google

```dart
final result = await authRepo.signInWithOAuth(
  SocialProvider.google,
  scopes: ['email', 'profile'],
);

if (result.user != null) {
  print('Signed in with Google: ${result.user!.email}');
}
```

#### Apple

```dart
final result = await authRepo.signInWithOAuth(
  SocialProvider.apple,
  scopes: ['email', 'name'],
);

if (result.user != null) {
  print('Signed in with Apple: ${result.user!.email}');
}
```

#### Facebook

```dart
final result = await authRepo.signInWithOAuth(
  SocialProvider.facebook,
  scopes: ['email', 'public_profile'],
);
```

#### GitHub

```dart
final result = await authRepo.signInWithOAuth(
  SocialProvider.github,
  scopes: ['user:email'],
);
```

**Supported Providers:**
- ✅ Google
- ✅ Apple
- ✅ Facebook
- ✅ GitHub
- ✅ Twitter
- ✅ GitLab
- ✅ Bitbucket
- ✅ Discord
- ✅ Azure
- ✅ Slack

---

### 4. Phone (SMS) Authentication

```dart
// Send OTP
await authRepo.sendOtp(
  phone: '+1234567890',
);

print('OTP sent to phone');

// Verify OTP
final result = await authRepo.verifyOtp(
  phone: '+1234567890',
  token: '123456',
  type: 'sms',
);

if (result.user != null) {
  print('Signed in via SMS');
}
```

**Features:**
- SMS OTP delivery
- Phone number verification
- International format support
- Configurable OTP length

---

## Session Management

### Get Current Session

```dart
final session = await authRepo.getCurrentSession();

if (session != null) {
  print('User: ${session.user.email}');
  print('Token: ${session.accessToken}');
  print('Expires: ${session.expiresAt}');
} else {
  print('No active session');
}
```

---

### Refresh Session

```dart
// Manual refresh
final newSession = await authRepo.refreshSession();

if (newSession != null) {
  print('Session refreshed');
  print('New token: ${newSession.accessToken}');
}
```

---

### Sign Out

```dart
await authRepo.signOut();
print('Signed out successfully');

// Clears:
// - Access token
// - Refresh token
// - Session data
// - Secure storage
```

---

### Check Sign-In Status

```dart
final isSignedIn = await authRepo.isSignedIn();

if (isSignedIn) {
  navigateToHome();
} else {
  navigateToLogin();
}
```

---

## User Management

### Update Metadata

```dart
await authRepo.updateUserMetadata({
  'name': 'John Updated',
  'avatar_url': 'https://example.com/avatar.jpg',
  'preferences': {
    'theme': 'dark',
    'notifications': true,
  },
});
```

---

### Password Reset

```dart
// Send reset email
await authRepo.sendPasswordResetEmail('user@example.com');
print('Password reset email sent');

// User clicks link in email, redirects to app
// Update password
await authRepo.updatePassword('NewSecurePass123!');
print('Password updated');
```

---

### Email Verification

```dart
// Resend verification email
await authRepo.resendVerificationEmail();

// Check verification status
final session = await authRepo.getCurrentSession();
if (session?.user.emailConfirmedAt != null) {
  print('Email verified!');
} else {
  print('Email not verified');
}
```

---

## Use Cases

### Use Case 1: Standard Email Sign-Up Flow

```dart
class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository(authService: SupabaseAuthService(...));

  Future<void> _signUp() async {
    try {
      final result = await _authRepo.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        metadata: {
          'display_name': _nameController.text,
        },
      );

      if (result.user != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Success!'),
            content: Text('Verification email sent. Please check your inbox.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } on AuthError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Use Case 2: Magic Link Passwordless Auth

```dart
class MagicLinkScreen extends StatelessWidget {
  final _authRepo = AuthRepository(...);
  final _emailController = TextEditingController();

  Future<void> _sendMagicLink() async {
    try {
      await _authRepo.signInWithMagicLink(
        email: _emailController.text,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Check Your Email'),
          content: Text('We sent you a magic link. Click it to sign in.'),
        ),
      );
    } on AuthError catch (e) {
      showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
          ),
          ElevatedButton(
            onPressed: _sendMagicLink,
            child: Text('Send Magic Link'),
          ),
        ],
      ),
    );
  }
}
```

---

### Use Case 3: Social Sign-In

```dart
class SocialLoginScreen extends StatelessWidget {
  final _authRepo = AuthRepository(...);

  Future<void> _signInWith(SocialProvider provider) async {
    try {
      final result = await _authRepo.signInWithOAuth(provider);

      if (result.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on AuthError catch (e) {
      showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text('Continue with Google'),
              onPressed: () => _signInWith(SocialProvider.google),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.apple),
              label: Text('Continue with Apple'),
              onPressed: () => _signInWith(SocialProvider.apple),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.facebook),
              label: Text('Continue with Facebook'),
              onPressed: () => _signInWith(SocialProvider.facebook),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Use Case 4: Auth Guard (Protected Routes)

```dart
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final _authRepo = AuthRepository(...);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authRepo.isSignedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.data == true) {
          return child; // User is signed in
        }

        // Redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        });

        return SizedBox();
      },
    );
  }
}

// Usage
MaterialApp(
  routes: {
    '/home': (context) => ProtectedRoute(child: HomeScreen()),
    '/profile': (context) => ProtectedRoute(child: ProfileScreen()),
  },
);
```

---

## Feature Matrix

### Authentication Methods

| Method | Supported | Platform | Notes |
|--------|-----------|----------|-------|
| Email/Password | ✅ | All | Requires email verification |
| Magic Link | ✅ | All | Passwordless |
| Google OAuth | ✅ | All | Most popular |
| Apple OAuth | ✅ | All | Required for iOS |
| Facebook OAuth | ✅ | All | - |
| GitHub OAuth | ✅ | All | Developer-friendly |
| Twitter OAuth | ✅ | All | - |
| Phone (SMS) | ✅ | All | Via Supabase |
| Anonymous | ⚠️ | All | Requires custom implementation |

---

### Features

| Feature | Supported | Implementation |
|---------|-----------|----------------|
| Email verification | ✅ | Automatic |
| Password reset | ✅ | Email-based |
| Session management | ✅ | Automatic |
| Token refresh | ✅ | Automatic |
| Secure storage | ✅ | Keychain/KeyStore |
| Row-level security | ✅ | Supabase RLS |
| User metadata | ✅ | JSON field |
| Multi-factor auth | ⚠️ | Supabase Pro |
| SSO | ⚠️ | Supabase Enterprise |

---

### Platform Support

| Platform | Supported | Notes |
|----------|-----------|-------|
| iOS | ✅ | Full support |
| Android | ✅ | Full support |
| Web | ✅ | Full support |
| macOS | ✅ | Full support |
| Linux | ✅ | Full support |
| Windows | ✅ | Full support |

---

**Ready to build secure authentication with Supabase!**
