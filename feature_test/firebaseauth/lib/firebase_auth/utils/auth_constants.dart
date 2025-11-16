/// Constants used throughout the auth module
class AuthConstants {
  AuthConstants._();

  /// Provider IDs
  static const String emailProvider = 'password';
  static const String googleProvider = 'google.com';
  static const String appleProvider = 'apple.com';
  static const String facebookProvider = 'facebook.com';
  static const String phoneProvider = 'phone';
  static const String anonymousProvider = 'anonymous';

  /// Password requirements
  static const int minPasswordLength = 6;
  static const int strongPasswordLength = 8;

  /// Phone OTP
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
  static const int otpResendCooldownSeconds = 30;

  /// Session
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  /// UI
  static const Duration loadingDelay = Duration(milliseconds: 500);
  static const Duration errorDisplayDuration = Duration(seconds: 3);

  /// Links
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
  static const String supportUrl = 'https://yourapp.com/support';

  /// Error messages (fallback)
  static const String genericErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String networkErrorMessage =
      'Network connection failed. Please check your internet connection.';
  static const String sessionExpiredMessage =
      'Your session has expired. Please sign in again.';

  /// Success messages
  static const String signUpSuccessMessage = 'Account created successfully!';
  static const String signInSuccessMessage = 'Welcome back!';
  static const String emailVerificationSentMessage =
      'Verification email sent. Please check your inbox.';
  static const String passwordResetSentMessage =
      'Password reset email sent. Please check your inbox.';
  static const String accountLinkedMessage = 'Account linked successfully!';
  static const String accountUnlinkedMessage = 'Account unlinked successfully!';

  /// Regular expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(r'^\+\d{10,15}$');
  static final RegExp strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );
}

/// Provider display names and icons
class ProviderInfo {
  final String id;
  final String displayName;
  final String iconAsset;

  const ProviderInfo({
    required this.id,
    required this.displayName,
    required this.iconAsset,
  });

  static const ProviderInfo email = ProviderInfo(
    id: AuthConstants.emailProvider,
    displayName: 'Email',
    iconAsset: 'assets/icons/email.png',
  );

  static const ProviderInfo google = ProviderInfo(
    id: AuthConstants.googleProvider,
    displayName: 'Google',
    iconAsset: 'assets/icons/google.png',
  );

  static const ProviderInfo apple = ProviderInfo(
    id: AuthConstants.appleProvider,
    displayName: 'Apple',
    iconAsset: 'assets/icons/apple.png',
  );

  static const ProviderInfo facebook = ProviderInfo(
    id: AuthConstants.facebookProvider,
    displayName: 'Facebook',
    iconAsset: 'assets/icons/facebook.png',
  );

  static const ProviderInfo phone = ProviderInfo(
    id: AuthConstants.phoneProvider,
    displayName: 'Phone',
    iconAsset: 'assets/icons/phone.png',
  );

  static ProviderInfo? fromId(String id) {
    switch (id) {
      case AuthConstants.emailProvider:
        return email;
      case AuthConstants.googleProvider:
        return google;
      case AuthConstants.appleProvider:
        return apple;
      case AuthConstants.facebookProvider:
        return facebook;
      case AuthConstants.phoneProvider:
        return phone;
      default:
        return null;
    }
  }
}
