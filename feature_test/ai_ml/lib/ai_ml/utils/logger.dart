/// Logging levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Logger interface for AI/ML module
abstract class AiLogger {
  void log(LogLevel level, String message, [Object? error, StackTrace? stackTrace]);

  void debug(String message) => log(LogLevel.debug, message);
  void info(String message) => log(LogLevel.info, message);
  void warning(String message, [Object? error]) => log(LogLevel.warning, message, error);
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      log(LogLevel.error, message, error, stackTrace);
}

/// Default console logger implementation
class ConsoleLogger implements AiLogger {
  final bool enabled;

  const ConsoleLogger({this.enabled = true});

  @override
  void log(LogLevel level, String message, [Object? error, StackTrace? stackTrace]) {
    if (!enabled) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);

    print('[$timestamp] $levelStr $message');

    if (error != null) {
      print('  Error: $error');
    }

    if (stackTrace != null) {
      print('  StackTrace:\n$stackTrace');
    }
  }
}

/// No-op logger (does nothing)
class NoOpLogger implements AiLogger {
  const NoOpLogger();

  @override
  void log(LogLevel level, String message, [Object? error, StackTrace? stackTrace]) {
    // Do nothing
  }
}
