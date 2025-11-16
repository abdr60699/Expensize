/// Base exception for offline support module
class OfflineException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  OfflineException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'OfflineException: $message\nCaused by: $originalError';
    }
    return 'OfflineException: $message';
  }
}

/// Exception thrown when network is not available
class NetworkUnavailableException extends OfflineException {
  NetworkUnavailableException([String? message])
      : super(message ?? 'Network is not available');
}

/// Exception thrown when operation requires online connection
class OnlineRequiredException extends OfflineException {
  OnlineRequiredException([String? message])
      : super(message ?? 'This operation requires an internet connection');
}
