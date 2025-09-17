import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/payment_models.dart';

class PaymentService extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<PaymentHistory> _paymentHistory = [];
  List<SubscriptionModel> _subscriptions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PaymentHistory> get paymentHistory => _paymentHistory;
  List<SubscriptionModel> get subscriptions => _subscriptions;

  PaymentService() {
    _initializeStripe();
    _loadPaymentHistory();
    _loadSubscriptions();
  }

  void _initializeStripe() {
    // Initialize Stripe with your publishable key
    // Replace with your actual Stripe publishable key
    Stripe.publishableKey = "pk_test_your_publishable_key_here";
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _loadPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('payment_history');
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        _paymentHistory = historyList.map((item) => PaymentHistory.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading payment history: $e');
    }
  }

  Future<void> _savePaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_paymentHistory.map((item) => item.toJson()).toList());
      await prefs.setString('payment_history', historyJson);
    } catch (e) {
      debugPrint('Error saving payment history: $e');
    }
  }

  Future<void> _loadSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionsJson = prefs.getString('subscriptions');
      if (subscriptionsJson != null) {
        final List<dynamic> subscriptionsList = jsonDecode(subscriptionsJson);
        _subscriptions = subscriptionsList.map((item) => SubscriptionModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading subscriptions: $e');
    }
  }

  Future<void> _saveSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionsJson = jsonEncode(_subscriptions.map((item) => item.toJson()).toList());
      await prefs.setString('subscriptions', subscriptionsJson);
    } catch (e) {
      debugPrint('Error saving subscriptions: $e');
    }
  }

  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // In a real app, you would create a payment intent on your backend
      // and return the client secret
      final clientSecret = await _createPaymentIntent(amount, currency, description);

      if (clientSecret == null) {
        _setError('Failed to create payment intent');
        _setLoading(false);
        return PaymentResult(success: false, error: 'Failed to create payment intent');
      }

      // Confirm the payment
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: 'customer@example.com',
            ),
          ),
        ),
      );

      // Payment successful - add to history
      final payment = PaymentHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        currency: currency,
        description: description,
        status: PaymentStatus.completed,
        paymentMethod: 'Card',
        transactionId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      _paymentHistory.insert(0, payment);
      await _savePaymentHistory();
      
      _setLoading(false);
      notifyListeners();

      return PaymentResult(
        success: true,
        paymentId: payment.id,
        transactionId: payment.transactionId,
      );

    } on StripeException catch (e) {
      _setError('Payment failed: ${e.error.localizedMessage}');
      _setLoading(false);
      return PaymentResult(
        success: false,
        error: e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return PaymentResult(success: false, error: e.toString());
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency, String description) async {
    try {
      // In a real app, you would call your backend API here
      // This is a simulation for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      
      // Return a fake client secret (in real app, this comes from Stripe API via your backend)
      return 'pi_fake_client_secret_for_demo_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  Future<bool> setupPaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
    required String cardHolderName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Create payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: cardHolderName,
            ),
          ),
        ),
      );

      // In a real app, you would save this payment method to your backend
      // For demo purposes, we'll just return success
      _setLoading(false);
      return true;

    } on StripeException catch (e) {
      _setError('Failed to setup payment method: ${e.error.localizedMessage}');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createSubscription({
    required String planId,
    required String planName,
    required double amount,
    required String interval,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // In a real app, you would create a subscription via your backend
      await Future.delayed(const Duration(seconds: 2));

      final subscription = SubscriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        planId: planId,
        planName: planName,
        amount: amount,
        currency: 'USD',
        interval: interval,
        status: SubscriptionStatus.active,
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: _calculateNextBillingDate(interval),
        createdAt: DateTime.now(),
      );

      _subscriptions.add(subscription);
      await _saveSubscriptions();

      _setLoading(false);
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Failed to create subscription');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancelSubscription(String subscriptionId) async {
    _setLoading(true);
    _setError(null);

    try {
      // In a real app, you would cancel the subscription via your backend
      await Future.delayed(const Duration(seconds: 1));

      final index = _subscriptions.indexWhere((s) => s.id == subscriptionId);
      if (index != -1) {
        _subscriptions[index] = _subscriptions[index].copyWith(
          status: SubscriptionStatus.canceled,
        );
        await _saveSubscriptions();
      }

      _setLoading(false);
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Failed to cancel subscription');
      _setLoading(false);
      return false;
    }
  }

  Future<PaymentResult> processRefund(String paymentId, {double? amount}) async {
    _setLoading(true);
    _setError(null);

    try {
      // In a real app, you would process the refund via your backend
      await Future.delayed(const Duration(seconds: 2));

      // Update payment history
      final index = _paymentHistory.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _paymentHistory[index] = _paymentHistory[index].copyWith(
          status: PaymentStatus.refunded,
        );
        await _savePaymentHistory();
      }

      _setLoading(false);
      notifyListeners();

      return PaymentResult(
        success: true,
        paymentId: paymentId,
      );

    } catch (e) {
      _setError('Failed to process refund');
      _setLoading(false);
      return PaymentResult(success: false, error: e.toString());
    }
  }

  DateTime _calculateNextBillingDate(String interval) {
    final now = DateTime.now();
    switch (interval.toLowerCase()) {
      case 'month':
        return DateTime(now.year, now.month + 1, now.day);
      case 'year':
        return DateTime(now.year + 1, now.month, now.day);
      case 'week':
        return now.add(const Duration(days: 7));
      default:
        return now.add(const Duration(days: 30));
    }
  }

  void clearError() {
    _setError(null);
  }
}
