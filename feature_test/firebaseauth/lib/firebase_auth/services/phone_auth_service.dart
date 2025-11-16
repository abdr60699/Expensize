import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../errors/auth_error.dart';
import '../utils/auth_constants.dart';

/// Service for handling phone number authentication with OTP.
///
/// Supports:
/// - Sending OTP to phone numbers
/// - Auto-retrieval on Android
/// - Manual OTP verification
/// - Resend with cooldown
class PhoneAuthService {
  final fb.FirebaseAuth _firebaseAuth;

  /// Currently active verification ID
  String? _verificationId;

  /// Resend token for retry logic
  int? _resendToken;

  /// Last OTP send time (for cooldown)
  DateTime? _lastOtpSentTime;

  /// Verification completer for auto-retrieval
  Completer<fb.AuthCredential>? _verificationCompleter;

  /// Timeout duration for verification
  final Duration verificationTimeout;

  /// Resend cooldown duration
  final Duration resendCooldown;

  PhoneAuthService({
    fb.FirebaseAuth? firebaseAuth,
    this.verificationTimeout = const Duration(seconds: AuthConstants.otpTimeoutSeconds),
    this.resendCooldown = const Duration(seconds: AuthConstants.otpResendCooldownSeconds),
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  /// Get current verification ID
  String? get verificationId => _verificationId;

  /// Check if resend is available (cooldown expired)
  bool get canResend {
    if (_lastOtpSentTime == null) return true;
    final elapsed = DateTime.now().difference(_lastOtpSentTime!);
    return elapsed >= resendCooldown;
  }

  /// Time remaining until resend is available
  Duration get resendCooldownRemaining {
    if (_lastOtpSentTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastOtpSentTime!);
    final remaining = resendCooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Verify phone number and send OTP
  ///
  /// [phoneNumber] must be in E.164 format (e.g., +1234567890)
  /// [forceResend] will use resend token if available
  ///
  /// Returns a Future that completes when:
  /// - On Android with auto-retrieval: automatically when SMS is received
  /// - On iOS/Web: when user manually enters code via [verifyOtp]
  ///
  /// Call [verifyOtp] manually if auto-retrieval doesn't work.
  Future<fb.AuthCredential?> verifyPhoneNumber({
    required String phoneNumber,
    bool forceResend = false,
  }) async {
    if (!forceResend && !canResend) {
      throw AuthError.custom(
        code: AuthErrorCode.tooManyRequests,
        message: 'Please wait before requesting another code',
        recoverySuggestion:
            'Wait ${resendCooldownRemaining.inSeconds} seconds',
      );
    }

    _verificationCompleter = Completer<fb.AuthCredential>();
    _lastOtpSentTime = DateTime.now();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: verificationTimeout,
        forceResendingToken: forceResend ? _resendToken : null,

        // Called when verification is completed automatically (Android)
        verificationCompleted: (fb.PhoneAuthCredential credential) {
          if (!_verificationCompleter!.isCompleted) {
            _verificationCompleter!.complete(credential);
          }
        },

        // Called when verification fails
        verificationFailed: (fb.FirebaseAuthException e) {
          if (!_verificationCompleter!.isCompleted) {
            _verificationCompleter!.completeError(
              AuthError.fromFirebaseException(e),
            );
          }
        },

        // Called when code is sent
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          // Don't complete here - wait for manual verification or auto-complete
        },

        // Called when auto-retrieval timeout expires
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          // Don't complete - user will verify manually
        },
      );

      // Return the credential (will complete when code is verified)
      return await _verificationCompleter!.future;
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError.fromException(e);
    }
  }

  /// Verify OTP code manually
  ///
  /// Use this when auto-retrieval doesn't work or on iOS/Web.
  /// [smsCode] is the 6-digit code from SMS.
  ///
  /// Returns Firebase credential that can be used to sign in.
  fb.AuthCredential verifyOtp(String smsCode) {
    if (_verificationId == null) {
      throw AuthError.custom(
        code: AuthErrorCode.invalidVerificationId,
        message: 'No verification in progress',
        recoverySuggestion: 'Request a new verification code',
      );
    }

    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Complete the verification completer if still pending
      if (_verificationCompleter != null &&
          !_verificationCompleter!.isCompleted) {
        _verificationCompleter!.complete(credential);
      }

      return credential;
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Create phone credential from verification ID and SMS code
  ///
  /// Alternative to [verifyOtp] if you want to create credential directly.
  fb.AuthCredential createCredential({
    required String verificationId,
    required String smsCode,
  }) {
    try {
      return fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
    } catch (e) {
      throw AuthError.fromException(e);
    }
  }

  /// Reset verification state
  ///
  /// Call this to start a new verification flow.
  void reset() {
    _verificationId = null;
    _resendToken = null;
    _verificationCompleter = null;
    // Don't reset _lastOtpSentTime to preserve cooldown
  }

  /// Clear all state including cooldown
  void clear() {
    _verificationId = null;
    _resendToken = null;
    _lastOtpSentTime = null;
    _verificationCompleter = null;
  }
}
