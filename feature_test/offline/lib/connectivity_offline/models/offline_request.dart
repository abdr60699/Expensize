import 'package:hive/hive.dart';

part 'offline_request.g.dart';

/// Priority levels for queued requests
enum RequestPriority {
  high,
  normal,
  low,
}

/// Represents a request queued for later execution
@HiveType(typeId: 3)
class OfflineRequest extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String method;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final Map<String, String>? headers;

  @HiveField(4)
  final dynamic body;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  int retryCount;

  @HiveField(7)
  DateTime? lastAttemptAt;

  @HiveField(8)
  final int priority; // 0 = high, 1 = normal, 2 = low

  @HiveField(9)
  String? lastError;

  @HiveField(10)
  final Map<String, dynamic>? metadata;

  OfflineRequest({
    required this.id,
    required this.method,
    required this.url,
    this.headers,
    this.body,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptAt,
    RequestPriority priority = RequestPriority.normal,
    this.lastError,
    this.metadata,
  }) : priority = priority.index;

  RequestPriority get priorityLevel => RequestPriority.values[priority];

  Duration get age => DateTime.now().difference(createdAt);

  bool shouldRetry(int maxRetries) => retryCount < maxRetries;

  void incrementRetry(String? error) {
    retryCount++;
    lastAttemptAt = DateTime.now();
    lastError = error;
    save();
  }

  @override
  String toString() {
    return 'OfflineRequest(id: $id, method: $method, url: $url, retries: $retryCount, priority: $priorityLevel)';
  }
}
