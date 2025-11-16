/// Privacy configuration for analytics and error reporting
///
/// Manages user consent and PII handling across all providers.
/// Ensures GDPR, CCPA, and other privacy regulation compliance.
class PrivacyConfig {
  /// Whether analytics tracking is enabled (user consent)
  final bool analyticsEnabled;

  /// Whether error/crash reporting is enabled (user consent)
  final bool errorReportingEnabled;

  /// Whether Personally Identifiable Information can be collected
  final bool allowPII;

  /// Whether to collect device information
  final bool collectDeviceInfo;

  /// Whether to collect location data (if available)
  final bool collectLocationData;

  /// Whether to collect IP addresses
  final bool collectIPAddress;

  /// List of PII field names to automatically filter out
  final Set<String> piiFieldsToFilter;

  /// Whether to hash/anonymize user IDs before sending
  final bool anonymizeUserIds;

  /// Whether to collect performance metrics
  final bool collectPerformanceMetrics;

  /// Whether to enable debug logging (development only)
  final bool enableDebugLogging;

  /// Data retention period in days (for local caching)
  final int? dataRetentionDays;

  const PrivacyConfig({
    this.analyticsEnabled = true,
    this.errorReportingEnabled = true,
    this.allowPII = false,
    this.collectDeviceInfo = true,
    this.collectLocationData = false,
    this.collectIPAddress = false,
    this.piiFieldsToFilter = const {
      'email',
      'phone',
      'phone_number',
      'name',
      'full_name',
      'first_name',
      'last_name',
      'address',
      'street',
      'city',
      'zip',
      'postal_code',
      'ssn',
      'credit_card',
      'card_number',
      'password',
      'token',
      'api_key',
      'secret',
    },
    this.anonymizeUserIds = false,
    this.collectPerformanceMetrics = true,
    this.enableDebugLogging = false,
    this.dataRetentionDays,
  });

  /// Create privacy config with full consent (all features enabled)
  factory PrivacyConfig.fullConsent() {
    return const PrivacyConfig(
      analyticsEnabled: true,
      errorReportingEnabled: true,
      allowPII: true,
      collectDeviceInfo: true,
      collectLocationData: true,
      collectIPAddress: true,
      anonymizeUserIds: false,
      collectPerformanceMetrics: true,
    );
  }

  /// Create privacy config with minimal data collection (GDPR-strict mode)
  factory PrivacyConfig.minimal() {
    return const PrivacyConfig(
      analyticsEnabled: false,
      errorReportingEnabled: false,
      allowPII: false,
      collectDeviceInfo: false,
      collectLocationData: false,
      collectIPAddress: false,
      anonymizeUserIds: true,
      collectPerformanceMetrics: false,
    );
  }

  /// Create privacy config for analytics only (no error reporting)
  factory PrivacyConfig.analyticsOnly() {
    return const PrivacyConfig(
      analyticsEnabled: true,
      errorReportingEnabled: false,
      allowPII: false,
      collectDeviceInfo: true,
      collectLocationData: false,
      collectIPAddress: false,
      anonymizeUserIds: false,
      collectPerformanceMetrics: true,
    );
  }

  /// Create privacy config for error reporting only (no analytics)
  factory PrivacyConfig.errorReportingOnly() {
    return const PrivacyConfig(
      analyticsEnabled: false,
      errorReportingEnabled: true,
      allowPII: false,
      collectDeviceInfo: true,
      collectLocationData: false,
      collectIPAddress: false,
      anonymizeUserIds: false,
      collectPerformanceMetrics: false,
    );
  }

  /// Create privacy config for development/debug mode
  factory PrivacyConfig.debug() {
    return const PrivacyConfig(
      analyticsEnabled: true,
      errorReportingEnabled: true,
      allowPII: true,
      collectDeviceInfo: true,
      collectLocationData: true,
      collectIPAddress: true,
      anonymizeUserIds: false,
      collectPerformanceMetrics: true,
      enableDebugLogging: true,
    );
  }

  /// Check if a field name appears to contain PII
  bool isPIIField(String fieldName) {
    final normalizedField = fieldName.toLowerCase();
    return piiFieldsToFilter.any(
      (piiField) => normalizedField.contains(piiField.toLowerCase()),
    );
  }

  /// Filter PII from a map of data
  Map<String, dynamic> filterPII(Map<String, dynamic> data) {
    if (allowPII) return data;

    return Map.fromEntries(
      data.entries.where((entry) => !isPIIField(entry.key)),
    );
  }

  /// Anonymize a user ID (simple hash)
  String? anonymizeUserId(String? userId) {
    if (userId == null || !anonymizeUserIds) return userId;

    // Simple hash for anonymization (use a proper hash in production)
    return userId.hashCode.abs().toString();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'analytics_enabled': analyticsEnabled,
      'error_reporting_enabled': errorReportingEnabled,
      'allow_pii': allowPII,
      'collect_device_info': collectDeviceInfo,
      'collect_location_data': collectLocationData,
      'collect_ip_address': collectIPAddress,
      'pii_fields_to_filter': piiFieldsToFilter.toList(),
      'anonymize_user_ids': anonymizeUserIds,
      'collect_performance_metrics': collectPerformanceMetrics,
      'enable_debug_logging': enableDebugLogging,
      'data_retention_days': dataRetentionDays,
    };
  }

  /// Create from JSON
  factory PrivacyConfig.fromJson(Map<String, dynamic> json) {
    return PrivacyConfig(
      analyticsEnabled: json['analytics_enabled'] as bool? ?? true,
      errorReportingEnabled: json['error_reporting_enabled'] as bool? ?? true,
      allowPII: json['allow_pii'] as bool? ?? false,
      collectDeviceInfo: json['collect_device_info'] as bool? ?? true,
      collectLocationData: json['collect_location_data'] as bool? ?? false,
      collectIPAddress: json['collect_ip_address'] as bool? ?? false,
      piiFieldsToFilter: (json['pii_fields_to_filter'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          const {
            'email',
            'phone',
            'phone_number',
            'name',
            'password',
            'token',
            'api_key',
          },
      anonymizeUserIds: json['anonymize_user_ids'] as bool? ?? false,
      collectPerformanceMetrics:
          json['collect_performance_metrics'] as bool? ?? true,
      enableDebugLogging: json['enable_debug_logging'] as bool? ?? false,
      dataRetentionDays: json['data_retention_days'] as int?,
    );
  }

  /// Create a copy with modified fields
  PrivacyConfig copyWith({
    bool? analyticsEnabled,
    bool? errorReportingEnabled,
    bool? allowPII,
    bool? collectDeviceInfo,
    bool? collectLocationData,
    bool? collectIPAddress,
    Set<String>? piiFieldsToFilter,
    bool? anonymizeUserIds,
    bool? collectPerformanceMetrics,
    bool? enableDebugLogging,
    int? dataRetentionDays,
  }) {
    return PrivacyConfig(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      errorReportingEnabled:
          errorReportingEnabled ?? this.errorReportingEnabled,
      allowPII: allowPII ?? this.allowPII,
      collectDeviceInfo: collectDeviceInfo ?? this.collectDeviceInfo,
      collectLocationData: collectLocationData ?? this.collectLocationData,
      collectIPAddress: collectIPAddress ?? this.collectIPAddress,
      piiFieldsToFilter: piiFieldsToFilter ?? this.piiFieldsToFilter,
      anonymizeUserIds: anonymizeUserIds ?? this.anonymizeUserIds,
      collectPerformanceMetrics:
          collectPerformanceMetrics ?? this.collectPerformanceMetrics,
      enableDebugLogging: enableDebugLogging ?? this.enableDebugLogging,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
    );
  }

  @override
  String toString() {
    return 'PrivacyConfig(analytics: $analyticsEnabled, errors: $errorReportingEnabled, allowPII: $allowPII)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrivacyConfig &&
        other.analyticsEnabled == analyticsEnabled &&
        other.errorReportingEnabled == errorReportingEnabled &&
        other.allowPII == allowPII &&
        other.collectDeviceInfo == collectDeviceInfo &&
        other.collectLocationData == collectLocationData &&
        other.collectIPAddress == collectIPAddress &&
        _setEquals(other.piiFieldsToFilter, piiFieldsToFilter) &&
        other.anonymizeUserIds == anonymizeUserIds &&
        other.collectPerformanceMetrics == collectPerformanceMetrics &&
        other.enableDebugLogging == enableDebugLogging &&
        other.dataRetentionDays == dataRetentionDays;
  }

  @override
  int get hashCode {
    return Object.hash(
      analyticsEnabled,
      errorReportingEnabled,
      allowPII,
      collectDeviceInfo,
      collectLocationData,
      collectIPAddress,
      piiFieldsToFilter,
      anonymizeUserIds,
      collectPerformanceMetrics,
      enableDebugLogging,
      dataRetentionDays,
    );
  }

  bool _setEquals(Set? a, Set? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    return a.every(b.contains);
  }
}
