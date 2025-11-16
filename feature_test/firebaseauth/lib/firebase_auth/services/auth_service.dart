import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import '../models/auth_result.dart';
import '../errors/auth_error.dart';
import '../repository/auth_repository.dart';
import 'social_auth/google_signin_adapter.dart';
import 'social_auth/apple_signin_adapter.dart';
import 'social_auth/facebook_signin_adapter.dart';
import 'phone_auth_service.dart';
import '../utils/auth_constants.dart';

/// Main authentication service facade.
///
/// This is the primary API for authentication operations. It orchestrates
/// repository, social sign-in adapters, and phone auth service.
///
/// **Email/Password:**
/// - [signUpWithEmail] - Create account
/// - [signInWithEmail] - Sign in
/// - [sendPasswordReset] - Reset password
/// - [sendEmailVerification] - Verify email
///
/// **Social Sign-In:**
/// - [signInWithGoogle] - Google OAuth
/// - [signInWithApple] - Apple Sign-In
/// - [signInWithFacebook] - Facebook Login
///
/// **Phone:**
/// - [signInWithPhone] - Phone OTP flow
/// - [verifyPhoneOtp] - Verify OTP code
///
/// **Anonymous:**
/// - [signInAnonymously] - Anonymous auth
///
/// **Account Management:**
/// - [linkProvider] - Link auth provider
/// - [unlinkProvider] - Unlink provider
/// - [updateProfile] - Update user profile
/// - [deleteAccount] - Delete user
/// - [reauthenticate] - Re-authenticate
///
/// **Session:**
/// - [signOut] - Sign out
/// - [refreshUser] - Refresh user data
/// - [getIdToken] - Get Firebase ID token
/// - [authStateChanges] - Stream of auth state
/// - [currentUser] - Current user (cached)
class AuthService {
  final AuthRepository _repository;
  final GoogleSignInAdapter _googleSignIn;
  final AppleSignInAdapter _appleSignIn;
  final FacebookSignInAdapter _facebookSignIn;
  final PhoneAuthService _phoneAuth;

  AuthService({
    required AuthRepository repository,
    GoogleSignInAdapter? googleSignIn,
    AppleSignInAdapter? appleSignIn,
    FacebookSignInAdapter? facebookSignIn,
    PhoneAuthService? phoneAuth,
  })  : _repository = repository,
        _googleSignIn = googleSignIn ?? GoogleSignInAdapter(),
        _appleSignIn = appleSignIn ?? AppleSignInAdapter(),
        _facebookSignIn = facebookSignIn ?? FacebookSignInAdapter(),
        _phoneAuth = phoneAuth ?? PhoneAuthService();

  // ==========================================================================
  // AUTH STATE
  // ==========================================================================

  /// Stream of authentication state changes
  ///
  /// Emits [UserModel] when user signs in, null when user signs out.
  Stream<UserModel?> get authStateChanges => _repository.authStateChanges;

  /// Get current user (cached)
  ///
  /// Returns null if no user is signed in.
  UserModel? get currentUser => _repository.currentUser;

  /// Refresh current user data from Firebase
  ///
  /// Reloads user data and updates cache. Returns updated user.
  Future<UserModel?> refreshUser() async {
    return await _repository.refreshUser();
  }

  /// Get Firebase ID token for current user
  ///
  /// [forceRefresh] will force token refresh even if not expired.
  ///
  /// Use this token for server-side verification and API calls.
  /// Token is automatically refreshed by Firebase SDK.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _repository.getIdToken(forceRefresh: forceRefresh);
  }

  // ==========================================================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ==========================================================================

  /// Sign up with email and password
  ///
  /// Creates a new user account and signs in.
  ///
  /// **Note:** Email verification is recommended. Use [sendEmailVerification]
  /// after sign-up and check [UserModel.emailVerified] before allowing access
  /// to sensitive features.
  ///
  /// **Errors:**
  /// - [AuthErrorCode.emailAlreadyInUse] - Email already registered
  /// - [AuthErrorCode.invalidEmail] - Invalid email format
  /// - [AuthErrorCode.weakPassword] - Password too weak
  ///
  /// **Example:**
  /// ```dart
  /// final result = await authService.signUpWithEmail(
  ///   email: 'user@example.com',
  ///   password: 'securePassword123',
  /// );
  ///
  /// result.onSuccess((user) {
  ///   if (result.requiresVerification) {
  ///     // Send verification email
  ///     authService.sendEmailVerification();
  ///   }
  /// }).onFailure((error) {
  ///   // Show error to user
  ///   print(error.friendlyMessage);
  /// });
  /// ```
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  ///
  /// **Errors:**
  /// - [AuthErrorCode.userNotFound] - No account with this email
  /// - [AuthErrorCode.wrongPassword] - Incorrect password
  /// - [AuthErrorCode.userDisabled] - Account disabled
  ///
  /// **Example:**
  /// ```dart
  /// final result = await authService.signInWithEmail(
  ///   email: 'user@example.com',
  ///   password: 'password',
  /// );
  ///
  /// if (result.isSuccess) {
  ///   // Navigate to home
  /// } else {
  ///   // Show error
  ///   showError(result.error!.friendlyMessage);
  /// }
  /// ```
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Send password reset email
  ///
  /// User will receive an email with a link to reset their password.
  ///
  /// **Errors:**
  /// - [AuthErrorCode.userNotFound] - No account with this email
  /// - [AuthErrorCode.invalidEmail] - Invalid email format
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.sendPasswordReset('user@example.com');
  ///   showMessage('Password reset email sent');
  /// } catch (e) {
  ///   if (e is AuthError) {
  ///     showError(e.friendlyMessage);
  ///   }
  /// }
  /// ```
  Future<void> sendPasswordReset(String email) async {
    await _repository.sendPasswordResetEmail(email);
  }

  /// Send email verification to current user
  ///
  /// User will receive an email with a verification link.
  ///
  /// **Note:** Call [refreshUser] after user clicks the link to update
  /// [UserModel.emailVerified] status.
  ///
  /// **Errors:**
  /// - [AuthErrorCode.userNotFound] - No user signed in
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.sendEmailVerification();
  ///   showMessage('Verification email sent');
  /// } catch (e) {
  ///   if (e is AuthError) {
  ///     showError(e.friendlyMessage);
  ///   }
  /// }
  /// ```
  Future<void> sendEmailVerification() async {
    await _repository.sendEmailVerification();
  }

  // ==========================================================================
  // SOCIAL SIGN-IN
  // ==========================================================================

  /// Sign in with Google
  ///
  /// Opens Google sign-in flow. On success, creates/signs in to Firebase account.
  ///
  /// **Platform Setup Required:**
  /// - Android: SHA-1/SHA-256 in Firebase console, google-services.json
  /// - iOS: GoogleService-Info.plist, URL schemes
  /// - Web: OAuth client ID in Firebase config
  ///
  /// **Errors:**
  /// - User cancellation returns error with unknown code
  /// - [AuthErrorCode.accountExistsWithDifferentCredential] - Email already used
  ///   with different provider (see [linkProvider] to merge accounts)
  ///
  /// **Example:**
  /// ```dart
  /// final result = await authService.signInWithGoogle();
  /// if (result.isSuccess) {
  ///   print('Signed in as ${result.user!.displayName}');
  /// }
  /// ```
  Future<AuthResult> signInWithGoogle() async {
    try {
      final credential = await _googleSignIn.signIn();
      return await _repository.signInWithCredential(credential);
    } on AuthError catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Sign in with Apple
  ///
  /// Opens Apple sign-in flow. Only available on iOS 13+, macOS 10.15+.
  ///
  /// **Platform Setup Required:**
  /// - iOS: Enable "Sign in with Apple" capability in Xcode
  /// - Apple Developer: Configure Sign in with Apple for your app ID
  /// - Firebase: Enable Apple provider in Authentication section
  ///
  /// **Errors:**
  /// - [AuthErrorCode.operationNotAllowed] - Not available on platform
  /// - User cancellation returns error with unknown code
  ///
  /// **Example:**
  /// ```dart
  /// if (AppleSignInAdapter.isAvailable) {
  ///   final result = await authService.signInWithApple();
  ///   // Handle result
  /// } else {
  ///   showMessage('Apple Sign-In not available');
  /// }
  /// ```
  Future<AuthResult> signInWithApple() async {
    try {
      final credential = await _appleSignIn.signIn();
      return await _repository.signInWithCredential(credential);
    } on AuthError catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Sign in with Facebook
  ///
  /// Opens Facebook login flow.
  ///
  /// **Platform Setup Required:**
  /// - Facebook App ID and App Name in Firebase console
  /// - Android: Facebook App ID in strings.xml
  /// - iOS: Facebook App ID in Info.plist, URL schemes
  /// - Facebook Developer: Configure OAuth redirect URIs
  ///
  /// **Errors:**
  /// - User cancellation returns error with unknown code
  /// - [AuthErrorCode.accountExistsWithDifferentCredential] - Email already used
  ///
  /// **Example:**
  /// ```dart
  /// final result = await authService.signInWithFacebook();
  /// if (result.isSuccess) {
  ///   print('Signed in as ${result.user!.displayName}');
  /// }
  /// ```
  Future<AuthResult> signInWithFacebook() async {
    try {
      final credential = await _facebookSignIn.signIn();
      return await _repository.signInWithCredential(credential);
    } on AuthError catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  // ==========================================================================
  // PHONE AUTHENTICATION
  // ==========================================================================

  /// Sign in with phone number (Step 1: Send OTP)
  ///
  /// Sends SMS with verification code to [phoneNumber].
  ///
  /// [phoneNumber] must be in E.164 format: +[country code][number]
  /// Example: +1234567890
  ///
  /// [forceResend] will resend code even if cooldown active.
  ///
  /// **Returns:**
  /// - On Android: May auto-complete when SMS received
  /// - On iOS/Web: Returns null, call [verifyPhoneOtp] after user enters code
  ///
  /// **Platform Considerations:**
  /// - Android: Auto-retrieval works, may need Play Integrity API
  /// - iOS: No auto-retrieval, user must enter code manually
  /// - Web: Requires reCAPTCHA verification
  ///
  /// **Errors:**
  /// - [AuthErrorCode.invalidPhoneNumber] - Invalid format
  /// - [AuthErrorCode.tooManyRequests] - SMS quota exceeded or cooldown active
  /// - [AuthErrorCode.quotaExceeded] - Daily SMS limit reached
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final credential = await authService.signInWithPhone('+1234567890');
  ///   if (credential != null) {
  ///     // Android auto-retrieved, sign in
  ///     final result = await _repository.signInWithCredential(credential);
  ///   } else {
  ///     // Show OTP input, wait for user to enter code
  ///     // Then call verifyPhoneOtp(code)
  ///   }
  /// } catch (e) {
  ///   // Handle error
  /// }
  /// ```
  Future<fb.AuthCredential?> signInWithPhone(
    String phoneNumber, {
    bool forceResend = false,
  }) async {
    return await _phoneAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResend: forceResend,
    );
  }

  /// Verify phone OTP code (Step 2: Complete verification)
  ///
  /// Call this after [signInWithPhone] when user enters the OTP code.
  ///
  /// [smsCode] is the 6-digit code from SMS.
  ///
  /// **Returns:** AuthCredential that can be used to sign in or link account.
  ///
  /// **Errors:**
  /// - [AuthErrorCode.invalidVerificationCode] - Wrong code
  /// - [AuthErrorCode.invalidVerificationId] - Verification expired
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final credential = authService.verifyPhoneOtp('123456');
  ///   final result = await _repository.signInWithCredential(credential);
  ///   if (result.isSuccess) {
  ///     // Signed in successfully
  ///   }
  /// } catch (e) {
  ///   showError('Invalid code');
  /// }
  /// ```
  fb.AuthCredential verifyPhoneOtp(String smsCode) {
    return _phoneAuth.verifyOtp(smsCode);
  }

  /// Check if phone OTP resend is available
  bool get canResendPhoneOtp => _phoneAuth.canResend;

  /// Time remaining until phone OTP resend is available
  Duration get phoneOtpResendCooldown => _phoneAuth.resendCooldownRemaining;

  // ==========================================================================
  // ANONYMOUS AUTHENTICATION
  // ==========================================================================

  /// Sign in anonymously
  ///
  /// Creates a temporary anonymous account. Useful for allowing users to try
  /// the app before signing up.
  ///
  /// **Anonymous Account Upgrade:**
  /// Use [linkProvider] to convert anonymous account to permanent by linking
  /// email/password or social provider.
  ///
  /// **Example:**
  /// ```dart
  /// // Sign in anonymously
  /// final result = await authService.signInAnonymously();
  ///
  /// // Later, upgrade to permanent account
  /// if (result.user!.isAnonymous) {
  ///   await authService.linkWithEmail(
  ///     email: 'user@example.com',
  ///     password: 'password',
  ///   );
  /// }
  /// ```
  Future<AuthResult> signInAnonymously() async {
    return await _repository.signInAnonymously();
  }

  // ==========================================================================
  // ACCOUNT LINKING/UNLINKING
  // ==========================================================================

  /// Link email/password to current account
  ///
  /// Adds email/password authentication to existing account (e.g., anonymous or social).
  ///
  /// **Use Cases:**
  /// - Upgrade anonymous account to permanent
  /// - Add email/password to social-only account
  ///
  /// **Errors:**
  /// - [AuthErrorCode.providerAlreadyLinked] - Email already linked
  /// - [AuthErrorCode.credentialAlreadyInUse] - Email used by another account
  /// - [AuthErrorCode.emailAlreadyInUse] - Email exists
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final result = await authService.linkWithEmail(
  ///     email: 'user@example.com',
  ///     password: 'password',
  ///   );
  ///   showMessage('Email linked successfully');
  /// } catch (e) {
  ///   // Handle error
  /// }
  /// ```
  Future<AuthResult> linkWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = fb.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    return await _repository.linkWithCredential(credential);
  }

  /// Link Google account to current account
  ///
  /// **Errors:**
  /// - [AuthErrorCode.providerAlreadyLinked] - Google already linked
  /// - [AuthErrorCode.credentialAlreadyInUse] - Google account used elsewhere
  Future<AuthResult> linkWithGoogle() async {
    try {
      final credential = await _googleSignIn.signIn();
      return await _repository.linkWithCredential(credential);
    } on AuthError catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Link Apple account to current account
  Future<AuthResult> linkWithApple() async {
    try {
      final credential = await _appleSignIn.signIn();
      return await _repository.linkWithCredential(credential);
    } on AuthError catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Link Facebook account to current account
  Future<AuthResult> linkWithFacebook() async {
    try {
      final credential = await _facebookSignIn.signIn();
      return await _repository.linkWithCredential(credential);
    } on AuthError catch (e) {
      return AuthResult.failure(e);
    } catch (e) {
      return AuthResult.failure(AuthError.fromException(e));
    }
  }

  /// Link phone number to current account
  ///
  /// Two-step process:
  /// 1. Call this to send OTP
  /// 2. Call [linkPhoneWithOtp] to complete linking
  Future<void> linkWithPhone(String phoneNumber) async {
    await _phoneAuth.verifyPhoneNumber(phoneNumber: phoneNumber);
  }

  /// Complete phone linking with OTP code
  Future<AuthResult> linkPhoneWithOtp(String smsCode) async {
    final credential = _phoneAuth.verifyOtp(smsCode);
    return await _repository.linkWithCredential(credential);
  }

  /// Unlink authentication provider
  ///
  /// Removes a linked provider from the account.
  ///
  /// [providerId] can be:
  /// - 'password' (email/password)
  /// - 'google.com'
  /// - 'apple.com'
  /// - 'facebook.com'
  /// - 'phone'
  ///
  /// **Note:** Cannot unlink if it's the only sign-in method.
  ///
  /// **Example:**
  /// ```dart
  /// // Unlink Google
  /// await authService.unlinkProvider('google.com');
  ///
  /// // Or use constants
  /// await authService.unlinkProvider(AuthConstants.googleProvider);
  /// ```
  Future<AuthResult> unlinkProvider(String providerId) async {
    return await _repository.unlinkProvider(providerId);
  }

  // ==========================================================================
  // ACCOUNT MANAGEMENT
  // ==========================================================================

  /// Update user profile
  ///
  /// Updates display name and/or photo URL.
  ///
  /// **Example:**
  /// ```dart
  /// await authService.updateProfile(
  ///   displayName: 'John Doe',
  ///   photoUrl: 'https://example.com/photo.jpg',
  /// );
  /// ```
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    await _repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  /// Re-authenticate with email/password
  ///
  /// Required before sensitive operations like:
  /// - Changing email
  /// - Changing password
  /// - Deleting account
  ///
  /// **Errors:**
  /// - [AuthErrorCode.wrongPassword] - Incorrect password
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.reauthenticateWithEmail(
  ///     email: user.email!,
  ///     password: 'currentPassword',
  ///   );
  ///   // Now can perform sensitive operation
  ///   await authService.deleteAccount();
  /// } catch (e) {
  ///   showError('Incorrect password');
  /// }
  /// ```
  Future<void> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    await _repository.reauthenticateWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Delete user account
  ///
  /// Permanently deletes the user account and all associated data.
  ///
  /// **May require recent authentication:** If the operation fails with
  /// [AuthErrorCode.requiresRecentLogin], call [reauthenticateWithEmail]
  /// first, then try again.
  ///
  /// **Warning:** This action cannot be undone.
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.deleteAccount();
  ///   // Account deleted, navigate to welcome screen
  /// } on AuthError catch (e) {
  ///   if (e.code == AuthErrorCode.requiresRecentLogin) {
  ///     // Ask user to sign in again
  ///     showReauthDialog();
  ///   }
  /// }
  /// ```
  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
  }

  // ==========================================================================
  // SESSION MANAGEMENT
  // ==========================================================================

  /// Sign out
  ///
  /// Signs out the current user and clears all local session data.
  ///
  /// **Example:**
  /// ```dart
  /// await authService.signOut();
  /// // Navigate to login screen
  /// ```
  Future<void> signOut() async {
    // Sign out from social providers
    await _googleSignIn.signOut();
    await _facebookSignIn.signOut();

    // Sign out from Firebase
    await _repository.signOut();

    // Clear phone auth state
    _phoneAuth.clear();
  }

  /// Dispose service resources
  ///
  /// Call this when the service is no longer needed (e.g., app shutdown).
  void dispose() {
    _repository.dispose();
  }
}
