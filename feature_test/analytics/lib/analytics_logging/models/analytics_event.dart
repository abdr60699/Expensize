/// Data model representing an analytics event
///
/// Used to track user interactions, screen views, and custom events
/// throughout the application.
class AnalyticsEvent {
  /// Unique name of the event (e.g., 'user_signup', 'purchase_completed')
  final String name;

  /// Optional parameters/properties for the event
  /// Example: {'product_id': '123', 'price': 29.99, 'currency': 'USD'}
  final Map<String, dynamic>? parameters;

  /// Timestamp when the event occurred (defaults to current time)
  final DateTime timestamp;

  /// Optional user ID associated with this event
  final String? userId;

  /// Optional session ID to group related events
  final String? sessionId;

  AnalyticsEvent({
    required this.name,
    this.parameters,
    DateTime? timestamp,
    this.userId,
    this.sessionId,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a screen view event
  ///
  /// Example:
  /// ```dart
  /// AnalyticsEvent.screenView(
  ///   screenName: 'HomeScreen',
  ///   screenClass: 'HomePage',
  /// )
  /// ```
  factory AnalyticsEvent.screenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? additionalParameters,
  }) {
    return AnalyticsEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
        ...?additionalParameters,
      },
    );
  }

  /// Create a user action event
  ///
  /// Example:
  /// ```dart
  /// AnalyticsEvent.userAction(
  ///   action: 'button_click',
  ///   category: 'navigation',
  ///   label: 'home_to_profile',
  /// )
  /// ```
  factory AnalyticsEvent.userAction({
    required String action,
    String? category,
    String? label,
    dynamic value,
    Map<String, dynamic>? additionalParameters,
  }) {
    return AnalyticsEvent(
      name: action,
      parameters: {
        if (category != null) 'category': category,
        if (label != null) 'label': label,
        if (value != null) 'value': value,
        ...?additionalParameters,
      },
    );
  }

  /// Create a custom event with arbitrary parameters
  ///
  /// Example:
  /// ```dart
  /// AnalyticsEvent.custom(
  ///   name: 'purchase_completed',
  ///   parameters: {
  ///     'transaction_id': 'TXN123',
  ///     'amount': 99.99,
  ///     'currency': 'USD',
  ///     'items': ['item1', 'item2'],
  ///   },
  /// )
  /// ```
  factory AnalyticsEvent.custom({
    required String name,
    Map<String, dynamic>? parameters,
    String? userId,
    String? sessionId,
  }) {
    return AnalyticsEvent(
      name: name,
      parameters: parameters,
      userId: userId,
      sessionId: sessionId,
    );
  }

  /// Convert event to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
    };
  }

  /// Create event from JSON
  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['user_id'] as String?,
      sessionId: json['session_id'] as String?,
    );
  }

  /// Validate event name (Firebase Analytics constraints)
  ///
  /// - Must be 40 characters or fewer
  /// - Can only contain alphanumeric characters and underscores
  /// - Must start with an alphabetic character
  bool isValidEventName() {
    if (name.isEmpty || name.length > 40) return false;

    final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
    return regex.hasMatch(name);
  }

  /// Validate parameter keys (Firebase Analytics constraints)
  ///
  /// - Must be 40 characters or fewer
  /// - Can only contain alphanumeric characters and underscores
  bool hasValidParameterKeys() {
    if (parameters == null) return true;

    final regex = RegExp(r'^[a-zA-Z0-9_]{1,40}$');
    return parameters!.keys.every((key) => regex.hasMatch(key));
  }

  /// Create a copy with modified fields
  AnalyticsEvent copyWith({
    String? name,
    Map<String, dynamic>? parameters,
    DateTime? timestamp,
    String? userId,
    String? sessionId,
  }) {
    return AnalyticsEvent(
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, parameters: $parameters, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsEvent &&
        other.name == name &&
        _mapEquals(other.parameters, parameters) &&
        other.timestamp == timestamp &&
        other.userId == userId &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    return Object.hash(name, parameters, timestamp, userId, sessionId);
  }

  bool _mapEquals(Map? a, Map? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
