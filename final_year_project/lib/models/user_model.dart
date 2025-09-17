class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'paymentMethods': paymentMethods.map((method) => method.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((address) => Address.fromJson(address))
          .toList() ?? [],
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((method) => PaymentMethod.fromJson(method))
          .toList() ?? [],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class Address {
  final String id;
  final String title;
  final String fullName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;
  final bool isDefault;

  Address({
    required this.id,
    required this.title,
    required this.fullName,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phone,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      title: json['title'],
      fullName: json['fullName'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      phone: json['phone'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }
}

class PaymentMethod {
  final String id;
  final String type; // 'card', 'paypal', 'apple_pay', 'google_pay'
  final String title;
  final String? cardNumber; // Last 4 digits
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardHolderName;
  final String? cardType; // 'visa', 'mastercard', 'amex'
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cardHolderName,
    this.cardType,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardHolderName': cardHolderName,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      cardNumber: json['cardNumber'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      cardHolderName: json['cardHolderName'],
      cardType: json['cardType'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  String get displayInfo {
    if (type == 'card' && cardNumber != null) {
      return '**** **** **** $cardNumber';
    }
    return title;
  }
}
