# Firebase Auth & FCM Features

Complete guide to authentication and push notifications capabilities.

## Table of Contents

- [Module Overview](#module-overview)
- [Folder Structure](#folder-structure)
- [Firebase Auth Features](#firebase-auth-features)
- [FCM Features](#fcm-features)
- [Use Cases](#use-cases)
- [Feature Matrix](#feature-matrix)

---

## Module Overview

This module contains **TWO major sub-modules**:

1. **firebase_auth** - Complete authentication system with multiple sign-in methods
2. **fcm** - Firebase Cloud Messaging for push notifications

Both modules work independently but can be used together for complete user management.

---

## Folder Structure

### Complete Directory Tree

```
lib/
├── firebase_auth/                    # 🔐 Authentication Module
│   ├── firebase_auth.dart            # Main export file
│   ├── services/
│   │   ├── firebase_auth_service.dart       # Core auth service
│   │   ├── phone_auth_service.dart          # Phone OTP service
│   │   └── social_auth/                     # Social sign-in adapters
│   │       ├── google_signin_adapter.dart   # Google Sign-In
│   │       ├── apple_signin_adapter.dart    # Apple Sign-In
│   │       └── facebook_signin_adapter.dart # Facebook Sign-In
│   ├── repository/
│   │   └── auth_repository.dart             # Firebase wrapper
│   ├── providers/
│   │   ├── riverpod/
│   │   │   └── auth_provider.dart           # Riverpod state management
│   │   └── getit/
│   │       └── auth_service_locator.dart    # GetIt dependency injection
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── sign_in_screen.dart          # Email/Password sign-in
│   │   │   └── phone_signin_screen.dart     # Phone OTP sign-in
│   │   └── widgets/
│   │       ├── auth_text_field.dart         # Reusable input field
│   │       └── social_sign_in_button.dart   # Social login button
│   ├── models/
│   │   ├── user_model.dart                  # User data model
│   │   └── auth_result.dart                 # Auth response model
│   ├── storage/
│   │   ├── token_store.dart                 # Abstract token storage
│   │   ├── secure_storage_impl.dart         # Secure storage (Keychain)
│   │   └── shared_prefs_impl.dart           # Shared preferences
│   ├── errors/
│   │   └── auth_error.dart                  # Categorized error types
│   └── utils/
│       ├── validators.dart                  # Email, password validators
│       └── constants.dart                   # Error messages, regex
│
└── fcm/                              # 📲 Push Notifications Module
    ├── fcm_notifications.dart        # Main export file
    └── src/
        ├── services/
        │   └── fcm_service.dart              # Core FCM service
        └── models/
            ├── push_notification.dart        # Notification data model
            └── fcm_config.dart               # FCM configuration

example/
└── main.dart                         # Demo app with all features
```

### Key Directory Explanations

#### `firebase_auth/services/`
Core authentication logic:
- **firebase_auth_service.dart**: Email/password, anonymous, linking
- **phone_auth_service.dart**: OTP verification, auto-resolve
- **social_auth/**: Adapters for Google, Apple, Facebook sign-in

#### `firebase_auth/providers/`
State management options (use ONE):
- **riverpod/**: For apps using Riverpod
- **getit/**: For apps using GetIt/Provider

#### `firebase_auth/ui/`
Pre-built UI components:
- **screens/**: Full-page sign-in flows
- **widgets/**: Reusable form components

#### `firebase_auth/storage/`
Token persistence:
- **secure_storage_impl.dart**: Production (flutter_secure_storage)
- **shared_prefs_impl.dart**: Development/testing

#### `fcm/`
Completely separate module for push notifications:
- Independent initialization
- Works with or without authentication
- Local notification support

---

## Firebase Auth Features

### 1. Email & Password Authentication

```dart
final authService = FirebaseAuthService();

// Sign up
final result = await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'SecurePass123!',
);

if (result.success && result.user != null) {
  print('Welcome ${result.user!.displayName}');
}

// Sign in
final signInResult = await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'SecurePass123!',
);
```

**Features:**
- Email validation with regex
- Password strength requirements
- Email verification
- Password reset

---

### 2. Phone Authentication (OTP)

```dart
final phoneService = PhoneAuthService();

// Send OTP
await phoneService.verifyPhoneNumber(
  phoneNumber: '+1234567890',
  codeSent: (verificationId, resendToken) {
    // Show OTP input screen
  },
  verificationCompleted: (credential) {
    // Auto-verified (Android only)
  },
  verificationFailed: (error) {
    // Handle error
  },
);

// Verify OTP
final result = await phoneService.signInWithOTP(
  verificationId: verificationId,
  smsCode: '123456',
);
```

**Features:**
- SMS OTP delivery
- Auto-verification on Android
- Resend OTP with timeout
- Custom timeout configuration

---

### 3. Social Sign-In

#### Google Sign-In

```dart
final googleAdapter = GoogleSignInAdapter();

final result = await googleAdapter.signIn();
if (result.success) {
  print('Signed in with Google: ${result.user!.email}');
}
```

#### Apple Sign-In

```dart
final appleAdapter = AppleSignInAdapter();

final result = await appleAdapter.signIn();
if (result.success) {
  print('Signed in with Apple: ${result.user!.uid}');
}
```

#### Facebook Sign-In

```dart
final facebookAdapter = FacebookSignInAdapter();

final result = await facebookAdapter.signIn();
if (result.success) {
  print('Signed in with Facebook: ${result.user!.displayName}');
}
```

**Features:**
- One-tap sign-in
- Profile data retrieval
- Token management
- Automatic account creation

---

### 4. Anonymous Authentication

```dart
final authService = FirebaseAuthService();

// Sign in anonymously
final result = await authService.signInAnonymously();

// Later: Convert to permanent account
final linkResult = await authService.linkWithEmailPassword(
  email: 'user@example.com',
  password: 'SecurePass123!',
);
```

**Features:**
- Guest access
- Data persistence
- Upgrade to permanent account
- Account linking

---

### 5. Account Linking

```dart
// Link Google to existing account
final googleCredential = await GoogleSignInAdapter().getCredential();
final result = await authService.linkWithCredential(googleCredential);

// Unlink provider
await authService.unlinkProvider('google.com');
```

**Features:**
- Link multiple sign-in methods
- Unlink providers
- Prevent duplicate accounts
- Seamless provider switching

---

### 6. User Management

```dart
// Update profile
await authService.updateProfile(
  displayName: 'John Doe',
  photoURL: 'https://example.com/photo.jpg',
);

// Delete account
await authService.deleteAccount();

// Re-authentication (before sensitive operations)
await authService.reauthenticate(
  email: 'user@example.com',
  password: 'CurrentPass123!',
);
```

**Features:**
- Profile updates
- Password change
- Email change
- Account deletion
- Re-authentication for security

---

### 7. Token Management

```dart
// Get ID token
final token = await authService.getIdToken();

// Refresh token
final newToken = await authService.getIdToken(forceRefresh: true);

// Listen to auth state
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User signed in: ${user.uid}');
  } else {
    print('User signed out');
  }
});
```

**Features:**
- ID token retrieval
- Automatic token refresh
- Secure storage with Keychain/KeyStore
- Auth state stream

---

### 8. State Management Integration

#### Riverpod

```dart
// lib/firebase_auth/providers/riverpod/auth_provider.dart
final authProvider = StreamProvider<UserModel?>((ref) {
  return FirebaseAuthService().authStateChanges;
});

// In your widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) => user != null ? HomeScreen() : LoginScreen(),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorScreen(error: err),
    );
  }
}
```

#### GetIt

```dart
// lib/firebase_auth/providers/getit/auth_service_locator.dart
final getIt = GetIt.instance;

void setupAuthServices() {
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<TokenStore>(SecureStorageTokenStore());
}

// Usage
final authService = getIt<FirebaseAuthService>();
```

---

## FCM Features

### 1. Push Notifications

```dart
final fcmService = await FCMService.initialize(
  FCMConfig(
    androidChannelId: 'default_channel',
    androidChannelName: 'Default Notifications',
    showForegroundNotifications: true,
  ),
);

// Listen to notifications
fcmService.notificationStream.listen((notification) {
  print('Title: ${notification.title}');
  print('Body: ${notification.body}');
  print('Data: ${notification.data}');
});
```

**Features:**
- Foreground notifications
- Background notifications
- Data-only messages
- Notification customization

---

### 2. FCM Token Management

```dart
// Get token
final token = await fcmService.getToken();
print('FCM Token: $token');

// Listen to token updates
fcmService.tokenStream.listen((newToken) {
  // Send to your backend
  sendTokenToServer(newToken);
});

// Delete token
await fcmService.deleteToken();
```

**Features:**
- Token retrieval
- Automatic token refresh
- Token deletion on sign-out

---

### 3. Topic Subscription

```dart
// Subscribe to topics
await fcmService.subscribeToTopic('all_users');
await fcmService.subscribeToTopic('premium_users');

// Unsubscribe
await fcmService.unsubscribeFromTopic('premium_users');
```

**Features:**
- Topic-based messaging
- Dynamic subscription management
- Multi-topic support

---

### 4. Notification Channels (Android)

```dart
final config = FCMConfig(
  androidChannelId: 'high_priority',
  androidChannelName: 'Important Notifications',
  androidChannelDescription: 'Critical app updates',
  androidImportance: AndroidImportance.high,
  androidSound: 'notification_sound',
  androidNotificationIcon: '@drawable/ic_notification',
  androidNotificationColor: '#FF5722',
);
```

**Features:**
- Custom notification channels
- Sound customization
- Icon and color branding
- Importance levels

---

### 5. iOS Configuration

```dart
final config = FCMConfig(
  enableAlert: true,
  enableBadge: true,
  enableSound: true,
  requestPermissionOnInit: true,
);

// Request permission manually
final settings = await fcmService.requestPermission();
print('Permission granted: ${settings.authorizationStatus}');
```

**Features:**
- Permission handling
- Badge management
- Sound settings
- Alert customization

---

## Use Cases

### Complete Auth Flow

```dart
// 1. Email sign-up
final result = await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'Pass123!',
);

// 2. Send verification email
await authService.sendEmailVerification();

// 3. Setup FCM after sign-in
final fcmToken = await fcmService.getToken();
await saveTokenToBackend(userId: result.user!.uid, token: fcmToken);

// 4. Subscribe to user-specific topic
await fcmService.subscribeToTopic('user_${result.user!.uid}');
```

### Social Sign-In with Linking

```dart
// 1. Sign in with Google
final googleResult = await GoogleSignInAdapter().signIn();

// 2. User already has email account - link them
if (googleResult.error?.code == 'account-exists-with-different-credential') {
  final providers = await authService.fetchSignInMethodsForEmail(
    googleResult.error!.email!,
  );

  // 3. Sign in with email first
  final emailResult = await authService.signInWithEmail(
    email: googleResult.error!.email!,
    password: userEnteredPassword,
  );

  // 4. Link Google credential
  final credential = await GoogleSignInAdapter().getCredential();
  await authService.linkWithCredential(credential);
}
```

### Guest to Registered User

```dart
// 1. Start as anonymous
final anonResult = await authService.signInAnonymously();

// User explores app, adds data...

// 2. Convert to permanent account
final linkResult = await authService.linkWithEmailPassword(
  email: 'user@example.com',
  password: 'SecurePass123!',
);

// All anonymous data is preserved!
```

---

## Feature Matrix

| Feature | Firebase Auth | FCM |
|---------|--------------|-----|
| Email/Password | ✅ | - |
| Phone OTP | ✅ | - |
| Google Sign-In | ✅ | - |
| Apple Sign-In | ✅ | - |
| Facebook Sign-In | ✅ | - |
| Anonymous Auth | ✅ | - |
| Account Linking | ✅ | - |
| Token Management | ✅ | ✅ |
| Push Notifications | - | ✅ |
| Foreground Notifications | - | ✅ |
| Background Notifications | - | ✅ |
| Topic Subscriptions | - | ✅ |
| Local Notifications | - | ✅ |
| Notification Channels | - | ✅ (Android) |
| Permission Handling | ✅ | ✅ |
| Secure Storage | ✅ | - |
| State Management (Riverpod) | ✅ | - |
| State Management (GetIt) | ✅ | - |
| Pre-built UI Screens | ✅ | - |
| Custom Validators | ✅ | - |
| Error Categorization | ✅ | ✅ |

---

## Platform Support

| Platform | Firebase Auth | FCM |
|----------|--------------|-----|
| Android | ✅ | ✅ |
| iOS | ✅ | ✅ |
| Web | ✅ | ✅ (limited) |

---

## Security Features

### Firebase Auth
- Secure password hashing (Firebase backend)
- Token encryption in Keychain/KeyStore
- Re-authentication for sensitive operations
- Email verification
- Password reset with verification

### FCM
- Token-based messaging
- Encrypted message delivery
- Permission-based access
- Topic authorization

---

**Ready to implement complete user authentication and push notifications!**
