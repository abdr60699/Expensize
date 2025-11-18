# Social Authentication Features

Complete guide to Google, Apple, and Facebook authentication capabilities.

## Table of Contents

- [Module Overview](#module-overview)
- [Folder Structure](#folder-structure)
- [Core Features](#core-features)
- [Provider Features](#provider-features)
- [Integration Options](#integration-options)
- [Use Cases](#use-cases)
- [Feature Matrix](#feature-matrix)

---

## Module Overview

Production-ready social authentication module supporting:
- **Google Sign-In** (iOS, Android, Web)
- **Apple Sign-In** (iOS, Android, Web)
- **Facebook Login** (iOS, Android, Web)

**Integration Options:**
- Firebase Authentication
- REST API backend
- Standalone (token storage only)

**Security:**
- Secure token storage (Keychain/KeyStore)
- OAuth 2.0 standard
- Token encryption
- HTTPS only

---

## Folder Structure

### Directory Tree

```
lib/
└── social_auth/
    ├── social_auth.dart           # Main entry point
    ├── social_auth_exports.dart   # All exports
    │
    ├── src/
    │   │
    │   ├── adapters/              # 🔌 Provider Adapters
    │   │   ├── base_auth_adapter.dart          # Abstract interface
    │   │   ├── google_auth_adapter.dart        # Google Sign-In
    │   │   ├── apple_auth_adapter.dart         # Apple Sign-In
    │   │   └── facebook_auth_adapter.dart      # Facebook Login
    │   │
    │   ├── core/                  # 🔧 Core Types
    │   │   ├── social_provider.dart            # Provider enum
    │   │   ├── auth_result.dart                # Result model
    │   │   ├── social_auth_error.dart          # Error types
    │   │   ├── auth_service.dart               # Backend interface
    │   │   ├── token_storage.dart              # Storage interface
    │   │   └── logger.dart                     # Logging interface
    │   │
    │   ├── services/              # 🔐 Backend Services
    │   │   ├── social_auth_manager.dart        # Main auth manager
    │   │   ├── firebase_auth_service.dart      # Firebase integration
    │   │   └── rest_api_auth_service.dart      # REST API integration
    │   │
    │   └── widgets/               # 🎨 UI Components
    │       ├── social_sign_in_button.dart      # Single provider button
    │       └── social_sign_in_row.dart         # Multi-provider buttons
```

### Key Components

**adapters/**
- Abstract interface for all providers
- Platform-specific implementations
- Google, Apple, Facebook adapters

**core/**
- Core data types and interfaces
- Provider enum and error types
- Token storage abstraction
- Backend service interface

**services/**
- Main SocialAuthManager
- Firebase integration
- REST API integration
- Extensible for custom backends

**widgets/**
- Pre-built sign-in buttons
- Customizable UI components
- Multi-provider layout

---

## Core Features

### 1. Unified API

Single API across all providers:

```dart
import 'package:socialauth/social_auth/social_auth.dart';

// Initialize
final socialAuth = SocialAuth(
  authService: FirebaseAuthService(),
  tokenStorage: SecureTokenStorage(),
  logger: ConsoleLogger(),
  enableGoogle: true,
  enableApple: true,
  enableFacebook: true,
);

// Google Sign-In
final googleResult = await socialAuth.signInWithGoogle();

// Apple Sign-In
final appleResult = await socialAuth.signInWithApple();

// Facebook Login
final facebookResult = await socialAuth.signInWithFacebook();
```

**Benefits:**
- Consistent API across providers
- Easy to switch providers
- Simplified error handling
- Platform abstraction

---

### 2. Secure Token Storage

```dart
// Tokens stored securely in Keychain/KeyStore
final storage = SecureTokenStorage();

// Store token
await storage.saveToken(
  provider: SocialProvider.google,
  token: 'access_token_here',
);

// Retrieve token
final token = await storage.getToken(SocialProvider.google);

// Delete token
await storage.deleteToken(SocialProvider.google);

// Delete all tokens
await storage.deleteAllTokens();
```

**Security Features:**
- iOS: Keychain storage
- Android: KeyStore with encryption
- Automatic token encryption
- Biometric protection (optional)

---

### 3. Provider Flexibility

Choose your backend integration:

```dart
// Option 1: Firebase Authentication
final socialAuth = SocialAuth(
  authService: FirebaseAuthService(),
  // ...
);

// Option 2: REST API
final socialAuth = SocialAuth(
  authService: RestApiAuthService(
    baseUrl: 'https://api.yourapp.com',
    endpoints: AuthEndpoints(
      signIn: '/auth/social/signin',
      signOut: '/auth/signout',
    ),
  ),
  // ...
);

// Option 3: No backend (standalone)
final socialAuth = SocialAuth(
  authService: null,  // No backend
  tokenStorage: SecureTokenStorage(),
  // ...
);
```

---

### 4. Error Handling

Comprehensive error categorization:

```dart
try {
  final result = await socialAuth.signInWithGoogle();

  if (result.isSuccess) {
    print('Signed in: ${result.user.email}');
  } else {
    // Handle specific errors
    switch (result.error?.code) {
      case 'user_cancelled':
        print('User cancelled sign-in');
        break;
      case 'network_error':
        print('No internet connection');
        break;
      case 'account_exists_with_different_credential':
        print('Email already used with different provider');
        break;
      default:
        print('Error: ${result.error?.message}');
    }
  }
} on SocialAuthException catch (e) {
  print('Auth error: ${e.message}');
}
```

**Error Types:**
- User cancelled
- Network errors
- Account conflicts
- Platform errors
- Provider-specific errors

---

### 5. Logging

Built-in logging system:

```dart
// Console logger (development)
final logger = ConsoleLogger(
  logLevel: LogLevel.verbose,
);

// Custom logger (production)
class AnalyticsLogger implements AuthLogger {
  @override
  void log(String message, {LogLevel level = LogLevel.info}) {
    // Send to analytics service
    analytics.logEvent(message, level: level.toString());
  }
}

final socialAuth = SocialAuth(
  logger: AnalyticsLogger(),
  // ...
);
```

**Log Levels:**
- verbose: Everything
- info: Important events
- warning: Warnings
- error: Errors only
- none: No logging

---

## Provider Features

### Google Sign-In

```dart
final result = await socialAuth.signInWithGoogle(
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.readonly',
  ],
  hostedDomain: 'yourcompany.com',  // Optional: Restrict to domain
);

if (result.isSuccess) {
  final user = result.user;
  print('Name: ${user.displayName}');
  print('Email: ${user.email}');
  print('Photo: ${user.photoUrl}');
  print('ID: ${user.id}');

  // Access token for API calls
  final token = await storage.getToken(SocialProvider.google);
}
```

**Features:**
- OAuth 2.0 authentication
- Custom scopes (email, profile, drive, etc.)
- Server auth code support
- Account selection
- Multi-account support
- Automatic token refresh
- Hosted domain restriction

**Platforms:**
- ✅ iOS
- ✅ Android
- ✅ Web
- ⚠️ macOS (with configuration)

---

### Apple Sign-In

```dart
final result = await socialAuth.signInWithApple(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);

if (result.isSuccess) {
  final user = result.user;
  print('Name: ${user.displayName}');  // Only on first sign-in
  print('Email: ${user.email}');       // May be relay email
  print('ID: ${user.id}');

  // Apple provides name only on first sign-in
  // Store it for future use
}
```

**Features:**
- Native iOS/macOS support
- Web authentication flow (Android/Web)
- Privacy-focused (email relay)
- First-time user data capture
- Credential management
- Platform availability detection

**Platforms:**
- ✅ iOS 13+
- ✅ macOS 10.15+
- ✅ Android (via web flow)
- ✅ Web

**Privacy:**
- Email relay option (hide real email)
- Name only provided once
- Minimal data sharing

---

### Facebook Login

```dart
final result = await socialAuth.signInWithFacebook(
  permissions: [
    'email',
    'public_profile',
    'user_friends',
  ],
);

if (result.isSuccess) {
  final user = result.user;
  print('Name: ${user.displayName}');
  print('Email: ${user.email}');
  print('Photo: ${user.photoUrl}');

  // Access token for Facebook API
  final token = await storage.getToken(SocialProvider.facebook);

  // Get additional profile data
  final profile = await FacebookAuth.instance.getUserData();
  print('Birthday: ${profile['birthday']}');
}
```

**Features:**
- OAuth 2.0 authentication
- Customizable permissions
- Profile data access
- Access token management
- Token expiration tracking
- Account linking/unlinking

**Platforms:**
- ✅ iOS
- ✅ Android
- ✅ Web

**Permissions:**
- email
- public_profile
- user_friends
- user_birthday
- user_location
- [Full list in docs]

---

## Integration Options

### Option 1: Firebase Integration

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:socialauth/social_auth/social_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final socialAuth = SocialAuth(
    authService: FirebaseAuthService(),
    tokenStorage: SecureTokenStorage(),
    enableGoogle: true,
    enableApple: true,
    enableFacebook: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(socialAuth: socialAuth),
    );
  }
}
```

**Benefits:**
- Unified user management
- Built-in user database
- Easy account linking
- Real-time auth state
- Server-side verification

---

### Option 2: REST API Integration

```dart
final socialAuth = SocialAuth(
  authService: RestApiAuthService(
    baseUrl: 'https://api.yourapp.com',
    endpoints: AuthEndpoints(
      signIn: '/auth/social/signin',
      signOut: '/auth/signout',
      getProfile: '/auth/profile',
    ),
    httpClient: http.Client(),
  ),
  tokenStorage: SecureTokenStorage(),
);

// Backend receives social tokens and creates session
final result = await socialAuth.signInWithGoogle();

if (result.isSuccess) {
  // Backend has created session
  // Token stored securely
}
```

**Backend Endpoints:**

POST `/auth/social/signin`
```json
{
  "provider": "google",
  "accessToken": "ya29...",
  "idToken": "eyJhbGc...",
  "userId": "12345",
  "email": "user@example.com"
}
```

Response:
```json
{
  "sessionToken": "sess_abc123",
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

---

### Option 3: Standalone Mode

```dart
// No backend required
final socialAuth = SocialAuth(
  authService: null,  // No backend
  tokenStorage: SecureTokenStorage(),
);

// Just get tokens and user info
final result = await socialAuth.signInWithGoogle();

if (result.isSuccess) {
  // Tokens stored securely
  // Use tokens for your own API calls
  final token = await SecureTokenStorage().getToken(SocialProvider.google);

  // Make authenticated requests
  final response = await http.get(
    Uri.parse('https://www.googleapis.com/drive/v3/files'),
    headers: {'Authorization': 'Bearer $token'},
  );
}
```

---

## Use Cases

### Use Case 1: Quick Social Login

```dart
class LoginScreen extends StatelessWidget {
  final SocialAuth socialAuth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign in with', style: TextStyle(fontSize: 20)),
            SizedBox(height: 24),

            // Pre-built button row
            SocialSignInRow(
              onGooglePressed: () => _signIn(SocialProvider.google),
              onApplePressed: () => _signIn(SocialProvider.apple),
              onFacebookPressed: () => _signIn(SocialProvider.facebook),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn(SocialProvider provider) async {
    AuthResult result;

    switch (provider) {
      case SocialProvider.google:
        result = await socialAuth.signInWithGoogle();
        break;
      case SocialProvider.apple:
        result = await socialAuth.signInWithApple();
        break;
      case SocialProvider.facebook:
        result = await socialAuth.signInWithFacebook();
        break;
      default:
        return;
    }

    if (result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!.message)),
      );
    }
  }
}
```

---

### Use Case 2: Account Linking

```dart
// User signed in with Google, now wants to link Facebook
class ProfileScreen extends StatelessWidget {
  Future<void> _linkFacebook() async {
    final result = await socialAuth.signInWithFacebook();

    if (result.isSuccess) {
      // Both Google and Facebook are now linked
      // Backend should merge accounts

      showSuccess('Facebook account linked!');
    } else {
      if (result.error?.code == 'account_exists_with_different_credential') {
        showError('This email is already used with another account');
      } else {
        showError(result.error?.message ?? 'Failed to link account');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _linkFacebook,
      child: Text('Link Facebook'),
    );
  }
}
```

---

### Use Case 3: Silent Sign-In

```dart
// Check if user has valid session on app start
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Check for stored tokens
    final googleToken = await SecureTokenStorage().getToken(SocialProvider.google);
    final appleToken = await SecureTokenStorage().getToken(SocialProvider.apple);
    final facebookToken = await SecureTokenStorage().getToken(SocialProvider.facebook);

    if (googleToken != null) {
      // Try silent Google sign-in
      final result = await GoogleAuthAdapter().silentSignIn();
      if (result.isSuccess) {
        _navigateToHome();
        return;
      }
    }

    // No valid session, show login
    _navigateToLogin();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

---

### Use Case 4: Custom Scopes (Google Drive Access)

```dart
// Request Google Drive access
final result = await socialAuth.signInWithGoogle(
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.readonly',
    'https://www.googleapis.com/auth/drive.file',
  ],
);

if (result.isSuccess) {
  // Get access token
  final token = await SecureTokenStorage().getToken(SocialProvider.google);

  // List user's Drive files
  final response = await http.get(
    Uri.parse('https://www.googleapis.com/drive/v3/files'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final files = json.decode(response.body)['files'];
    print('Drive files: $files');
  }
}
```

---

## Feature Matrix

### Provider Support

| Feature | Google | Apple | Facebook |
|---------|--------|-------|----------|
| iOS | ✅ | ✅ | ✅ |
| Android | ✅ | ⚠️ (web flow) | ✅ |
| Web | ✅ | ✅ | ✅ |
| macOS | ⚠️ | ✅ | ⚠️ |
| OAuth 2.0 | ✅ | ✅ | ✅ |
| Custom scopes | ✅ | ✅ | ✅ |
| Profile data | ✅ | ⚠️ (limited) | ✅ |
| Silent sign-in | ✅ | ✅ | ✅ |
| Sign out | ✅ | ✅ | ✅ |
| Token refresh | ✅ | ✅ | ✅ |

**Legend:**
- ✅ Fully supported
- ⚠️ Limited support or requires configuration
- ❌ Not supported

---

### Integration Options

| Feature | Firebase | REST API | Standalone |
|---------|----------|----------|------------|
| User management | ✅ | ⚠️ (custom) | ❌ |
| Account linking | ✅ | ⚠️ (custom) | ❌ |
| Real-time auth state | ✅ | ❌ | ❌ |
| Server verification | ✅ | ✅ | ❌ |
| Token storage | ✅ | ✅ | ✅ |
| Offline support | ⚠️ | ❌ | ✅ |

---

### Security Features

| Feature | Supported | Implementation |
|---------|-----------|----------------|
| Secure token storage | ✅ | Keychain/KeyStore |
| Token encryption | ✅ | AES-256 |
| OAuth 2.0 | ✅ | All providers |
| HTTPS only | ✅ | Enforced |
| Biometric protection | ⚠️ | Optional |
| Token expiration | ✅ | Automatic |
| Refresh tokens | ✅ | Provider-dependent |

---

**Ready to implement social authentication!**
