# Integration Guide

How to integrate Firebase Auth & FCM modules into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Module Structure Overview](#module-structure-overview)
- [Installation](#installation)
- [Firebase Auth Integration](#firebase-auth-integration)
- [FCM Integration](#fcm-integration)
- [Combined Integration](#combined-integration)
- [UI Integration](#ui-integration)
- [State Management](#state-management)
- [Best Practices](#best-practices)
- [Migration Guide](#migration-guide)

---

## Prerequisites

- Flutter SDK >=3.4.1
- Firebase project with:
  - Authentication enabled
  - Cloud Messaging enabled (for FCM)
- Platform-specific configurations:
  - iOS: APNs certificate uploaded
  - Android: google-services.json configured

---

## Module Structure Overview

This module has **TWO independent sub-modules**:

```
firebaseauth/
├── lib/
│   ├── firebase_auth/          ← Authentication module
│   │   ├── services/           ← Core auth logic
│   │   ├── repository/         ← Firebase wrapper
│   │   ├── providers/          ← Riverpod/GetIt
│   │   ├── ui/                 ← Pre-built screens & widgets
│   │   ├── models/             ← Data models
│   │   ├── storage/            ← Token storage
│   │   ├── errors/             ← Error handling
│   │   └── utils/              ← Validators, constants
│   │
│   └── fcm/                    ← Push notifications module
│       └── src/
│           ├── services/       ← FCM service
│           └── models/         ← Notification models
```

**You can use:**
- Only Firebase Auth
- Only FCM
- Both together (recommended)

---

## Installation

### Step 1: Copy Module

```bash
# Copy the entire firebaseauth folder to your project
cp -r feature_test/firebaseauth /path/to/your/project/packages/firebaseauth
```

### Step 2: Add Dependency

In your app's `pubspec.yaml`:

```yaml
dependencies:
  firebaseauth:
    path: ./packages/firebaseauth
```

### Step 3: Install

```bash
flutter pub get
```

---

## Firebase Auth Integration

### Basic Integration (5 Minutes)

#### 1. Import Module

```dart
// lib/main.dart
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';
```

#### 2. Initialize Firebase

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
```

#### 3. Create Auth Service

```dart
// lib/services/auth_service.dart
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _authService = FirebaseAuthService();
  final _tokenStore = SecureStorageTokenStore();

  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      // Save token
      final token = await _authService.getIdToken();
      if (token != null) {
        await _tokenStore.saveToken(token);
      }
    }

    return result;
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      final token = await _authService.getIdToken();
      if (token != null) {
        await _tokenStore.saveToken(token);
      }
    }

    return result;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _tokenStore.deleteToken();
  }

  Stream<UserModel?> get authStateChanges =>
      _authService.authStateChanges;
}
```

#### 4. Protect Your Routes

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<UserModel?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            return user != null ? HomeScreen() : SignInScreen();
          }
          return SplashScreen();
        },
      ),
    );
  }
}
```

---

### Advanced Integration

#### Repository Pattern

```dart
// lib/repositories/auth_repository.dart
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final TokenStore _tokenStore;
  final GoogleSignInAdapter _googleAdapter;
  final AppleSignInAdapter _appleAdapter;
  final PhoneAuthService _phoneService;

  AuthRepository({
    FirebaseAuthService? authService,
    TokenStore? tokenStore,
  })  : _authService = authService ?? FirebaseAuthService(),
        _tokenStore = tokenStore ?? SecureStorageTokenStore(),
        _googleAdapter = GoogleSignInAdapter(),
        _appleAdapter = AppleSignInAdapter(),
        _phoneService = PhoneAuthService();

  // Email & Password
  Future<AuthResult> signUpWithEmail(String email, String password) async {
    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );
    await _saveTokenIfSuccess(result);
    return result;
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    await _saveTokenIfSuccess(result);
    return result;
  }

  // Social Sign-In
  Future<AuthResult> signInWithGoogle() async {
    final result = await _googleAdapter.signIn();
    await _saveTokenIfSuccess(result);
    return result;
  }

  Future<AuthResult> signInWithApple() async {
    final result = await _appleAdapter.signIn();
    await _saveTokenIfSuccess(result);
    return result;
  }

  // Phone
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(AuthCredential) verificationCompleted,
    required Function(AuthError) verificationFailed,
  }) async {
    await _phoneService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
    );
  }

  Future<AuthResult> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final result = await _phoneService.signInWithOTP(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _saveTokenIfSuccess(result);
    return result;
  }

  // Account Management
  Future<void> sendEmailVerification() =>
      _authService.sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> updateProfile({String? displayName, String? photoURL}) =>
      _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    await _tokenStore.deleteToken();
  }

  // Helpers
  Future<void> _saveTokenIfSuccess(AuthResult result) async {
    if (result.success && result.user != null) {
      final token = await _authService.getIdToken();
      if (token != null) {
        await _tokenStore.saveToken(token);
      }
    }
  }

  Stream<UserModel?> get authStateChanges => _authService.authStateChanges;

  Future<void> signOut() async {
    await _authService.signOut();
    await _tokenStore.deleteToken();
  }
}
```

---

## FCM Integration

### Basic Integration

#### 1. Import Module

```dart
import 'package:firebaseauth/fcm/fcm_notifications.dart';
```

#### 2. Initialize FCM

```dart
// lib/main.dart
late FCMService fcmService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM
  fcmService = await FCMService.initialize(
    FCMConfig(
      androidChannelId: 'default_channel',
      androidChannelName: 'Default Notifications',
      androidChannelDescription: 'General app notifications',
      showForegroundNotifications: true,
      requestPermissionOnInit: true,
    ),
  );

  runApp(MyApp());
}
```

#### 3. Listen to Notifications

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() {
    // Listen to notifications
    fcmService.notificationStream.listen((notification) {
      print('Notification: ${notification.title}');

      // Handle notification tap
      if (notification.data.containsKey('route')) {
        _navigateToRoute(notification.data['route']!);
      }
    });

    // Listen to token updates
    fcmService.tokenStream.listen((token) {
      print('FCM Token: $token');
      _sendTokenToBackend(token);
    });
  }

  void _navigateToRoute(String route) {
    // Navigate based on notification data
  }

  Future<void> _sendTokenToBackend(String token) async {
    // Send token to your backend
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}
```

---

### Advanced FCM Integration

#### Notification Service

```dart
// lib/services/notification_service.dart
import 'package:firebaseauth/fcm/fcm_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FCMService _fcmService;
  StreamSubscription<PushNotification>? _notificationSubscription;
  StreamSubscription<String>? _tokenSubscription;

  Future<void> initialize() async {
    _fcmService = await FCMService.initialize(
      FCMConfig(
        androidChannelId: 'high_priority',
        androidChannelName: 'Important Notifications',
        androidChannelDescription: 'Critical app updates',
        androidImportance: AndroidImportance.high,
        showForegroundNotifications: true,
        enableAlert: true,
        enableBadge: true,
        enableSound: true,
        androidNotificationIcon: '@drawable/ic_notification',
        androidNotificationColor: '#FF5722',
      ),
    );

    _setupListeners();
  }

  void _setupListeners() {
    _notificationSubscription = _fcmService.notificationStream.listen(
      _handleNotification,
      onError: (error) {
        print('Notification error: $error');
      },
    );

    _tokenSubscription = _fcmService.tokenStream.listen(
      _handleTokenUpdate,
      onError: (error) {
        print('Token error: $error');
      },
    );
  }

  void _handleNotification(PushNotification notification) {
    print('Title: ${notification.title}');
    print('Body: ${notification.body}');
    print('Data: ${notification.data}');

    // Route based on notification type
    final type = notification.data['type'];
    switch (type) {
      case 'message':
        _handleMessage(notification);
        break;
      case 'update':
        _handleUpdate(notification);
        break;
      default:
        _handleDefault(notification);
    }
  }

  void _handleMessage(PushNotification notification) {
    // Navigate to messages screen
  }

  void _handleUpdate(PushNotification notification) {
    // Show update dialog
  }

  void _handleDefault(PushNotification notification) {
    // Default handling
  }

  Future<void> _handleTokenUpdate(String token) async {
    print('New FCM Token: $token');
    // Send to backend
    await _sendTokenToServer(token);
  }

  Future<void> _sendTokenToServer(String token) async {
    // Implement your backend API call
  }

  Future<void> subscribeToUserTopics(String userId) async {
    await _fcmService.subscribeToTopic('user_$userId');
    await _fcmService.subscribeToTopic('all_users');
  }

  Future<void> unsubscribeFromUserTopics(String userId) async {
    await _fcmService.unsubscribeFromTopic('user_$userId');
  }

  Future<String?> getToken() => _fcmService.getToken();

  void dispose() {
    _notificationSubscription?.cancel();
    _tokenSubscription?.cancel();
  }
}
```

---

## Combined Integration

### Complete User Flow

```dart
// lib/services/user_service.dart
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';
import 'package:firebaseauth/fcm/fcm_notifications.dart';

class UserService {
  final AuthRepository _authRepo;
  final FCMService _fcmService;

  UserService({
    required AuthRepository authRepo,
    required FCMService fcmService,
  })  : _authRepo = authRepo,
        _fcmService = fcmService;

  /// Complete sign-up flow with FCM setup
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    // 1. Sign up with Firebase Auth
    final result = await _authRepo.signUpWithEmail(email, password);

    if (result.success && result.user != null) {
      // 2. Send email verification
      await _authRepo.sendEmailVerification();

      // 3. Setup FCM
      await _setupFCMForUser(result.user!.uid);
    }

    return result;
  }

  /// Complete sign-in flow with FCM setup
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    // 1. Sign in with Firebase Auth
    final result = await _authRepo.signInWithEmail(email, password);

    if (result.success && result.user != null) {
      // 2. Setup FCM
      await _setupFCMForUser(result.user!.uid);
    }

    return result;
  }

  /// Setup FCM for authenticated user
  Future<void> _setupFCMForUser(String userId) async {
    // Get FCM token
    final token = await _fcmService.getToken();
    if (token != null) {
      // Send to backend
      await _sendFCMTokenToBackend(userId, token);

      // Subscribe to user-specific topic
      await _fcmService.subscribeToTopic('user_$userId');

      // Subscribe to general topics
      await _fcmService.subscribeToTopic('all_users');
    }
  }

  /// Complete sign-out flow
  Future<void> signOut() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Unsubscribe from topics
      await _fcmService.unsubscribeFromTopic('user_${currentUser.uid}');
      await _fcmService.unsubscribeFromTopic('all_users');
    }

    // Delete FCM token
    await _fcmService.deleteToken();

    // Sign out
    await _authRepo.signOut();
  }

  Future<void> _sendFCMTokenToBackend(String userId, String token) async {
    // Implement your backend API call
  }
}
```

---

## UI Integration

### Using Pre-Built Screens

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      onSignInSuccess: (user) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      onSignUpTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SignUpScreen()),
        );
      },
    );
  }
}
```

### Using Pre-Built Widgets

```dart
// lib/screens/custom_login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

class CustomLoginScreen extends StatefulWidget {
  @override
  State<CustomLoginScreen> createState() => _CustomLoginScreenState();
}

class _CustomLoginScreenState extends State<CustomLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Use pre-built text field widget
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),

            SizedBox(height: 16),

            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              validator: Validators.validatePassword,
            ),

            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),

            SizedBox(height: 16),

            // Use pre-built social sign-in buttons
            SocialSignInButton(
              provider: SocialProvider.google,
              onPressed: _signInWithGoogle,
            ),

            SocialSignInButton(
              provider: SocialProvider.apple,
              onPressed: _signInWithApple,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    final result = await _authService.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      _showError(result.error?.message ?? 'Sign in failed');
    }
  }

  Future<void> _signInWithGoogle() async {
    final result = await GoogleSignInAdapter().signIn();
    // Handle result
  }

  Future<void> _signInWithApple() async {
    final result = await AppleSignInAdapter().signIn();
    // Handle result
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

## State Management

### Option 1: Riverpod

```dart
// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// In your widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return HomeScreen();
        }
        return LoginScreen();
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorScreen(error: err.toString()),
    );
  }
}
```

### Option 2: GetIt

```dart
// lib/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );

  getIt.registerLazySingleton<TokenStore>(
    () => SecureStorageTokenStore(),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authService: getIt<FirebaseAuthService>(),
      tokenStore: getIt<TokenStore>(),
    ),
  );

  // Social adapters
  getIt.registerLazySingleton<GoogleSignInAdapter>(
    () => GoogleSignInAdapter(),
  );
}

// In main.dart
void main() {
  setupServiceLocator();
  runApp(MyApp());
}

// Usage
class LoginScreen extends StatelessWidget {
  final authRepo = getIt<AuthRepository>();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await authRepo.signInWithGoogle();
        // Handle result
      },
      child: Text('Sign in with Google'),
    );
  }
}
```

---

## Best Practices

### 1. Error Handling

```dart
Future<void> signIn(String email, String password) async {
  try {
    final result = await authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
      // Success
      navigateToHome();
    } else {
      // Handle specific errors
      switch (result.error?.code) {
        case 'user-not-found':
          showError('No user found with this email');
          break;
        case 'wrong-password':
          showError('Incorrect password');
          break;
        case 'too-many-requests':
          showError('Too many attempts. Try again later.');
          break;
        default:
          showError(result.error?.message ?? 'Sign in failed');
      }
    }
  } catch (e) {
    showError('An unexpected error occurred');
  }
}
```

### 2. Token Refresh

```dart
class ApiClient {
  final AuthRepository _authRepo;

  Future<Response> makeAuthenticatedRequest(String endpoint) async {
    // Get fresh token
    final token = await _authRepo.getIdToken(forceRefresh: false);

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        // Token expired, refresh
        final newToken = await _authRepo.getIdToken(forceRefresh: true);

        // Retry request
        return await http.get(
          Uri.parse(endpoint),
          headers: {'Authorization': 'Bearer $newToken'},
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
```

### 3. Lifecycle Management

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh FCM token when app comes to foreground
      fcmService.getToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}
```

### 4. Testing

```dart
// test/auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}
class MockTokenStore extends Mock implements TokenStore {}

void main() {
  late AuthRepository authRepo;
  late MockFirebaseAuthService mockAuthService;
  late MockTokenStore mockTokenStore;

  setUp(() {
    mockAuthService = MockFirebaseAuthService();
    mockTokenStore = MockTokenStore();
    authRepo = AuthRepository(
      authService: mockAuthService,
      tokenStore: mockTokenStore,
    );
  });

  test('signInWithEmail saves token on success', () async {
    final testUser = UserModel(uid: '123', email: 'test@example.com');
    final testResult = AuthResult(success: true, user: testUser);

    when(() => mockAuthService.signInWithEmail(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => testResult);

    when(() => mockAuthService.getIdToken()).thenAnswer((_) async => 'token123');
    when(() => mockTokenStore.saveToken(any())).thenAnswer((_) async => {});

    await authRepo.signInWithEmail('test@example.com', 'password');

    verify(() => mockTokenStore.saveToken('token123')).called(1);
  });
}
```

---

## Migration Guide

### From firebase_auth Package

```dart
// Before
import 'package:firebase_auth/firebase_auth.dart';

final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// After
import 'package:firebaseauth/firebase_auth/firebase_auth.dart';

final authService = FirebaseAuthService();
final result = await authService.signUpWithEmail(
  email: email,
  password: password,
);

if (result.success && result.user != null) {
  // User created
}
```

### From firebase_messaging Package

```dart
// Before
import 'package:firebase_messaging/firebase_messaging.dart';

final messaging = FirebaseMessaging.instance;
await messaging.requestPermission();
final token = await messaging.getToken();

FirebaseMessaging.onMessage.listen((message) {
  print(message.notification?.title);
});

// After
import 'package:firebaseauth/fcm/fcm_notifications.dart';

final fcmService = await FCMService.initialize(FCMConfig());
final token = await fcmService.getToken();

fcmService.notificationStream.listen((notification) {
  print(notification.title);
});
```

---

## Integration Checklist

### Firebase Auth
- [ ] Copy firebaseauth module to project
- [ ] Add dependency in pubspec.yaml
- [ ] Configure Firebase (google-services.json / GoogleService-Info.plist)
- [ ] Initialize Firebase in main.dart
- [ ] Create auth repository/service
- [ ] Implement sign-in screens
- [ ] Setup token storage
- [ ] Add auth state listener
- [ ] Test email/password flow
- [ ] Test social sign-in (optional)
- [ ] Add error handling

### FCM
- [ ] Initialize FCM service
- [ ] Setup notification listeners
- [ ] Configure Android notification channel
- [ ] Add iOS notification permissions
- [ ] Test foreground notifications
- [ ] Test background notifications
- [ ] Implement notification routing
- [ ] Setup topic subscriptions
- [ ] Send test notification from Firebase Console

---

**Ready to build complete authentication and messaging!**
