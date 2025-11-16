/// Utility functions for time-related operations
class TimeUtils {
  TimeUtils._();

  /// Formats a duration into a human-readable string
  ///
  /// Examples:
  /// - 90 seconds -> "1:30"
  /// - 3661 seconds -> "1:01:01"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Formats remaining time in a user-friendly way
  ///
  /// Examples:
  /// - 90 seconds -> "1 minute 30 seconds"
  /// - 3661 seconds -> "1 hour 1 minute"
  static String formatRemainingTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];

    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    }

    if (minutes > 0) {
      parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
    }

    if (hours == 0 && seconds > 0) {
      parts.add('$seconds ${seconds == 1 ? 'second' : 'seconds'}');
    }

    if (parts.isEmpty) {
      return '0 seconds';
    }

    return parts.join(' ');
  }

  /// Checks if a timestamp has expired
  static bool isExpired(DateTime timestamp, Duration timeout) {
    return DateTime.now().isAfter(timestamp.add(timeout));
  }

  /// Gets remaining time until expiration
  static Duration? getRemainingTime(DateTime timestamp, Duration timeout) {
    final expiresAt = timestamp.add(timeout);
    final now = DateTime.now();

    if (now.isAfter(expiresAt)) {
      return null;
    }

    return expiresAt.difference(now);
  }

  /// Parses ISO 8601 datetime string safely
  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Converts DateTime to ISO 8601 string
  static String? formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String();
  }

  /// Gets current timestamp as ISO 8601 string
  static String getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }

  /// Checks if current time is within a time range
  static bool isWithinRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }
}
