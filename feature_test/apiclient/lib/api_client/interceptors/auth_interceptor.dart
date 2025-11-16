/// Authentication interceptor for Dio
library;

import 'package:dio/dio.dart';
import '../services/token_service.dart';

/// Interceptor for adding authentication tokens to requests
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;

  AuthInterceptor(this._tokenService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for certain endpoints (like login, register)
    if (_shouldSkipAuth(options)) {
      return handler.next(options);
    }

    // Get authorization header
    final authHeader = await _tokenService.getAuthorizationHeader();

    if (authHeader != null) {
      options.headers['Authorization'] = authHeader;
    }

    return handler.next(options);
  }

  /// Check if request should skip authentication
  bool _shouldSkipAuth(RequestOptions options) {
    // Check if request has skip auth flag
    if (options.extra.containsKey('skipAuth') &&
        options.extra['skipAuth'] == true) {
      return true;
    }

    // Skip auth for common authentication endpoints
    final skipPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
    ];

    return skipPaths.any((path) => options.path.contains(path));
  }
}
