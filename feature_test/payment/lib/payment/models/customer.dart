/// Customer and billing information models
library;

/// Customer information for payment
class Customer {
  /// Unique customer identifier
  final String? customerId;

  /// Customer email
  final String email;

  /// Customer full name
  final String? name;

  /// Customer phone number
  final String? phone;

  /// Billing address
  final BillingAddress? billingAddress;

  /// Shipping address (if different from billing)
  final BillingAddress? shippingAddress;

  /// Customer metadata
  final Map<String, dynamic>? metadata;

  const Customer({
    this.customerId,
    required this.email,
    this.name,
    this.phone,
    this.billingAddress,
    this.shippingAddress,
    this.metadata,
  });

  /// Validate customer data
  bool get isValid {
    if (email.isEmpty) return false;
    if (!_isValidEmail(email)) return false;
    return true;
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Copy with modifications
  Customer copyWith({
    String? customerId,
    String? email,
    String? name,
    String? phone,
    BillingAddress? billingAddress,
    BillingAddress? shippingAddress,
    Map<String, dynamic>? metadata,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'email': email,
      'name': name,
      'phone': phone,
      'billingAddress': billingAddress?.toJson(),
      'shippingAddress': shippingAddress?.toJson(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] as String?,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      billingAddress: json['billingAddress'] != null
          ? BillingAddress.fromJson(
              json['billingAddress'] as Map<String, dynamic>)
          : null,
      shippingAddress: json['shippingAddress'] != null
          ? BillingAddress.fromJson(
              json['shippingAddress'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $customerId, email: $email, name: $name)';
  }
}

/// Billing/shipping address
class BillingAddress {
  /// Street address line 1
  final String line1;

  /// Street address line 2 (optional)
  final String? line2;

  /// City
  final String city;

  /// State/province/region
  final String? state;

  /// Postal/ZIP code
  final String postalCode;

  /// ISO country code (US, GB, IN, etc.)
  final String country;

  const BillingAddress({
    required this.line1,
    this.line2,
    required this.city,
    this.state,
    required this.postalCode,
    required this.country,
  });

  /// Full address as single string
  String get fullAddress {
    final buffer = StringBuffer(line1);
    if (line2 != null && line2!.isNotEmpty) {
      buffer.write(', $line2');
    }
    buffer.write(', $city');
    if (state != null && state!.isNotEmpty) {
      buffer.write(', $state');
    }
    buffer.write(' $postalCode, $country');
    return buffer.toString();
  }

  /// Copy with modifications
  BillingAddress copyWith({
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    return BillingAddress(
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  /// Create from JSON
  factory BillingAddress.fromJson(Map<String, dynamic> json) {
    return BillingAddress(
      line1: json['line1'] as String,
      line2: json['line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
    );
  }

  @override
  String toString() => fullAddress;
}
