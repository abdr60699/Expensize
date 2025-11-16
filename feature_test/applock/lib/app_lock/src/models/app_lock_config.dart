import 'package:flutter/material.dart';

/// Configuration for the AppLockManager.
///
/// Controls behavior like PIN length requirements, retry limits,
/// lockout duration, auto-lock timeout, and biometric settings.
class AppLockConfig {
  /// Minimum length for PIN (default: 4)
  final int pinMinLength;

  /// Maximum number of failed attempts before lockout (default: 5)
  final int maxAttempts;

  /// Duration to lock user out after maxAttempts failures (default: 5 minutes)
  final Duration lockoutDuration;

  /// Auto-lock timeout after inactivity (default: 60 seconds)
  final Duration autoLockTimeout;

  /// Whether biometric authentication is allowed (default: true)
  final bool allowBiometrics;

  /// Whether to require PIN setup on first app launch (default: false)
  final bool requirePinOnInstall;

  /// Prefix for secure storage keys (default: "reusable_app_lock_")
  final String secureStorageKeyPrefix;

  /// Number of PBKDF2 iterations for PIN hashing (default: 100,000)
  /// Higher values are more secure but slower
  final int pbkdf2Iterations;

  /// Primary color for UI theming
  final Color? primaryColor;

  /// Background color for lock screen
  final Color? backgroundColor;

  /// Text color for UI elements
  final Color? textColor;

  /// Custom title for lock screen
  final String? lockScreenTitle;

  /// Custom subtitle for lock screen
  final String? lockScreenSubtitle;

  const AppLockConfig({
    this.pinMinLength = 4,
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 5),
    this.autoLockTimeout = const Duration(seconds: 60),
    this.allowBiometrics = true,
    this.requirePinOnInstall = false,
    this.secureStorageKeyPrefix = 'reusable_app_lock_',
    this.pbkdf2Iterations = 100000,
    this.primaryColor,
    this.backgroundColor,
    this.textColor,
    this.lockScreenTitle,
    this.lockScreenSubtitle,
  });

  /// Creates a copy with modified properties
  AppLockConfig copyWith({
    int? pinMinLength,
    int? maxAttempts,
    Duration? lockoutDuration,
    Duration? autoLockTimeout,
    bool? allowBiometrics,
    bool? requirePinOnInstall,
    String? secureStorageKeyPrefix,
    int? pbkdf2Iterations,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    String? lockScreenTitle,
    String? lockScreenSubtitle,
  }) {
    return AppLockConfig(
      pinMinLength: pinMinLength ?? this.pinMinLength,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      lockoutDuration: lockoutDuration ?? this.lockoutDuration,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      allowBiometrics: allowBiometrics ?? this.allowBiometrics,
      requirePinOnInstall: requirePinOnInstall ?? this.requirePinOnInstall,
      secureStorageKeyPrefix:
          secureStorageKeyPrefix ?? this.secureStorageKeyPrefix,
      pbkdf2Iterations: pbkdf2Iterations ?? this.pbkdf2Iterations,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      lockScreenTitle: lockScreenTitle ?? this.lockScreenTitle,
      lockScreenSubtitle: lockScreenSubtitle ?? this.lockScreenSubtitle,
    );
  }

  @override
  String toString() {
    return 'AppLockConfig('
        'pinMinLength: $pinMinLength, '
        'maxAttempts: $maxAttempts, '
        'lockoutDuration: $lockoutDuration, '
        'autoLockTimeout: $autoLockTimeout, '
        'allowBiometrics: $allowBiometrics, '
        'requirePinOnInstall: $requirePinOnInstall)';
  }
}
