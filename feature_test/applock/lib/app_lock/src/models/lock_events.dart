/// Events that can occur during app lock lifecycle
abstract class LockEvent {
  final DateTime timestamp;

  LockEvent() : timestamp = DateTime.now();
}

/// App was locked
class AppLockedEvent extends LockEvent {
  final String reason;

  AppLockedEvent({this.reason = 'manual'});

  @override
  String toString() => 'AppLockedEvent(reason: $reason, time: $timestamp)';
}

/// App was unlocked
class AppUnlockedEvent extends LockEvent {
  final String method; // 'pin' or 'biometric'

  AppUnlockedEvent({required this.method});

  @override
  String toString() => 'AppUnlockedEvent(method: $method, time: $timestamp)';
}

/// Failed unlock attempt
class UnlockFailedEvent extends LockEvent {
  final int attemptsRemaining;

  UnlockFailedEvent({required this.attemptsRemaining});

  @override
  String toString() =>
      'UnlockFailedEvent(attemptsRemaining: $attemptsRemaining, time: $timestamp)';
}

/// User locked out due to too many failed attempts
class LockoutEvent extends LockEvent {
  final Duration duration;

  LockoutEvent({required this.duration});

  @override
  String toString() => 'LockoutEvent(duration: $duration, time: $timestamp)';
}

/// PIN was set or changed
class PinChangedEvent extends LockEvent {
  final bool isInitialSetup;

  PinChangedEvent({this.isInitialSetup = false});

  @override
  String toString() =>
      'PinChangedEvent(isInitialSetup: $isInitialSetup, time: $timestamp)';
}

/// Biometric setting changed
class BiometricSettingChangedEvent extends LockEvent {
  final bool enabled;

  BiometricSettingChangedEvent({required this.enabled});

  @override
  String toString() =>
      'BiometricSettingChangedEvent(enabled: $enabled, time: $timestamp)';
}
