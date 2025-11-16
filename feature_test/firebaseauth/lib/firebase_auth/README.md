# Firebase Auth Module - Complete Integration Guide

A production-ready, reusable Firebase Authentication module for Flutter with support for Email/Password, Phone OTP, Social Sign-In (Google, Apple, Facebook), Anonymous auth, account linking, and secure token storage.

## Quick Start

See full documentation in STRUCTURE.md

### Installation

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  flutter_riverpod: ^2.4.9
  google_sign_in: ^6.1.6
  sign_in_with_apple: ^5.0.0
  flutter_facebook_auth: ^6.0.3
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
```

### Usage (Riverpod)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final user = ref.watch(currentUserProvider);
    return MaterialApp(home: user != null ? HomeScreen() : SignInScreen());
  }
}
```

### Usage (GetIt)

```dart
import 'features/firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await registerAuthModule();
  runApp(MyApp());
}
```

## Features

- ✅ Email/Password authentication  
- ✅ Phone OTP verification
- ✅ Google, Apple, Facebook sign-in
- ✅ Anonymous sign-in
- ✅ Account linking/unlinking
- ✅ Email verification & password reset
- ✅ Secure token storage
- ✅ Comprehensive error handling

## Platform Setup

### Android
1. Add `google-services.json` to `android/app/`
2. Add SHA-1/SHA-256 to Firebase Console
3. Enable sign-in methods in Firebase Console

### iOS
1. Add `GoogleService-Info.plist` to Xcode project
2. Enable "Sign in with Apple" capability
3. Update Info.plist with URL schemes

See STRUCTURE.md for detailed platform setup instructions.

## API Examples

```dart
// Sign in with email
final result = await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password',
);

// Sign in with Google
final result = await authService.signInWithGoogle();

// Link Google account
await authService.linkWithGoogle();

// Sign out
await authService.signOut();
```

## Server-Side Token Verification

```javascript
// Node.js
const decodedToken = await admin.auth().verifyIdToken(idToken);
const uid = decodedToken.uid;
```

```dart
// Flutter
final idToken = await authService.getIdToken();
// Send to backend in Authorization header
```

## Testing

```bash
flutter test test/unit/
flutter test test/widget/
```

## License

Part of the Reusable Widgets repository.
