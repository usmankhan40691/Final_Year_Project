import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import '../main.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;
  final Function(LocalProduct) onToggleFavorite;
  final Function(LocalProduct) onAddToCart;
  final bool Function(LocalProduct) isFavorite;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.isFavorite,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late List<LocalProduct> products;

  @override
  void initState() {
    super.initState();
    products = getProducts(widget.category);
  }

  List<LocalProduct> getProducts(String category) {
    final Map<String, List<String>> categoryImages = {
      'Phones': List.generate(12, (i) => 'assets/images/phone${i + 1}.jpg'),
      'Consoles': List.generate(8, (i) => 'assets/images/console${i + 1}.jpg'),
      'Laptops': List.generate(11, (i) => 'assets/images/laptop${i + 1}.jpg'),
      'Cameras': List.generate(10, (i) => 'assets/images/camera${i + 1}.jpg'),
      'Accessories': List.generate(12, (i) => 'assets/images/accessories${i + 1}.jpg'),
    };

    final images = categoryImages[category] ?? [];
    return List.generate(
      images.length,
      (i) => LocalProduct(
        id: '${category}_$i',
        category: category,
        title: category == 'Phones'
            ? 'iPhone ${i + 11} Pro'
            : category == 'Consoles'
                ? 'Nintendo Switch${i > 3 ? ' Lite' : ''}'
                : category == 'Laptops'
                    ? 'MacBook ${i % 2 == 0 ? 'Pro' : 'Air'} ${i + 13}"'
                    : category == 'Cameras'
                        ? 'Canon EOS ${i + 70}D'
                        : 'AirPods ${i % 2 == 0 ? 'Pro' : 'Max'}',
        price: category == 'Phones'
            ? '£${699 + i * 10}.00'
            : category == 'Consoles'
                ? '£${169 + i * 30}.00'
                : category == 'Laptops'
                    ? '£${999 + i * 50}.00'
                    : category == 'Cameras'
                        ? '£${499 + i * 25}.00'
                        : '£${109 + i * 10}.00',
        oldPrice: category == 'Phones'
            ? '£${749 + i * 10}.00'
            : category == 'Consoles'
                ? '£${219 + i * 30}.00'
                : category == 'Laptops'
                    ? '£${1099 + i * 50}.00'
                    : category == 'Cameras'
                        ? '£${549 + i * 25}.00'
                        : '£${139 + i * 10}.00',
        description: _getProductDescription(category, i),
        image: images[i],
        rating: 4.8 - (i * 0.1),
        reviews: 117 + i * 5,
      ),
    );
  }

  String _getProductDescription(String category, int index) {
    switch (category) {
      case 'Phones':
        return 'The iPhone ${index + 11} Pro features a stunning Super Retina XDR display, A15 Bionic chip, and Pro camera system.';
      case 'Consoles':
        return 'Nintendo Switch gaming console is a compact device that can be taken everywhere. This portable super device is also equipped with 2 gamepads.';
      case 'Laptops':
        return 'MacBook ${index % 2 == 0 ? 'Pro' : 'Air'} with Apple M2 chip delivers incredible performance and battery life.';
      case 'Cameras':
        return 'Canon EOS ${index + 70}D DSLR camera with advanced autofocus and high-resolution imaging capabilities.';
      case 'Accessories':
        return 'Premium wireless headphones with active noise cancellation and superior sound quality.';
      default:
        return 'High-quality product with excellent features and performance.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
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
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products found.'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${products.length} products found',
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
                        double aspectRatio = 0.8; // Better mobile aspect ratio
                        double horizontalPadding = 8;
                        double spacing = 8;
                        
                        // Responsive breakpoints - Mobile first approach
                        if (width >= 1920) {
                          crossAxisCount = 6;
                          aspectRatio = 0.75;
                          horizontalPadding = 24;
                          spacing = 16;
                        } else if (width >= 1440) {
                          crossAxisCount = 5;
                          aspectRatio = 0.75;
                          horizontalPadding = 20;
                          spacing = 14;
                        } else if (width >= 1200) {
                          crossAxisCount = 4;
                          aspectRatio = 0.75;
                          horizontalPadding = 16;
                          spacing = 12;
                        } else if (width >= 1024) {
                          crossAxisCount = 4;
                          aspectRatio = 0.8;
                          horizontalPadding = 16;
                          spacing = 12;
                        } else if (width >= 768) {
                          crossAxisCount = 3;
                          aspectRatio = 0.8;
                          horizontalPadding = 12;
                          spacing = 10;
                        } else if (width >= 600) {
                          crossAxisCount = 2;
                          aspectRatio = 0.75;
                          horizontalPadding = 12;
                          spacing = 8;
                        } else {
                          // Mobile devices - Conservative settings
                          crossAxisCount = 2;
                          aspectRatio = 0.7; // Taller cards for mobile
                          horizontalPadding = 8;
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
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        product: product,
                                        onToggleFavorite: widget.onToggleFavorite,
                                        onAddToCart: widget.onAddToCart,
                                        isFavorite: widget.isFavorite(product),
                                      ),
                                    ),
                                  );
                                },
                                child: _ProductCard(
                                  product: product,
                                  isFavorite: widget.isFavorite(product),
                                  onToggleFavorite: () => widget.onToggleFavorite(product),
                                  onAddToCart: () => widget.onAddToCart(product),
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

class _ProductCard extends StatefulWidget {
  final LocalProduct product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(_ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  bool get isTopItem {
    // Mark first 3 items as top items
    return int.tryParse(widget.product.id.split('_').last) != null && 
           int.parse(widget.product.id.split('_').last) < 3;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with favorite button and top item badge
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF5F5F5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.product.image,
                      fit: BoxFit.cover, // Changed to cover for full width
                      width: double.infinity,
                      height: double.infinity,
                      cacheWidth: 300, // Add cache optimization
                      cacheHeight: 300,
                      errorBuilder: (context, error, stackTrace) {
                        print('Image loading error for ${widget.product.image}: $error');
                        return Container(
                          color: const Color(0xFFF5F5F5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Top item badge
                if (isTopItem)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Top item',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Favorite icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      widget.onToggleFavorite();
                      final message = _isFavorite ? 'Added to favorites' : 'Removed from favorites';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8), // Increased padding for larger icon
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey[600],
                        size: 22, // Increased icon size
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8), // Reduced padding for mobile
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12, // Reduced for mobile
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Rating
                  SizedBox(
                    height: 14,
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '/5',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Price section
                  SizedBox(
                    height: 16,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.product.price,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.product.oldPrice,
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 30, // Reduced height for mobile
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onAddToCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${widget.product.title} added to cart')),
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
                      ),
                      child: const Text(
                        'Add to cart',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
