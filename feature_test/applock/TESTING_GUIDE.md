# App Lock Feature - Testing Guide

## Overview
This is a comprehensive app lock feature for Flutter that provides PIN and biometric authentication with secure storage, auto-lock, and brute-force protection.

## Features Implemented
- ✅ PIN Authentication with PBKDF2 hashing (100,000 iterations)
- ✅ Biometric Authentication (Face ID, Touch ID, Android Biometric)
- ✅ Secure Storage using flutter_secure_storage
- ✅ Auto-Lock with configurable timeout
- ✅ Brute-Force Protection (lockout after 5 failed attempts)
- ✅ Route Guards with AppLockGuard widget
- ✅ Customizable UI with theming support
- ✅ Lifecycle Handling (automatic lock on app background)

## Dependencies (Latest Versions)
```yaml
dependencies:
  flutter_secure_storage: ^9.2.4
  local_auth: ^3.0.0
  shared_preferences: ^2.5.3
  crypto: ^3.0.7
```

## Setup Instructions

### 1. Install Dependencies
```bash
cd /path/to/applock
flutter pub get
```

### 2. Platform-Specific Configuration

#### iOS Configuration
Add to `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>We need to use Face ID to unlock the app</string>
```

#### Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

For Android API 23+, the app already uses EncryptedSharedPreferences.

### 3. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run

# For specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

## Testing Checklist

### ✅ Initial Setup
- [ ] App launches successfully
- [ ] Shows PIN setup screen on first launch
- [ ] Requires minimum 4-digit PIN
- [ ] Confirms PIN by re-entering
- [ ] Shows error if PINs don't match
- [ ] Navigates to main screen after successful setup

### ✅ PIN Verification
- [ ] Locks app and shows lock screen
- [ ] Accepts correct PIN and unlocks
- [ ] Shows error message for incorrect PIN
- [ ] Displays remaining attempts (5 max)
- [ ] Decrements attempts on each failure

### ✅ Lockout Protection
- [ ] Locks out after 5 failed attempts
- [ ] Shows lockout duration (5 minutes)
- [ ] Displays countdown timer
- [ ] Prevents PIN entry during lockout
- [ ] Clears lockout after duration expires

### ✅ Biometric Authentication
- [ ] Shows biometric button if available
- [ ] Biometric settings screen works
- [ ] Can enable biometric authentication
- [ ] Can disable biometric authentication
- [ ] Shows appropriate message if not available
- [ ] Falls back to PIN if biometric fails

### ✅ Change PIN
- [ ] Change PIN screen accessible from menu
- [ ] Requires old PIN verification
- [ ] Accepts new PIN with confirmation
- [ ] Shows success message after change
- [ ] New PIN works for unlocking

### ✅ Auto-Lock
- [ ] Auto-locks after 30 seconds of inactivity
- [ ] Locks immediately when app goes to background
- [ ] Requires unlock when returning to foreground
- [ ] Timer resets on user interaction

### ✅ Protected Screens
- [ ] AppLockGuard shows lock screen if locked
- [ ] Shows protected content after unlock
- [ ] Works with navigation (push/pop)

### ✅ Reset Functionality
- [ ] Reset confirms before proceeding
- [ ] Removes PIN and all settings
- [ ] Returns to setup screen after reset
- [ ] Clears all secure storage

### ✅ UI/UX
- [ ] Lock screen is visually appealing
- [ ] PIN pad is responsive
- [ ] Error messages are clear
- [ ] Success feedback is visible
- [ ] Loading states work properly
- [ ] Theming applies correctly

## Manual Test Scenarios

### Scenario 1: First-Time User
1. Launch the app (fresh install)
2. Should see "Welcome! Set up a PIN to secure your app"
3. Enter a 4-digit PIN (e.g., 1234)
4. Re-enter the same PIN to confirm
5. Should navigate to the main app screen

### Scenario 2: Wrong PIN Attempts
1. Lock the app (tap lock icon)
2. Enter wrong PIN 5 times
3. Should see "Too many failed attempts. Locked out for 5 minutes"
4. Should not allow PIN entry during lockout
5. Wait for lockout to expire or reset

### Scenario 3: Biometric Setup
1. Navigate to "Biometric Settings"
2. Toggle "Enable Biometric Unlock"
3. Complete biometric authentication
4. Lock the app
5. Should see fingerprint/face icon
6. Tap to authenticate with biometric

### Scenario 4: Change PIN
1. Navigate to "Change PIN"
2. Enter old PIN
3. Enter new PIN
4. Confirm new PIN
5. Should see "PIN changed successfully"
6. Lock and unlock with new PIN

### Scenario 5: Protected Screen
1. Tap "Protected Screen"
2. Should show lock screen if locked
3. Enter correct PIN
4. Should show protected content
5. Go back to main screen

### Scenario 6: Auto-Lock Test
1. Ensure app is unlocked
2. Wait 30 seconds without interaction
3. Try to navigate or interact
4. Should lock automatically

### Scenario 7: Background Lock
1. Unlock the app
2. Switch to another app (home button or app switcher)
3. Return to the app
4. Should show lock screen

## Performance Benchmarks

### Expected Performance
- PIN verification: < 200ms (due to PBKDF2 with 100k iterations)
- Biometric auth: < 1s (device-dependent)
- Lock screen display: < 100ms
- Auto-lock trigger: instant

### Memory Usage
- Expected: ~50-100 MB total
- Secure storage: minimal (<1 KB per entry)

## Troubleshooting

### Issue: "Biometric not available"
**Solution**:
- Ensure device has biometric hardware
- Ensure at least one biometric is enrolled
- Check platform-specific permissions

### Issue: "PIN not set" error
**Solution**:
- Reset the app storage
- Clear app data/cache
- Reinstall the app

### Issue: Lockout won't clear
**Solution**:
- Check device time is correct
- Wait full 5 minutes
- Use reset functionality to clear

### Issue: App crashes on lock screen
**Solution**:
- Check Flutter/Dart SDK versions
- Run `flutter clean && flutter pub get`
- Check console for error messages

## Code Quality Checks

### Run Tests
```bash
# Run unit tests
flutter test lib/app_lock/tests/

# Run with coverage
flutter test --coverage
```

### Run Analysis
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Security Considerations

### ✅ Implemented Security Features
- PBKDF2 with 100,000 iterations for PIN hashing
- Cryptographically secure random salt generation
- Constant-time comparison to prevent timing attacks
- Secure storage using platform Keychain/KeyStore
- No plain-text PIN storage
- Automatic lockout on failed attempts
- Auto-lock on background/inactivity

### ⚠️ Important Notes
- PINs are never logged or stored in plain text
- Biometric data never leaves the device
- Secure storage is encrypted at platform level
- Failed attempts are tracked in SharedPreferences (non-sensitive)

## Architecture Overview

```
lib/app_lock/
├── reusable_app_lock.dart          # Main export file
├── src/
│   ├── app_lock_manager.dart       # Core manager
│   ├── guards/
│   │   └── app_lock_guard.dart     # Route guard widget
│   ├── models/
│   │   ├── app_lock_config.dart    # Configuration
│   │   ├── lock_state.dart         # State management
│   │   ├── lock_events.dart        # Event tracking
│   │   └── pin_verify_result.dart  # Verification result
│   ├── services/
│   │   ├── secure_storage_adapter.dart  # Secure storage
│   │   ├── settings_storage.dart        # Settings storage
│   │   └── local_auth_service.dart      # Biometric auth
│   ├── utils/
│   │   ├── crypto_utils.dart       # Cryptography
│   │   └── time_utils.dart         # Time utilities
│   └── widgets/
│       ├── app_lock_screen.dart    # Lock screen UI
│       ├── pin_pad.dart            # PIN input pad
│       └── lock_indicator.dart     # Visual feedback
```

## Integration into Main App

To integrate this into your main Expensize app:

```dart
// 1. Initialize in main.dart
final appLockManager = AppLockManager(
  config: const AppLockConfig(
    pinMinLength: 6,  // Customize as needed
    maxAttempts: 3,
    lockoutDuration: Duration(minutes: 10),
    autoLockTimeout: Duration(seconds: 60),
    allowBiometrics: true,
    primaryColor: YourApp.primaryColor,
  ),
);
await appLockManager.initialize();

// 2. Wrap your app with AppLockGuard
runApp(
  AppLockGuard(
    manager: appLockManager,
    child: YourMainApp(),
  ),
);

// 3. Protect sensitive screens
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AppLockGuard(
      manager: appLockManager,
      child: SensitiveScreen(),
    ),
  ),
);
```

## Next Steps

1. **Run the app** on your local machine with Flutter installed
2. **Test all features** using the checklist above
3. **Configure** the AppLockConfig parameters as needed
4. **Integrate** into the main Expensize app
5. **Add tests** for your specific use cases
6. **Customize UI** to match your app's design

## Support

For issues or questions:
- Check the inline documentation in the code
- Review the example in `lib/app_lock/examples/example_main.dart`
- Test individual components using the test files
- Check Flutter/package documentation for dependency issues

---

**Status**: ✅ Ready for testing
**Last Updated**: November 16, 2025
**Flutter SDK**: Compatible with Flutter 3.4.1+
**Dependencies**: All using latest stable versions
