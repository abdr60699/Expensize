/// Result of a PIN verification attempt
class PinVerifyResult {
  /// Whether the PIN verification was successful
  final bool success;

  /// Number of attempts remaining before lockout (0 means locked out)
  final int attemptsRemaining;

  /// Whether the user is currently locked out
  final bool lockedOut;

  /// Optional message explaining the result
  final String? message;

  /// Duration until lockout expires (null if not locked out)
  final Duration? lockoutDuration;

  const PinVerifyResult({
    required this.success,
    required this.attemptsRemaining,
    required this.lockedOut,
    this.message,
    this.lockoutDuration,
  });

  /// Creates a successful verification result
  factory PinVerifyResult.success() {
    return const PinVerifyResult(
      success: true,
      attemptsRemaining: 0,
      lockedOut: false,
      message: 'PIN verified successfully',
    );
  }

  /// Creates a failed verification result
  factory PinVerifyResult.failure({
    required int attemptsRemaining,
    String? message,
  }) {
    return PinVerifyResult(
      success: false,
      attemptsRemaining: attemptsRemaining,
      lockedOut: false,
      message: message ?? 'Incorrect PIN',
    );
  }

  /// Creates a locked out result
  factory PinVerifyResult.lockout({
    required Duration lockoutDuration,
    String? message,
  }) {
    return PinVerifyResult(
      success: false,
      attemptsRemaining: 0,
      lockedOut: true,
      lockoutDuration: lockoutDuration,
      message: message ?? 'Too many failed attempts. Please try again later.',
    );
  }

  @override
  String toString() {
    return 'PinVerifyResult('
        'success: $success, '
        'attemptsRemaining: $attemptsRemaining, '
        'lockedOut: $lockedOut, '
        'message: $message)';
  }
}
