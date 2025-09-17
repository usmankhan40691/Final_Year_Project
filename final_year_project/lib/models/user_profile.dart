class UserProfile {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? phone;
  final String? profileImage;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final bool isActive;
  final UserStats stats;
  final UserSettings settings;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.phone,
    this.profileImage,
    this.dateJoined,
    this.lastLogin,
    this.isActive = true,
    required this.stats,
    required this.settings,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email.split('@')[0]; // Fallback to email username
  }

  String get displayName => username ?? fullName;

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0].toUpperCase()}${lastName![0].toUpperCase()}';
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      dateJoined: json['date_joined'] != null ? DateTime.parse(json['date_joined']) : null,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      isActive: json['is_active'] ?? true,
      stats: UserStats.fromJson(json['stats'] ?? {}),
      settings: UserSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'phone': phone,
      'profile_image': profileImage,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'stats': stats.toJson(),
      'settings': settings.toJson(),
    };
  }

  UserProfile copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    String? phone,
    String? profileImage,
    DateTime? dateJoined,
    DateTime? lastLogin,
    bool? isActive,
    UserStats? stats,
    UserSettings? settings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
    );
  }
}

class UserStats {
  final int ordersCount;
  final int addressesCount;
  final int paymentMethodsCount;
  final int wishlistCount;
  final double totalSpent;
  final int loyaltyPoints;
  final double walletBalance;
  final List<RecentOrder> recentOrders;

  UserStats({
    this.ordersCount = 0,
    this.addressesCount = 0,
    this.paymentMethodsCount = 0,
    this.wishlistCount = 0,
    this.totalSpent = 0.0,
    this.loyaltyPoints = 0,
    this.walletBalance = 0.0,
    this.recentOrders = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      ordersCount: json['orders_count'] ?? 0,
      addressesCount: json['addresses_count'] ?? 0,
      paymentMethodsCount: json['payment_methods_count'] ?? 0,
      wishlistCount: json['wishlist_count'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      loyaltyPoints: json['loyalty_points'] ?? 0,
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      recentOrders: (json['recent_orders'] as List<dynamic>?)
          ?.map((order) => RecentOrder.fromJson(order))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders_count': ordersCount,
      'addresses_count': addressesCount,
      'payment_methods_count': paymentMethodsCount,
      'wishlist_count': wishlistCount,
      'total_spent': totalSpent,
      'loyalty_points': loyaltyPoints,
      'wallet_balance': walletBalance,
      'recent_orders': recentOrders.map((order) => order.toJson()).toList(),
    };
  }
}

class RecentOrder {
  final int id;
  final String productName;
  final DateTime orderDate;
  final String status;
  final double amount;
  final String? productImage;

  RecentOrder({
    required this.id,
    required this.productName,
    required this.orderDate,
    required this.status,
    required this.amount,
    this.productImage,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      orderDate: DateTime.parse(json['order_date']),
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      productImage: json['product_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'amount': amount,
      'product_image': productImage,
    };
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final String preferredLanguage;
  final String preferredCurrency;
  final bool darkMode;
  final bool biometricAuth;

  UserSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'USD',
    this.darkMode = false,
    this.biometricAuth = false,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notifications_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? false,
      preferredLanguage: json['preferred_language'] ?? 'en',
      preferredCurrency: json['preferred_currency'] ?? 'USD',
      darkMode: json['dark_mode'] ?? false,
      biometricAuth: json['biometric_auth'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'preferred_language': preferredLanguage,
      'preferred_currency': preferredCurrency,
      'dark_mode': darkMode,
      'biometric_auth': biometricAuth,
    };
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    String? preferredLanguage,
    String? preferredCurrency,
    bool? darkMode,
    bool? biometricAuth,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      darkMode: darkMode ?? this.darkMode,
      biometricAuth: biometricAuth ?? this.biometricAuth,
    );
  }
}

class ProfileUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? phone;
  final String? profileImage;

  ProfileUpdateRequest({
    this.firstName,
    this.lastName,
    this.username,
    this.phone,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (username != null) data['username'] = username;
    if (phone != null) data['phone'] = phone;
    if (profileImage != null) data['profile_image'] = profileImage;
    return data;
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}