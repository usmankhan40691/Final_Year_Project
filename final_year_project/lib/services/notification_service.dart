import 'package:flutter/foundation.dart';
import 'dart:async';

enum NotificationType {
  info,
  success,
  warning,
  error,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeLast();
    }
    
    notifyListeners();

    // Auto-remove info notifications after 30 seconds
    if (type == NotificationType.info) {
      Timer(const Duration(seconds: 30), () {
        removeNotification(notification.id);
      });
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Stock notification methods
  void notifyOutOfStock(String productName) {
    addNotification(
      title: 'Out of Stock',
      message: '$productName is now out of stock',
      type: NotificationType.warning,
    );
  }

  void notifyBackInStock(String productName) {
    addNotification(
      title: 'Back in Stock',
      message: '$productName is now available',
      type: NotificationType.success,
    );
  }

  void notifyLowStock(String productName, int quantity) {
    addNotification(
      title: 'Low Stock Alert',
      message: 'Only $quantity left of $productName',
      type: NotificationType.warning,
    );
  }

  void notifyOrderPlaced(String orderNumber) {
    addNotification(
      title: 'Order Placed',
      message: 'Your order #$orderNumber has been placed successfully',
      type: NotificationType.success,
    );
  }

  void notifyPaymentFailed(String reason) {
    addNotification(
      title: 'Payment Failed',
      message: 'Payment failed: $reason',
      type: NotificationType.error,
    );
  }

  void notifyCouponApplied(String couponCode, double discount) {
    addNotification(
      title: 'Coupon Applied',
      message: 'Coupon $couponCode applied! You saved ₹${discount.toStringAsFixed(2)}',
      type: NotificationType.success,
    );
  }
}