/// Data model representing user properties for analytics
///
/// Used to set user properties and identification across analytics providers.
/// Supports PII handling and consent management.
class AnalyticsUser {
  /// Unique user identifier (app-specific, not PII)
  final String? userId;

  /// User properties (e.g., subscription_tier, user_type, app_version)
  /// Should NOT contain PII unless consent is explicitly granted
  final Map<String, dynamic>? properties;

  /// Email address (PII - requires consent)
  final String? email;

  /// Phone number (PII - requires consent)
  final String? phoneNumber;

  /// Full name (PII - requires consent)
  final String? name;

  /// User consent status for analytics tracking
  final bool hasAnalyticsConsent;

  /// User consent status for error/crash reporting
  final bool hasCrashReportingConsent;

  /// Whether PII (Personally Identifiable Information) can be sent
  final bool canSendPII;

  const AnalyticsUser({
    this.userId,
    this.properties,
    this.email,
    this.phoneNumber,
    this.name,
    this.hasAnalyticsConsent = true,
    this.hasCrashReportingConsent = true,
    this.canSendPII = false,
  });

  /// Create anonymous user with minimal data
  factory AnalyticsUser.anonymous() {
    return const AnalyticsUser(
      hasAnalyticsConsent: true,
      hasCrashReportingConsent: true,
      canSendPII: false,
    );
  }

  /// Create user with ID only (no PII)
  factory AnalyticsUser.withId(String userId) {
    return AnalyticsUser(
      userId: userId,
      hasAnalyticsConsent: true,
      hasCrashReportingConsent: true,
      canSendPII: false,
    );
  }

  /// Create user with full consent and PII
  factory AnalyticsUser.withFullConsent({
    required String userId,
    String? email,
    String? phoneNumber,
    String? name,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsUser(
      userId: userId,
      email: email,
      phoneNumber: phoneNumber,
      name: name,
      properties: properties,
      hasAnalyticsConsent: true,
      hasCrashReportingConsent: true,
      canSendPII: true,
    );
  }

  /// Get sanitized user data (removes PII if consent not granted)
  AnalyticsUser get sanitized {
    if (canSendPII) return this;

    return AnalyticsUser(
      userId: userId,
      properties: _sanitizeProperties(properties),
      hasAnalyticsConsent: hasAnalyticsConsent,
      hasCrashReportingConsent: hasCrashReportingConsent,
      canSendPII: false,
    );
  }

  /// Get user properties suitable for sending to analytics providers
  Map<String, dynamic> getAnalyticsProperties() {
    final props = <String, dynamic>{
      if (userId != null) 'user_id': userId,
      ...?properties,
    };

    // Only include PII if consent granted
    if (canSendPII) {
      if (email != null) props['email'] = email;
      if (phoneNumber != null) props['phone'] = phoneNumber;
      if (name != null) props['name'] = name;
    }

    return props;
  }

  /// Get user properties for error context (Sentry/Crashlytics)
  Map<String, dynamic> getErrorContextProperties() {
    final props = <String, dynamic>{
      if (userId != null) 'id': userId,
      ...?properties,
    };

    // Only include PII if consent granted
    if (canSendPII) {
      if (email != null) props['email'] = email;
      if (name != null) props['name'] = name;
    }

    return props;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (properties != null) 'properties': properties,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (name != null) 'name': name,
      'has_analytics_consent': hasAnalyticsConsent,
      'has_crash_reporting_consent': hasCrashReportingConsent,
      'can_send_pii': canSendPII,
    };
  }

  /// Create from JSON
  factory AnalyticsUser.fromJson(Map<String, dynamic> json) {
    return AnalyticsUser(
      userId: json['user_id'] as String?,
      properties: json['properties'] as Map<String, dynamic>?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      name: json['name'] as String?,
      hasAnalyticsConsent: json['has_analytics_consent'] as bool? ?? true,
      hasCrashReportingConsent:
          json['has_crash_reporting_consent'] as bool? ?? true,
      canSendPII: json['can_send_pii'] as bool? ?? false,
    );
  }

  /// Create a copy with modified fields
  AnalyticsUser copyWith({
    String? userId,
    Map<String, dynamic>? properties,
    String? email,
    String? phoneNumber,
    String? name,
    bool? hasAnalyticsConsent,
    bool? hasCrashReportingConsent,
    bool? canSendPII,
  }) {
    return AnalyticsUser(
      userId: userId ?? this.userId,
      properties: properties ?? this.properties,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      hasAnalyticsConsent: hasAnalyticsConsent ?? this.hasAnalyticsConsent,
      hasCrashReportingConsent:
          hasCrashReportingConsent ?? this.hasCrashReportingConsent,
      canSendPII: canSendPII ?? this.canSendPII,
    );
  }

  /// Helper to sanitize properties (remove known PII fields)
  static Map<String, dynamic>? _sanitizeProperties(
      Map<String, dynamic>? props) {
    if (props == null) return null;

    final piiFields = {
      'email',
      'phone',
      'phone_number',
      'name',
      'full_name',
      'first_name',
      'last_name',
      'address',
      'ssn',
      'credit_card',
      'password',
    };

    return Map.fromEntries(
      props.entries.where((entry) => !piiFields.contains(entry.key)),
    );
  }

  @override
  String toString() {
    return 'AnalyticsUser(userId: $userId, hasConsent: $hasAnalyticsConsent, canSendPII: $canSendPII)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsUser &&
        other.userId == userId &&
        _mapEquals(other.properties, properties) &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.name == name &&
        other.hasAnalyticsConsent == hasAnalyticsConsent &&
        other.hasCrashReportingConsent == hasCrashReportingConsent &&
        other.canSendPII == canSendPII;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      properties,
      email,
      phoneNumber,
      name,
      hasAnalyticsConsent,
      hasCrashReportingConsent,
      canSendPII,
    );
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
