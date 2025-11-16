/// UPI app information model
library;

/// Information about a UPI payment app
class UpiAppInfo {
  /// Unique adapter identifier
  final String appId;

  /// Display name (e.g., "Google Pay", "PhonePe")
  final String appName;

  /// Android package name
  final String packageName;

  /// Icon asset path (optional)
  final String? iconAsset;

  /// Whether app is installed on device
  final bool isInstalled;

  /// Display priority (lower = higher priority)
  final int priority;

  /// Whether this is user's preferred app
  final bool isPreferred;

  /// App color (for UI theming)
  final int? brandColor;

  /// Short description
  final String? description;

  const UpiAppInfo({
    required this.appId,
    required this.appName,
    required this.packageName,
    this.iconAsset,
    required this.isInstalled,
    this.priority = 999,
    this.isPreferred = false,
    this.brandColor,
    this.description,
  });

  /// Google Pay app info
  static UpiAppInfo googlePay({
    required bool isInstalled,
    bool isPreferred = false,
  }) {
    return UpiAppInfo(
      appId: 'google_pay',
      appName: 'Google Pay',
      packageName: 'com.google.android.apps.nbu.paisa.user',
      iconAsset: 'assets/upi_icons/google_pay.png',
      isInstalled: isInstalled,
      priority: 1,
      isPreferred: isPreferred,
      brandColor: 0xFF4285F4, // Google Blue
      description: 'Pay with Google Pay',
    );
  }

  /// PhonePe app info
  static UpiAppInfo phonePe({
    required bool isInstalled,
    bool isPreferred = false,
  }) {
    return UpiAppInfo(
      appId: 'phonepe',
      appName: 'PhonePe',
      packageName: 'com.phonepe.app',
      iconAsset: 'assets/upi_icons/phonepe.png',
      isInstalled: isInstalled,
      priority: 2,
      isPreferred: isPreferred,
      brandColor: 0xFF5F259F, // PhonePe Purple
      description: 'Pay with PhonePe',
    );
  }

  /// BHIM app info
  static UpiAppInfo bhim({
    required bool isInstalled,
    bool isPreferred = false,
  }) {
    return UpiAppInfo(
      appId: 'bhim',
      appName: 'BHIM UPI',
      packageName: 'in.org.npci.upiapp',
      iconAsset: 'assets/upi_icons/bhim.png',
      isInstalled: isInstalled,
      priority: 3,
      isPreferred: isPreferred,
      brandColor: 0xFF00529C, // BHIM Blue
      description: 'Pay with BHIM',
    );
  }

  /// Paytm app info
  static UpiAppInfo paytm({
    required bool isInstalled,
    bool isPreferred = false,
  }) {
    return UpiAppInfo(
      appId: 'paytm',
      appName: 'Paytm',
      packageName: 'net.one97.paytm',
      iconAsset: 'assets/upi_icons/paytm.png',
      isInstalled: isInstalled,
      priority: 4,
      isPreferred: isPreferred,
      brandColor: 0xFF00B9F5, // Paytm Blue
      description: 'Pay with Paytm',
    );
  }

  /// Amazon Pay app info
  static UpiAppInfo amazonPay({
    required bool isInstalled,
    bool isPreferred = false,
  }) {
    return UpiAppInfo(
      appId: 'amazon_pay',
      appName: 'Amazon Pay',
      packageName: 'in.amazon.mShop.android.shopping',
      iconAsset: 'assets/upi_icons/amazon_pay.png',
      isInstalled: isInstalled,
      priority: 5,
      isPreferred: isPreferred,
      brandColor: 0xFFFF9900, // Amazon Orange
      description: 'Pay with Amazon Pay',
    );
  }

  /// Copy with modifications
  UpiAppInfo copyWith({
    String? appId,
    String? appName,
    String? packageName,
    String? iconAsset,
    bool? isInstalled,
    int? priority,
    bool? isPreferred,
    int? brandColor,
    String? description,
  }) {
    return UpiAppInfo(
      appId: appId ?? this.appId,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      iconAsset: iconAsset ?? this.iconAsset,
      isInstalled: isInstalled ?? this.isInstalled,
      priority: priority ?? this.priority,
      isPreferred: isPreferred ?? this.isPreferred,
      brandColor: brandColor ?? this.brandColor,
      description: description ?? this.description,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'appName': appName,
      'packageName': packageName,
      'iconAsset': iconAsset,
      'isInstalled': isInstalled,
      'priority': priority,
      'isPreferred': isPreferred,
      'brandColor': brandColor,
      'description': description,
    };
  }

  /// Create from JSON
  factory UpiAppInfo.fromJson(Map<String, dynamic> json) {
    return UpiAppInfo(
      appId: json['appId'] as String,
      appName: json['appName'] as String,
      packageName: json['packageName'] as String,
      iconAsset: json['iconAsset'] as String?,
      isInstalled: json['isInstalled'] as bool,
      priority: json['priority'] as int? ?? 999,
      isPreferred: json['isPreferred'] as bool? ?? false,
      brandColor: json['brandColor'] as int?,
      description: json['description'] as String?,
    );
  }

  @override
  String toString() {
    return 'UpiAppInfo(id: $appId, name: $appName, installed: $isInstalled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpiAppInfo && other.appId == appId;
  }

  @override
  int get hashCode => appId.hashCode;
}
