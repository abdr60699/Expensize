/// Logger interface for pluggable logging
abstract class SocialAuthLogger {
  void debug(String message);
  void info(String message);
  void warning(String message);
  void error(String message, [dynamic error, StackTrace? stackTrace]);
}

/// No-op logger for production
class NoOpLogger implements SocialAuthLogger {
  const NoOpLogger();

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {}
}

/// Console logger for development
class ConsoleLogger implements SocialAuthLogger {
  const ConsoleLogger();

  @override
  void debug(String message) {
    print('[DEBUG] $message');
  }

  @override
  void info(String message) {
    print('[INFO] $message');
  }

  @override
  void warning(String message) {
    print('[WARNING] $message');
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }
}
