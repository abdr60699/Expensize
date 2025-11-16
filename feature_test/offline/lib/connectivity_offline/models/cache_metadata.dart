import 'package:hive/hive.dart';

part 'cache_metadata.g.dart';

/// Metadata for cached entries
@HiveType(typeId: 1)
class CacheMetadata extends HiveObject {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final DateTime? expiresAt;

  @HiveField(3)
  final int sizeInBytes;

  @HiveField(4)
  int accessCount;

  @HiveField(5)
  DateTime lastAccessedAt;

  @HiveField(6)
  final String? etag;

  @HiveField(7)
  final Map<String, String>? headers;

  CacheMetadata({
    required this.key,
    required this.createdAt,
    this.expiresAt,
    required this.sizeInBytes,
    this.accessCount = 0,
    required this.lastAccessedAt,
    this.etag,
    this.headers,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration get age => DateTime.now().difference(createdAt);

  void incrementAccessCount() {
    accessCount++;
    lastAccessedAt = DateTime.now();
    save();
  }

  @override
  String toString() {
    return 'CacheMetadata(key: $key, created: $createdAt, expires: $expiresAt, size: $sizeInBytes, accessed: $accessCount)';
  }
}

/// Cache entry combining data and metadata
@HiveType(typeId: 2)
class CacheEntry extends HiveObject {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final dynamic data;

  @HiveField(2)
  final CacheMetadata metadata;

  CacheEntry({
    required this.key,
    required this.data,
    required this.metadata,
  });

  bool get isExpired => metadata.isExpired;

  @override
  String toString() {
    return 'CacheEntry(key: $key, metadata: $metadata)';
  }
}
