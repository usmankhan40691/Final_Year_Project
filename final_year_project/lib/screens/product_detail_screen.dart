import 'package:flutter/material.dart';
import '../main.dart';

class ProductDetailScreen extends StatefulWidget {
  final LocalProduct product;
  final Function(LocalProduct) onToggleFavorite;
  final Function(LocalProduct) onAddToCart;
  final bool isFavorite;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.isFavorite,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen width
        double imageHeight;
        double contentPadding;
        double titleFontSize;
        double priceFontSize;
        double buttonHeight;
        bool isLargeScreen = constraints.maxWidth >= 1200;
        
        if (constraints.maxWidth >= 2560) {
          // TV screens
          imageHeight = 500;
          contentPadding = 48;
          titleFontSize = 32;
          priceFontSize = 32;
          buttonHeight = 72;
        } else if (constraints.maxWidth >= 1920) {
          // Large Desktop
          imageHeight = 450;
          contentPadding = 40;
          titleFontSize = 30;
          priceFontSize = 30;
          buttonHeight = 68;
        } else if (constraints.maxWidth >= 1440) {
          // Desktop
          imageHeight = 400;
          contentPadding = 36;
          titleFontSize = 28;
          priceFontSize = 28;
          buttonHeight = 64;
        } else if (constraints.maxWidth >= 1200) {
          // Large Laptop
          imageHeight = 380;
          contentPadding = 32;
          titleFontSize = 26;
          priceFontSize = 26;
          buttonHeight = 60;
        } else if (constraints.maxWidth >= 1024) {
          // Laptop
          imageHeight = 360;
          contentPadding = 28;
          titleFontSize = 25;
          priceFontSize = 25;
          buttonHeight = 58;
        } else if (constraints.maxWidth >= 768) {
          // Tablet
          imageHeight = 340;
          contentPadding = 24;
          titleFontSize = 24;
          priceFontSize = 24;
          buttonHeight = 56;
        } else if (constraints.maxWidth >= 600) {
          // Large Phone
          imageHeight = 320;
          contentPadding = 20;
          titleFontSize = 22;
          priceFontSize = 22;
          buttonHeight = 54;
        } else if (constraints.maxWidth >= 480) {
          // Phone
          imageHeight = 300;
          contentPadding = 18;
          titleFontSize = 20;
          priceFontSize = 20;
          buttonHeight = 52;
        } else {
          // Small Phone
          imageHeight = 280;
          contentPadding = 16;
          titleFontSize = 18;
          priceFontSize = 18;
          buttonHeight = 50;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F6FA),
          body: isLargeScreen ? _buildDesktopLayout(constraints, imageHeight, contentPadding, titleFontSize, priceFontSize, buttonHeight) 
                             : _buildMobileLayout(constraints, imageHeight, contentPadding, titleFontSize, priceFontSize, buttonHeight),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BoxConstraints constraints, double imageHeight, double contentPadding, double titleFontSize, double priceFontSize, double buttonHeight) {
    return Stack(
      children: [
        Row(
          children: [
            // Left side - Image
            Expanded(
              flex: 1,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: imageHeight),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          widget.product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, size: titleFontSize * 3, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Right side - Content
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(contentPadding),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProductContent(contentPadding, titleFontSize, priceFontSize, buttonHeight, true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildTopBar(contentPadding * 0.5),
      ],
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints, double imageHeight, double contentPadding, double titleFontSize, double priceFontSize, double buttonHeight) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top image with rounded corners
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported, size: titleFontSize * 3, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              
              // White card with details (use Transform.translate for overlap)
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  padding: EdgeInsets.fromLTRB(contentPadding, contentPadding * 1.3, contentPadding, contentPadding),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _buildProductContent(contentPadding, titleFontSize, priceFontSize, buttonHeight, false),
                ),
              ),
            ],
          ),
        ),
        _buildTopBar(contentPadding * 0.7),
      ],
    );
  }

  Widget _buildProductContent(double contentPadding, double titleFontSize, double priceFontSize, double buttonHeight, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop) ...[
          // Handle bar for mobile
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          SizedBox(height: contentPadding * 0.8),
        ],
        
        // Product title
        Text(
          widget.product.title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: contentPadding * 0.7),
        
        // Rating and reviews
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: contentPadding * 0.5, vertical: contentPadding * 0.25),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: titleFontSize * 0.7),
                  const SizedBox(width: 4),
                  Text(
                    widget.product.rating.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize * 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.product.reviews} reviews',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize * 0.45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: contentPadding * 0.5, vertical: contentPadding * 0.25),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEB3B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up, color: Colors.orange, size: titleFontSize * 0.7),
                  const SizedBox(width: 4),
                  Text(
                    '94%',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize * 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: contentPadding * 0.5, vertical: contentPadding * 0.25),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.black54, size: titleFontSize * 0.7),
                  const SizedBox(width: 4),
                  Text(
                    '8',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize * 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: contentPadding * 0.8),
        
        // Price information
        Row(
          children: [
            Text(
              widget.product.price,
              style: TextStyle(
                fontSize: priceFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.product.oldPrice,
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey[500],
                fontSize: priceFontSize * 0.7,
              ),
            ),
          ],
        ),
        SizedBox(height: contentPadding * 0.3),
        Text(
          'from £14 per month',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: titleFontSize * 0.6,
          ),
        ),
        SizedBox(height: contentPadding * 0.8),
        
        // Description
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: titleFontSize * 0.65,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        SizedBox(height: contentPadding * 0.3),
        
        // Read more link
        GestureDetector(
          onTap: () {
            // Show full description
          },
          child: Text(
            'Read more',
            style: TextStyle(
              color: const Color(0xFFB6FF5B),
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize * 0.65,
            ),
          ),
        ),
        SizedBox(height: contentPadding * 1.3),
        
        // Add to cart button
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              widget.onAddToCart(widget.product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to cart'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.black87,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB6FF5B),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Add to cart',
              style: TextStyle(
                fontSize: titleFontSize * 0.75,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: contentPadding * 0.7),
        
        // Delivery info
        Text(
          'Delivery on 26 October',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: titleFontSize * 0.6,
          ),
        ),
        SizedBox(height: contentPadding),
      ],
    );
  }

  Widget _buildTopBar(double padding) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      widget.onToggleFavorite(widget.product);
                      final message = widget.isFavorite 
                          ? 'Removed from favorites' 
                          : 'Added to favorites';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}






