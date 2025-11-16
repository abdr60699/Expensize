/// Represents the current lock state of the application
class LockState {
  /// Whether the app is currently locked
  final bool locked;

  /// Timestamp when the app was locked (null if not locked)
  final DateTime? lockedAt;

  /// Timestamp when the app was last unlocked (null if never unlocked)
  final DateTime? lastUnlockedAt;

  /// Number of failed unlock attempts
  final int failedAttempts;

  /// Whether the user is currently locked out due to too many failed attempts
  final bool isLockedOut;

  /// Timestamp when lockout will expire (null if not locked out)
  final DateTime? lockoutExpiresAt;

  const LockState({
    required this.locked,
    this.lockedAt,
    this.lastUnlockedAt,
    this.failedAttempts = 0,
    this.isLockedOut = false,
    this.lockoutExpiresAt,
  });

  /// Creates initial unlocked state
  factory LockState.unlocked() {
    return const LockState(
      locked: false,
      failedAttempts: 0,
      isLockedOut: false,
    );
  }

  /// Creates locked state
  factory LockState.locked() {
    return LockState(
      locked: true,
      lockedAt: DateTime.now(),
      failedAttempts: 0,
      isLockedOut: false,
    );
  }

  /// Creates a copy with modified properties
  LockState copyWith({
    bool? locked,
    DateTime? lockedAt,
    DateTime? lastUnlockedAt,
    int? failedAttempts,
    bool? isLockedOut,
    DateTime? lockoutExpiresAt,
  }) {
    return LockState(
      locked: locked ?? this.locked,
      lockedAt: lockedAt ?? this.lockedAt,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      isLockedOut: isLockedOut ?? this.isLockedOut,
      lockoutExpiresAt: lockoutExpiresAt ?? this.lockoutExpiresAt,
    );
  }

  /// Whether lockout has expired
  bool get isLockoutExpired {
    if (!isLockedOut || lockoutExpiresAt == null) return true;
    return DateTime.now().isAfter(lockoutExpiresAt!);
  }

  /// Remaining lockout duration
  Duration? get remainingLockoutDuration {
    if (!isLockedOut || lockoutExpiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(lockoutExpiresAt!)) return Duration.zero;
    return lockoutExpiresAt!.difference(now);
  }

  @override
  String toString() {
    return 'LockState('
        'locked: $locked, '
        'failedAttempts: $failedAttempts, '
        'isLockedOut: $isLockedOut, '
        'lockoutExpiresAt: $lockoutExpiresAt)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockState &&
          runtimeType == other.runtimeType &&
          locked == other.locked &&
          failedAttempts == other.failedAttempts &&
          isLockedOut == other.isLockedOut;

  @override
  int get hashCode =>
      locked.hashCode ^ failedAttempts.hashCode ^ isLockedOut.hashCode;
}
