import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/auth_service.dart';
import '../core/auth_result.dart';

/// REST API Authentication Service
///
/// Example implementation of AuthService using a custom REST API
class RestApiAuthService implements AuthService {
  final String baseUrl;
  final http.Client client;
  final Map<String, String> defaultHeaders;

  String? _sessionToken;

  RestApiAuthService({
    required this.baseUrl,
    http.Client? client,
    this.defaultHeaders = const {},
  }) : client = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> authenticateWithProvider(
    AuthResult authResult,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/social-login'),
        headers: {
          'Content-Type': 'application/json',
          ...defaultHeaders,
        },
        body: jsonEncode({
          'provider': authResult.provider.id,
          'accessToken': authResult.accessToken,
          'idToken': authResult.idToken,
          'authorizationCode': authResult.authorizationCode,
          'user': authResult.user.toJson(),
          'timestamp': authResult.timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Store session token
        _sessionToken = data['sessionToken'] as String?;

        return {
          'success': true,
          ...data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Authentication failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<void> signOut() async {
    if (_sessionToken == null) return;

    try {
      await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
          'Content-Type': 'application/json',
          ...defaultHeaders,
        },
      );
    } finally {
      _sessionToken = null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    if (_sessionToken == null) return false;

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
          ...defaultHeaders,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_sessionToken == null) return null;

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
          ...defaultHeaders,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Link social provider to existing account
  Future<Map<String, dynamic>> linkProvider(AuthResult authResult) async {
    if (_sessionToken == null) {
      throw Exception('User must be logged in to link provider');
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/link-provider'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
          'Content-Type': 'application/json',
          ...defaultHeaders,
        },
        body: jsonEncode({
          'provider': authResult.provider.id,
          'accessToken': authResult.accessToken,
          'idToken': authResult.idToken,
          'user': authResult.user.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          ...jsonDecode(response.body),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to link provider',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get current session token
  String? get sessionToken => _sessionToken;

  /// Set session token (for session restoration)
  set sessionToken(String? token) => _sessionToken = token;
}
