# App Lock Feature

A production-ready Flutter app lock module with PIN and biometric authentication.

## Features

- 🔐 **PIN Authentication** - Secure PIN with PBKDF2 hashing (100k iterations)
- 👆 **Biometric Auth** - Face ID, Touch ID, Android Biometric support
- 🔒 **Auto-Lock** - Configurable timeout and background lock
- 🛡️ **Brute-Force Protection** - Lockout after failed attempts
- 🎨 **Customizable UI** - Themeable lock screen
- 📱 **Route Guards** - Protect specific screens with AppLockGuard
- 💾 **Secure Storage** - Platform Keychain/KeyStore integration

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Test the Features
- Set up a 4-digit PIN on first launch
- Try all features from the main menu
- Test auto-lock, biometric auth, and PIN change

## Platform Setup

### iOS
Add to `Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>We need to use Face ID to unlock the app</string>
```

### Android
Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

## Dependencies (Latest Versions)

- `flutter_secure_storage: ^9.2.4` - Secure storage
- `local_auth: ^3.0.0` - Biometric authentication
- `shared_preferences: ^2.5.3` - Settings storage
- `crypto: ^3.0.7` - Cryptographic functions

## Documentation

📖 **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive testing guide with:
- Feature checklist
- Test scenarios
- Troubleshooting
- Integration instructions

## Architecture

```
lib/app_lock/
├── reusable_app_lock.dart     # Main export
├── src/
│   ├── app_lock_manager.dart  # Core manager
│   ├── guards/                # Route protection
│   ├── models/                # Data models
│   ├── services/              # Storage & auth
│   ├── utils/                 # Crypto & helpers
│   └── widgets/               # UI components
```

## Usage Example

```dart
// Initialize
final manager = AppLockManager(
  config: AppLockConfig(
    pinMinLength: 4,
    maxAttempts: 5,
    lockoutDuration: Duration(minutes: 5),
    allowBiometrics: true,
  ),
);
await manager.initialize();

// Protect your app
AppLockGuard(
  manager: manager,
  child: YourApp(),
);
```

## Security

✅ PBKDF2 with 100,000 iterations
✅ Constant-time comparison
✅ Secure platform storage
✅ No plain-text PIN storage
✅ Automatic lockout protection

## Status

**Ready for Testing** ✅

All features implemented with latest package versions. See [TESTING_GUIDE.md](TESTING_GUIDE.md) for detailed testing instructions.

---

**Last Updated**: November 16, 2025
**Flutter SDK**: 3.4.1+
**License**: MIT
