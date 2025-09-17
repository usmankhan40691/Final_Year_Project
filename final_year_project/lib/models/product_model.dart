class ProductVariant {
  final int id;
  final String sku;
  final String? size;
  final String? color;
  final String? material;
  final double priceAdjustment;
  final double finalPrice;
  final int stockQuantity;
  final String? image;
  final bool isActive;
  final bool isInStock;

  ProductVariant({
    required this.id,
    required this.sku,
    this.size,
    this.color,
    this.material,
    required this.priceAdjustment,
    required this.finalPrice,
    required this.stockQuantity,
    this.image,
    this.isActive = true,
    required this.isInStock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      sku: json['sku'],
      size: json['size'],
      color: json['color'],
      material: json['material'],
      priceAdjustment: double.parse(json['price_adjustment'].toString()),
      finalPrice: double.parse(json['final_price'].toString()),
      stockQuantity: json['stock_quantity'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
      isInStock: json['is_in_stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'size': size,
      'color': color,
      'material': material,
      'price_adjustment': priceAdjustment,
      'final_price': finalPrice,
      'stock_quantity': stockQuantity,
      'image': image,
      'is_active': isActive,
      'is_in_stock': isInStock,
    };
  }

  String get displayName {
    List<String> parts = [];
    if (size != null && size!.isNotEmpty) parts.add(size!);
    if (color != null && color!.isNotEmpty) parts.add(color!);
    if (material != null && material!.isNotEmpty) parts.add(material!);
    return parts.isNotEmpty ? parts.join(' | ') : 'Default';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Product {
  final int id;
  final String name;
  final String description;
  final String categoryName;
  final double price;
  final double? oldPrice;
  final int stockQuantity;
  final String? image;
  final double rating;
  final int reviewsCount;
  final bool isOnSale;
  final double discountPercentage;
  final bool isInStock;
  final bool isActive;
  final bool isFeatured;
  final bool hasVariants;
  final List<ProductVariant> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryName,
    required this.price,
    this.oldPrice,
    required this.stockQuantity,
    this.image,
    required this.rating,
    required this.reviewsCount,
    required this.isOnSale,
    required this.discountPercentage,
    required this.isInStock,
    this.isActive = true,
    this.isFeatured = false,
    this.hasVariants = false,
    this.variants = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<ProductVariant> variantsList = [];
    if (json['variants'] != null) {
      variantsList = (json['variants'] as List)
          .map((variant) => ProductVariant.fromJson(variant))
          .toList();
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryName: json['category_name'] ?? json['category'] ?? '',
      price: double.parse(json['price'].toString()),
      oldPrice: json['old_price'] != null ? double.parse(json['old_price'].toString()) : null,
      stockQuantity: json['stock_quantity'] ?? 0,
      image: json['image'],
      rating: double.parse(json['rating']?.toString() ?? '0.0'),
      reviewsCount: json['reviews_count'] ?? json['reviews'] ?? 0,
      isOnSale: json['is_on_sale'] ?? false,
      discountPercentage: double.parse(json['discount_percentage']?.toString() ?? '0.0'),
      isInStock: json['is_in_stock'] ?? json['stock_quantity'] > 0,
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      hasVariants: json['has_variants'] ?? false,
      variants: variantsList,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_name': categoryName,
      'price': price,
      'old_price': oldPrice,
      'stock_quantity': stockQuantity,
      'image': image,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_on_sale': isOnSale,
      'discount_percentage': discountPercentage,
      'is_in_stock': isInStock,
      'is_active': isActive,
      'is_featured': isFeatured,
      'has_variants': hasVariants,
      'variants': variants.map((v) => v.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getter for backward compatibility with local product model
  String get title => name;
  String get category => categoryName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Create a local product for demo purposes
  factory Product.createLocal({
    required int id,
    required String name,
    required String category,
    required double price,
    double? oldPrice,
    required String description,
    String? image,
    double rating = 4.5,
    int reviews = 100,
    bool hasVariants = false,
    List<ProductVariant> variants = const [],
  }) {
    return Product(
      id: id,
      name: name,
      description: description,
      categoryName: category,
      price: price,
      oldPrice: oldPrice,
      stockQuantity: 10,
      image: image,
      rating: rating,
      reviewsCount: reviews,
      isOnSale: oldPrice != null && oldPrice > price,
      discountPercentage: oldPrice != null ? ((oldPrice - price) / oldPrice * 100) : 0.0,
      isInStock: true,
      hasVariants: hasVariants,
      variants: variants,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class CartItem {
  final int id;
  final Product product;
  final ProductVariant? variant;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int availableStock;
  final bool isOutOfStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.product,
    this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.availableStock,
    required this.isOutOfStock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      variant: json['variant'] != null ? ProductVariant.fromJson(json['variant']) : null,
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      availableStock: json['available_stock'] ?? 0,
      isOutOfStock: json['is_out_of_stock'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'variant': variant?.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'available_stock': availableStock,
      'is_out_of_stock': isOutOfStock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    String name = product.name;
    if (variant != null) {
      name += ' (${variant!.displayName})';
    }
    return name;
  }
}

class CartSummary {
  final int itemsCount;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final String? couponCode;

  CartSummary({
    required this.itemsCount,
    required this.subtotal,
    this.discountAmount = 0.0,
    required this.taxAmount,
    this.shippingCost = 0.0,
    required this.total,
    this.couponCode,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      itemsCount: json['items_count'],
      subtotal: double.parse(json['subtotal'].toString()),
      discountAmount: double.parse(json['discount_amount']?.toString() ?? '0.0'),
      taxAmount: double.parse(json['tax_amount'].toString()),
      shippingCost: double.parse(json['shipping_cost']?.toString() ?? '0.0'),
      total: double.parse(json['total'].toString()),
      couponCode: json['coupon_code'],
    );
  }
}

class Coupon {
  final int id;
  final String code;
  final String description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minimumOrderAmount;
  final double? maximumDiscountAmount;
  final int? usageLimit;
  final int usageLimitPerUser;
  final int usedCount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final bool isValid;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.usageLimit,
    required this.usageLimitPerUser,
    required this.usedCount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    required this.isValid,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      description: json['description'] ?? '',
      discountType: json['discount_type'],
      discountValue: double.parse(json['discount_value'].toString()),
      minimumOrderAmount: double.parse(json['minimum_order_amount'].toString()),
      maximumDiscountAmount: json['maximum_discount_amount'] != null
          ? double.parse(json['maximum_discount_amount'].toString())
          : null,
      usageLimit: json['usage_limit'],
      usageLimitPerUser: json['usage_limit_per_user'] ?? 1,
      usedCount: json['used_count'] ?? 0,
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'] ?? true,
      isValid: json['is_valid'] ?? true,
    );
  }

  double calculateDiscount(double orderAmount) {
    if (!isValid || orderAmount < minimumOrderAmount) {
      return 0.0;
    }

    double discount = 0.0;
    if (discountType == 'percentage') {
      discount = (orderAmount * discountValue) / 100;
    } else {
      discount = discountValue;
    }

    if (maximumDiscountAmount != null && discount > maximumDiscountAmount!) {
      discount = maximumDiscountAmount!;
    }

    return discount;
  }

  String get displayText {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}% OFF';
    } else {
      return '₹${discountValue.toInt()} OFF';
    }
  }
}