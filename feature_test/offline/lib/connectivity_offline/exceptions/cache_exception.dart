import 'offline_exception.dart';

/// Exception thrown for cache-related errors
class CacheException extends OfflineException {
  CacheException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when cache is full
class CacheFullException extends CacheException {
  final int currentSize;
  final int maxSize;

  CacheFullException({
    required this.currentSize,
    required this.maxSize,
  }) : super('Cache is full: $currentSize/$maxSize bytes');
}

/// Exception thrown when cache entry is not found
class CacheNotFoundException extends CacheException {
  final String key;

  CacheNotFoundException(this.key)
      : super('Cache entry not found for key: $key');
}

/// Exception thrown when cache entry has expired
class CacheExpiredException extends CacheException {
  final String key;
  final DateTime expirationTime;

  CacheExpiredException({
    required this.key,
    required this.expirationTime,
  }) : super('Cache entry expired for key: $key at $expirationTime');
}

/// Exception thrown when cache initialization fails
class CacheInitializationException extends CacheException {
  CacheInitializationException(String message, {dynamic originalError})
      : super(message, originalError: originalError);
}
