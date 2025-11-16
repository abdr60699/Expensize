/// Logging interceptor for Dio
library;

import 'package:dio/dio.dart';

/// Interceptor for logging HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  final bool enableRequestLogging;
  final bool enableResponseLogging;
  final bool enableErrorLogging;
  final bool logHeaders;
  final bool logRequestBody;
  final bool logResponseBody;

  LoggingInterceptor({
    this.enableRequestLogging = true,
    this.enableResponseLogging = true,
    this.enableErrorLogging = true,
    this.logHeaders = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enableRequestLogging) {
      _logRequest(options);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableResponseLogging) {
      _logResponse(response);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableErrorLogging) {
      _logError(err);
    }
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    print('╔════════════════════════════════════════════════════════════════');
    print('║ 🌐 HTTP REQUEST');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ ${options.method} ${options.uri}');

    if (logHeaders && options.headers.isNotEmpty) {
      print('╟────────────────────────────────────────────────────────────────');
      print('║ Headers:');
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        final maskedValue = _maskSensitiveData(key, value.toString());
        print('║   $key: $maskedValue');
      });
    }

    if (logRequestBody && options.data != null) {
      print('╟────────────────────────────────────────────────────────────────');
      print('║ Body:');
      print('║ ${_formatData(options.data)}');
    }

    print('╚════════════════════════════════════════════════════════════════');
  }

  void _logResponse(Response response) {
    print('╔════════════════════════════════════════════════════════════════');
    print('║ ✅ HTTP RESPONSE');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ ${response.requestOptions.method} ${response.requestOptions.uri}');
    print('║ Status: ${response.statusCode} ${response.statusMessage ?? ''}');

    if (logHeaders && response.headers.map.isNotEmpty) {
      print('╟────────────────────────────────────────────────────────────────');
      print('║ Headers:');
      response.headers.map.forEach((key, value) {
        print('║   $key: ${value.join(', ')}');
      });
    }

    if (logResponseBody && response.data != null) {
      print('╟────────────────────────────────────────────────────────────────');
      print('║ Body:');
      print('║ ${_formatData(response.data)}');
    }

    print('╚════════════════════════════════════════════════════════════════');
  }

  void _logError(DioException err) {
    print('╔════════════════════════════════════════════════════════════════');
    print('║ ❌ HTTP ERROR');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('║ Error Type: ${err.type.name}');

    if (err.response != null) {
      print('║ Status: ${err.response!.statusCode} ${err.response!.statusMessage ?? ''}');

      if (err.response!.data != null) {
        print('╟────────────────────────────────────────────────────────────────');
        print('║ Error Data:');
        print('║ ${_formatData(err.response!.data)}');
      }
    }

    print('║ Message: ${err.message}');
    print('╚════════════════════════════════════════════════════════════════');
  }

  String _formatData(dynamic data) {
    try {
      if (data is Map || data is List) {
        // Pretty print JSON
        return data.toString().replaceAll(', ', ',\n║   ');
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }

  String _maskSensitiveData(String key, String value) {
    final sensitiveKeys = [
      'authorization',
      'token',
      'api-key',
      'api_key',
      'apikey',
      'password',
      'secret',
    ];

    if (sensitiveKeys.any((k) => key.toLowerCase().contains(k))) {
      if (value.length > 10) {
        return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
      }
      return '****';
    }

    return value;
  }
}
