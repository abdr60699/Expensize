/// Retry interceptor with token refresh flow
library;

import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../core/api_response.dart';

/// Interceptor for retrying failed requests with token refresh
class RetryInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  final Future<ApiResponse<Map<String, dynamic>>> Function()? _onRefreshToken;
  final int maxRetries;

  bool _isRefreshing = false;
  final List<_RetryRequest> _requestQueue = [];

  RetryInterceptor({
    required TokenService tokenService,
    required Dio dio,
    Future<ApiResponse<Map<String, dynamic>>> Function()? onRefreshToken,
    this.maxRetries = 3,
  })  : _tokenService = tokenService,
        _dio = dio,
        _onRefreshToken = onRefreshToken;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if we should retry this request
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Handle 401 Unauthorized - try token refresh
    if (err.response?.statusCode == 401) {
      return _handleUnauthorized(err, handler);
    }

    // Handle network errors with retry
    if (_isNetworkError(err)) {
      return _handleNetworkError(err, handler);
    }

    return handler.next(err);
  }

  /// Handle 401 Unauthorized error with token refresh
  Future<void> _handleUnauthorized(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_onRefreshToken == null) {
      return handler.next(err);
    }

    // If already refreshing, queue the request
    if (_isRefreshing) {
      return _queueRequest(err, handler);
    }

    _isRefreshing = true;

    try {
      // Refresh the token
      final response = await _onRefreshToken!();

      if (response.success && response.data != null) {
        // Save new tokens
        final accessToken = response.data!['accessToken'] as String?;
        final refreshToken = response.data!['refreshToken'] as String?;

        if (accessToken != null) {
          await _tokenService.saveAccessToken(accessToken);

          if (refreshToken != null) {
            await _tokenService.saveRefreshToken(refreshToken);
          }

          // Retry the original request
          final newResponse = await _retryRequest(err.requestOptions);
          return handler.resolve(newResponse);
        }
      }

      // Refresh failed - reject all queued requests
      _isRefreshing = false;
      _rejectQueuedRequests(err);
      return handler.next(err);
    } catch (e) {
      _isRefreshing = false;
      _rejectQueuedRequests(err);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
      _processQueue();
    }
  }

  /// Handle network errors with retry logic
  Future<void> _handleNetworkError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    // Exponential backoff
    final delay = Duration(milliseconds: 500 * (retryCount + 1));
    await Future.delayed(delay);

    try {
      // Increment retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      // Retry the request
      final response = await _retryRequest(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }

  /// Queue request while token is being refreshed
  Future<void> _queueRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final completer = _RetryRequest(err.requestOptions, handler);
    _requestQueue.add(completer);
  }

  /// Process queued requests after token refresh
  void _processQueue() {
    for (final request in _requestQueue) {
      _retryRequest(request.options).then((response) {
        request.handler.resolve(response);
      }).catchError((error) {
        request.handler.reject(error as DioException);
      });
    }
    _requestQueue.clear();
  }

  /// Reject all queued requests
  void _rejectQueuedRequests(DioException error) {
    for (final request in _requestQueue) {
      request.handler.reject(error);
    }
    _requestQueue.clear();
  }

  /// Retry a request with updated token
  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    // Get new token
    final authHeader = await _tokenService.getAuthorizationHeader();
    if (authHeader != null) {
      options.headers['Authorization'] = authHeader;
    }

    // Create new request with updated options
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
        contentType: options.contentType,
        responseType: options.responseType,
        extra: options.extra,
      ),
    );
  }

  /// Check if request should be retried
  bool _shouldRetry(DioException err) {
    // Don't retry if explicitly disabled
    if (err.requestOptions.extra.containsKey('disableRetry') &&
        err.requestOptions.extra['disableRetry'] == true) {
      return false;
    }

    // Retry on 401 Unauthorized (for token refresh)
    if (err.response?.statusCode == 401) {
      return true;
    }

    // Retry on network errors
    if (_isNetworkError(err)) {
      return true;
    }

    return false;
  }

  /// Check if error is a network error
  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}

/// Queued request during token refresh
class _RetryRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.options, this.handler);
}
