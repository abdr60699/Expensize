# Setup Guide

Complete guide to setting up the App Lock module from scratch.

## Table of Contents

- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Platform Configuration](#platform-configuration)
- [Configuration Options](#configuration-options)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

```bash
# 1. Navigate to module
cd feature_test/applock

# 2. Install dependencies
flutter pub get

# 3. Run demo app
flutter run
```

---

## Detailed Setup

### Step 1: Dependencies

```yaml
dependencies:
  flutter_secure_storage: ^9.2.4
  local_auth: ^3.0.0
  shared_preferences: ^2.5.3
  crypto: ^3.0.7
```

```bash
flutter pub get
```

### Step 2: Platform Configuration

#### iOS Setup

**Info.plist:**
```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock app with Face ID</string>

<key>NSFingerprintUsageDescription</key>
<string>Unlock app with Touch ID</string>
```

#### Android Setup

**AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

**build.gradle:**
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21  // Required
    }
}
```

### Step 3: Initialize

```dart
final manager = AppLockManager(
  config: AppLockConfig(
    pinMinLength: 4,
    maxAttempts: 5,
    lockoutDuration: Duration(minutes: 5),
    autoLockTimeout: Duration(minutes: 2),
    allowBiometrics: true,
    pbkdf2Iterations: 100000,
  ),
);

await manager.initialize();
```

---

## Configuration Options

### AppLockConfig

```dart
AppLockConfig(
  // PIN settings
  pinMinLength: 4,                          // Minimum PIN length
  pbkdf2Iterations: 100000,                 // PBKDF2 iterations

  // Security settings
  maxAttempts: 5,                           // Max failed attempts
  lockoutDuration: Duration(minutes: 5),    // Lockout duration

  // Auto-lock settings
  autoLockTimeout: Duration(minutes: 2),    // Auto-lock timeout
  lockOnBackground: true,                    // Lock when app goes to background

  // Biometric settings
  allowBiometrics: true,                    // Enable biometric auth

  // Storage settings
  secureStorageKeyPrefix: 'com.yourapp.applock.',
)
```

---

## Testing

### 1. Test PIN Setup

```dart
final result = await manager.setPin('1234');
assert(result == true);
print('✅ PIN setup successful');
```

### 2. Test PIN Verification

```dart
final verifyResult = await manager.verifyPin('1234');
assert(verifyResult.success);
print('✅ PIN verification successful');
```

### 3. Test Biometric

```dart
final enabled = await manager.enableBiometric();
if (enabled) {
  final authenticated = await manager.authenticateBiometric();
  print('✅ Biometric works: $authenticated');
}
```

### 4. Test Lockout

```dart
// Try wrong PIN multiple times
for (int i = 0; i < 5; i++) {
  await manager.verifyPin('0000');
}

final result = await manager.verifyPin('1234');
assert(result.isLockout);
print('✅ Lockout protection working');
```

---

## Troubleshooting

### Issue: "Biometric not available"

**Solution:**
- Ensure device has biometric hardware
- Check permissions in manifest/Info.plist
- Verify biometric is enrolled on device

### Issue: "PIN not saving"

**Solution:**
```dart
// Check if secure storage is working
final test = await FlutterSecureStorage().write(key: 'test', value: 'value');
final read = await FlutterSecureStorage().read(key: 'test');
print('Secure storage works: ${read == 'value'}');
```

### Issue: "Auto-lock not working"

**Solution:**
- Ensure `initialize()` is called
- Call `updateLastActivity()` on user interaction
- Check auto-lock timeout configuration

---

## Setup Checklist

- [ ] Flutter SDK >=3.4.1
- [ ] Dependencies installed
- [ ] iOS permissions configured
- [ ] Android permissions configured
- [ ] AppLockManager initialized
- [ ] PIN setup tested
- [ ] Biometric tested (if available)
- [ ] Auto-lock tested
- [ ] Lockout tested

---

## Next Steps

1. ✅ Complete setup
2. 📖 Read [FEATURES.md](./FEATURES.md)
3. 🔧 Read [INTEGRATION.md](./INTEGRATION.md)
4. 🚀 Secure your app!

---

**Setup complete! Your app is now secure.**
