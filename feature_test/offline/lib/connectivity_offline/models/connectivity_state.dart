import 'package:flutter/foundation.dart';

/// Enum representing the connectivity status
enum ConnectivityStatus {
  online,
  offline,
  limited,
}

/// Enum representing the connection type
enum ConnectionType {
  wifi,
  cellular,
  ethernet,
  bluetooth,
  vpn,
  none,
  unknown,
}

/// Enum representing connection quality
enum ConnectionQuality {
  excellent,
  good,
  fair,
  poor,
  unknown,
}

/// Represents the current connectivity state
@immutable
class ConnectivityState {
  final ConnectivityStatus status;
  final ConnectionType connectionType;
  final ConnectionQuality quality;
  final bool isMetered;
  final DateTime timestamp;

  const ConnectivityState({
    required this.status,
    required this.connectionType,
    this.quality = ConnectionQuality.unknown,
    this.isMetered = false,
    required this.timestamp,
  });

  bool get isOnline => status == ConnectivityStatus.online;
  bool get isOffline => status == ConnectivityStatus.offline;
  bool get hasLimitedConnectivity => status == ConnectivityStatus.limited;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    ConnectionType? connectionType,
    ConnectionQuality? quality,
    bool? isMetered,
    DateTime? timestamp,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      connectionType: connectionType ?? this.connectionType,
      quality: quality ?? this.quality,
      isMetered: isMetered ?? this.isMetered,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectivityState &&
        other.status == status &&
        other.connectionType == connectionType;
  }

  @override
  int get hashCode => status.hashCode ^ connectionType.hashCode;

  @override
  String toString() {
    return 'ConnectivityState(status: $status, type: $connectionType, quality: $quality, metered: $isMetered)';
  }
}
