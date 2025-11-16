import 'package:flutter/foundation.dart';

/// Status of a sync operation
enum SyncStatus {
  idle,
  running,
  completed,
  failed,
  cancelled,
}

/// Result of a synchronization operation
@immutable
class SyncResult {
  final SyncStatus status;
  final int successCount;
  final int failureCount;
  final int totalCount;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> errors;
  final Map<String, dynamic>? metadata;

  const SyncResult({
    required this.status,
    required this.successCount,
    required this.failureCount,
    required this.totalCount,
    required this.startTime,
    this.endTime,
    this.errors = const [],
    this.metadata,
  });

  double get progress {
    if (totalCount == 0) return 0.0;
    return (successCount + failureCount) / totalCount;
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isComplete => status == SyncStatus.completed;
  bool get isRunning => status == SyncStatus.running;
  bool get hasFailed => status == SyncStatus.failed;
  bool get hasErrors => errors.isNotEmpty;

  SyncResult copyWith({
    SyncStatus? status,
    int? successCount,
    int? failureCount,
    int? totalCount,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? errors,
    Map<String, dynamic>? metadata,
  }) {
    return SyncResult(
      status: status ?? this.status,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      totalCount: totalCount ?? this.totalCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      errors: errors ?? this.errors,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'SyncResult(status: $status, success: $successCount/$totalCount, failures: $failureCount)';
  }
}
