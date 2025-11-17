import 'package:flutter/foundation.dart';
import 'social_provider.dart';

/// User information from social provider
@immutable
class SocialUser {
  final String id;
  final String? email;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final Map<String, dynamic>? additionalInfo;

  const SocialUser({
    required this.id,
    this.email,
    this.name,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'additionalInfo': additionalInfo,
    };
  }

  @override
  String toString() => 'SocialUser(id: $id, email: $email, name: $name)';
}

/// Result of a social authentication attempt
@immutable
class AuthResult {
  final SocialProvider provider;
  final String? accessToken;
  final String? idToken;
  final String? authorizationCode;
  final SocialUser user;
  final Map<String, dynamic>? providerData;
  final DateTime timestamp;

  AuthResult({
    required this.provider,
    this.accessToken,
    this.idToken,
    this.authorizationCode,
    required this.user,
    this.providerData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;
  bool get hasIdToken => idToken != null && idToken!.isNotEmpty;
  bool get hasAuthCode => authorizationCode != null && authorizationCode!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.id,
      'accessToken': accessToken,
      'idToken': idToken,
      'authorizationCode': authorizationCode,
      'user': user.toJson(),
      'providerData': providerData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'AuthResult(provider: ${provider.name}, user: ${user.email})';
}
