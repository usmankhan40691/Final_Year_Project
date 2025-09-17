import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  CartSummary? _cartSummary;
  Coupon? _appliedCoupon;
  double _discountAmount = 0.0;
  Set<int> _updatingItems = {}; // Track which items are being updated

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CartSummary? get cartSummary => _cartSummary;
  Coupon? get appliedCoupon => _appliedCoupon;
  double get discountAmount => _discountAmount;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  bool isItemUpdating(int itemId) => _updatingItems.contains(itemId);

  CartService() {
    _loadCartFromStorage();
    // Don't fetch cart automatically - let it be called explicitly when user is authenticated
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_items');
      if (cartJson != null) {
        final cartData = jsonDecode(cartJson) as List;
        _cartItems = cartData.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
  }

  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items', cartJson);
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  Future<bool> fetchCart() async {
    // For guest users, just load from local storage without making API calls
    final headers = await _getAuthHeaders();
    if (headers['Authorization'] == null) {
      // Guest user - just use local cart
      _setError(null);
      return true;
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/cart/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _cartItems = (data['cart_items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
          _cartSummary = CartSummary.fromJson(data['summary']);
          await _saveCartToStorage();
          _setLoading(false);
          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - treat as guest user, don't show error
        _setError(null);
      } else {
        _setError('Failed to fetch cart');
      }
    } catch (e) {
      // On network error, don't show error to user, just use local cart
      debugPrint('Fetch cart error: $e');
      _setError(null);
    }

    _setLoading(false);
    return false;
  }

  Future<bool> addToCart(int productId, int quantity, {int? variantId}) async {
    // For guest users, don't make API calls - this should use addToLocalCart instead
    final headers = await _getAuthHeaders();
    if (headers['Authorization'] == null) {
      // Guest user - this method shouldn't be called, but handle gracefully
      _setError(null);
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final body = {
        'product_id': productId,
        'quantity': quantity,
      };
      
      if (variantId != null) {
        body['variant_id'] = variantId;
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/cart/add/'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          await fetchCart(); // Refresh cart
          _setLoading(false);
          return true;
        }
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Failed to add item to cart');
      }
    } catch (e) {
      // Don't show network error to user
      debugPrint('Add to cart error: $e');
      _setError(null);
    }

    _setLoading(false);
    return false;
  }

  Future<bool> updateCartItem(int itemId, int quantity) async {
    _updatingItems.add(itemId);
    _setError(null);
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/api/cart/update/$itemId/'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          await fetchCart(); // Refresh cart
          _updatingItems.remove(itemId);
          notifyListeners();
          return true;
        }
      } else {
        // If API fails, update local cart
        debugPrint('API update item failed, updating local cart');
        final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
        if (itemIndex >= 0) {
          final item = _cartItems[itemIndex];
          final unitPrice = item.unitPrice > 0 ? item.unitPrice : item.product.price;
          
          _cartItems[itemIndex] = CartItem(
            id: item.id,
            product: item.product,
            variant: item.variant,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: unitPrice * quantity,
            availableStock: item.availableStock,
            isOutOfStock: item.isOutOfStock,
            createdAt: item.createdAt,
            updatedAt: DateTime.now(),
          );
          
          _updateLocalCartSummary();
          await _saveCartToStorage();
        }
        
        _updatingItems.remove(itemId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Even on error, update local cart and don't show network error
      debugPrint('Update cart error: $e');
      
      // Even on error, update local cart
      final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex >= 0) {
        final item = _cartItems[itemIndex];
        final unitPrice = item.unitPrice > 0 ? item.unitPrice : item.product.price;
        
        _cartItems[itemIndex] = CartItem(
          id: item.id,
          product: item.product,
          variant: item.variant,
          quantity: quantity,
          unitPrice: unitPrice,
          totalPrice: unitPrice * quantity,
          availableStock: item.availableStock,
          isOutOfStock: item.isOutOfStock,
          createdAt: item.createdAt,
          updatedAt: DateTime.now(),
        );
        
        _updateLocalCartSummary();
        await _saveCartToStorage();
      }
    }

    _updatingItems.remove(itemId);
    notifyListeners();
    return true; // Always return true since we update local cart
  }

  Future<bool> removeFromCart(int itemId) async {
    _updatingItems.add(itemId);
    _setError(null);
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/api/cart/remove/$itemId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          await fetchCart(); // Refresh cart
          _updatingItems.remove(itemId);
          notifyListeners();
          return true;
        }
      } else {
        // If API fails, remove from local cart
        debugPrint('API remove item failed, removing from local cart');
        _cartItems.removeWhere((item) => item.id == itemId);
        _updateLocalCartSummary();
        await _saveCartToStorage();
        _updatingItems.remove(itemId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Don't show network errors to users - handle silently
      debugPrint('Remove from cart error: $e');
      
      // Even on error, remove from local cart
      _cartItems.removeWhere((item) => item.id == itemId);
      _updateLocalCartSummary();
      await _saveCartToStorage();
    }

    _updatingItems.remove(itemId);
    notifyListeners();
    return true; // Always return true since we remove from local cart
  }

  Future<bool> clearCart() async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/api/cart/clear/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _cartItems.clear();
          _cartSummary = null;
          _appliedCoupon = null;
          _discountAmount = 0.0;
          await _saveCartToStorage();
          _setLoading(false);
          notifyListeners();
          return true;
        }
      } else {
        // If API call fails, clear local cart anyway
        debugPrint('API clear cart failed, clearing local cart');
        _cartItems.clear();
        _cartSummary = null;
        _appliedCoupon = null;
        _discountAmount = 0.0;
        await _saveCartToStorage();
        _setLoading(false);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Don't show network errors to users - handle silently
      debugPrint('Clear cart error: $e');
      
      // Even on error, clear local cart
      _cartItems.clear();
      _cartSummary = null;
      _appliedCoupon = null;
      _discountAmount = 0.0;
      await _saveCartToStorage();
    }

    _setLoading(false);
    notifyListeners();
    return true; // Always return true since we clear local cart
  }

  Future<DjangoOrder?> checkout(CheckoutData checkoutData) async {
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/checkout/'),
        headers: headers,
        body: jsonEncode(checkoutData.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _cartItems.clear();
          _cartSummary = null;
          await _saveCartToStorage();
          _setLoading(false);
          notifyListeners();
          return DjangoOrder.fromJson(data['order']);
        }
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Checkout failed');
      }
    } catch (e) {
      // Don't show network errors to users for checkout failures
      debugPrint('Checkout error: $e');
      _setError('Unable to process checkout. Please try again.');
    }

    _setLoading(false);
    return null;
  }

  void clearError() {
    _setError(null);
  }

  // Coupon Management
  Future<bool> validateCoupon(String couponCode) async {
    if (_cartSummary == null) return false;
    
    _setLoading(true);
    _setError(null);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/coupons/validate/'),
        headers: headers,
        body: jsonEncode({
          'code': couponCode,
          'order_amount': _cartSummary!.subtotal,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final couponData = data['coupon'];
          _appliedCoupon = Coupon.fromJson(couponData);
          _discountAmount = double.parse(couponData['discount_amount'].toString());
          _updateCartSummaryWithDiscount();
          _setLoading(false);
          notifyListeners();
          return true;
        }
      } else {
        final data = jsonDecode(response.body);
        _setError(data['errors']?.toString() ?? 'Invalid coupon code');
      }
    } catch (e) {
      // Don't show network errors to users for coupon validation
      debugPrint('Validate coupon error: $e');
      _setError('Unable to validate coupon. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _discountAmount = 0.0;
    _updateCartSummaryWithDiscount();
    notifyListeners();
  }

  void _updateCartSummaryWithDiscount() {
    if (_cartSummary != null) {
      final discountedSubtotal = _cartSummary!.subtotal - _discountAmount;
      final shippingCost = discountedSubtotal >= 500 ? 0.0 : 50.0; // Recalculate shipping based on discounted amount
      final newTotal = discountedSubtotal + _cartSummary!.taxAmount + shippingCost;
      
      _cartSummary = CartSummary(
        itemsCount: _cartSummary!.itemsCount,
        subtotal: _cartSummary!.subtotal,
        discountAmount: _discountAmount,
        taxAmount: _cartSummary!.taxAmount,
        shippingCost: shippingCost,
        total: newTotal,
        couponCode: _appliedCoupon?.code,
      );
    }
  }

  // Local cart management for guest users
  void addToLocalCart(Product product, {int quantity = 1, ProductVariant? variant}) {
    // Check stock availability
    int availableStock = variant?.stockQuantity ?? product.stockQuantity;
    if (availableStock <= 0) {
      _setError('${product.name} is out of stock');
      return;
    }

    final existingIndex = _cartItems.indexWhere((item) => 
      item.product.id == product.id && 
      ((item.variant == null && variant == null) || 
       (item.variant?.id == variant?.id)));
    
    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      // Check if new quantity exceeds stock
      if (newQuantity > availableStock) {
        _setError('Cannot add more items. Only $availableStock available in stock. You already have ${existingItem.quantity} in cart.');
        return;
      }
      
      final unitPrice = variant?.finalPrice ?? product.price;
      _cartItems[existingIndex] = CartItem(
        id: existingItem.id,
        product: product,
        variant: variant,
        quantity: newQuantity,
        unitPrice: unitPrice,
        totalPrice: unitPrice * newQuantity,
        availableStock: availableStock,
        isOutOfStock: availableStock <= 0,
        createdAt: existingItem.createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      // Check if quantity exceeds stock for new item
      if (quantity > availableStock) {
        _setError('Cannot add $quantity items. Only $availableStock available in stock.');
        return;
      }
      
      final unitPrice = variant?.finalPrice ?? product.price;
      _cartItems.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch,
        product: product,
        variant: variant,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: unitPrice * quantity,
        availableStock: availableStock,
        isOutOfStock: availableStock <= 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    
    _setError(null); // Clear any previous errors
    _saveCartToStorage();
    _updateLocalCartSummary();
    notifyListeners();
  }

  void updateLocalCartQuantity(int productId, int quantity, {ProductVariant? variant}) {
    final index = _cartItems.indexWhere((item) => 
      item.product.id == productId && 
      ((item.variant == null && variant == null) || 
       (item.variant?.id == variant?.id)));
    
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        final item = _cartItems[index];
        final availableStock = item.availableStock;
        
        // Check stock limit
        if (quantity > availableStock) {
          _setError('Cannot update quantity. Only $availableStock available in stock.');
          return;
        }
        
        final unitPrice = item.variant?.finalPrice ?? item.product.price;
        _cartItems[index] = CartItem(
          id: item.id,
          product: item.product,
          variant: item.variant,
          quantity: quantity,
          unitPrice: unitPrice,
          totalPrice: unitPrice * quantity,
          availableStock: availableStock,
          isOutOfStock: availableStock <= 0,
          createdAt: item.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      
      _setError(null); // Clear any previous errors
      _saveCartToStorage();
      _updateLocalCartSummary();
      notifyListeners();
    }
  }

  void _updateLocalCartSummary() {
    if (_cartItems.isEmpty) {
      _cartSummary = null;
      return;
    }

    double subtotal = 0.0;
    for (var item in _cartItems) {
      final price = item.unitPrice > 0 ? item.unitPrice : item.product.price;
      subtotal += price * item.quantity;
    }
    
    final discountedSubtotal = subtotal - _discountAmount;
    final taxRate = 0.18; // 18% GST
    final taxAmount = discountedSubtotal * taxRate;
    final shippingCost = discountedSubtotal >= 500 ? 0.0 : 50.0; // Free shipping above ₹500
    final total = discountedSubtotal + taxAmount + shippingCost;

    _cartSummary = CartSummary(
      itemsCount: _cartItems.length,
      subtotal: subtotal,
      discountAmount: _discountAmount,
      taxAmount: taxAmount,
      shippingCost: shippingCost,
      total: total,
      couponCode: _appliedCoupon?.code,
    );
  }

  void removeFromLocalCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    _saveCartToStorage();
    notifyListeners();
  }

  void clearLocalCart() {
    _cartItems.clear();
    _saveCartToStorage();
    notifyListeners();
  }
}