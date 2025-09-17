import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  // State
  String _selectedPaymentType = 'card';
  String? _cardType;
  bool _isDefault = false;
  bool _isLoading = false;

  final List<Map<String, String>> _paymentTypes = [
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': 'credit_card'},
    {'id': 'paypal', 'name': 'PayPal', 'icon': 'account_balance_wallet'},
    {'id': 'apple_pay', 'name': 'Apple Pay', 'icon': 'phone_iphone'},
    {'id': 'google_pay', 'name': 'Google Pay', 'icon': 'android'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  String? _detectCardType(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    
    if (cardNumber.isEmpty) return null;
    
    // Visa
    if (cardNumber.startsWith('4')) {
      return 'visa';
    }
    // Mastercard
    else if (cardNumber.startsWith(RegExp(r'^5[1-5]')) || 
             cardNumber.startsWith(RegExp(r'^2[2-7]'))) {
      return 'mastercard';
    }
    // American Express
    else if (cardNumber.startsWith(RegExp(r'^3[47]'))) {
      return 'amex';
    }
    // Discover
    else if (cardNumber.startsWith('6011') || 
             cardNumber.startsWith(RegExp(r'^65'))) {
      return 'discover';
    }
    
    return null;
  }

  void _formatCardNumber(String value) {
    String formatted = value.replaceAll(' ', '');
    String newValue = '';
    
    for (int i = 0; i < formatted.length; i++) {
      if (i % 4 == 0 && i != 0) {
        newValue += ' ';
      }
      newValue += formatted[i];
    }
    
    _cardNumberController.value = TextEditingValue(
      text: newValue,
      selection: TextSelection.collapsed(offset: newValue.length),
    );
    
    // Detect card type
    setState(() {
      _cardType = _detectCardType(formatted);
    });
  }

  void _formatExpiry(String value) {
    String formatted = value.replaceAll('/', '');
    String newValue = '';
    
    for (int i = 0; i < formatted.length && i < 4; i++) {
      if (i == 2) {
        newValue += '/';
      }
      newValue += formatted[i];
    }
    
    _expiryController.value = TextEditingValue(
      text: newValue,
      selection: TextSelection.collapsed(offset: newValue.length),
    );
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      PaymentMethod paymentMethod;
      
      if (_selectedPaymentType == 'card') {
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        final lastFourDigits = cardNumber.length >= 4 
            ? cardNumber.substring(cardNumber.length - 4)
            : cardNumber;
        
        final expiryParts = _expiryController.text.split('/');
        
        paymentMethod = PaymentMethod(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'card',
          title: _titleController.text.trim(),
          cardNumber: lastFourDigits,
          expiryMonth: expiryParts.isNotEmpty ? expiryParts[0] : null,
          expiryYear: expiryParts.length > 1 ? expiryParts[1] : null,
          cardHolderName: _cardHolderController.text.trim(),
          cardType: _cardType,
          isDefault: _isDefault,
        );
      } else {
        paymentMethod = PaymentMethod(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: _selectedPaymentType,
          title: _titleController.text.trim(),
          isDefault: _isDefault,
        );
      }

      final success = await authService.addPaymentMethod(paymentMethod);
      
      if (success && mounted) {
        Navigator.pop(context, paymentMethod);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add payment method'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePaymentMethod,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : const Color(0xFFB6FF5B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Type Selection
              const Text(
                'Payment Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._paymentTypes.map((type) => _buildPaymentTypeCard(type)),
              
              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Payment Method Title *',
                  hintText: 'e.g., My Visa Card, Personal PayPal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFB6FF5B), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              if (_selectedPaymentType == 'card') ...[
                const SizedBox(height: 24),
                
                // Card Details Section
                const Text(
                  'Card Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Card Number
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
                  ],
                  decoration: InputDecoration(
                    labelText: 'Card Number *',
                    hintText: '1234 5678 9012 3456',
                    suffixIcon: _cardType != null
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/images/card_$_cardType.png',
                              width: 32,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.credit_card,
                                color: Colors.grey[400],
                              ),
                            ),
                          )
                        : Icon(Icons.credit_card, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFB6FF5B), width: 2),
                    ),
                  ),
                  onChanged: _formatCardNumber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    final cardNumber = value.replaceAll(' ', '');
                    if (cardNumber.length < 13 || cardNumber.length > 19) {
                      return 'Please enter a valid card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expiry and CVV Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Expiry *',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFB6FF5B), width: 2),
                          ),
                        ),
                        onChanged: _formatExpiry,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiry date';
                          }
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Please enter valid expiry (MM/YY)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          labelText: 'CVV *',
                          hintText: '123',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFB6FF5B), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter CVV';
                          }
                          if (value.length < 3 || value.length > 4) {
                            return 'Please enter valid CVV';
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
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Cardholder Name *',
                    hintText: 'Enter name on card',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFB6FF5B), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter cardholder name';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 24),

              // Default Payment Method Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFB6FF5B),
                    checkColor: Colors.black,
                  ),
                  const Expanded(
                    child: Text(
                      'Set as default payment method',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB6FF5B),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Save Payment Method',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              // Security Note
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your payment information is encrypted and secure. We never store your full card details.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeCard(Map<String, String> type) {
    final isSelected = _selectedPaymentType == type['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = type['id']!;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB6FF5B).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFB6FF5B) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: type['id']!,
              groupValue: _selectedPaymentType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentType = value;
                  });
                }
              },
              activeColor: const Color(0xFFB6FF5B),
            ),
            Icon(
              _getPaymentIcon(type['icon']!),
              color: Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              type['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String iconName) {
    switch (iconName) {
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'android':
        return Icons.android;
      default:
        return Icons.payment;
    }
  }
}
