# App Lock Features

Complete guide to all features and capabilities available in the App Lock module.

## Table of Contents

- [PIN Authentication](#pin-authentication)
- [Biometric Authentication](#biometric-authentication)
- [Auto-Lock](#auto-lock)
- [Brute-Force Protection](#brute-force-protection)
- [Route Guards](#route-guards)
- [Lock State Management](#lock-state-management)
- [Security](#security)

---

## PIN Authentication

Secure PIN-based app locking with industry-standard cryptography.

### Set PIN

**What you can do:**
- Set a new PIN on first launch
- Configure minimum PIN length
- Secure hashing with PBKDF2
- Automatic unlocking after setup

**Example:**
\`\`\`dart
final manager = AppLockManager(
  config: AppLockConfig(
    pinMinLength: 4,
    pbkdf2Iterations: 100000,
  ),
);

await manager.initialize();

// Set PIN
final success = await manager.setPin('1234');
if (success) {
  print('PIN set successfully');
}
\`\`\`

### Change PIN

**Example:**
\`\`\`dart
final success = await manager.changePin(
  oldPin: '1234',
  newPin: '5678',
);

if (success) {
  print('PIN changed successfully');
} else {
  print('Old PIN incorrect or new PIN invalid');
}
\`\`\`

### Verify PIN

**Example:**
\`\`\`dart
final result = await manager.verifyPin('1234');

if (result.success) {
  await manager.unlock();
  print('PIN verified successfully');
} else if (result.isLockout) {
  print('Locked out: ${result.message}');
  print('Try again in: ${result.lockoutDuration}');
} else {
  print('Incorrect PIN');
  print('Attempts remaining: ${result.attemptsRemaining}');
}
\`\`\`

---

## Biometric Authentication

Support for Face ID, Touch ID, and Android Biometric API.

### Enable Biometric

**Example:**
\`\`\`dart
if (config.allowBiometrics) {
  final success = await manager.enableBiometric();
  
  if (success) {
    print('Biometric enabled');
  } else {
    print('Biometric not available or authentication failed');
  }
}
\`\`\`

### Authenticate with Biometric

**Example:**
\`\`\`dart
final authenticated = await manager.authenticateBiometric();

if (authenticated) {
  await manager.unlock();
  print('Unlocked with biometric');
} else {
  print('Biometric authentication failed');
}
\`\`\`

### Disable Biometric

**Example:**
\`\`\`dart
await manager.disableBiometric();
\`\`\`

---

## Auto-Lock

Automatic locking after inactivity or app backgrounding.

### Configure Auto-Lock Timeout

**Example:**
\`\`\`dart
final manager = AppLockManager(
  config: AppLockConfig(
    autoLockTimeout: Duration(minutes: 5),
    lockOnBackground: true,
  ),
);
\`\`\`

### Lock Manually

**Example:**
\`\`\`dart
await manager.lockNow();
\`\`\`

### Update Activity

**Example:**
\`\`\`dart
// Call on user interaction to reset auto-lock timer
await manager.updateLastActivity();
\`\`\`

---

## Brute-Force Protection

Lockout after failed attempts with exponential backoff.

### Configuration

**Example:**
\`\`\`dart
final manager = AppLockManager(
  config: AppLockConfig(
    maxAttempts: 5,
    lockoutDuration: Duration(minutes: 5),
  ),
);
\`\`\`

---

## Route Guards

Protect specific routes with `AppLockGuard` widget.

**Example:**
\`\`\`dart
AppLockGuard(
  manager: manager,
  child: ProtectedScreen(),
)
\`\`\`

---

## Lock State Management

Monitor and react to lock state changes.

**Example:**
\`\`\`dart
manager.onLockStateChanged.listen((state) {
  if (state.locked) {
    print('App is locked');
  } else {
    print('App is unlocked');
  }
});

manager.onLockEvents.listen((event) {
  if (event is LockoutEvent) {
    print('User locked out for ${event.duration}');
  }
});
\`\`\`

---

## Security

### Cryptographic Features

✅ **PBKDF2** with 100,000 iterations
✅ **Secure Storage** (Keychain/KeyStore)
✅ **Constant-time** PIN comparison
✅ **No plain-text** PIN storage
✅ **Salt generation** per PIN
✅ **Automatic** lockout protection

**Example Configuration:**
\`\`\`dart
final config = AppLockConfig(
  pbkdf2Iterations: 100000,  // OWASP recommended
  secureStorageKeyPrefix: 'com.yourapp.applock.',
);
\`\`\`

---

## Summary

The App Lock module provides:

✅ **PIN Authentication** with PBKDF2 hashing
✅ **Biometric Authentication** (Face ID, Touch ID)
✅ **Auto-Lock** with configurable timeout
✅ **Brute-Force Protection** with lockout
✅ **Route Guards** for protecting screens
✅ **Event Streams** for monitoring
✅ **Secure Storage** using platform Keychain/KeyStore
✅ **Production-Ready** security features

All designed to provide enterprise-grade security for your Flutter app.
