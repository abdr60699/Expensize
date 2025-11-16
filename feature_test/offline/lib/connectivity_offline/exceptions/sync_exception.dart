import 'offline_exception.dart';

/// Exception thrown for sync-related errors
class SyncException extends OfflineException {
  SyncException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when sync conflicts occur
class SyncConflictException extends SyncException {
  final dynamic localData;
  final dynamic remoteData;

  SyncConflictException({
    required this.localData,
    required this.remoteData,
    String? message,
  }) : super(message ?? 'Sync conflict detected');
}

/// Exception thrown when sync fails
class SyncFailedException extends SyncException {
  final int failedCount;
  final int totalCount;

  SyncFailedException({
    required this.failedCount,
    required this.totalCount,
    String? message,
  }) : super(message ?? 'Sync failed: $failedCount/$totalCount operations failed');
}

/// Exception thrown when sync is cancelled
class SyncCancelledException extends SyncException {
  SyncCancelledException([String? message])
      : super(message ?? 'Sync operation was cancelled');
}
