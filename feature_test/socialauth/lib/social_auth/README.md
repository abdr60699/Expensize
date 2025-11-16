# Flutter Social Authentication Module

Production-ready, reusable social sign-in module supporting Google, Apple, and Facebook authentication.

## ✨ Features

- ✅ **Google Sign-In** - Full OAuth 2.0 support
- ✅ **Sign in with Apple** - Native iOS/macOS + web support
- ✅ **Facebook Login** - Complete Facebook Graph API integration
- ✅ **Adapter-based architecture** - Easy to extend with new providers
- ✅ **Pluggable backends** - Firebase Auth or custom REST API
- ✅ **Secure token storage** - Built-in secure storage support
- ✅ **UI components** - Customizable sign-in buttons
- ✅ **Platform-aware** - Automatically handles platform limitations
- ✅ **Comprehensive error handling** - Clear, actionable error messages
- ✅ **Type-safe** - Full Dart null safety support

## 📦 Installation

### 1. Add Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  # Social auth providers
  google_sign_in: ^6.1.5
  sign_in_with_apple: ^5.0.0
  flutter_facebook_auth: ^6.0.3

  # Backend integration (choose one or both)
  firebase_auth: ^4.15.0  # For Firebase
  http: ^1.1.0  # For REST API

  # Secure storage
  flutter_secure_storage: ^9.0.0
```

### 2. Run Pub Get

```bash
flutter pub get
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'social_auth/social_auth.dart';

void main() {
  // Initialize social auth
  SocialAuth.initialize(
    logger: ConsoleLogger(), // Optional: for debug logs
  );

  runApp(MyApp());
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SocialSignInRow(
          onProviderSelected: (provider) async {
            try {
              final AuthResult result;

              switch (provider) {
                case SocialProvider.google:
                  result = await SocialAuth.instance.signInWithGoogle();
                  break;
                case SocialProvider.apple:
                  result = await SocialAuth.instance.signInWithApple();
                  break;
                case SocialProvider.facebook:
                  result = await SocialAuth.instance.signInWithFacebook();
                  break;
              }

              print('Signed in as: ${result.user.email}');
              // Navigate to home screen
            } on SocialAuthError catch (e) {
              print('Error: ${e.message}');
            }
          },
        ),
      ),
    );
  }
}
```

### With Firebase Backend

```dart
import 'firebase_core.dart';
import 'social_auth/social_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize social auth with Firebase
  SocialAuth.initialize(
    authService: FirebaseAuthService(),
    tokenStorage: SecureTokenStorage(),
    logger: ConsoleLogger(),
  );

  runApp(MyApp());
}
```

### With Custom REST API

```dart
SocialAuth.initialize(
  authService: RestApiAuthService(
    baseUrl: 'https://api.example.com',
  ),
  tokenStorage: SecureTokenStorage(),
);

// Sign in
final result = await SocialAuth.instance.signInWithGoogle();

// The REST API service will POST to:
// https://api.example.com/auth/social-login
// with the provider tokens
```

## 🔧 Provider Setup

### Google Sign-In Setup

#### Android Setup

1. **Get SHA-1 and SHA-256 certificates:**

```bash
# Debug certificate
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# Release certificate
keytool -list -v -alias <your-alias> -keystore <path-to-keystore>
```

2. **Configure Google Cloud Console:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create/select project
   - Enable "Google Sign-In API"
   - Go to "Credentials" → "Create OAuth 2.0 Client ID"
   - Select "Android"
   - Add package name: `com.example.yourapp`
   - Add SHA-1 and SHA-256 certificates
   - Save the client ID

3. **Download `google-services.json`:**
   - Place in `android/app/google-services.json`

4. **Update `android/build.gradle`:**

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

5. **Update `android/app/build.gradle`:**

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21  // Google Sign-In requires API 21+
    }
}
```

#### iOS Setup

1. **Configure Google Cloud Console:**
   - Create OAuth 2.0 Client ID
   - Select "iOS"
   - Add bundle ID: `com.example.yourapp`
   - Save the client ID

2. **Download `GoogleService-Info.plist`:**
   - Place in `ios/Runner/GoogleService-Info.plist`
   - Add to Xcode project

3. **Update `ios/Runner/Info.plist`:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>

<key>GIDClientID</key>
<string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>
```

### Apple Sign-In Setup

#### Prerequisites
- Apple Developer Account ($99/year)
- iOS 13.0+ or macOS 10.15+

#### Steps

1. **Enable Sign in with Apple:**
   - Go to [Apple Developer Portal](https://developer.apple.com/)
   - Select your app identifier
   - Enable "Sign in with Apple" capability
   - Save

2. **Create Services ID (for Web/Android):**
   - Go to "Certificates, Identifiers & Profiles"
   - Click "Identifiers" → "+" → "Services IDs"
   - Register service ID: `com.example.yourapp.signin`
   - Enable "Sign in with Apple"
   - Configure:
     - Domains: `example.com`
     - Return URLs: `https://example.com/auth/apple/callback`

3. **Create Key:**
   - Go to "Keys" → "+" → "Sign in with Apple"
   - Download `.p8` file (one-time download)
   - Note the Key ID

4. **iOS/macOS Configuration:**

Update `ios/Runner/Runner.entitlements`:

```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

Update Xcode:
- Open `ios/Runner.xcworkspace`
- Select Runner target
- Go to "Signing & Capabilities"
- Click "+" → Add "Sign in with Apple"

5. **Android/Web Configuration:**

```dart
SocialAuth.initialize(
  appleClientId: 'com.example.yourapp.signin',
  appleRedirectUri: 'https://example.com/auth/apple/callback',
);
```

### Facebook Login Setup

#### Steps

1. **Create Facebook App:**
   - Go to [Facebook Developers](https://developers.facebook.com/)
   - Create new app
   - Add "Facebook Login" product
   - Note App ID and App Secret

2. **Android Setup:**

Update `android/app/src/main/res/values/strings.xml`:

```xml
<resources>
    <string name="app_name">Your App</string>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
</resources>
```

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Add inside application tag -->
        <meta-data
            android:name="com.facebook.sdk.ApplicationId"
            android:value="@string/facebook_app_id"/>

        <meta-data
            android:name="com.facebook.sdk.ClientToken"
            android:value="@string/facebook_client_token"/>

        <activity
            android:name="com.facebook.FacebookActivity"
            android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
            android:label="@string/app_name" />

        <activity
            android:name="com.facebook.CustomTabActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="@string/fb_login_protocol_scheme" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

**Generate Key Hash:**

```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

Add to Facebook App Settings → Basic → Key Hashes

3. **iOS Setup:**

Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbYOUR_FACEBOOK_APP_ID</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Your App Name</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
</array>
```

4. **Configure Facebook App Settings:**
   - iOS:
     - Add bundle ID: `com.example.yourapp`
   - Android:
     - Add package name: `com.example.yourapp`
     - Add class name: `com.example.yourapp.MainActivity`
     - Add key hash (from step 2)

## 📱 Custom Backend Integration

### REST API Example

Your backend should implement:

#### POST /auth/social-login

**Request:**
```json
{
  "provider": "google",
  "accessToken": "ya29.a0AfH6...",
  "idToken": "eyJhbGciOiJSUzI1NiIs...",
  "authorizationCode": "4/0AX4XfWh...",
  "user": {
    "id": "1234567890",
    "email": "user@example.com",
    "name": "John Doe",
    "avatarUrl": "https://..."
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Response:**
```json
{
  "success": true,
  "sessionToken": "your-jwt-token",
  "user": {
    "id": "user-id-in-your-db",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "isNewUser": false
}
```

#### POST /auth/logout

**Headers:**
```
Authorization: Bearer {sessionToken}
```

**Response:**
```json
{
  "success": true
}
```

### Server-Side Token Verification

**Google:**
```python
from google.auth.transport import requests
from google.oauth2 import id_token

def verify_google_token(token):
    idinfo = id_token.verify_oauth2_token(
        token, requests.Request(), YOUR_CLIENT_ID
    )
    return idinfo['sub'], idinfo['email']
```

**Apple:**
```python
import jwt
from jwt import PyJWKClient

def verify_apple_token(token):
    jwks_client = PyJWKClient('https://appleid.apple.com/auth/keys')
    signing_key = jwks_client.get_signing_key_from_jwt(token)

    data = jwt.decode(
        token,
        signing_key.key,
        algorithms=['RS256'],
        audience=YOUR_CLIENT_ID,
    )
    return data['sub'], data.get('email')
```

**Facebook:**
```python
import requests

def verify_facebook_token(access_token):
    url = f'https://graph.facebook.com/me?fields=id,email,name&access_token={access_token}'
    response = requests.get(url)
    return response.json()
```

## 🎨 UI Customization

### Custom Button Styles

```dart
SocialSignInButton(
  provider: SocialProvider.google,
  onPressed: () => handleGoogleSignIn(),
  height: 56,
  width: double.infinity,
  borderRadius: BorderRadius.circular(12),
  textStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  customLabel: 'Sign in with Google',
)
```

### Custom Icon

```dart
SocialSignInButton(
  provider: SocialProvider.google,
  customIcon: Image.asset('assets/google_logo.png', width: 24),
  onPressed: () => handleGoogleSignIn(),
)
```

### Loading State

```dart
SocialSignInButton(
  provider: SocialProvider.google,
  isLoading: _isLoading,
  onPressed: () async {
    setState(() => _isLoading = true);
    try {
      await SocialAuth.instance.signInWithGoogle();
    } finally {
      setState(() => _isLoading = false);
    }
  },
)
```

## 🔒 Security Best Practices

### 1. Never Store Provider Tokens Permanently

```dart
// ✅ Good - Send tokens to your backend
final result = await SocialAuth.instance.signInWithGoogle();
await myBackend.exchangeToken(result.accessToken);

// ❌ Bad - Don't store provider tokens locally
await prefs.setString('google_token', result.accessToken);
```

### 2. Use HTTPS for All Backend Calls

```dart
RestApiAuthService(
  baseUrl: 'https://api.example.com', // ✅ HTTPS
  // baseUrl: 'http://api.example.com', // ❌ Never use HTTP
);
```

### 3. Validate Tokens Server-Side

Always verify tokens on your backend before creating sessions.

### 4. Use Secure Storage

```dart
final tokenStorage = SecureTokenStorage(); // Uses flutter_secure_storage
```

### 5. Implement Proper Session Management

```dart
// Check authentication status
if (await socialAuth.isSignedIn(SocialProvider.google)) {
  // User still signed in
}
```

## 🧪 Testing

### Unit Tests

See `test/social_auth_test.dart` for examples.

### Integration Tests

```dart
testWidgets('Google sign-in flow', (tester) async {
  await tester.pumpWidget(MyApp());

  await tester.tap(find.byType(SocialSignInButton));
  await tester.pumpAndSettle();

  // Verify navigation to home screen
  expect(find.text('Welcome'), findsOneWidget);
});
```

## 📖 API Reference

### SocialAuth

```dart
// Initialize
SocialAuth.initialize({
  AuthService? authService,
  TokenStorage? tokenStorage,
  SocialAuthLogger? logger,
  bool enableGoogle = true,
  bool enableApple = true,
  bool enableFacebook = true,
});

// Sign in methods
Future<AuthResult> signInWithGoogle();
Future<AuthResult> signInWithApple();
Future<AuthResult> signInWithFacebook();

// Sign out
Future<void> signOut();

// Utility methods
Future<bool> isSignedIn(SocialProvider provider);
bool isPlatformSupported(SocialProvider provider);
List<SocialProvider> get availableProviders;
```

### AuthResult

```dart
class AuthResult {
  final SocialProvider provider;
  final String? accessToken;
  final String? idToken;
  final String? authorizationCode;
  final SocialUser user;
  final Map<String, dynamic>? providerData;
}
```

### SocialUser

```dart
class SocialUser {
  final String id;
  final String? email;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
}
```

## ⚠️ Platform Considerations

### iOS
- Requires iOS 13+ for Apple Sign-In
- Apple Sign-In is REQUIRED if you offer other social logins (App Store requirement)

### Android
- Minimum SDK 21 for Google Sign-In
- Requires SHA certificates for Google and Facebook

### Web
- Google Sign-In requires web client ID
- Apple Sign-In requires Services ID configuration
- Facebook requires web app setup

## 🐛 Troubleshooting

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 📄 License

MIT License - see LICENSE file

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](docs/CONTRIBUTING.md)

## 📞 Support

For issues and questions:
- GitHub Issues: [Create Issue](../../issues)
- Documentation: [Full Docs](docs/)
