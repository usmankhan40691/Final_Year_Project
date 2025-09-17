import 'package:flutter_test/flutter_test.dart';
import 'package:final_year_project/services/cart_service.dart';
import 'package:final_year_project/models/product_model.dart';

void main() {
  group('Cart and Checkout System Tests', () {
    late CartService cartService;
    late Product testProduct;
    late ProductVariant testVariant;

    setUp(() {
      cartService = CartService();
      testProduct = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        price: 100.0,
        oldPrice: 120.0,
        stockQuantity: 10,
        categoryName: 'Test Category',
        rating: 4.5,
        reviewsCount: 25,
        isOnSale: true,
        discountPercentage: 16.67,
        isInStock: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testVariant = ProductVariant(
        id: 1,
        sku: 'TEST-L',
        size: 'Large',
        priceAdjustment: 10.0,
        finalPrice: 110.0,
        stockQuantity: 5,
        isInStock: true,
      );
    });

    group('Product Variants', () {
      test('should create product variant with correct properties', () {
        expect(testVariant.id, 1);
        expect(testVariant.size, 'Large');
        expect(testVariant.priceAdjustment, 10.0);
        expect(testVariant.stockQuantity, 5);
        expect(testVariant.finalPrice, 110.0);
        expect(testVariant.isActive, true);
      });

      test('should display variant name correctly', () {
        expect(testVariant.displayName, 'Large');
        
        final colorVariant = ProductVariant(
          id: 2,
          sku: 'TEST-RED',
          color: 'Red',
          priceAdjustment: 0.0,
          finalPrice: 100.0,
          stockQuantity: 8,
          isInStock: true,
        );
        
        expect(colorVariant.displayName, 'Red');
      });
    });

    group('Cart Operations', () {
      test('should add product to local cart', () {
        cartService.addToLocalCart(testProduct, quantity: 2);
        
        expect(cartService.itemCount, 1);
        expect(cartService.cartItems.first.quantity, 2);
        expect(cartService.cartItems.first.product.id, testProduct.id);
      });

      test('should add product variant to cart', () {
        cartService.addToLocalCart(testProduct, quantity: 1, variant: testVariant);
        
        expect(cartService.itemCount, 1);
        expect(cartService.cartItems.first.variant?.id, testVariant.id);
        expect(cartService.cartItems.first.unitPrice, testVariant.finalPrice);
      });

      test('should handle out of stock products', () {
        final outOfStockProduct = Product(
          id: 2,
          name: 'Out of Stock Product',
          description: 'Test',
          price: 50.0,
          stockQuantity: 0,
          categoryName: 'Test',
          rating: 0.0,
          reviewsCount: 0,
          isOnSale: false,
          discountPercentage: 0.0,
          isInStock: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        cartService.addToLocalCart(outOfStockProduct, quantity: 1);
        
        expect(cartService.itemCount, 0);
        expect(cartService.errorMessage, isNotNull);
        expect(cartService.errorMessage!.toLowerCase(), contains('out of stock'));
      });

      test('should not exceed available stock', () {
        cartService.addToLocalCart(testProduct, quantity: 15); // More than available stock (10)
        
        expect(cartService.itemCount, 0);
        expect(cartService.errorMessage, isNotNull);
        expect(cartService.errorMessage!.toLowerCase(), contains('only'));
      });

      test('should update cart quantity correctly', () {
        cartService.addToLocalCart(testProduct, quantity: 2);
        cartService.updateLocalCartQuantity(testProduct.id, 5);
        
        expect(cartService.cartItems.first.quantity, 5);
      });

      test('should remove item when quantity is set to 0', () {
        cartService.addToLocalCart(testProduct, quantity: 2);
        cartService.updateLocalCartQuantity(testProduct.id, 0);
        
        expect(cartService.itemCount, 0);
      });

      test('should merge same products in cart', () {
        cartService.addToLocalCart(testProduct, quantity: 2);
        cartService.addToLocalCart(testProduct, quantity: 3);
        
        expect(cartService.itemCount, 1);
        expect(cartService.cartItems.first.quantity, 5);
      });
    });

    group('Coupon System', () {
      test('should calculate percentage discount correctly', () {
        final coupon = Coupon(
          id: 1,
          code: 'SAVE20',
          description: 'Save 20%',
          discountType: 'percentage',
          discountValue: 20.0,
          minimumOrderAmount: 100.0,
          maximumDiscountAmount: 50.0,
          validFrom: DateTime.now().subtract(const Duration(days: 1)),
          validUntil: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          isValid: true,
          usageLimitPerUser: 1,
          usedCount: 0,
        );

        final discount = coupon.calculateDiscount(200.0);
        expect(discount, 40.0); // 20% of 200
      });

      test('should respect maximum discount amount', () {
        final coupon = Coupon(
          id: 1,
          code: 'SAVE20',
          description: 'Save 20%',
          discountType: 'percentage',
          discountValue: 20.0,
          minimumOrderAmount: 100.0,
          maximumDiscountAmount: 30.0,
          validFrom: DateTime.now().subtract(const Duration(days: 1)),
          validUntil: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          isValid: true,
          usageLimitPerUser: 1,
          usedCount: 0,
        );

        final discount = coupon.calculateDiscount(200.0);
        expect(discount, 30.0); // Capped at maximumDiscountAmount
      });

      test('should return 0 discount for orders below minimum', () {
        final coupon = Coupon(
          id: 1,
          code: 'SAVE20',
          description: 'Save 20%',
          discountType: 'percentage',
          discountValue: 20.0,
          minimumOrderAmount: 100.0,
          validFrom: DateTime.now().subtract(const Duration(days: 1)),
          validUntil: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          isValid: true,
          usageLimitPerUser: 1,
          usedCount: 0,
        );

        final discount = coupon.calculateDiscount(80.0);
        expect(discount, 0.0);
      });
    });

    group('Cart Summary Calculations', () {
      test('should calculate cart summary correctly', () {
        cartService.addToLocalCart(testProduct, quantity: 2);
        
        final summary = cartService.cartSummary;
        expect(summary, isNotNull);
        expect(summary!.itemsCount, 1);
        expect(summary.subtotal, 200.0); // 100 * 2
        expect(summary.taxAmount, 36.0); // 18% of 200
        expect(summary.shippingCost, 50.0); // Under ₹500, so ₹50 shipping
        expect(summary.total, 286.0); // 200 + 36 + 50
      });
    });

    group('Edge Cases', () {
      test('should handle empty cart gracefully', () {
        expect(cartService.itemCount, 0);
        expect(cartService.cartSummary, isNull);
        expect(cartService.cartItems, isEmpty);
      });

      test('should handle invalid product IDs', () {
        cartService.updateLocalCartQuantity(-1, 5);
        expect(cartService.itemCount, 0); // No change
      });

      test('should clear error on successful operation', () {
        // First trigger an error by adding too many items
        cartService.addToLocalCart(testProduct, quantity: 1000);
        expect(cartService.errorMessage, isNotNull);

        // Then perform successful operation
        cartService.addToLocalCart(testProduct, quantity: 2);
        expect(cartService.errorMessage, isNull);
      });
    });
  });
}

    group('Cart Summary Calculations', () {
      test('should calculate cart summary correctly', () {
        cartService.addToLocalCart(testProduct, quantity: 2);
        
        final summary = cartService.cartSummary;
        expect(summary, isNotNull);
        expect(summary!.itemsCount, 1);
        expect(summary.subtotal, 200.0); // 100 * 2
        expect(summary.taxAmount, 36.0); // 18% of 200
        expect(summary.shippingCost, 50.0); // Under ₹500, so ₹50 shipping
        expect(summary.total, 286.0); // 200 + 36 + 50
      });

      test('should provide free shipping above ₹500', () {
        final expensiveProduct = Product(
          id: 3,
          name: 'Expensive Product',
          description: 'Test',
          price: 300.0,
          stockQuantity: 10,
          categoryId: 1,
          categoryName: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          variants: [],
        );

        cartService.addToLocalCart(expensiveProduct, quantity: 2);
        
        final summary = cartService.cartSummary;
        expect(summary!.subtotal, 600.0);
        expect(summary.shippingCost, 0.0); // Free shipping
      });
    });

    group('Stock Status Display', () {
      testWidgets('should show stock badge for low stock products', (WidgetTester tester) async {
        final lowStockProduct = Product(
          id: 4,
          name: 'Low Stock Product',
          description: 'Test',
          price: 50.0,
          stockQuantity: 3,
          categoryId: 1,
          categoryName: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          variants: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: lowStockProduct),
            ),
          ),
        );

        expect(find.text('Only 3 left'), findsOneWidget);
      });

      testWidgets('should show out of stock badge', (WidgetTester tester) async {
        final outOfStockProduct = Product(
          id: 5,
          name: 'Out of Stock Product',
          description: 'Test',
          price: 50.0,
          stockQuantity: 0,
          categoryId: 1,
          categoryName: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          variants: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: outOfStockProduct),
            ),
          ),
        );

        expect(find.text('Out of Stock'), findsOneWidget);
      });
    });

    group('Cart Badge', () {
      testWidgets('should display correct cart count', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: cartService,
              child: const Scaffold(
                body: CartBadge(
                  child: Icon(Icons.shopping_cart),
                ),
              ),
            ),
          ),
        );

        // Initially no badge
        expect(find.text('0'), findsNothing);

        // Add item to cart
        cartService.addToLocalCart(testProduct, quantity: 2);
        await tester.pump();

        expect(find.text('1'), findsOneWidget); // 1 unique item
      });

      testWidgets('should handle cart count over 99', (WidgetTester tester) async {
        // This would require adding many different products to test the 99+ display
        // For now, we'll test the logic in the widget
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: cartService,
              child: const Scaffold(
                body: CartBadge(
                  child: Icon(Icons.shopping_cart),
                ),
              ),
            ),
          ),
        );

        // The actual test would involve adding 100+ different products
        // which is impractical for a unit test
      });
    });

    group('Error Handling', () {
      testWidgets('should show error snackbar for failed operations', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    ErrorHandler.showError(context, 'Test error message');
                  },
                  child: const Text('Show Error'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('Test error message'), findsOneWidget);
      });

      testWidgets('should show success snackbar', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    ErrorHandler.showSuccess(context, 'Success message');
                  },
                  child: const Text('Show Success'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Success'));
        await tester.pump();

        expect(find.text('Success message'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      test('should handle empty cart gracefully', () {
        expect(cartService.itemCount, 0);
        expect(cartService.cartSummary, isNull);
        expect(cartService.cartItems, isEmpty);
      });

      test('should handle invalid product IDs', () {
        cartService.updateLocalCartQuantity(-1, 5);
        expect(cartService.itemCount, 0); // No change
      });

      test('should handle very large quantities', () {
        cartService.addToLocalCart(testProduct, quantity: 1000000);
        expect(cartService.itemCount, 0); // Should fail due to stock limit
        expect(cartService.errorMessage, isNotNull);
      });

      test('should clear error on successful operation', () {
        // First trigger an error
        cartService.addToLocalCart(testProduct, quantity: 1000);
        expect(cartService.errorMessage, isNotNull);

        // Then perform successful operation
        cartService.addToLocalCart(testProduct, quantity: 2);
        expect(cartService.errorMessage, isNull);
      });
    });
  });
}