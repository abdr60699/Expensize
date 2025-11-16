/// Validation utilities for authentication inputs
class AuthValidators {
  AuthValidators._();

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validate strong password (letters, numbers, special chars)
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate phone number format
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces, dashes, and parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it starts with + and has 10-15 digits
    if (!cleaned.startsWith('+')) {
      return 'Phone number must start with country code (e.g., +1)';
    }

    final digits = cleaned.substring(1);
    if (!RegExp(r'^\d{10,15}$').hasMatch(digits)) {
      return 'Please enter a valid phone number with country code';
    }

    return null;
  }

  /// Validate OTP code
  static String? validateOtpCode(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Verification code is required';
    }

    if (value.length != length) {
      return 'Verification code must be $length digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Verification code must contain only numbers';
    }

    return null;
  }

  /// Validate display name
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Only letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Check if email is valid (boolean)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  /// Check if password is valid (boolean)
  static bool isValidPassword(String password, {int minLength = 6}) {
    return validatePassword(password, minLength: minLength) == null;
  }

  /// Check if phone number is valid (boolean)
  static bool isValidPhoneNumber(String phone) {
    return validatePhoneNumber(phone) == null;
  }

  /// Sanitize phone number (remove formatting, keep + and digits)
  static String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Format phone number for display (e.g., +1 (555) 123-4567)
  static String formatPhoneNumber(String phone) {
    final cleaned = sanitizePhoneNumber(phone);

    if (cleaned.startsWith('+1') && cleaned.length == 12) {
      // US/Canada format
      return '+1 (${cleaned.substring(2, 5)}) ${cleaned.substring(5, 8)}-${cleaned.substring(8)}';
    }

    return phone; // Return original if not recognized format
  }
}
