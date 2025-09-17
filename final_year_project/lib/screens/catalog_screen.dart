import 'package:flutter/material.dart';
import 'category_products_screen.dart';
import '../main.dart';

class CatalogScreen extends StatelessWidget {
  final Function(LocalProduct) onToggleFavorite;
  final Function(LocalProduct) onAddToCart;
  final bool Function(LocalProduct) isFavorite;

  const CatalogScreen({
    super.key,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.isFavorite,
  });

  final List<Map<String, dynamic>> categories = const [
    {"name": "Phones", "image": "assets/images/catalogphone.jpg", "icon": Icons.phone_android},
    {"name": "Consoles", "image": "assets/images/catalogconsole.jpg", "icon": Icons.videogame_asset},
    {"name": "Laptops", "image": "assets/images/cataloglaptop.jpg", "icon": Icons.laptop_mac},
    {"name": "Cameras", "image": "assets/images/catalogcamera.jpg", "icon": Icons.camera_alt},
    {"name": "Accessories", "image": "assets/images/catalogaccessories.jpg", "icon": Icons.headphones},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Catalog',
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
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header text
              const Text(
                'Browse Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find products from different categories',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Categories grid
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  int crossAxisCount = 2;
                  double aspectRatio = 1.2;
                  double horizontalPadding = 16;
                  double spacing = 16;
                  
                  // TV Screens (4K and beyond)
                  if (width >= 2560) {
                    crossAxisCount = 8;
                    aspectRatio = 1.3;
                    horizontalPadding = 40;
                    spacing = 24;
                  }
                  // Large Desktop/TV (1920px+)
                  else if (width >= 1920) {
                    crossAxisCount = 6;
                    aspectRatio = 1.25;
                    horizontalPadding = 32;
                    spacing = 20;
                  }
                  // Desktop (1440px+)
                  else if (width >= 1440) {
                    crossAxisCount = 5;
                    aspectRatio = 1.2;
                    horizontalPadding = 24;
                    spacing = 18;
                  }
                  // Small Desktop/Large Laptop (1200px+)
                  else if (width >= 1200) {
                    crossAxisCount = 4;
                    aspectRatio = 1.15;
                    horizontalPadding = 20;
                    spacing = 16;
                  }
                  // Laptop (1024px+)
                  else if (width >= 1024) {
                    crossAxisCount = 3;
                    aspectRatio = 1.15;
                    horizontalPadding = 20;
                    spacing = 16;
                  }
                  // Large Tablet (768px+)
                  else if (width >= 768) {
                    crossAxisCount = 3;
                    aspectRatio = 1.1;
                    horizontalPadding = 16;
                    spacing = 14;
                  }
                  // Small Tablet (600px+)
                  else if (width >= 600) {
                    crossAxisCount = 2;
                    aspectRatio = 1.2;
                    horizontalPadding = 16;
                    spacing = 12;
                  }
                  // Phone
                  else {
                    crossAxisCount = 2;
                    aspectRatio = 1.15;
                    horizontalPadding = 16;
                    spacing = 12;
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
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryProductsScreen(
                                  category: category["name"],
                                  onToggleFavorite: onToggleFavorite,
                                  onAddToCart: onAddToCart,
                                  isFavorite: isFavorite,
                                ),
                              ),
                            );
                          },
                          child: _CategoryCard(
                            name: category["name"],
                            image: category["image"],
                            icon: category["icon"],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String image;
  final IconData icon;

  const _CategoryCard({
    required this.name,
    required this.image,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    icon,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            // Category info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB6FF5B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Explore',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
