import 'package:flutter/foundation.dart';

/// Information about a network request for caching purposes
@immutable
class NetworkRequestInfo {
  final String method;
  final String url;
  final Map<String, String>? headers;
  final Map<String, dynamic>? queryParameters;
  final dynamic body;

  const NetworkRequestInfo({
    required this.method,
    required this.url,
    this.headers,
    this.queryParameters,
    this.body,
  });

  String generateCacheKey() {
    final buffer = StringBuffer();
    buffer.write(method.toUpperCase());
    buffer.write(':');
    buffer.write(url);

    if (queryParameters != null && queryParameters!.isNotEmpty) {
      final sortedParams = queryParameters!.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      buffer.write('?');
      buffer.write(sortedParams.map((e) => '${e.key}=${e.value}').join('&'));
    }

    if (body != null && (method == 'POST' || method == 'PUT' || method == 'PATCH')) {
      buffer.write(':');
      buffer.write(body.toString());
    }

    return buffer.toString();
  }

  @override
  String toString() {
    return 'NetworkRequestInfo(method: $method, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkRequestInfo &&
        other.method == method &&
        other.url == url;
  }

  @override
  int get hashCode => method.hashCode ^ url.hashCode;
}
