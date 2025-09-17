class UserPaymentMethod {
  final int? id;
  final String type; // 'card', 'paypal', 'apple_pay', 'google_pay', 'bank_transfer'
  final String title;
  final String? cardNumber; // Last 4 digits only for security
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardHolderName;
  final String? cardBrand; // 'visa', 'mastercard', 'amex', 'discover'
  final String? paypalEmail;
  final String? bankName;
  final String? accountNumber; // Last 4 digits only
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPaymentMethod({
    this.id,
    required this.type,
    required this.title,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cardHolderName,
    this.cardBrand,
    this.paypalEmail,
    this.bankName,
    this.accountNumber,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPaymentMethod.fromJson(Map<String, dynamic> json) {
    return UserPaymentMethod(
      id: json['id'],
      type: json['type'] ?? 'card',
      title: json['title'] ?? '',
      cardNumber: json['card_number'],
      expiryMonth: json['expiry_month'],
      expiryYear: json['expiry_year'],
      cardHolderName: json['card_holder_name'],
      cardBrand: json['card_brand'],
      paypalEmail: json['paypal_email'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'title': title,
      'card_number': cardNumber,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'card_holder_name': cardHolderName,
      'card_brand': cardBrand,
      'paypal_email': paypalEmail,
      'bank_name': bankName,
      'account_number': accountNumber,
      'is_default': isDefault,
    };
  }

  String get displayInfo {
    switch (type) {
      case 'card':
        if (cardNumber != null) {
          return '**** **** **** $cardNumber';
        }
        break;
      case 'paypal':
        if (paypalEmail != null) {
          return paypalEmail!;
        }
        break;
      case 'bank_transfer':
        if (bankName != null && accountNumber != null) {
          return '$bankName ****$accountNumber';
        }
        break;
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
    }
    return title;
  }

  String get cardIconPath {
    switch (cardBrand?.toLowerCase()) {
      case 'visa':
        return 'assets/icons/visa.png';
      case 'mastercard':
        return 'assets/icons/mastercard.png';
      case 'amex':
      case 'american_express':
        return 'assets/icons/amex.png';
      case 'discover':
        return 'assets/icons/discover.png';
      default:
        return 'assets/icons/credit_card.png';
    }
  }

  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;
    
    final now = DateTime.now();
    final expiryDate = DateTime(
      int.parse('20$expiryYear'), // Assuming YY format
      int.parse(expiryMonth!),
    );
    
    return now.isAfter(expiryDate);
  }

  UserPaymentMethod copyWith({
    int? id,
    String? type,
    String? title,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cardHolderName,
    String? cardBrand,
    String? paypalEmail,
    String? bankName,
    String? accountNumber,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardBrand: cardBrand ?? this.cardBrand,
      paypalEmail: paypalEmail ?? this.paypalEmail,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPaymentMethod &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}