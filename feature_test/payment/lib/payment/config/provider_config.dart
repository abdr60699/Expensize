/// Provider-specific configurations
library;

/// Payment environment
enum PaymentEnvironment {
  production,
  sandbox,
  development,
}

/// Base provider configuration
abstract class ProviderConfig {
  final String providerId;
  final bool enabled;
  final PaymentEnvironment environment;

  const ProviderConfig({
    required this.providerId,
    required this.enabled,
    required this.environment,
  });

  Map<String, dynamic> toJson();
}

/// Stripe provider configuration
class StripeConfig extends ProviderConfig {
  final String publishableKey;
  final String? merchantId;
  final bool enableApplePay;
  final bool enableGooglePay;

  const StripeConfig({
    required this.publishableKey,
    this.merchantId,
    this.enableApplePay = true,
    this.enableGooglePay = true,
    PaymentEnvironment environment = PaymentEnvironment.sandbox,
    bool enabled = true,
  }) : super(
          providerId: 'stripe',
          enabled: enabled,
          environment: environment,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'enabled': enabled,
      'environment': environment.name,
      'publishableKey': publishableKey,
      'merchantId': merchantId,
      'enableApplePay': enableApplePay,
      'enableGooglePay': enableGooglePay,
    };
  }

  factory StripeConfig.fromJson(Map<String, dynamic> json) {
    return StripeConfig(
      publishableKey: json['publishableKey'] as String,
      merchantId: json['merchantId'] as String?,
      enableApplePay: json['enableApplePay'] as bool? ?? true,
      enableGooglePay: json['enableGooglePay'] as bool? ?? true,
      environment: PaymentEnvironment.values.firstWhere(
        (e) => e.name == json['environment'],
        orElse: () => PaymentEnvironment.sandbox,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

/// PayPal provider configuration
class PayPalConfig extends ProviderConfig {
  final String clientId;
  final String returnUrl;
  final String cancelUrl;

  const PayPalConfig({
    required this.clientId,
    required this.returnUrl,
    required this.cancelUrl,
    PaymentEnvironment environment = PaymentEnvironment.sandbox,
    bool enabled = true,
  }) : super(
          providerId: 'paypal',
          enabled: enabled,
          environment: environment,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'enabled': enabled,
      'environment': environment.name,
      'clientId': clientId,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };
  }

  factory PayPalConfig.fromJson(Map<String, dynamic> json) {
    return PayPalConfig(
      clientId: json['clientId'] as String,
      returnUrl: json['returnUrl'] as String,
      cancelUrl: json['cancelUrl'] as String,
      environment: PaymentEnvironment.values.firstWhere(
        (e) => e.name == json['environment'],
        orElse: () => PaymentEnvironment.sandbox,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

/// Razorpay provider configuration
class RazorpayConfig extends ProviderConfig {
  final String keyId;
  final String? keySecret;

  const RazorpayConfig({
    required this.keyId,
    this.keySecret,
    PaymentEnvironment environment = PaymentEnvironment.sandbox,
    bool enabled = true,
  }) : super(
          providerId: 'razorpay',
          enabled: enabled,
          environment: environment,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'enabled': enabled,
      'environment': environment.name,
      'keyId': keyId,
      'keySecret': keySecret,
    };
  }

  factory RazorpayConfig.fromJson(Map<String, dynamic> json) {
    return RazorpayConfig(
      keyId: json['keyId'] as String,
      keySecret: json['keySecret'] as String?,
      environment: PaymentEnvironment.values.firstWhere(
        (e) => e.name == json['environment'],
        orElse: () => PaymentEnvironment.sandbox,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

/// Google Play Billing configuration
class GooglePlayConfig extends ProviderConfig {
  final bool autoConsume;
  final bool enablePendingPurchases;

  const GooglePlayConfig({
    this.autoConsume = true,
    this.enablePendingPurchases = true,
    PaymentEnvironment environment = PaymentEnvironment.production,
    bool enabled = true,
  }) : super(
          providerId: 'google_play',
          enabled: enabled,
          environment: environment,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'enabled': enabled,
      'environment': environment.name,
      'autoConsume': autoConsume,
      'enablePendingPurchases': enablePendingPurchases,
    };
  }

  factory GooglePlayConfig.fromJson(Map<String, dynamic> json) {
    return GooglePlayConfig(
      autoConsume: json['autoConsume'] as bool? ?? true,
      enablePendingPurchases:
          json['enablePendingPurchases'] as bool? ?? true,
      environment: PaymentEnvironment.values.firstWhere(
        (e) => e.name == json['environment'],
        orElse: () => PaymentEnvironment.production,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

/// Apple IAP configuration
class AppleIAPConfig extends ProviderConfig {
  final bool autoFinishTransactions;

  const AppleIAPConfig({
    this.autoFinishTransactions = true,
    PaymentEnvironment environment = PaymentEnvironment.production,
    bool enabled = true,
  }) : super(
          providerId: 'apple_iap',
          enabled: enabled,
          environment: environment,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'enabled': enabled,
      'environment': environment.name,
      'autoFinishTransactions': autoFinishTransactions,
    };
  }

  factory AppleIAPConfig.fromJson(Map<String, dynamic> json) {
    return AppleIAPConfig(
      autoFinishTransactions:
          json['autoFinishTransactions'] as bool? ?? true,
      environment: PaymentEnvironment.values.firstWhere(
        (e) => e.name == json['environment'],
        orElse: () => PaymentEnvironment.production,
      ),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
