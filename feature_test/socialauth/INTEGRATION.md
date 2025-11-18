# Integration Guide

How to integrate social authentication into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Installation](#installation)
- [Basic Integration](#basic-integration)
- [Firebase Integration](#firebase-integration)
- [REST API Integration](#rest-api-integration)
- [UI Integration](#ui-integration)
- [Platform Configuration](#platform-configuration)
- [Best Practices](#best-practices)
- [Testing](#testing)

---

## Prerequisites

- Flutter SDK >=3.4.1
- Provider accounts:
  - Google Cloud Console
  - Apple Developer Account (for Apple Sign-In)
  - Facebook Developer Account
- Platform-specific setup (iOS, Android)

---

## Module Structure

```
lib/social_auth/
├── social_auth.dart           # Main facade
├── src/
│   ├── adapters/              # Provider implementations
│   ├── core/                  # Core types & interfaces
│   ├── services/              # Backend integrations
│   └── widgets/               # UI components
```

---

## Installation

### Step 1: Copy Module

```bash
cp -r feature_test/socialauth/lib/social_auth /path/to/your/project/lib/
```

### Step 2: Add Dependencies

```yaml
dependencies:
  # Social providers
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.5
  flutter_facebook_auth: ^7.1.1

  # Security
  flutter_secure_storage: ^9.2.4

  # Optional - Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4

  # Optional - REST API
  http: ^1.2.2
```

```bash
flutter pub get
```

---

## Basic Integration

### Quick Start (5 Minutes)

```dart
import 'package:your_app/social_auth/social_auth.dart';

// Initialize
final socialAuth = SocialAuth(
  tokenStorage: SecureTokenStorage(),
  logger: ConsoleLogger(),
  enableGoogle: true,
  enableApple: true,
  enableFacebook: true,
);

// Sign in
class LoginScreen extends StatelessWidget {
  Future<void> _signInWithGoogle() async {
    final result = await socialAuth.signInWithGoogle();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _signInWithGoogle,
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
```

---

## Firebase Integration

### Step 1: Initialize Firebase

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
```

### Step 2: Create Auth Service

```dart
// lib/services/auth_service.dart
import 'package:your_app/social_auth/social_auth.dart';

class AuthService {
  late final SocialAuth _socialAuth;

  AuthService() {
    _socialAuth = SocialAuth(
      authService: FirebaseAuthService(),
      tokenStorage: SecureTokenStorage(),
      logger: ConsoleLogger(),
      enableGoogle: true,
      enableApple: true,
      enableFacebook: true,
    );
  }

  Future<AuthResult> signInWithGoogle() =>
      _socialAuth.signInWithGoogle();

  Future<AuthResult> signInWithApple() =>
      _socialAuth.signInWithApple();

  Future<AuthResult> signInWithFacebook() =>
      _socialAuth.signInWithFacebook();

  Future<void> signOut() async {
    await _socialAuth.signOut();
  }

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();
}
```

### Step 3: Use in App

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
```

---

## REST API Integration

### Backend Service

```dart
// lib/services/custom_auth_service.dart
class CustomAuthService implements AuthService {
  final String baseUrl;
  final http.Client client;

  CustomAuthService({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<void> handleSocialSignIn({
    required SocialProvider provider,
    required String accessToken,
    String? idToken,
    Map<String, dynamic>? userData,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/social'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'provider': provider.name,
        'accessToken': accessToken,
        'idToken': idToken,
        'userData': userData,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend auth failed');
    }

    final data = json.decode(response.body);

    // Store session token
    await SecureTokenStorage().saveToken(
      provider: SocialProvider.custom,
      token: data['sessionToken'],
    );
  }

  @override
  Future<void> signOut() async {
    await client.post(Uri.parse('$baseUrl/auth/signout'));
    await SecureTokenStorage().deleteAllTokens();
  }
}
```

### Initialize with Custom Service

```dart
final socialAuth = SocialAuth(
  authService: CustomAuthService(
    baseUrl: 'https://api.yourapp.com',
  ),
  tokenStorage: SecureTokenStorage(),
);
```

---

## UI Integration

### Pre-Built Buttons

```dart
import 'package:your_app/social_auth/social_auth.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Single buttons
            SocialSignInButton(
              provider: SocialProvider.google,
              onPressed: () => _signIn(context, SocialProvider.google),
            ),

            SizedBox(height: 16),

            SocialSignInButton(
              provider: SocialProvider.apple,
              onPressed: () => _signIn(context, SocialProvider.apple),
            ),

            SizedBox(height: 16),

            SocialSignInButton(
              provider: SocialProvider.facebook,
              onPressed: () => _signIn(context, SocialProvider.facebook),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn(BuildContext context, SocialProvider provider) async {
    // Implementation
  }
}
```

### Button Row

```dart
// All providers in one row
SocialSignInRow(
  onGooglePressed: () => _signIn(SocialProvider.google),
  onApplePressed: () => _signIn(SocialProvider.apple),
  onFacebookPressed: () => _signIn(SocialProvider.facebook),
)
```

### Custom Buttons

```dart
ElevatedButton.icon(
  icon: Image.asset('assets/google_logo.png', height: 24),
  label: Text('Continue with Google'),
  onPressed: () async {
    final result = await socialAuth.signInWithGoogle();
    _handleResult(result);
  },
)
```

---

## Platform Configuration

### iOS Setup

#### Google Sign-In

1. Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>

<key>GIDClientID</key>
<string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>
```

2. Get CLIENT_ID from `GoogleService-Info.plist`

#### Apple Sign-In

1. Enable capability in Xcode:
   - Target → Signing & Capabilities
   - Add "Sign in with Apple"

2. Add to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR-BUNDLE-ID</string>
    </array>
  </dict>
</array>
```

#### Facebook Login

1. Add to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR-APP-ID</string>
    </array>
  </dict>
</array>

<key>FacebookAppID</key>
<string>YOUR-APP-ID</string>
<key>FacebookDisplayName</key>
<string>Your App Name</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
</array>
```

---

### Android Setup

#### Google Sign-In

1. Add SHA-1 fingerprint to Firebase Console

```bash
cd android
./gradlew signingReport
```

2. Add to `android/app/build.gradle`:

```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

#### Apple Sign-In

No additional setup needed (uses web flow)

#### Facebook Login

1. Add to `android/app/src/main/res/values/strings.xml`:

```xml
<string name="facebook_app_id">YOUR-APP-ID</string>
<string name="fb_login_protocol_scheme">fbYOUR-APP-ID</string>
<string name="facebook_client_token">YOUR-CLIENT-TOKEN</string>
```

2. Add to `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.facebook.sdk.ApplicationId"
    android:value="@string/facebook_app_id"/>

<meta-data
    android:name="com.facebook.sdk.ClientToken"
    android:value="@string/facebook_client_token"/>
```

---

## Best Practices

### 1. Error Handling

```dart
Future<void> signIn(SocialProvider provider) async {
  try {
    final result = await socialAuth.signIn(provider);

    if (result.isSuccess) {
      _navigateToHome();
    } else {
      _handleError(result.error!);
    }
  } on SocialAuthException catch (e) {
    _showError(e.message);
  } catch (e) {
    _showError('An unexpected error occurred');
  }
}

void _handleError(SocialAuthError error) {
  switch (error.code) {
    case 'user_cancelled':
      // User cancelled, don't show error
      break;
    case 'network_error':
      _showError('No internet connection');
      break;
    case 'account_exists_with_different_credential':
      _showAccountConflictDialog(error);
      break;
    default:
      _showError(error.message);
  }
}
```

### 2. Token Management

```dart
class TokenManager {
  final SecureTokenStorage _storage = SecureTokenStorage();

  Future<String?> getValidToken(SocialProvider provider) async {
    final token = await _storage.getToken(provider);

    if (token == null) return null;

    // Check if token is expired
    if (_isTokenExpired(token)) {
      await _refreshToken(provider);
      return await _storage.getToken(provider);
    }

    return token;
  }

  bool _isTokenExpired(String token) {
    // Implement token expiration check
    return false;
  }

  Future<void> _refreshToken(SocialProvider provider) async {
    // Implement token refresh
  }
}
```

### 3. Logging

```dart
class AnalyticsLogger implements AuthLogger {
  @override
  void log(String message, {LogLevel level = LogLevel.info}) {
    // Production: Send to analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'auth_event',
      parameters: {
        'message': message,
        'level': level.toString(),
      },
    );

    // Development: Print to console
    if (kDebugMode) {
      print('[$level] $message');
    }
  }
}
```

---

## Testing

### Mock Social Auth

```dart
class MockSocialAuth implements SocialAuth {
  @override
  Future<AuthResult> signInWithGoogle({List<String>? scopes}) async {
    await Future.delayed(Duration(seconds: 1));

    return AuthResult(
      isSuccess: true,
      user: SocialUser(
        id: 'test_123',
        email: 'test@example.com',
        displayName: 'Test User',
      ),
      provider: SocialProvider.google,
    );
  }

  // Implement other methods...
}
```

### Widget Tests

```dart
testWidgets('Login button triggers sign in', (tester) async {
  final mockAuth = MockSocialAuth();

  await tester.pumpWidget(
    MaterialApp(
      home: LoginScreen(socialAuth: mockAuth),
    ),
  );

  await tester.tap(find.text('Sign in with Google'));
  await tester.pumpAndSettle();

  expect(find.byType(HomeScreen), findsOneWidget);
});
```

---

## Integration Checklist

### Google Sign-In
- [ ] Copy social_auth module
- [ ] Add google_sign_in dependency
- [ ] Create Google Cloud project
- [ ] Configure OAuth consent screen
- [ ] Get OAuth client IDs (iOS, Android, Web)
- [ ] Add SHA-1 fingerprint (Android)
- [ ] Configure iOS Info.plist
- [ ] Test sign-in flow

### Apple Sign-In
- [ ] Add sign_in_with_apple dependency
- [ ] Enable Sign in with Apple capability (Xcode)
- [ ] Configure Services ID (Apple Developer)
- [ ] Add iOS Info.plist entries
- [ ] Test on physical iOS device
- [ ] Test web flow (Android)

### Facebook Login
- [ ] Add flutter_facebook_auth dependency
- [ ] Create Facebook App
- [ ] Get App ID and Client Token
- [ ] Configure iOS Info.plist
- [ ] Configure Android strings.xml
- [ ] Add privacy policy URL
- [ ] Test login flow

### Backend Integration
- [ ] Choose integration (Firebase/REST/Standalone)
- [ ] Implement auth service
- [ ] Setup token storage
- [ ] Add error handling
- [ ] Test auth flow end-to-end

---

**Ready to integrate social authentication!**
