import 'user_model.dart';

class CheckoutData {
  final String shippingName;
  final String shippingEmail;
  final String shippingPhone;
  final String shippingAddressLine1;
  final String shippingAddressLine2;
  final String shippingCity;
  final String shippingState;
  final String shippingPostalCode;
  final String shippingCountry;
  final String paymentMethod;
  final String? couponCode;

  CheckoutData({
    required this.shippingName,
    required this.shippingEmail,
    required this.shippingPhone,
    required this.shippingAddressLine1,
    required this.shippingAddressLine2,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPostalCode,
    required this.shippingCountry,
    required this.paymentMethod,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'shipping_name': shippingName,
      'shipping_email': shippingEmail,
      'shipping_phone': shippingPhone,
      'shipping_address_line1': shippingAddressLine1,
      'shipping_address_line2': shippingAddressLine2,
      'shipping_city': shippingCity,
      'shipping_state': shippingState,
      'shipping_postal_code': shippingPostalCode,
      'shipping_country': shippingCountry,
      'payment_method': paymentMethod,
      'coupon_code': couponCode,
    };
  }
}

class DjangoOrder {
  final int id;
  final String orderNumber;
  final String userEmail;
  final String shippingName;
  final String shippingEmail;
  final String shippingPhone;
  final String shippingAddressLine1;
  final String shippingAddressLine2;
  final String shippingCity;
  final String shippingState;
  final String shippingPostalCode;
  final String shippingCountry;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double totalAmount;
  final String orderStatus;
  final String paymentStatus;
  final DateTime createdAt;

  DjangoOrder({
    required this.id,
    required this.orderNumber,
    required this.userEmail,
    required this.shippingName,
    required this.shippingEmail,
    required this.shippingPhone,
    required this.shippingAddressLine1,
    required this.shippingAddressLine2,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPostalCode,
    required this.shippingCountry,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory DjangoOrder.fromJson(Map<String, dynamic> json) {
    return DjangoOrder(
      id: json['id'],
      orderNumber: json['order_number'],
      userEmail: json['user_email'],
      shippingName: json['shipping_name'],
      shippingEmail: json['shipping_email'],
      shippingPhone: json['shipping_phone'],
      shippingAddressLine1: json['shipping_address_line1'],
      shippingAddressLine2: json['shipping_address_line2'] ?? '',
      shippingCity: json['shipping_city'],
      shippingState: json['shipping_state'],
      shippingPostalCode: json['shipping_postal_code'],
      shippingCountry: json['shipping_country'],
      subtotal: double.parse(json['subtotal'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      shippingCost: double.parse(json['shipping_cost'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final OrderStatus status;
  final Address shippingAddress;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.deliveredAt,
    this.trackingNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'status': status.toString(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingNumber': trackingNumber,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      shipping: json['shipping'].toDouble(),
      total: json['total'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
      ),
      shippingAddress: Address.fromJson(json['shippingAddress']),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod']),
      createdAt: DateTime.parse(json['createdAt']),
      deliveredAt: json['deliveredAt'] != null 
          ? DateTime.parse(json['deliveredAt']) 
          : null,
      trackingNumber: json['trackingNumber'],
    );
  }
}

class OrderItem {
  final String productId;
  final String title;
  final String image;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      title: json['title'],
      image: json['image'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order is awaiting confirmation';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderStatus.processing:
        return 'Your order is being prepared';
      case OrderStatus.shipped:
        return 'Your order is on its way';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
      case OrderStatus.refunded:
        return 'Your order has been refunded';
    }
  }
}
