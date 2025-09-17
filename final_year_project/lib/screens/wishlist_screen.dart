import 'package:flutter/material.dart';
import '../main.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  final List<LocalProduct> favoriteItems;
  final Function(LocalProduct) onToggleFavorite;
  final Function(LocalProduct) onAddToCart;

  const WishlistScreen({
    super.key,
    required this.favoriteItems,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Favorites',
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
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding products to your wishlist',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${favoriteItems.length} items',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double width = constraints.maxWidth;
                        int crossAxisCount = 2;
                        double aspectRatio = 0.75;
                        double horizontalPadding = 16;
                        double spacing = 12;
                        
                        // TV Screens (4K and beyond)
                        if (width >= 2560) {
                          crossAxisCount = 10;
                          aspectRatio = 0.85;
                          horizontalPadding = 40;
                          spacing = 20;
                        }
                        // Large Desktop/TV (1920px+)
                        else if (width >= 1920) {
                          crossAxisCount = 8;
                          aspectRatio = 0.8;
                          horizontalPadding = 32;
                          spacing = 16;
                        }
                        // Desktop (1440px+)
                        else if (width >= 1440) {
                          crossAxisCount = 6;
                          aspectRatio = 0.8;
                          horizontalPadding = 24;
                          spacing = 14;
                        }
                        // Small Desktop/Large Laptop (1200px+)
                        else if (width >= 1200) {
                          crossAxisCount = 5;
                          aspectRatio = 0.75;
                          horizontalPadding = 20;
                          spacing = 12;
                        }
                        // Laptop (1024px+)
                        else if (width >= 1024) {
                          crossAxisCount = 4;
                          aspectRatio = 0.75;
                          horizontalPadding = 20;
                          spacing = 12;
                        }
                        // Large Tablet (768px+)
                        else if (width >= 768) {
                          crossAxisCount = 3;
                          aspectRatio = 0.7;
                          horizontalPadding = 16;
                          spacing = 12;
                        }
                        // Small Tablet (600px+)
                        else if (width >= 600) {
                          crossAxisCount = 3;
                          aspectRatio = 0.68;
                          horizontalPadding = 16;
                          spacing = 10;
                        }
                        // Large Phone (480px+)
                        else if (width >= 480) {
                          crossAxisCount = 2;
                          aspectRatio = 0.75;
                          horizontalPadding = 16;
                          spacing = 12;
                        }
                        // Small Phone
                        else {
                          crossAxisCount = 2;
                          aspectRatio = 0.7;
                          horizontalPadding = 12;
                          spacing = 8;
                        }
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: aspectRatio,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                            ),
                            itemCount: favoriteItems.length,
                            itemBuilder: (context, index) {
                              final product = favoriteItems[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        product: product,
                                        onToggleFavorite: onToggleFavorite,
                                        onAddToCart: onAddToCart,
                                        isFavorite: true,
                                      ),
                                    ),
                                  );
                                },
                                child: _FavoriteProductCard(
                                  product: product,
                                  onToggleFavorite: () => onToggleFavorite(product),
                                  onAddToCart: () => onAddToCart(product),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _FavoriteProductCard extends StatelessWidget {
  final LocalProduct product;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const _FavoriteProductCard({
    required this.product,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  bool get isTopItem {
    // Mark first 3 items as top items - extract numeric part if possible
    final numericId = int.tryParse(product.id);
    if (numericId != null) {
      return numericId < 3;
    }
    // For string IDs, use hashCode for consistency
    return product.id.hashCode % 10 < 3;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with favorite button and top item badge
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: const EdgeInsets.all(10), // slightly reduced margin
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF5F5F5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 36,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Top item badge
                if (isTopItem)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Top item',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favorite icon (always filled since it's in favorites)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      onToggleFavorite();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.heart_broken, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('${product.title} removed from favorites'),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 7,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 90, // force content to fit in grid cell
                  ),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Product name
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 9,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '/5',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        // Price section
                        Row(
                          children: [
                            Text(
                              product.price,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.oldPrice,
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[400],
                                fontSize: 7,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Add to cart button
                        SizedBox(
                          width: double.infinity,
                          height: 20,
                          child: ElevatedButton(
                            onPressed: () {
                              onAddToCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 13),
                                      const SizedBox(width: 8),
                                      Text('${product.title} added to cart'),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Add to cart',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
