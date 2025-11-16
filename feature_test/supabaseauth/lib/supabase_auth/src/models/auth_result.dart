import 'social_provider.dart';

/// Represents the result of an authentication operation
class AuthResult {
  /// The authentication provider used (email, google, apple, etc.)
  final String provider;

  /// User information
  final AuthUser user;

  /// Access token for API requests
  final String? accessToken;

  /// Refresh token for obtaining new access tokens
  final String? refreshToken;

  /// When the access token expires
  final DateTime? expiresAt;

  /// Additional data from the provider
  final Map<String, dynamic>? providerData;

  /// Timestamp of when this result was created
  final DateTime timestamp;

  const AuthResult({
    required this.provider,
    required this.user,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.providerData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? const Duration().inMilliseconds as DateTime;

  /// Copy with new values
  AuthResult copyWith({
    String? provider,
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    Map<String, dynamic>? providerData,
    DateTime? timestamp,
  }) {
    return AuthResult(
      provider: provider ?? this.provider,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      providerData: providerData ?? this.providerData,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
      'providerData': providerData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      provider: json['provider'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      providerData: json['providerData'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Represents a user in the authentication system
class AuthUser {
  /// Unique user ID
  final String id;

  /// User's email address
  final String? email;

  /// User's full name
  final String? name;

  /// URL to user's avatar/profile picture
  final String? avatarUrl;

  /// Whether the email has been confirmed
  final DateTime? confirmedAt;

  /// User metadata
  final Map<String, dynamic>? metadata;

  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.confirmedAt,
    this.metadata,
  });

  /// Whether the user's email is confirmed
  bool get isEmailConfirmed => confirmedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? confirmedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
