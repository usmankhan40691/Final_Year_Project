import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class OrderService extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderService() {
    _loadOrdersFromStorage();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _loadOrdersFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('user_orders') ?? [];
      _orders = ordersJson
          .map((orderStr) => Order.fromJson(jsonDecode(orderStr)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders from storage: $e');
    }
  }

  Future<void> _saveOrdersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = _orders
          .map((order) => jsonEncode(order.toJson()))
          .toList();
      await prefs.setStringList('user_orders', ordersJson);
    } catch (e) {
      debugPrint('Error saving orders to storage: $e');
    }
  }

  Future<String?> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required Address shippingAddress,
    required PaymentMethod paymentMethod,
    double taxRate = 0.1, // 10% tax
    double shippingCost = 5.99,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Calculate totals
      double subtotal = 0;
      for (final cartItem in cartItems) {
        final price = cartItem.product.price;
        subtotal += price * cartItem.quantity;
      }

      final tax = subtotal * taxRate;
      final total = subtotal + tax + shippingCost;

      // Convert cart items to order items
      final orderItems = cartItems.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id.toString(),
          title: cartItem.product.name,
          image: cartItem.product.image ?? '',
          price: cartItem.product.price,
          quantity: cartItem.quantity,
        );
      }).toList();

      // Create order
      final order = Order(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        items: orderItems,
        subtotal: subtotal,
        tax: tax,
        shipping: shippingCost,
        total: total,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Add to orders list
      _orders.insert(0, order); // Add to beginning for latest first
      await _saveOrdersToStorage();

      _setLoading(false);
      notifyListeners();
      
      return order.id;
    } catch (e) {
      _setError('Failed to create order');
      _setLoading(false);
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final updatedOrder = Order(
          id: _orders[orderIndex].id,
          userId: _orders[orderIndex].userId,
          items: _orders[orderIndex].items,
          subtotal: _orders[orderIndex].subtotal,
          tax: _orders[orderIndex].tax,
          shipping: _orders[orderIndex].shipping,
          total: _orders[orderIndex].total,
          status: status,
          shippingAddress: _orders[orderIndex].shippingAddress,
          paymentMethod: _orders[orderIndex].paymentMethod,
          createdAt: _orders[orderIndex].createdAt,
          deliveredAt: status == OrderStatus.delivered ? DateTime.now() : _orders[orderIndex].deliveredAt,
          trackingNumber: _orders[orderIndex].trackingNumber,
        );

        _orders[orderIndex] = updatedOrder;
        await _saveOrdersToStorage();
        notifyListeners();
      }

      _setLoading(false);
    } catch (e) {
      _setError('Failed to update order status');
      _setLoading(false);
    }
  }

  List<Order> getOrdersForUser(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _setError(null);
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // Calculate cart totals for checkout preview
  Map<String, double> calculateCartTotals(
    List<CartItem> cartItems, {
    double taxRate = 0.1,
    double shippingCost = 5.99,
  }) {
    double subtotal = 0;
    
    for (final cartItem in cartItems) {
      final price = cartItem.product.price;
      subtotal += price * cartItem.quantity;
    }

    final tax = subtotal * taxRate;
    final total = subtotal + tax + shippingCost;

    return {
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shippingCost,
      'total': total,
    };
  }
}
