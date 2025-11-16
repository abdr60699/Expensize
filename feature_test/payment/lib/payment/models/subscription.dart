/// Subscription models
library;

/// Subscription status
enum SubscriptionStatus {
  /// In trial period
  trialing,

  /// Active subscription
  active,

  /// Payment failed, in grace period
  pastDue,

  /// Canceled by user
  canceled,

  /// Subscription expired
  expired,

  /// Temporarily paused
  paused,

  /// Incomplete (awaiting payment confirmation)
  incomplete,
}

/// Billing interval for subscriptions
enum BillingInterval {
  /// Daily billing
  daily,

  /// Weekly billing
  weekly,

  /// Monthly billing
  monthly,

  /// Quarterly billing (every 3 months)
  quarterly,

  /// Semi-annual billing (every 6 months)
  semiAnnual,

  /// Annual billing
  annual,
}

/// Subscription cancellation reason
enum CancellationReason {
  /// User requested cancellation
  userRequested,

  /// Payment failed
  paymentFailed,

  /// Fraud detected
  fraud,

  /// Service no longer needed
  serviceNotNeeded,

  /// Too expensive
  tooExpensive,

  /// Switching to competitor
  switchingToCompetitor,

  /// Low quality
  lowQuality,

  /// Missing features
  missingFeatures,

  /// Customer support issues
  customerSupport,

  /// Other reason
  other,
}

/// Subscription information
class Subscription {
  /// Unique subscription identifier
  final String subscriptionId;

  /// Customer identifier
  final String customerId;

  /// Subscription plan identifier
  final String planId;

  /// Current subscription status
  final SubscriptionStatus status;

  /// Subscription start date
  final DateTime startDate;

  /// Subscription end date (if canceled)
  final DateTime? endDate;

  /// Trial period end date
  final DateTime? trialEndDate;

  /// Current billing period start
  final DateTime currentPeriodStart;

  /// Current billing period end
  final DateTime currentPeriodEnd;

  /// Recurring amount
  final double amount;

  /// Currency code
  final String currency;

  /// Billing interval
  final BillingInterval interval;

  /// Payment provider identifier
  final String providerId;

  /// Cancel at end of period (won't renew)
  final bool cancelAtPeriodEnd;

  /// Cancellation reason (if canceled)
  final CancellationReason? cancellationReason;

  /// Cancellation date
  final DateTime? canceledAt;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const Subscription({
    required this.subscriptionId,
    required this.customerId,
    required this.planId,
    required this.status,
    required this.startDate,
    this.endDate,
    this.trialEndDate,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.providerId,
    this.cancelAtPeriodEnd = false,
    this.cancellationReason,
    this.canceledAt,
    this.metadata,
  });

  /// Whether subscription is currently active
  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing;

  /// Whether subscription is in trial period
  bool get isTrialing => status == SubscriptionStatus.trialing;

  /// Whether subscription is canceled
  bool get isCanceled => status == SubscriptionStatus.canceled;

  /// Whether subscription is in grace period
  bool get isInGracePeriod => status == SubscriptionStatus.pastDue;

  /// Days remaining in current period
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(currentPeriodEnd)) return 0;
    return currentPeriodEnd.difference(now).inDays;
  }

  /// Days remaining in trial (0 if not trialing)
  int get trialDaysRemaining {
    if (trialEndDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(trialEndDate!)) return 0;
    return trialEndDate!.difference(now).inDays;
  }

  /// Next billing date
  DateTime get nextBillingDate => currentPeriodEnd;

  /// Copy with modifications
  Subscription copyWith({
    String? subscriptionId,
    String? customerId,
    String? planId,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    double? amount,
    String? currency,
    BillingInterval? interval,
    String? providerId,
    bool? cancelAtPeriodEnd,
    CancellationReason? cancellationReason,
    DateTime? canceledAt,
    Map<String, dynamic>? metadata,
  }) {
    return Subscription(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      customerId: customerId ?? this.customerId,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      interval: interval ?? this.interval,
      providerId: providerId ?? this.providerId,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      canceledAt: canceledAt ?? this.canceledAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'customerId': customerId,
      'planId': planId,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'currentPeriodStart': currentPeriodStart.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'interval': interval.name,
      'providerId': providerId,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
      'cancellationReason': cancellationReason?.name,
      'canceledAt': canceledAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionId: json['subscriptionId'] as String,
      customerId: json['customerId'] as String,
      planId: json['planId'] as String,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'] as String)
          : null,
      currentPeriodStart: DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      interval: BillingInterval.values.firstWhere(
        (e) => e.name == json['interval'],
        orElse: () => BillingInterval.monthly,
      ),
      providerId: json['providerId'] as String,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      cancellationReason: json['cancellationReason'] != null
          ? CancellationReason.values.firstWhere(
              (e) => e.name == json['cancellationReason'],
              orElse: () => CancellationReason.other,
            )
          : null,
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Subscription(id: $subscriptionId, plan: $planId, status: $status, amount: $amount $currency/$interval)';
  }
}

/// Subscription request for creation
class SubscriptionRequest {
  /// Subscription plan identifier
  final String planId;

  /// Customer identifier
  final String customerId;

  /// Trial period in days (0 for no trial)
  final int trialDays;

  /// Custom amount (if different from plan default)
  final double? customAmount;

  /// Promo/coupon code
  final String? promoCode;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const SubscriptionRequest({
    required this.planId,
    required this.customerId,
    this.trialDays = 0,
    this.customAmount,
    this.promoCode,
    this.metadata,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'customerId': customerId,
      'trialDays': trialDays,
      'customAmount': customAmount,
      'promoCode': promoCode,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory SubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return SubscriptionRequest(
      planId: json['planId'] as String,
      customerId: json['customerId'] as String,
      trialDays: json['trialDays'] as int? ?? 0,
      customAmount: json['customAmount'] != null
          ? (json['customAmount'] as num).toDouble()
          : null,
      promoCode: json['promoCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Subscription update request
class SubscriptionUpdate {
  /// New plan ID (for upgrades/downgrades)
  final String? planId;

  /// Update amount
  final double? amount;

  /// Promo code to apply
  final String? promoCode;

  /// Whether to prorate charges
  final bool prorate;

  const SubscriptionUpdate({
    this.planId,
    this.amount,
    this.promoCode,
    this.prorate = true,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'amount': amount,
      'promoCode': promoCode,
      'prorate': prorate,
    };
  }
}

/// Subscription result
class SubscriptionResult {
  /// Created/updated subscription
  final Subscription subscription;

  /// Whether operation was successful
  final bool success;

  /// Error message if failed
  final String? error;

  const SubscriptionResult({
    required this.subscription,
    required this.success,
    this.error,
  });

  /// Create successful result
  factory SubscriptionResult.success(Subscription subscription) {
    return SubscriptionResult(
      subscription: subscription,
      success: true,
    );
  }

  /// Create failed result
  factory SubscriptionResult.failed({
    required Subscription subscription,
    required String error,
  }) {
    return SubscriptionResult(
      subscription: subscription,
      success: false,
      error: error,
    );
  }
}
