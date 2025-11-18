# Integration Guide

How to integrate the App Lock module into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Basic Integration](#basic-integration)
- [Advanced Integration](#advanced-integration)
- [UI Customization](#ui-customization)
- [Best Practices](#best-practices)
- [Testing](#testing)

---

## Prerequisites

- Flutter SDK >=3.4.1
- Android SDK 21+ (for Android Biometric API)
- iOS 12.0+ (for Face ID/Touch ID)

---

## Installation

### Step 1: Copy Module

```bash
cp -r feature_test/applock /path/to/your/project/packages/applock
```

### Step 2: Add Dependency

```yaml
dependencies:
  applock:
    path: ./packages/applock
```

### Step 3: Install

```bash
flutter pub get
```

---

## Basic Integration

### Step 1: Platform Setup

**iOS (Info.plist):**
```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock app with Face ID</string>
```

**Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

### Step 2: Initialize

```dart
// lib/main.dart
import 'package:applock/reusable_app_lock.dart';

late AppLockManager appLockManager;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appLockManager = AppLockManager(
    config: AppLockConfig(
      pinMinLength: 4,
      maxAttempts: 5,
      lockoutDuration: Duration(minutes: 5),
      autoLockTimeout: Duration(minutes: 2),
      allowBiometrics: true,
    ),
  );

  await appLockManager.initialize();

  runApp(MyApp());
}
```

### Step 3: Protect Your App

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppLockGuard(
        manager: appLockManager,
        child: HomeScreen(),
      ),
    );
  }
}
```

---

## Advanced Integration

### Global App Lock Service

```dart
// lib/services/app_lock_service.dart
import 'package:applock/reusable_app_lock.dart';

class AppLockService {
  static final AppLockService _instance = AppLockService._internal();
  factory AppLockService() => _instance;
  AppLockService._internal();

  late AppLockManager _manager;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _manager = AppLockManager(
      config: AppLockConfig(
        pinMinLength: 4,
        maxAttempts: 5,
        lockoutDuration: Duration(minutes: 5),
        autoLockTimeout: Duration(minutes: 2),
        allowBiometrics: true,
      ),
    );

    await _manager.initialize();

    // Listen to lock events
    _manager.onLockEvents.listen(_handleLockEvent);

    _initialized = true;
  }

  void _handleLockEvent(LockEvent event) {
    if (event is LockoutEvent) {
      // Log lockout event
      print('User locked out for ${event.duration}');
    } else if (event is UnlockFailedEvent) {
      // Log failed attempt
      print('Failed unlock: ${event.attemptsRemaining} remaining');
    }
  }

  AppLockManager get manager => _manager;
}
```

---

## UI Customization

### Custom Lock Screen

```dart
AppLockScreen(
  manager: appLockManager,
  title: 'Enter PIN',
  subtitle: 'Unlock to continue',
  backgroundColor: Colors.blue,
  pinDotColor: Colors.white,
  onUnlockSuccess: () {
    Navigator.pushReplacement(context, ...);
  },
)
```

---

## Best Practices

### 1. Handle App Lifecycle

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
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
    if (state == AppLifecycleState.paused) {
      appLockManager.lockNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(...);
  }
}
```

### 2. Update Activity on User Interaction

```dart
GestureDetector(
  onTap: () async {
    await appLockManager.updateLastActivity();
    // Handle tap
  },
  child: YourWidget(),
)
```

---

## Testing

### Mock AppLockManager

```dart
class MockAppLockManager extends Mock implements AppLockManager {}

void main() {
  test('PIN verification works', () async {
    final mockManager = MockAppLockManager();

    when(mockManager.verifyPin('1234'))
        .thenAnswer((_) async => PinVerifyResult.success());

    final result = await mockManager.verifyPin('1234');

    expect(result.success, isTrue);
  });
}
```

---

## Integration Checklist

- [ ] Copy applock module to project
- [ ] Add dependencies
- [ ] Add platform permissions (iOS/Android)
- [ ] Initialize AppLockManager in main.dart
- [ ] Wrap app with AppLockGuard
- [ ] Test PIN setup flow
- [ ] Test biometric authentication
- [ ] Test auto-lock
- [ ] Test lockout protection
- [ ] Handle app lifecycle events

---

**Ready to secure your app!**
