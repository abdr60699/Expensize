# Changelog

All notable changes to the Reusable App Lock module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Reusable App Lock module
- **PIN Authentication**
  - Secure PIN setup with PBKDF2-HMAC-SHA256 hashing (100,000 iterations)
  - PIN verification with brute-force protection
  - PIN change functionality with old PIN verification
  - Configurable minimum PIN length (default: 4 digits)

- **Biometric Authentication**
  - Face ID support for iOS
  - Touch ID support for iOS
  - Android Biometric support (fingerprint, face, iris)
  - Fallback to PIN when biometric fails
  - Enable/disable biometric from settings

- **Security Features**
  - Secure storage using flutter_secure_storage (Keychain/KeyStore)
  - PBKDF2 key derivation with configurable iterations
  - Random 256-bit salt generation
  - Constant-time comparison to prevent timing attacks
  - Failed attempt tracking with lockout
  - Configurable lockout duration (default: 5 minutes)
  - Configurable maximum attempts (default: 5)

- **Auto-Lock**
  - Configurable inactivity timeout
  - Automatic lock on app background
  - Automatic lock on app inactive
  - Manual lock capability
  - Lifecycle-aware implementation

- **UI Components**
  - AppLockScreen widget with three modes (setup, verify, change)
  - PinPad numeric keypad widget
  - LockIndicator for PIN entry visualization
  - Customizable theming (colors, text)
  - Smooth animations and transitions
  - Accessibility support

- **Route Protection**
  - AppLockGuard widget for protecting routes
  - AppLockRouteGuard for navigation integration
  - Option to show lock screen as dialog overlay
  - Callbacks for lock/unlock events

- **Events and Monitoring**
  - Lock state change stream
  - Lock events stream (locked, unlocked, failed, lockout, PIN changed)
  - Real-time failed attempts tracking
  - Lockout countdown

- **Testing**
  - Comprehensive unit tests for crypto utilities
  - Unit tests for AppLockManager
  - Widget tests for UI components
  - Mock-friendly architecture
  - Test coverage for critical security flows

- **Documentation**
  - Comprehensive README with examples
  - Platform setup guide for iOS and Android
  - API reference documentation
  - Security considerations
  - Troubleshooting guide
  - Example application

### Security
- All PINs hashed with PBKDF2-HMAC-SHA256
- Secrets stored only in platform secure storage
- Constant-time string comparison
- Brute-force protection with lockout
- Biometric data never leaves device

### Known Limitations
- Biometrics may not work reliably on some Android emulators
- Server-assisted PIN recovery not yet implemented
- Encrypted backup/export not yet implemented

## [Unreleased]

### Planned Features
- Server-assisted PIN recovery
- Encrypted backup and restore
- Multiple PIN profiles (app PIN vs section PIN)
- PIN complexity requirements (alphanumeric, symbols)
- Customizable grace period before lockout
- Biometric-only mode (no PIN fallback)
- Analytics and logging hooks
- Multi-language support

---

For more information, see the [README](./README.md).
