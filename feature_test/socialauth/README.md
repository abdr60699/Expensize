# Social Authentication Module

Production-ready social authentication module for Flutter applications supporting Google, Apple, and Facebook sign-in with Firebase and REST API integration.

## Features

### 🔐 Supported Providers

#### Google Sign-In
- **All platforms** (iOS, Android, Web)
- OAuth 2.0 authentication flow
- Customizable scopes (email, profile, drive, etc.)
- Server auth code support for backend integration
- Account selection and multi-account support
- Automatic token refresh

#### Apple Sign-In
- **iOS 13+ & macOS 10.15+** native support
- **Android & Web** via web authentication flow
- Privacy-focused (email relay option)
- First-time user data capture
- Credential management and validation
- Platform availability detection

#### Facebook Login
- **All platforms** (iOS, Android, Web)
- Customizable permissions (email, public_profile, friends, etc.)
- Profile data access (name, email, picture)
- Access token management
- Token expiration tracking
- Account linking and unlinking

### 🔒 Security Features

- **Secure Token Storage** - Uses `flutter_secure_storage` (Keychain/KeyStore)
- **Token Encryption** - Tokens encrypted at rest
- **OAuth 2.0 Standard** - Industry-standard authentication
- **HTTPS Only** - All API calls over secure connections
- **No Credential Storage** - Credentials never stored in code
- **Platform Security** - Leverages iOS Keychain and Android KeyStore

### 🔧 Integration Options

- **Firebase Integration** - Optional Firebase Auth for unified user management
- **REST API Integration** - Direct backend integration via HTTP client
- **Standalone Mode** - Use without any backend (token storage only)
- **Flexible Architecture** - Easily swap authentication backends

## Quick Start

### 1. Installation

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  # Core Flutter
  flutter:
    sdk: flutter

  # Social Authentication
  google_sign_in: ^7.2.0
  sign_in_with_apple: ^7.0.1
  flutter_facebook_auth: ^7.1.2

  # Security
  flutter_secure_storage: ^9.2.4

  # Optional - Firebase Integration
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2

  # Optional - REST API Integration
  http: ^1.6.0
```

Then run:
```bash
flutter pub get
```

### 2. Basic Usage

```dart
import 'package:socialauth/social_auth/social_auth.dart';

// Initialize
final socialAuth = SocialAuth(
  authService: FirebaseAuthService(),  // Optional
  tokenStorage: SecureTokenStorage(),
  logger: ConsoleLogger(),
  enableGoogle: true,
  enableApple: true,
  enableFacebook: true,
);

// Sign in with Google
try {
  final result = await socialAuth.signInWithGoogle();
  print('Signed in: ${result.user.email}');
  print('Access Token: ${result.accessToken}');
} on SocialAuthError catch (e) {
  print('Error: ${e.message}');
}

// Sign in with Apple
final appleResult = await socialAuth.signInWithApple();

// Sign in with Facebook
final fbResult = await socialAuth.signInWithFacebook();

// Sign out
await socialAuth.signOut();
```

### 3. With Firebase Integration

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:socialauth/social_auth/social_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SocialAuth with Firebase
  SocialAuth.initialize(
    authService: FirebaseAuthService(),
    enableGoogle: true,
    googleScopes: ['email', 'profile'],
    enableApple: true,
    appleClientId: 'com.yourapp.service',
    appleRedirectUri: 'https://yourapp.com/auth/callback',
    enableFacebook: true,
    facebookPermissions: ['email', 'public_profile'],
  );

  runApp(MyApp());
}

// Use singleton instance
final result = await SocialAuth.instance.signInWithGoogle();
```

### 4. Standalone (No Firebase)

```dart
// Use without Firebase
final socialAuth = SocialAuth(
  // No authService - tokens stored locally only
  tokenStorage: SecureTokenStorage(),
  logger: ConsoleLogger(),
  enableGoogle: true,
  enableApple: true,
  enableFacebook: true,
);

// Sign in and get tokens
final result = await socialAuth.signInWithGoogle();

// Send tokens to your backend
await yourBackendApi.authenticate(
  accessToken: result.accessToken,
  idToken: result.idToken,
  provider: result.provider.id,
);
```

## Configuration

### Google Sign-In Setup

#### Android
1. Get your SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
   ```
2. Add SHA-1 to Firebase Console (if using Firebase)
3. Download `google-services.json` → `android/app/`

#### iOS
1. Download `GoogleService-Info.plist` → `ios/Runner/`
2. Add URL scheme to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

#### Web
1. Create OAuth 2.0 Client ID in Google Cloud Console
2. Add authorized JavaScript origins
3. Configure redirect URIs

**See:** [Google Sign-In Flutter Package](https://pub.dev/packages/google_sign_in)

### Apple Sign-In Setup

#### iOS/macOS
1. Enable "Sign in with Apple" capability in Xcode
2. Configure App ID in Apple Developer Portal
3. Create Sign in with Apple key (for backend verification)

#### Android/Web
1. Create Service ID in Apple Developer Portal
2. Configure return URLs
3. Set client ID and redirect URI:
   ```dart
   SocialAuth(
     enableApple: true,
     appleClientId: 'com.yourapp.service',
     appleRedirectUri: 'https://yourapp.com/auth/callback',
   )
   ```

**See:** [Sign in with Apple](https://pub.dev/packages/sign_in_with_apple)

### Facebook Login Setup

#### Create Facebook App
1. Go to https://developers.facebook.com
2. Create new app
3. Add platforms (iOS, Android, Web)
4. Get App ID and Client Token

#### Android
Add to `android/app/src/main/res/values/strings.xml`:
```xml
<string name="facebook_app_id">YOUR_APP_ID</string>
<string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
```

Add to `AndroidManifest.xml`:
```xml
<meta-data
  android:name="com.facebook.sdk.ApplicationId"
  android:value="@string/facebook_app_id"/>
<meta-data
  android:name="com.facebook.sdk.ClientToken"
  android:value="@string/facebook_client_token"/>
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR_APP_ID</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>YOUR_APP_ID</string>
<key>FacebookDisplayName</key>
<string>YourAppName</string>
```

**See:** [Facebook Login Flutter Package](https://pub.dev/packages/flutter_facebook_auth)

## Advanced Usage

### Custom Scopes

```dart
// Google with custom scopes
final result = await socialAuth.signInWithGoogle(
  scopes: ['email', 'profile', 'https://www.googleapis.com/auth/drive.file'],
);

// Apple with custom scopes
final appleResult = await socialAuth.signInWithApple(
  scopes: ['email', 'name'],  // 'email' and 'name' only
);

// Facebook with custom permissions
final fbResult = await socialAuth.signInWithFacebook(
  scopes: ['email', 'public_profile', 'user_friends'],
);
```

### Checking Platform Support

```dart
// Check if provider is supported on current platform
if (socialAuth.isPlatformSupported(SocialProvider.apple)) {
  // Show Apple sign-in button
}

// Get list of available providers
final available = socialAuth.availableProviders;
// [SocialProvider.google, SocialProvider.apple, SocialProvider.facebook]

// Get list of configured providers
final configured = socialAuth.configuredProviders;
```

### Checking Sign-In Status

```dart
// Check if signed in with specific provider
final isGoogleSignedIn = await socialAuth.isSignedIn(SocialProvider.google);
final isFacebookSignedIn = await socialAuth.isSignedIn(SocialProvider.facebook);

if (isGoogleSignedIn) {
  // User already signed in with Google
}
```

### Account Linking (Firebase Only)

```dart
// With FirebaseAuthService
final firebaseService = FirebaseAuthService();

// First, sign in with one provider
final googleResult = await socialAuth.signInWithGoogle();
final authData = await firebaseService.authenticateWithProvider(googleResult);

// Then link another provider to same Firebase account
final facebookResult = await socialAuth.signInWithFacebook();
final linkData = await firebaseService.linkProvider(facebookResult);

if (linkData['success']) {
  print('Accounts linked!');
}
```

### Custom Token Storage

```dart
// Implement custom token storage
class CustomTokenStorage implements TokenStorage {
  @override
  Future<void> saveToken(String key, String value) async {
    // Your implementation
  }

  @override
  Future<String?> readToken(String key) async {
    // Your implementation
  }

  @override
  Future<void> deleteToken(String key) async {
    // Your implementation
  }

  @override
  Future<void> deleteAll() async {
    // Your implementation
  }

  @override
  Future<bool> hasToken(String key) async {
    // Your implementation
  }
}

// Use custom storage
final socialAuth = SocialAuth(
  tokenStorage: CustomTokenStorage(),
);
```

### Custom Authentication Service

```dart
// Implement custom auth service
class MyBackendAuthService implements AuthService {
  final http.Client client;

  MyBackendAuthService(this.client);

  @override
  Future<Map<String, dynamic>> authenticateWithProvider(
    AuthResult authResult,
  ) async {
    // Send tokens to your backend
    final response = await client.post(
      Uri.parse('https://your-api.com/auth/social'),
      body: {
        'provider': authResult.provider.id,
        'access_token': authResult.accessToken,
        'id_token': authResult.idToken,
      },
    );

    return jsonDecode(response.body);
  }

  @override
  Future<void> signOut() async {
    // Sign out from your backend
  }

  @override
  Future<bool> isAuthenticated() async {
    // Check authentication status
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    // Get current user from backend
  }
}

// Use custom service
final socialAuth = SocialAuth(
  authService: MyBackendAuthService(http.Client()),
);
```

### Error Handling

```dart
try {
  final result = await socialAuth.signInWithGoogle();
  // Success
} on SocialAuthError catch (e) {
  switch (e.code) {
    case SocialAuthErrorCode.userCancelled:
      print('User cancelled sign-in');
      break;
    case SocialAuthErrorCode.networkError:
      print('Network error: ${e.message}');
      break;
    case SocialAuthErrorCode.platformNotSupported:
      print('Platform not supported');
      break;
    case SocialAuthErrorCode.providerError:
      print('Provider error: ${e.message}');
      break;
    default:
      print('Unknown error: ${e.message}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

### Custom Logger

```dart
class MyLogger implements SocialAuthLogger {
  @override
  void info(String message) {
    // Log to your analytics service
  }

  @override
  void warning(String message) {
    // Log warning
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    // Log error with stack trace
  }
}

final socialAuth = SocialAuth(
  logger: MyLogger(),
);
```

## API Reference

### SocialAuth

Main facade for social authentication.

**Methods:**
- `signInWithGoogle({scopes, parameters})` - Sign in with Google
- `signInWithApple({scopes, parameters})` - Sign in with Apple
- `signInWithFacebook({scopes, parameters})` - Sign in with Facebook
- `signOut()` - Sign out from all providers
- `isSignedIn(provider)` - Check if signed in with provider
- `isPlatformSupported(provider)` - Check platform support

**Properties:**
- `configuredProviders` - List of configured providers
- `availableProviders` - List of available providers for current platform

### AuthResult

Authentication result containing user data and tokens.

**Properties:**
- `provider` - Social provider (google, apple, facebook)
- `user` - User information (id, email, name, avatar)
- `accessToken` - OAuth access token
- `idToken` - ID token (Google, Apple)
- `authorizationCode` - Authorization code (Apple, Google server auth)
- `providerData` - Additional provider-specific data

### SocialUser

User information from social provider.

**Properties:**
- `id` - Unique user ID from provider
- `email` - User email (may be null for Apple)
- `name` - Full name
- `firstName` - First name
- `lastName` - Last name
- `avatarUrl` - Profile picture URL
- `additionalInfo` - Provider-specific data

### SocialAuthError

Error class for authentication failures.

**Properties:**
- `code` - Error code (userCancelled, networkError, etc.)
- `message` - Error message
- `provider` - Provider that caused error
- `originalError` - Original exception

## UI Components

### SocialSignInButton

Pre-built sign-in button for a specific provider.

```dart
import 'package:socialauth/social_auth/social_auth.dart';

SocialSignInButton(
  provider: SocialProvider.google,
  onPressed: () async {
    final result = await socialAuth.signInWithGoogle();
  },
  text: 'Sign in with Google',  // Optional
  style: ButtonStyle(...),      // Optional
)
```

### SocialSignInRow

Row of social sign-in buttons.

```dart
SocialSignInRow(
  providers: [
    SocialProvider.google,
    SocialProvider.apple,
    SocialProvider.facebook,
  ],
  onSignIn: (provider, result) {
    print('Signed in with ${provider.name}');
  },
  spacing: 16,  // Optional
)
```

## Architecture

```
lib/
├── social_auth/
│   ├── src/
│   │   ├── adapters/              # Provider adapters
│   │   │   ├── base_auth_adapter.dart
│   │   │   ├── google_auth_adapter.dart
│   │   │   ├── apple_auth_adapter.dart
│   │   │   └── facebook_auth_adapter.dart
│   │   ├── core/                  # Core models
│   │   │   ├── social_provider.dart
│   │   │   ├── auth_result.dart
│   │   │   ├── social_auth_error.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── token_storage.dart
│   │   │   └── logger.dart
│   │   ├── services/              # Services
│   │   │   ├── social_auth_manager.dart
│   │   │   ├── firebase_auth_service.dart
│   │   │   └── rest_api_auth_service.dart
│   │   └── widgets/               # UI components
│   │       ├── social_sign_in_button.dart
│   │       └── social_sign_in_row.dart
│   └── social_auth.dart          # Main export
└── main.dart                      # Demo application
```

## Platform Support

| Platform | Google | Apple | Facebook |
|----------|--------|-------|----------|
| Android  | ✅     | ✅*   | ✅       |
| iOS      | ✅     | ✅    | ✅       |
| macOS    | ✅     | ✅    | ✅       |
| Web      | ✅     | ✅*   | ✅       |
| Linux    | ❌     | ❌    | ❌       |
| Windows  | ❌     | ❌    | ❌       |

\* Requires additional configuration (web authentication flow)

## Testing

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing instructions including:
- Setup guides for each provider
- Platform-specific configuration
- Test scenarios and checklists
- Troubleshooting common issues
- Security best practices

## Example App

The included example app demonstrates:
- Firebase initialization with fallback
- All three social providers (Google, Apple, Facebook)
- Platform support detection
- Error handling
- User profile display
- Sign-out functionality
- Module information screen

Run the example:
```bash
cd /home/user/Expensize/feature_test/socialauth
flutter run
```

## Security Best Practices

### ✅ DO
- Store tokens securely (use `flutter_secure_storage`)
- Validate tokens on your backend
- Use HTTPS for all API calls
- Implement token refresh logic
- Request minimal scopes/permissions
- Rotate API keys regularly
- Enable two-factor authentication

### ❌ DON'T
- Store credentials in code
- Commit API keys to version control
- Trust client-side authentication alone
- Use HTTP for sensitive data
- Request unnecessary permissions
- Share tokens between apps
- Store tokens in SharedPreferences

## Troubleshooting

### Google Sign-In Issues
- **Error: 10** - Check SHA-1 fingerprint is registered
- **No account picker** - Call `signOut()` first to force account selection
- **Network error** - Verify internet connection and Google Play Services

### Apple Sign-In Issues
- **Not available** - Check iOS version (13+) or macOS version (10.15+)
- **Web flow fails** - Verify Service ID and redirect URI configuration
- **Missing user data** - Apple only sends data on FIRST sign-in

### Facebook Login Issues
- **App ID error** - Check Facebook App ID in configuration
- **OAuth error** - Verify redirect URIs are whitelisted
- **Permissions denied** - User must grant permissions explicitly

See [TESTING_GUIDE.md](TESTING_GUIDE.md#troubleshooting) for more details.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Support

- 📖 [Documentation](TESTING_GUIDE.md)
- 🐛 [Issue Tracker](https://github.com/your-repo/issues)
- 💬 [Discussions](https://github.com/your-repo/discussions)

## Credits

Built with:
- [google_sign_in](https://pub.dev/packages/google_sign_in) - Google Sign-In for Flutter
- [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple) - Sign in with Apple
- [flutter_facebook_auth](https://pub.dev/packages/flutter_facebook_auth) - Facebook Login
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Secure token storage
- [firebase_auth](https://pub.dev/packages/firebase_auth) - Firebase Authentication

---

**Last Updated**: November 16, 2025
**Version**: 1.0.0
**Flutter SDK**: 3.4.1+
**Maintainer**: Expensize Team
