# Firebase Auth Module

A production-ready Firebase Authentication module for Flutter with comprehensive auth features and Firebase Cloud Messaging.

## Features

- 🔐 **Email/Password Auth** - Complete sign-up, sign-in, password reset, email verification
- 📱 **Phone OTP** - SMS-based phone number verification
- 👤 **Social Sign-In** - Google, Facebook, and Apple authentication
- 🔗 **Account Linking** - Link/unlink multiple auth providers
- 👻 **Anonymous Auth** - Guest user support
- 💾 **Secure Storage** - Token storage with flutter_secure_storage
- 🔔 **Firebase Cloud Messaging** - Push notifications with FCM
- 🎨 **UI Kit** - Pre-built sign-in screens and widgets
- 🧩 **State Management** - Riverpod 3.0 and GetIt support

## Quick Start

### 1. Setup Firebase Project

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
cd path/to/firebaseauth
flutterfire configure
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

**Note**: The app will show a configuration error screen until Firebase is properly set up. Follow the [TESTING_GUIDE.md](TESTING_GUIDE.md) for detailed setup instructions.

## Dependencies (Latest Versions)

```yaml
# Firebase
firebase_core: ^4.2.1
firebase_auth: ^6.1.2
firebase_messaging: ^16.0.4

# Social Auth
google_sign_in: ^7.2.0
flutter_facebook_auth: ^7.1.2
sign_in_with_apple: ^7.0.1

# State Management
flutter_riverpod: ^3.0.3
get_it: ^9.0.5

# Storage & Notifications
flutter_secure_storage: ^9.2.4
shared_preferences: ^2.5.3
flutter_local_notifications: ^19.5.0
```

## Documentation

📖 **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive guide with:
- Firebase project setup
- Platform-specific configuration
- Authentication method setup
- Testing checklist
- Troubleshooting
- Integration examples

📖 **[firebase_auth/README.md](lib/firebase_auth/README.md)** - Module documentation
📖 **[fcm/README.md](lib/fcm/README.md)** - FCM setup guide

## Architecture

```
lib/
├── firebase_auth/          # Auth module
│   ├── services/          # Auth services
│   ├── repository/        # Firebase wrapper
│   ├── providers/         # Riverpod/GetIt
│   ├── ui/                # Pre-built screens
│   ├── models/            # Data models
│   └── storage/           # Token storage
├── fcm/                   # FCM module
│   ├── services/          # FCM service
│   └── models/            # Notification models
└── main.dart              # Example app
```

## Usage Example

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_auth/firebase_auth.dart';

// Sign in with email
final authService = ref.read(authServiceProvider);
final result = await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in with Google
final result = await authService.signInWithGoogle();

// Watch auth state
final authState = ref.watch(authStateProvider);
final user = ref.watch(currentUserProvider);

// Link accounts
await authService.linkWithGoogle();
await authService.linkWithFacebook();
```

## Authentication Methods

### Supported Providers
- ✅ Email/Password
- ✅ Phone (SMS OTP)
- ✅ Google OAuth
- ✅ Facebook Login
- ✅ Apple Sign-In
- ✅ Anonymous

### Account Management
- Change password
- Reset password
- Email verification
- Update profile
- Delete account
- Link/unlink providers

## Firebase Setup Requirements

Before running the app, you must:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your app to the project (Android, iOS, Web)
3. Download configuration files:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`
4. Enable authentication methods in Firebase Console
5. Configure platform-specific settings

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for detailed step-by-step instructions.

## Platform Requirements

### Android
- Min SDK: 23
- Target SDK: 34
- Google Play Services
- MultiDex enabled

### iOS
- Min iOS version: 13.0
- CocoaPods
- Xcode 15+

### Web
- Modern browser with JavaScript enabled
- reCAPTCHA for phone auth

## Security Features

✅ Secure token storage (Keychain/KeyStore)
✅ Automatic token refresh
✅ OAuth 2.0 flows
✅ Input validation
✅ Error handling
✅ Session management

## State Management Options

### Riverpod (Recommended)
```dart
runApp(
  ProviderScope(
    child: MyApp(),
  ),
);
```

### GetIt
```dart
await registerAuthModule();
final authService = GetIt.I<AuthService>();
```

## Status

**Ready for Testing** ⚠️

All features implemented with latest package versions. Requires Firebase project setup to run.

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for complete setup and testing instructions.

---

**Last Updated**: November 16, 2025
**Flutter SDK**: 3.4.1+
**Firebase**: Latest stable versions
**License**: MIT
