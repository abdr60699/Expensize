# Reusable App Lock 🔐

A production-ready Flutter package for implementing app-level PIN and biometric authentication with secure storage, auto-lock, brute-force protection, and retry limits.

## ✨ Features

- **PIN Authentication**: Secure PIN setup, verification, and change with PBKDF2 hashing
- **Biometric Authentication**: Face ID, Touch ID, and Android Biometric support
- **Secure Storage**: Uses `flutter_secure_storage` for sensitive data (Keychain/KeyStore)
- **Auto-Lock**: Configurable timeout with automatic background locking
- **Brute-Force Protection**: Configurable retry limits with lockout cooldown
- **Route Guards**: Easy widget-based protection with `AppLockGuard`
- **Customizable UI**: Themeable lock screen with full control
- **Lifecycle Handling**: Automatic lock on app background/inactive states
- **Event Streams**: Monitor lock state changes and events
- **Null-Safe**: Built with null-safety from the ground up
- **Well-Tested**: Comprehensive unit and widget tests
- **Accessible**: Proper focus management and screen reader support

## 🚀 Quick Start

### 1. Add Dependencies

This package requires:
- `flutter_secure_storage: ^9.0.0`
- `shared_preferences: ^2.2.2`
- `local_auth: ^2.1.0`
- `crypto: ^3.0.3`

These are already included in the main `pubspec.yaml` of the reusablewidgets project.

### 2. Platform Setup

#### iOS
Add to `Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock app with Face ID</string>
```

#### Android
Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

**Minimum SDK**: Android API 23 (Marshmallow)

See [Platform Setup Guide](./docs/platform-setup.md) for detailed instructions.

### 3. Initialize

```dart
import 'package:reuablewidgets/features/app_lock/reusable_app_lock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create manager
  final appLockManager = AppLockManager(
    config: const AppLockConfig(
      pinMinLength: 4,
      maxAttempts: 5,
      lockoutDuration: Duration(minutes: 5),
      autoLockTimeout: Duration(seconds: 30),
      allowBiometrics: true,
    ),
  );

  // Initialize (must be called before using)
  await appLockManager.initialize();

  runApp(MyApp(manager: appLockManager));
}
```

### 4. Set Up PIN

```dart
// Check if PIN is already set
final isEnabled = await manager.isEnabled();

if (!isEnabled) {
  // Show PIN setup screen
  AppLockScreen(
    manager: manager,
    mode: AppLockMode.setup,
    onSetupComplete: () {
      // PIN setup complete
    },
  );
}
```

### 5. Protect Routes

```dart
// Wrap any widget/screen with AppLockGuard
AppLockGuard(
  manager: manager,
  child: HomePage(),
)
```

## 📚 Core API

### AppLockManager

Main facade for app lock functionality.

```dart
final manager = AppLockManager(config: AppLockConfig());
await manager.initialize();

// PIN operations
await manager.setPin('1234');
await manager.changePin(oldPin: '1234', newPin: '5678');
final result = await manager.verifyPin('1234');

// Biometric operations
await manager.enableBiometric();
await manager.disableBiometric();
final authenticated = await manager.authenticateBiometric();

// Lock/Unlock
await manager.lockNow();
await manager.unlock();
final isLocked = await manager.isLocked();

// Settings
await manager.setAutoLockTimeout(Duration(minutes: 1));

// Reset (removes all data)
await manager.reset();

// Events
manager.onLockStateChanged.listen((state) {
  print('Locked: ${state.locked}');
});
```

### AppLockConfig

Configuration for the lock manager.

```dart
const config = AppLockConfig(
  pinMinLength: 4,              // Minimum PIN length
  maxAttempts: 5,               // Max failed attempts before lockout
  lockoutDuration: Duration(minutes: 5),  // Lockout duration
  autoLockTimeout: Duration(seconds: 30), // Auto-lock timeout
  allowBiometrics: true,        // Allow biometric authentication
  pbkdf2Iterations: 100000,     // PBKDF2 iteration count (security)
  primaryColor: Colors.blue,    // UI theme color
);
```

### AppLockScreen

Pre-built lock screen UI.

```dart
// Setup mode (enter PIN + confirm)
AppLockScreen(
  manager: manager,
  mode: AppLockMode.setup,
  onSetupComplete: () {},
)

// Verify mode (unlock)
AppLockScreen(
  manager: manager,
  mode: AppLockMode.verify,
  onVerified: () {},
  showBiometric: true,
)

// Change mode (old PIN + new PIN + confirm)
AppLockScreen(
  manager: manager,
  mode: AppLockMode.change,
  onChangeComplete: () {},
)
```

### AppLockGuard

Widget that blocks content until unlocked.

```dart
AppLockGuard(
  manager: manager,
  child: ProtectedContent(),
  lockScreen: CustomLockScreen(),  // Optional custom lock screen
  showAsDialog: false,              // Show as dialog overlay
  onUnlocked: () {},                // Callback when unlocked
  onLocked: () {},                  // Callback when locked
)
```

### PinVerifyResult

Result of PIN verification.

```dart
final result = await manager.verifyPin('1234');

if (result.success) {
  // PIN correct
} else if (result.lockedOut) {
  // Too many failed attempts
  print('Locked out for: ${result.lockoutDuration}');
} else {
  // PIN incorrect
  print('Attempts remaining: ${result.attemptsRemaining}');
  print('Message: ${result.message}');
}
```

## 🔒 Security

### PIN Storage

- PINs are **never** stored in plain text
- Uses PBKDF2-HMAC-SHA256 with 100,000 iterations (configurable)
- Random 256-bit salt for each PIN
- Constant-time comparison to prevent timing attacks
- Stored in platform secure storage (iOS Keychain / Android KeyStore)

### Brute-Force Protection

- Configurable maximum attempts (default: 5)
- Automatic lockout after max attempts
- Configurable lockout duration (default: 5 minutes)
- Failed attempts counter persists across app restarts

### Biometric Security

- Biometric data never leaves the device
- PIN always available as fallback
- Requires user confirmation for each authentication
- Can be disabled at any time

### Auto-Lock

- Locks on app background/inactive
- Configurable inactivity timeout
- Manual lock available
- Lifecycle-aware

## 📖 Advanced Usage

### Custom Storage Adapters

```dart
class CustomSecureStorage implements SecureStorageAdapter {
  // Implement your own secure storage backend
}

final manager = AppLockManager(
  config: config,
  secureAdapter: CustomSecureStorage(),
);
```

### Event Monitoring

```dart
// Listen to lock state changes
manager.onLockStateChanged.listen((state) {
  print('Locked: ${state.locked}');
  print('Failed attempts: ${state.failedAttempts}');
  print('Locked out: ${state.isLockedOut}');
});

// Listen to specific events
manager.onLockEvents.listen((event) {
  if (event is AppLockedEvent) {
    print('App locked: ${event.reason}');
  } else if (event is UnlockFailedEvent) {
    print('Unlock failed: ${event.attemptsRemaining} remaining');
  } else if (event is LockoutEvent) {
    print('User locked out for: ${event.duration}');
  }
});
```

### Custom Lock Screen

```dart
class MyCustomLockScreen extends StatelessWidget {
  final AppLockManager manager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppLockScreen(
          manager: manager,
          mode: AppLockMode.verify,
          title: 'Custom Title',
          subtitle: 'Custom Subtitle',
          primaryColor: Colors.purple,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}

// Use custom lock screen
AppLockGuard(
  manager: manager,
  lockScreen: MyCustomLockScreen(manager: manager),
  child: HomePage(),
)
```

### Lifecycle Integration

```dart
class MyApp extends StatefulWidget with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      appLockManager.lockNow();
    }
  }
}
```

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
flutter test lib/features/app_lock/tests/

# Run specific test file
flutter test lib/features/app_lock/tests/crypto_utils_test.dart
```

### Mocking in Tests

```dart
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements SecureStorageAdapter {}

test('my test', () async {
  final mockStorage = MockSecureStorage();
  when(() => mockStorage.readSecure(any())).thenAnswer((_) async => null);

  final manager = AppLockManager(
    config: AppLockConfig(),
    secureAdapter: mockStorage,
  );

  // Test your code
});
```

## 🛠️ Troubleshooting

### Biometric not available

```dart
final canCheck = await FlutterLocalAuthService().canCheckBiometrics();
if (!canCheck) {
  // Device doesn't support biometrics or user hasn't enrolled
}
```

### Secure storage errors on Android

- Ensure minimum SDK is 23 or higher
- Check that `encryptedSharedPreferences` is enabled
- On emulator, biometrics may not work (use real device)

### Auto-lock not working

- Ensure you're calling `manager.initialize()` before `runApp()`
- Check that `WidgetsBindingObserver` is properly set up
- Verify auto-lock timeout configuration

### PIN reset

```dart
// Remove all PIN data and settings
await manager.reset();

// Keep non-sensitive settings
await manager.reset(keepConfig: true);
```

## 📝 Migration Notes

### Rotating KDF Iteration Count

If you need to increase the PBKDF2 iteration count:

1. Store current iteration count with the hash
2. On next PIN verification, check stored iteration count
3. If different, re-hash with new iteration count
4. Update stored hash and iteration count

```dart
// Future enhancement - currently iteration count is in config
```

### Data Migration

To migrate data from old storage to new:

1. Read from old storage
2. Verify old data
3. Write to new storage
4. Delete old storage

## 🔄 Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## 📄 License

This package is part of the reusablewidgets project.

## 🙋 Support

- **Documentation**: See [docs/](./docs/) folder
- **Examples**: See [examples/](./examples/) folder
- **Tests**: See [tests/](./tests/) folder
- **Issues**: Report bugs or request features via project issues

## 🎯 Roadmap

- [ ] Server-assisted PIN recovery
- [ ] Encrypted backup/export
- [ ] Multiple PINs (app PIN vs section PIN)
- [ ] PIN complexity requirements
- [ ] Grace period before lockout
- [ ] Customizable lockout behavior

---

**Built with ❤️ using Flutter and modern security practices**
