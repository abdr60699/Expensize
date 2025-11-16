/// Main payment configuration
library;

import 'provider_config.dart';

/// Payment module configuration
class PaymentConfig {
  /// Map of provider ID to provider configuration
  final Map<String, ProviderConfig> providers;

  /// Whether to enable analytics tracking
  final bool enableAnalytics;

  /// Whether to enable logging
  final bool enableLogging;

  /// Backend API URL for receipt validation
  final String? backendUrl;

  /// Request timeout duration
  final Duration requestTimeout;

  /// Maximum retry attempts for failed requests
  final int maxRetries;

  /// Enable automatic retry on transient failures
  final bool autoRetry;

  /// Test mode (use sandbox/test environments)
  final bool isTestMode;

  const PaymentConfig({
    required this.providers,
    this.enableAnalytics = true,
    this.enableLogging = true,
    this.backendUrl,
    this.requestTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.autoRetry = true,
    this.isTestMode = false,
  });

  /// Create production configuration
  factory PaymentConfig.production({
    required Map<String, ProviderConfig> providers,
    String? backendUrl,
    bool enableAnalytics = true,
  }) {
    return PaymentConfig(
      providers: providers,
      backendUrl: backendUrl,
      enableAnalytics: enableAnalytics,
      enableLogging: false,
      isTestMode: false,
    );
  }

  /// Create development/test configuration
  factory PaymentConfig.development({
    required Map<String, ProviderConfig> providers,
    String? backendUrl,
  }) {
    return PaymentConfig(
      providers: providers,
      backendUrl: backendUrl,
      enableAnalytics: false,
      enableLogging: true,
      isTestMode: true,
    );
  }

  /// Get provider configuration by ID
  ProviderConfig? getProvider(String providerId) {
    return providers[providerId];
  }

  /// Get all enabled provider IDs
  List<String> get enabledProviders {
    return providers.entries
        .where((entry) => entry.value.enabled)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if provider is enabled
  bool isProviderEnabled(String providerId) {
    final provider = providers[providerId];
    return provider?.enabled ?? false;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'providers':
          providers.map((key, value) => MapEntry(key, value.toJson())),
      'enableAnalytics': enableAnalytics,
      'enableLogging': enableLogging,
      'backendUrl': backendUrl,
      'requestTimeoutSeconds': requestTimeout.inSeconds,
      'maxRetries': maxRetries,
      'autoRetry': autoRetry,
      'isTestMode': isTestMode,
    };
  }

  /// Create from JSON
  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    final providersMap = <String, ProviderConfig>{};

    final providersJson = json['providers'] as Map<String, dynamic>? ?? {};
    for (final entry in providersJson.entries) {
      final providerJson = entry.value as Map<String, dynamic>;
      final providerId = entry.key;

      // Create appropriate provider config based on type
      ProviderConfig config;
      switch (providerId) {
        case 'stripe':
          config = StripeConfig.fromJson(providerJson);
          break;
        case 'paypal':
          config = PayPalConfig.fromJson(providerJson);
          break;
        case 'razorpay':
          config = RazorpayConfig.fromJson(providerJson);
          break;
        case 'google_play':
          config = GooglePlayConfig.fromJson(providerJson);
          break;
        case 'apple_iap':
          config = AppleIAPConfig.fromJson(providerJson);
          break;
        default:
          continue; // Skip unknown providers
      }

      providersMap[providerId] = config;
    }

    return PaymentConfig(
      providers: providersMap,
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
      enableLogging: json['enableLogging'] as bool? ?? true,
      backendUrl: json['backendUrl'] as String?,
      requestTimeout: Duration(
        seconds: json['requestTimeoutSeconds'] as int? ?? 30,
      ),
      maxRetries: json['maxRetries'] as int? ?? 3,
      autoRetry: json['autoRetry'] as bool? ?? true,
      isTestMode: json['isTestMode'] as bool? ?? false,
    );
  }
}
