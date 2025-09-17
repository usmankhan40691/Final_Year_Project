class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? transactionId;
  final String? error;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.transactionId,
    this.error,
  });
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
  canceled,
}

class PaymentHistory {
  final String id;
  final double amount;
  final String currency;
  final String description;
  final PaymentStatus status;
  final String paymentMethod;
  final String transactionId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PaymentHistory({
    required this.id,
    required this.amount,
    required this.currency,
    required this.description,
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    required this.createdAt,
    this.metadata,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      description: json['description'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'description': description,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  PaymentHistory copyWith({
    String? id,
    double? amount,
    String? currency,
    String? description,
    PaymentStatus? status,
    String? paymentMethod,
    String? transactionId,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentHistory(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum SubscriptionStatus {
  active,
  paused,
  canceled,
  expired,
}

class SubscriptionModel {
  final String id;
  final String planId;
  final String planName;
  final double amount;
  final String currency;
  final String interval;
  final SubscriptionStatus status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime createdAt;

  SubscriptionModel({
    required this.id,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      planId: json['planId'],
      planName: json['planName'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      interval: json['interval'],
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == 'SubscriptionStatus.${json['status']}',
        orElse: () => SubscriptionStatus.active,
      ),
      currentPeriodStart: DateTime.parse(json['currentPeriodStart']),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'planName': planName,
      'amount': amount,
      'currency': currency,
      'interval': interval,
      'status': status.toString().split('.').last,
      'currentPeriodStart': currentPeriodStart.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? planId,
    String? planName,
    double? amount,
    String? currency,
    String? interval,
    SubscriptionStatus? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      interval: interval ?? this.interval,
      status: status ?? this.status,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusText {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.canceled:
        return 'Canceled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isCanceled => status == SubscriptionStatus.canceled;
  bool get isExpired => status == SubscriptionStatus.expired;
}
