/// Reusable App Lock Module
///
/// A production-ready Flutter package for implementing app-level PIN and
/// biometric authentication with secure storage, auto-lock, and retry limits.
///
/// ## Features
///
/// - **PIN Authentication**: Set, change, and verify PINs with PBKDF2 hashing
/// - **Biometric Authentication**: Face ID, Touch ID, and Android Biometric
/// - **Secure Storage**: Uses flutter_secure_storage for sensitive data
/// - **Auto-Lock**: Configurable timeout with background lock support
/// - **Brute-Force Protection**: Retry limits with lockout cooldown
/// - **Route Guards**: Protect routes with AppLockGuard widget
/// - **Customizable UI**: Themeable lock screen with localization support
/// - **Lifecycle Handling**: Automatic lock on app background
///
/// ## Quick Start
///
/// ```dart
/// import 'package:reuablewidgets/features/app_lock/reusable_app_lock.dart';
///
/// // Create manager with config
/// final manager = AppLockManager(
///   config: AppLockConfig(
///     pinMinLength: 4,
///     maxAttempts: 5,
///     lockoutDuration: Duration(minutes: 5),
///   ),
/// );
///
/// // Initialize
/// await manager.initialize();
///
/// // Set PIN
/// await manager.setPin('1234');
///
/// // Protect routes
/// AppLockGuard(
///   manager: manager,
///   child: MyProtectedScreen(),
/// );
/// ```
///
/// ## Security
///
/// - PINs are never stored in plain text
/// - Uses PBKDF2 with 100,000 iterations for PIN hashing
/// - Secrets stored in platform-specific secure storage (Keychain/KeyStore)
/// - Constant-time comparison to prevent timing attacks
/// - Brute-force protection with exponential backoff
///
/// ## Platform Setup
///
/// ### iOS
/// Add to Info.plist:
/// ```xml
/// <key>NSFaceIDUsageDescription</key>
/// <string>Unlock app with Face ID</string>
/// ```
///
/// ### Android
/// Add to AndroidManifest.xml:
/// ```xml
/// <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
/// ```
///
library reusable_app_lock;

// Core Manager
export 'src/app_lock_manager.dart';

// Models
export 'src/models/app_lock_config.dart';
export 'src/models/lock_state.dart';
export 'src/models/pin_verify_result.dart';
export 'src/models/lock_events.dart';

// Services (for advanced usage and testing)
export 'src/services/secure_storage_adapter.dart';
export 'src/services/settings_storage.dart';
export 'src/services/local_auth_service.dart';

// Widgets
export 'src/widgets/app_lock_screen.dart';
export 'src/widgets/pin_pad.dart';
export 'src/widgets/lock_indicator.dart';

// Guards
export 'src/guards/app_lock_guard.dart';

// Utilities (for advanced usage)
export 'src/utils/crypto_utils.dart' show CryptoUtils;
export 'src/utils/time_utils.dart' show TimeUtils;
