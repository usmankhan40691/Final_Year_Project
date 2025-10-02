import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'product_detail_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final Function(LocalProduct) onToggleFavorite;
  final Function(LocalProduct) onAddToCart;
  final bool Function(LocalProduct) isFavorite;

  const HomeScreen({
    super.key,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.isFavorite,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    'Phones',
    'Consoles',
    'Laptops',
    'Cameras',
    'Accessories',
  ];

  final Map<String, IconData> categoryIcons = {
    'Phones': Icons.phone_android,
    'Consoles': Icons.videogame_asset,
    'Laptops': Icons.laptop_mac,
    'Cameras': Icons.camera_alt,
    'Accessories': Icons.headphones,
  };

  String selectedCategory = 'Phones';

  // Map category to image asset list
  final Map<String, List<String>> categoryImages = {
    'Phones': [
      'assets/images/phone1.jpg',
      'assets/images/phone2.jpg',
      'assets/images/phone3.jpg',
      'assets/images/phone4.jpg',
      'assets/images/phone5.jpg',
      'assets/images/phone6.jpg',
      'assets/images/phone7.jpg',
      'assets/images/phone8.jpg',
      'assets/images/phone9.jpg',
      'assets/images/phone10.jpg',
      'assets/images/phone11.jpg',
      'assets/images/phone12.jpg',
    ],
    'Consoles': [
      'assets/images/console1.jpg',
      'assets/images/console2.jpg',
      'assets/images/console3.jpg',
      'assets/images/console4.jpg',
      'assets/images/console5.jpg',
      'assets/images/console6.jpg',
      'assets/images/console7.jpg',
      'assets/images/console8.jpg',
    ],
    'Laptops': [
      'assets/images/laptop1.jpg',
      'assets/images/laptop2.jpg',
      'assets/images/laptop3.jpg',
      'assets/images/laptop4.jpg',
      'assets/images/laptop5.jpg',
      'assets/images/laptop6.jpg',
      'assets/images/laptop7.jpg',
      'assets/images/laptop8.jpg',
      'assets/images/laptop9.jpg',
      'assets/images/laptop10.jpg',
      'assets/images/laptop11.jpg',
    ],
    'Cameras': [
      'assets/images/camera1.jpg',
      'assets/images/camera2.jpg',
      'assets/images/camera3.jpg',
      'assets/images/camera4.jpg',
      'assets/images/camera5.jpg',
      'assets/images/camera6.jpg',
      'assets/images/camera7.jpg',
      'assets/images/camera8.jpg',
      'assets/images/camera9.jpg',
      'assets/images/camera10.jpg',
    ],
    'Accessories': [
      'assets/images/accessories1.jpg',
      'assets/images/accessories2.jpg',
      'assets/images/accessories3.jpg',
      'assets/images/accessories4.jpg',
      'assets/images/accessories5.jpg',
      'assets/images/accessories6.jpg',
      'assets/images/accessories7.jpg',
      'assets/images/accessories8.jpg',
      'assets/images/accessories9.jpg',
      'assets/images/accessories10.jpg',
      'assets/images/accessories11.jpg',
      'assets/images/accessories12.jpg',
    ],
  };

  List<LocalProduct> get products {
    final cat = selectedCategory;
    final images = categoryImages[cat] ?? [];
    return List.generate(
      images.length,
      (i) => LocalProduct(
        id: '${cat}_$i',
        category: cat,
        title: cat == 'Phones'
            ? 'iPhone ${i + 4}'
            : cat == 'Consoles'
                ? 'Nintendo Switch${i > 3 ? ' Lite' : ''}'
                : cat == 'Laptops'
                    ? 'MacBook ${i % 2 == 0 ? 'Pro' : 'Air'} ${i + 1}"'
                    : cat == 'Cameras'
                        ? 'Canon EOS ${i + 7}D'
                        : 'AirPods ${i % 2 == 0 ? 'Pro' : 'Max'}',
        price: cat == 'Phones'
            ? '£${699 + i * 10}.00'
            : cat == 'Consoles'
                ? '£${169 + i * 30}.00'
                : cat == 'Laptops'
                    ? '£${999 + i * 50}.00'
                    : cat == 'Cameras'
                        ? '£${499 + i * 25}.00'
                        : '£${109 + i * 10}.00',
        oldPrice: cat == 'Phones'
            ? '£${749 + i * 10}.00'
            : cat == 'Consoles'
                ? '£${219 + i * 30}.00'
                : cat == 'Laptops'
                    ? '£${1099 + i * 50}.00'
                    : cat == 'Cameras'
                        ? '£${549 + i * 25}.00'
                        : '£${139 + i * 10}.00',
        description: _getProductDescription(cat, i),
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
    final filteredProducts = products;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFB6FF5B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Swift Cart',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location + Profile
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Hafeez Center, Lahore',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search the entire shop',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Delivery Banner
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F5E8), Color(0xFFB6FF5B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Delivery is 50% cheaper',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Color(0xFFB6FF5B), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Categories
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  double categoryHeight = 70;
                  double itemWidth = 60;
                  double spacing = 12;
                  
                  // Responsive category sizing with overflow protection
                  if (width >= 1440) {
                    categoryHeight = 90;
                    itemWidth = 80;
                    spacing = 20;
                  } else if (width >= 1024) {
                    categoryHeight = 85;
                    itemWidth = 75;
                    spacing = 18;
                  } else if (width >= 768) {
                    categoryHeight = 80;
                    itemWidth = 70;
                    spacing = 16;
                  } else if (width >= 480) {
                    categoryHeight = 75;
                    itemWidth = 65;
                    spacing = 14;
                  } else if (width >= 380) {
                    categoryHeight = 70;
                    itemWidth = 60;
                    spacing = 12;
                  } else {
                    // Very small screens
                    categoryHeight = 65;
                    itemWidth = 55;
                    spacing = 10;
                  }
                  
                  return SizedBox(
                    height: categoryHeight,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isActive = cat == selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = cat;
                            });
                          },
                          child: _CategoryIcon(
                            label: cat,
                            icon: categoryIcons[cat]!,
                            active: isActive,
                            size: itemWidth,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Flash Sale Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Flash Sale',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '02:59:23',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Responsive product grid with aggressive overflow protection
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  int crossAxisCount = 2;
                  double aspectRatio = 0.85; // Better aspect ratio
                  double horizontalPadding = 2;
                  double spacing = 8; // Better spacing
                  
                  // Ultra-conservative responsive breakpoints - mobile-first
                  if (width >= 1920) {
                    crossAxisCount = 6;
                    aspectRatio = 0.85;
                    horizontalPadding = 16;
                    spacing = 12;
                  } else if (width >= 1440) {
                    crossAxisCount = 5;
                    aspectRatio = 0.85;
                    horizontalPadding = 12;
                    spacing = 10;
                  } else if (width >= 1200) {
                    crossAxisCount = 4;
                    aspectRatio = 0.85;
                    horizontalPadding = 10;
                    spacing = 8;
                  } else if (width >= 1024) {
                    crossAxisCount = 4;
                    aspectRatio = 0.90;
                    horizontalPadding = 8;
                    spacing = 8;
                  } else if (width >= 768) {
                    crossAxisCount = 3;
                    aspectRatio = 0.90;
                    horizontalPadding = 6;
                    spacing = 6;
                  } else if (width >= 500) {
                    // Large mobile/small tablet
                    crossAxisCount = 2;
                    aspectRatio = 0.85;
                    horizontalPadding = 4;
                    spacing = 6;
                  } else if (width >= 400) {
                    // Standard mobile
                    crossAxisCount = 2;
                    aspectRatio = 0.80;
                    horizontalPadding = 4;
                    spacing = 6;
                  } else {
                    // Small mobile - ultra conservative
                    crossAxisCount = 2;
                    aspectRatio = 0.75;
                    horizontalPadding = 2;
                    spacing = 4;
                  }
                  
                  return Container(
                    width: double.infinity,
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
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
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
                          child: _FlashSaleCard(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Category Icon widget
class _CategoryIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final double size;

  const _CategoryIcon({
    required this.label,
    required this.icon,
    this.active = false,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    double iconContainerSize = size * 0.75;
    double iconSize = iconContainerSize * 0.46;
    double fontSize = size * 0.18; // Slightly increased font ratio
    double rightPadding = size * 0.2; // Reduced right padding
    
    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFB6FF5B) : Colors.grey[100],
                borderRadius: BorderRadius.circular(iconContainerSize * 0.31),
                border: active ? Border.all(color: Colors.green, width: 1.5) : null,
                boxShadow: active ? [
                  BoxShadow(
                    color: const Color(0xFFB6FF5B).withOpacity(0.25),
                    spreadRadius: 0.5,
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: active ? Colors.black : Colors.grey[600],
                size: iconSize,
              ),
            ),
            SizedBox(height: size * 0.08),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? Colors.black : Colors.grey[600],
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Flash Sale Product Card
class _FlashSaleCard extends StatelessWidget {
  final LocalProduct product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const _FlashSaleCard({
    required this.product,
    required this.isFavorite,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive font sizes based on card width
        double cardWidth = constraints.maxWidth;
        double fontSize = cardWidth < 150 ? 11 : cardWidth < 200 ? 12 : 14;
        double priceFontSize = cardWidth < 150 ? 12 : cardWidth < 200 ? 14 : 16;
        double ratingFontSize = cardWidth < 150 ? 10 : 12;
        double buttonFontSize = cardWidth < 150 ? 10 : 12;
        double iconSize = cardWidth < 150 ? 20 : 22; // Increased icon size
        
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
                          product.image,
                          fit: BoxFit.cover, // Changed to cover for full width
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF5F5F5),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
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
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Top item',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: cardWidth < 150 ? 8 : 10,
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
                          onToggleFavorite();
                          final message = isFavorite ? 'Removed from favorites' : 'Added to favorites';
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
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[600],
                            size: iconSize,
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
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Expanded(
                        flex: 2,
                        child: Text(
                          product.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Rating
                      SizedBox(
                        height: 16,
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: ratingFontSize + 2,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: ratingFontSize,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '/5',
                              style: TextStyle(
                                fontSize: ratingFontSize,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Price section
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.price,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6366F1),
                                  fontSize: priceFontSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                product.oldPrice,
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[400],
                                  fontSize: priceFontSize - 4,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Add to cart button
                      SizedBox(
                        width: double.infinity,
                        height: cardWidth < 150 ? 28 : 32,
                        child: ElevatedButton(
                          onPressed: () {
                            onAddToCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('${product.title} added to cart')),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                          child: Text(
                            'Add to cart',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: buttonFontSize,
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
      },
    );
  }
}
