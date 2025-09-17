import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class StripeCheckoutScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final Map<String, dynamic>? metadata;

  const StripeCheckoutScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.description,
    this.metadata,
  });

  @override
  State<StripeCheckoutScreen> createState() => _StripeCheckoutScreenState();
}

class _StripeCheckoutScreenState extends State<StripeCheckoutScreen> {
  PaymentMethod? _selectedPaymentMethod;
  bool _savePaymentMethod = false;
  final _formKey = GlobalKey<FormState>();
  
  // Card form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer2<PaymentService, AuthService>(
        builder: (context, paymentService, authService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                _buildOrderSummary(),
                
                const SizedBox(height: 24),
                
                // Payment Methods
                _buildPaymentMethodsSection(authService),
                
                const SizedBox(height: 24),
                
                // New Card Form (if no existing payment method selected)
                if (_selectedPaymentMethod == null)
                  _buildNewCardForm(),
                
                const SizedBox(height: 32),
                
                // Pay Button
                _buildPayButton(paymentService, authService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '${widget.currency.toUpperCase()} ${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.currency.toUpperCase()} ${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB6FF5B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection(AuthService authService) {
    if (!authService.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final paymentMethods = authService.currentUser!.paymentMethods;
    
    if (paymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Payment Methods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...paymentMethods.map((method) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: RadioListTile<PaymentMethod>(
            value: method,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
            title: Text(
              method.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(method.displayInfo),
            secondary: _buildPaymentMethodIcon(method),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _selectedPaymentMethod == method 
                    ? const Color(0xFFB6FF5B) 
                    : Colors.grey[300]!,
                width: _selectedPaymentMethod == method ? 2 : 1,
              ),
            ),
            activeColor: const Color(0xFFB6FF5B),
          ),
        )),
        
        const SizedBox(height: 16),
        
        // Add new payment method option
        InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPaymentMethod == null 
                    ? const Color(0xFFB6FF5B) 
                    : Colors.grey[300]!,
                width: _selectedPaymentMethod == null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_card_outlined,
                  color: _selectedPaymentMethod == null 
                      ? const Color(0xFFB6FF5B) 
                      : Colors.grey[600],
                ),
                const SizedBox(width: 16),
                Text(
                  'Add new payment method',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selectedPaymentMethod == null 
                        ? Colors.black 
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodIcon(PaymentMethod method) {
    IconData iconData;
    Color iconColor;

    switch (method.type) {
      case 'card':
        switch (method.cardType?.toLowerCase()) {
          case 'visa':
            iconData = Icons.credit_card;
            iconColor = Colors.blue;
            break;
          case 'mastercard':
            iconData = Icons.credit_card;
            iconColor = Colors.orange;
            break;
          case 'amex':
            iconData = Icons.credit_card;
            iconColor = Colors.green;
            break;
          default:
            iconData = Icons.credit_card;
            iconColor = Colors.grey;
        }
        break;
      case 'paypal':
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.payment;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor);
  }

  Widget _buildNewCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Card Number
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFB6FF5B)),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: _formatCardNumber,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter card number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Expiry and CVV
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/25',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFB6FF5B)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _formatExpiry,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter expiry date';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFB6FF5B)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cardholder Name
          TextFormField(
            controller: _cardHolderController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFB6FF5B)),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Save payment method checkbox
          Consumer<AuthService>(
            builder: (context, authService, child) {
              if (!authService.isAuthenticated) {
                return const SizedBox.shrink();
              }
              
              return CheckboxListTile(
                value: _savePaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _savePaymentMethod = value ?? false;
                  });
                },
                title: const Text(
                  'Save payment method for future purchases',
                  style: TextStyle(fontSize: 14),
                ),
                activeColor: const Color(0xFFB6FF5B),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(PaymentService paymentService, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: paymentService.isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB6FF5B),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: paymentService.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Pay ${widget.currency.toUpperCase()} ${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _formatCardNumber(String value) {
    // Remove all non-digit characters
    String digits = value.replaceAll(RegExp(r'\D'), '');
    
    // Add spaces every 4 digits
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digits[i];
    }
    
    // Limit to 19 characters (16 digits + 3 spaces)
    if (formatted.length > 19) {
      formatted = formatted.substring(0, 19);
    }
    
    _cardNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _formatExpiry(String value) {
    // Remove all non-digit characters
    String digits = value.replaceAll(RegExp(r'\D'), '');
    
    // Add slash after MM
    String formatted = '';
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += digits[i];
    }
    
    _expiryController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _processPayment() async {
    // Validate form if using new card
    if (_selectedPaymentMethod == null) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }
    }

    final paymentService = Provider.of<PaymentService>(context, listen: false);

    try {
      final result = await paymentService.processPayment(
        amount: widget.amount,
        currency: widget.currency,
        description: widget.description,
        metadata: widget.metadata,
      );

      if (result.success && mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Payment Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transaction ID: ${result.transactionId}'),
                const SizedBox(height: 8),
                Text('Amount: ${widget.currency.toUpperCase()} ${widget.amount.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(result); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6FF5B),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );

        // Save payment method if requested
        if (_savePaymentMethod && _selectedPaymentMethod == null) {
          final authService = Provider.of<AuthService>(context, listen: false);
          if (authService.isAuthenticated) {
            // TODO: Save the payment method to user profile
          }
        }
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${result.error ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }
}
