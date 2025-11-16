/// Product models for in-app purchases and payments
library;

/// Product type
enum ProductType {
  /// Consumable product (can be purchased multiple times)
  consumable,

  /// Non-consumable product (one-time purchase)
  nonConsumable,

  /// Auto-renewable subscription
  autoRenewableSubscription,

  /// Non-renewable subscription
  nonRenewableSubscription,
}

/// Product/SKU information
class Product {
  /// Unique product identifier (SKU)
  final String id;

  /// Product title/name
  final String title;

  /// Product description
  final String description;

  /// Product type
  final ProductType type;

  /// Price information
  final Price price;

  /// Product is available for purchase
  final bool isAvailable;

  /// Subscription plan information (if applicable)
  final SubscriptionPlan? subscriptionPlan;

  /// Trial period (if applicable)
  final TrialPeriod? trialPeriod;

  /// Introductory price (if applicable)
  final Price? introductoryPrice;

  /// Product metadata
  final Map<String, dynamic>? metadata;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    this.isAvailable = true,
    this.subscriptionPlan,
    this.trialPeriod,
    this.introductoryPrice,
    this.metadata,
  });

  /// Whether product is a subscription
  bool get isSubscription =>
      type == ProductType.autoRenewableSubscription ||
      type == ProductType.nonRenewableSubscription;

  /// Whether product is consumable
  bool get isConsumable => type == ProductType.consumable;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'price': price.toJson(),
      'isAvailable': isAvailable,
      'subscriptionPlan': subscriptionPlan?.toJson(),
      'trialPeriod': trialPeriod?.toJson(),
      'introductoryPrice': introductoryPrice?.toJson(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ProductType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductType.consumable,
      ),
      price: Price.fromJson(json['price'] as Map<String, dynamic>),
      isAvailable: json['isAvailable'] as bool? ?? true,
      subscriptionPlan: json['subscriptionPlan'] != null
          ? SubscriptionPlan.fromJson(
              json['subscriptionPlan'] as Map<String, dynamic>)
          : null,
      trialPeriod: json['trialPeriod'] != null
          ? TrialPeriod.fromJson(json['trialPeriod'] as Map<String, dynamic>)
          : null,
      introductoryPrice: json['introductoryPrice'] != null
          ? Price.fromJson(json['introductoryPrice'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, title: $title, price: ${price.formattedPrice})';
  }
}

/// Price information
class Price {
  /// Price amount
  final double amount;

  /// ISO currency code
  final String currency;

  /// Formatted price string (e.g., "\$9.99")
  final String formattedPrice;

  /// Currency symbol
  final String? currencySymbol;

  const Price({
    required this.amount,
    required this.currency,
    required this.formattedPrice,
    this.currencySymbol,
  });

  /// Create price from amount and currency
  factory Price.fromAmount({
    required double amount,
    required String currency,
  }) {
    final symbol = _getCurrencySymbol(currency);
    final formatted = '$symbol${amount.toStringAsFixed(2)}';

    return Price(
      amount: amount,
      currency: currency,
      formattedPrice: formatted,
      currencySymbol: symbol,
    );
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return currency;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'formattedPrice': formattedPrice,
      'currencySymbol': currencySymbol,
    };
  }

  /// Create from JSON
  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      formattedPrice: json['formattedPrice'] as String,
      currencySymbol: json['currencySymbol'] as String?,
    );
  }

  @override
  String toString() => formattedPrice;
}

/// Subscription plan details
class SubscriptionPlan {
  /// Plan identifier
  final String planId;

  /// Billing period duration
  final Duration period;

  /// Number of billing cycles (null for infinite)
  final int? numberOfPeriods;

  /// Free trial available
  final bool hasTrial;

  /// Introductory pricing available
  final bool hasIntroductoryPrice;

  const SubscriptionPlan({
    required this.planId,
    required this.period,
    this.numberOfPeriods,
    this.hasTrial = false,
    this.hasIntroductoryPrice = false,
  });

  /// Period in human-readable format
  String get periodDescription {
    if (period.inDays == 1) return 'Daily';
    if (period.inDays == 7) return 'Weekly';
    if (period.inDays == 30 || period.inDays == 31) return 'Monthly';
    if (period.inDays == 90) return 'Quarterly';
    if (period.inDays == 365) return 'Annual';
    return '${period.inDays} days';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'periodInDays': period.inDays,
      'numberOfPeriods': numberOfPeriods,
      'hasTrial': hasTrial,
      'hasIntroductoryPrice': hasIntroductoryPrice,
    };
  }

  /// Create from JSON
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      planId: json['planId'] as String,
      period: Duration(days: json['periodInDays'] as int),
      numberOfPeriods: json['numberOfPeriods'] as int?,
      hasTrial: json['hasTrial'] as bool? ?? false,
      hasIntroductoryPrice: json['hasIntroductoryPrice'] as bool? ?? false,
    );
  }
}

/// Trial period information
class TrialPeriod {
  /// Trial duration
  final Duration duration;

  /// Trial price (0 for free trial)
  final double price;

  const TrialPeriod({
    required this.duration,
    this.price = 0.0,
  });

  /// Whether trial is free
  bool get isFree => price == 0.0;

  /// Trial period in human-readable format
  String get description {
    if (duration.inDays == 1) return '1-day trial';
    if (duration.inDays == 7) return '7-day trial';
    if (duration.inDays == 14) return '14-day trial';
    if (duration.inDays == 30) return '30-day trial';
    return '${duration.inDays}-day trial';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'durationInDays': duration.inDays,
      'price': price,
    };
  }

  /// Create from JSON
  factory TrialPeriod.fromJson(Map<String, dynamic> json) {
    return TrialPeriod(
      duration: Duration(days: json['durationInDays'] as int),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Product catalog/store
class ProductCatalog {
  /// All available products
  final List<Product> products;

  /// Catalog last updated
  final DateTime lastUpdated;

  const ProductCatalog({
    required this.products,
    required this.lastUpdated,
  });

  /// Get product by ID
  Product? getProduct(String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Get all subscription products
  List<Product> get subscriptions {
    return products.where((p) => p.isSubscription).toList();
  }

  /// Get all consumable products
  List<Product> get consumables {
    return products.where((p) => p.isConsumable).toList();
  }

  /// Get all non-consumable products
  List<Product> get nonConsumables {
    return products
        .where((p) => p.type == ProductType.nonConsumable)
        .toList();
  }
}
