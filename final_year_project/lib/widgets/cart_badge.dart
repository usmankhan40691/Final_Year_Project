import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class CartBadge extends StatelessWidget {
  final Widget child;
  final Color badgeColor;
  final Color textColor;
  final double? fontSize;
  final EdgeInsets? padding;

  const CartBadge({
    super.key,
    required this.child,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, _) {
        final itemCount = cartService.itemCount;
        
        return Stack(
          children: [
            child,
            if (itemCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: padding ?? const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    itemCount > 99 ? '99+' : '$itemCount',
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize ?? 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CartAppBarBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const CartAppBarBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, _) {
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: CartBadge(
              badgeColor: const Color(0xFFB6FF5B),
              textColor: Colors.black,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CartFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CartFloatingActionButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, _) {
        if (cartService.itemCount == 0) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: const Color(0xFFB6FF5B),
          foregroundColor: Colors.black,
          child: CartBadge(
            badgeColor: Colors.red,
            textColor: Colors.white,
            fontSize: 8,
            padding: const EdgeInsets.all(1),
            child: const Icon(
              Icons.shopping_cart,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}