import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../models/user_model.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddPaymentMethodSheet(context);
            },
          ),
        ],
      ),
      body: Consumer2<AuthService, PaymentService>(
        builder: (context, authService, paymentService, child) {
          if (!authService.isAuthenticated) {
            return _buildNotAuthenticatedState();
          }

          final paymentMethods = authService.currentUser!.paymentMethods;

          if (paymentMethods.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: paymentMethods.length,
            itemBuilder: (context, index) {
              final paymentMethod = paymentMethods[index];
              return _PaymentMethodCard(
                paymentMethod: paymentMethod,
                onEdit: () => _showEditPaymentMethodSheet(context, paymentMethod),
                onDelete: () => _showDeleteDialog(context, paymentMethod, authService),
                onSetDefault: () => _setDefaultPaymentMethod(context, paymentMethod, authService),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddPaymentMethodSheet(context);
        },
        backgroundColor: const Color(0xFFB6FF5B),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_card_outlined),
        label: const Text('Add Card'),
      ),
    );
  }

  Widget _buildNotAuthenticatedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Sign In Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please sign in to manage your payment methods',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Methods',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first payment method to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _showAddPaymentMethodSheet(context);
              },
              icon: const Icon(Icons.add_card_outlined),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6FF5B),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddPaymentMethodBottomSheet(),
    );
  }

  void _showEditPaymentMethodSheet(BuildContext context, PaymentMethod paymentMethod) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddPaymentMethodBottomSheet(paymentMethod: paymentMethod),
    );
  }

  void _showDeleteDialog(BuildContext context, PaymentMethod paymentMethod, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete "${paymentMethod.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement delete payment method logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment method deleted successfully')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _setDefaultPaymentMethod(BuildContext context, PaymentMethod paymentMethod, AuthService authService) async {
    // TODO: Implement set default payment method logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Set "${paymentMethod.title}" as default payment method')),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _PaymentMethodCard({
    required this.paymentMethod,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: paymentMethod.isDefault ? const Color(0xFFB6FF5B) : Colors.grey[200]!,
          width: paymentMethod.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCardIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentMethod.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        paymentMethod.displayInfo,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (paymentMethod.isDefault) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB6FF5B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                      case 'default':
                        onSetDefault();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!paymentMethod.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (paymentMethod.type == 'card' && paymentMethod.expiryMonth != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Expires ${paymentMethod.expiryMonth}/${paymentMethod.expiryYear}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (paymentMethod.cardHolderName != null)
                    Text(
                      paymentMethod.cardHolderName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardIcon() {
    IconData iconData;
    Color iconColor;

    switch (paymentMethod.type) {
      case 'card':
        switch (paymentMethod.cardType?.toLowerCase()) {
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
      case 'apple_pay':
        iconData = Icons.phone_iphone;
        iconColor = Colors.black;
        break;
      case 'google_pay':
        iconData = Icons.android;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.payment;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
}

class _AddPaymentMethodBottomSheet extends StatefulWidget {
  final PaymentMethod? paymentMethod;

  const _AddPaymentMethodBottomSheet({this.paymentMethod});

  @override
  State<_AddPaymentMethodBottomSheet> createState() => _AddPaymentMethodBottomSheetState();
}

class _AddPaymentMethodBottomSheetState extends State<_AddPaymentMethodBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  bool _isDefault = false;
  String _selectedType = 'card';

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final paymentMethod = widget.paymentMethod!;
    _titleController.text = paymentMethod.title;
    _selectedType = paymentMethod.type;
    _cardNumberController.text = paymentMethod.cardNumber ?? '';
    if (paymentMethod.expiryMonth != null && paymentMethod.expiryYear != null) {
      _expiryController.text = '${paymentMethod.expiryMonth}/${paymentMethod.expiryYear}';
    }
    _cardHolderController.text = paymentMethod.cardHolderName ?? '';
    _isDefault = paymentMethod.isDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.paymentMethod == null ? 'Add Payment Method' : 'Edit Payment Method',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Form
          Expanded(
            child: SingleChildScrollView(
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        _TypeChip(
                          label: 'Credit/Debit Card',
                          value: 'card',
                          isSelected: _selectedType == 'card',
                          onSelected: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                        _TypeChip(
                          label: 'PayPal',
                          value: 'paypal',
                          isSelected: _selectedType == 'paypal',
                          onSelected: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                        _TypeChip(
                          label: 'Apple Pay',
                          value: 'apple_pay',
                          isSelected: _selectedType == 'apple_pay',
                          onSelected: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                        _TypeChip(
                          label: 'Google Pay',
                          value: 'google_pay',
                          isSelected: _selectedType == 'google_pay',
                          onSelected: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method Name',
                        hintText: 'My Visa Card, PayPal, etc.',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a payment method name';
                        }
                        return null;
                      },
                    ),
                    
                    if (_selectedType == 'card') ...[
                      const SizedBox(height: 16),
                      
                      // Card Number
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
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
                              decoration: const InputDecoration(
                                labelText: 'MM/YY',
                                hintText: '12/25',
                                border: OutlineInputBorder(),
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
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
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
                      
                      // Card Holder Name
                      TextFormField(
                        controller: _cardHolderController,
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          hintText: 'John Doe',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter cardholder name';
                          }
                          return null;
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Default Payment Method Switch
                    Row(
                      children: [
                        Switch(
                          value: _isDefault,
                          onChanged: (value) {
                            setState(() {
                              _isDefault = value;
                            });
                          },
                          activeColor: const Color(0xFFB6FF5B),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Set as default payment method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                        onPressed: _savePaymentMethod,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB6FF5B),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.paymentMethod == null ? 'Add Payment Method' : 'Update Payment Method',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  void _savePaymentMethod() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save payment method logic with Stripe
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.paymentMethod == null 
                ? 'Payment method added successfully' 
                : 'Payment method updated successfully'
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelected(value);
        }
      },
      selectedColor: const Color(0xFFB6FF5B),
      checkmarkColor: Colors.black,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
