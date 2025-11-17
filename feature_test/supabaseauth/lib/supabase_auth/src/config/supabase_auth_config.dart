import '../models/social_provider.dart';

/// Password validation requirements
class PasswordRequirements {
  /// Minimum password length
  final int minLength;

  /// Require at least one uppercase letter
  final bool requireUppercase;

  /// Require at least one digit
  final bool requireDigit;

  /// Require at least one special character
  final bool requireSpecialChar;

  const PasswordRequirements({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireDigit = true,
    this.requireSpecialChar = true,
  });

  /// Default secure requirements
  static const secure = PasswordRequirements(
    minLength: 8,
    requireUppercase: true,
    requireDigit: true,
    requireSpecialChar: true,
  );

  /// Basic requirements
  static const basic = PasswordRequirements(
    minLength: 6,
    requireUppercase: false,
    requireDigit: false,
    requireSpecialChar: false,
  );
}

/// Configuration for Supabase authentication
class SupabaseAuthConfig {
  /// Supabase project URL
  final String supabaseUrl;

  /// Supabase anonymous key
  final String supabaseAnonKey;

  /// Enabled OAuth providers
  final List<SocialProvider> enabledProviders;

  /// Use secure storage for session tokens
  final bool useSecureStorageForSession;

  /// Redirect URL for OAuth callbacks
  final String? redirectUrl;

  /// OAuth scopes
  final Map<SocialProvider, List<String>>? providerScopes;

  /// Password requirements for signup
  final PasswordRequirements passwordRequirements;

  /// Enable email confirmation requirement
  final bool requireEmailConfirmation;

  /// Enable debug logging
  final bool enableLogging;

  /// Custom auth URL (for self-hosted)
  final String? authUrl;

  const SupabaseAuthConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.enabledProviders = const [
      SocialProvider.google,
      SocialProvider.apple,
      SocialProvider.facebook,
    ],
    this.useSecureStorageForSession = true,
    this.redirectUrl,
    this.providerScopes,
    this.passwordRequirements = PasswordRequirements.secure,
    this.requireEmailConfirmation = true,
    this.enableLogging = false,
    this.authUrl,
  });

  /// Create configuration from environment variables
  factory SupabaseAuthConfig.fromEnvironment({
    required Map<String, String> env,
    List<SocialProvider>? enabledProviders,
    bool useSecureStorageForSession = true,
    PasswordRequirements? passwordRequirements,
    bool requireEmailConfirmation = true,
    bool enableLogging = false,
  }) {
    final supabaseUrl = env['SUPABASE_URL'];
    final supabaseAnonKey = env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in environment',
      );
    }

    return SupabaseAuthConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      enabledProviders: enabledProviders ??
          const [
            SocialProvider.google,
            SocialProvider.apple,
            SocialProvider.facebook,
          ],
      useSecureStorageForSession: useSecureStorageForSession,
      redirectUrl: env['SUPABASE_REDIRECT_URL'],
      passwordRequirements: passwordRequirements ?? PasswordRequirements.secure,
      requireEmailConfirmation: requireEmailConfirmation,
      enableLogging: enableLogging,
      authUrl: env['SUPABASE_AUTH_URL'],
    );
  }

  SupabaseAuthConfig copyWith({
    String? supabaseUrl,
    String? supabaseAnonKey,
    List<SocialProvider>? enabledProviders,
    bool? useSecureStorageForSession,
    String? redirectUrl,
    Map<SocialProvider, List<String>>? providerScopes,
    PasswordRequirements? passwordRequirements,
    bool? requireEmailConfirmation,
    bool? enableLogging,
    String? authUrl,
  }) {
    return SupabaseAuthConfig(
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      enabledProviders: enabledProviders ?? this.enabledProviders,
      useSecureStorageForSession:
          useSecureStorageForSession ?? this.useSecureStorageForSession,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      providerScopes: providerScopes ?? this.providerScopes,
      passwordRequirements: passwordRequirements ?? this.passwordRequirements,
      requireEmailConfirmation:
          requireEmailConfirmation ?? this.requireEmailConfirmation,
      enableLogging: enableLogging ?? this.enableLogging,
      authUrl: authUrl ?? this.authUrl,
    );
  }
}
