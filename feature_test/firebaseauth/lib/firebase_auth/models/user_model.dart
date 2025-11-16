import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Domain model representing an authenticated user.
///
/// This model is decoupled from Firebase's User class and contains
/// only serializable, safe-to-store fields. It can be persisted,
/// cached, and used throughout the app without Firebase dependencies.
class UserModel {
  /// Unique user identifier from Firebase Auth
  final String uid;

  /// User's email address (may be null for phone/anonymous users)
  final String? email;

  /// User's phone number (may be null)
  final String? phoneNumber;

  /// Display name
  final String? displayName;

  /// Profile photo URL
  final String? photoUrl;

  /// Whether email has been verified
  final bool emailVerified;

  /// Whether this is an anonymous account
  final bool isAnonymous;

  /// List of linked provider IDs (e.g., 'google.com', 'password', 'phone')
  final List<String> providerIds;

  /// Account creation timestamp
  final DateTime? createdAt;

  /// Last sign-in timestamp
  final DateTime? lastSignInAt;

  /// Custom metadata (optional, for app-specific data)
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.isAnonymous = false,
    this.providerIds = const [],
    this.createdAt,
    this.lastSignInAt,
    this.metadata,
  });

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(fb.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
      providerIds: user.providerData.map((info) => info.providerId).toList(),
      createdAt: user.metadata.creationTime,
      lastSignInAt: user.metadata.lastSignInTime,
    );
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      providerIds: (json['providerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastSignInAt: json['lastSignInAt'] != null
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      'providerIds': providerIds,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if user has a specific provider linked
  bool hasProvider(String providerId) {
    return providerIds.contains(providerId);
  }

  /// Check if user can be upgraded (anonymous to permanent)
  bool get canBeUpgraded => isAnonymous;

  /// Copy with new values
  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    bool? isAnonymous,
    List<String>? providerIds,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      providerIds: providerIds ?? this.providerIds,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          emailVerified == other.emailVerified &&
          isAnonymous == other.isAnonymous;

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      emailVerified.hashCode ^
      isAnonymous.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, phone: $phoneNumber, '
        'emailVerified: $emailVerified, isAnonymous: $isAnonymous, '
        'providers: $providerIds)';
  }
}
