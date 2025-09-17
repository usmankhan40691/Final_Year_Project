import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/django_auth_service.dart';
import 'services/order_service.dart';
import 'services/payment_service.dart';
import 'services/location_service.dart';
import 'services/cart_service.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/django_auth_screen.dart';
import 'services/profile_service.dart';
import 'models/product_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DjangoAuthService()),
        ChangeNotifierProvider(create: (_) => ProfileService()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'E-Commerce App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Product Model - Backwards compatibility wrapper
class LocalProduct {
  final String id;
  final String category;
  final String title;
  final String price;
  final String oldPrice;
  final String description;
  final String image;
  final double rating;
  final int reviews;

  const LocalProduct({
    required this.id,
    required this.category,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.description,
    required this.image,
    this.rating = 4.8,
    this.reviews = 117,
  });

  // Convert to unified Product model
  Product toProduct() {
    // Better price parsing - handle both £ and ₹ symbols
    double parsedPrice = 0.0;
    double? parsedOldPrice;
    
    // Parse current price - remove currency symbols and clean up
    String cleanPrice = price.replaceAll(RegExp(r'[£₹,\s]'), '');
    parsedPrice = double.tryParse(cleanPrice) ?? 0.0;
    
    // Parse old price if available
    if (oldPrice.isNotEmpty) {
      String cleanOldPrice = oldPrice.replaceAll(RegExp(r'[£₹,\s]'), '');
      parsedOldPrice = double.tryParse(cleanOldPrice);
    }
    
    return Product.createLocal(
      id: int.tryParse(id) ?? id.hashCode % 100000,
      name: title,
      category: category,
      price: parsedPrice,
      oldPrice: parsedOldPrice,
      description: description,
      image: image,
      rating: rating,
      reviews: reviews,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalProduct && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Local Cart Item Model for backwards compatibility
class LocalCartItem {
  final LocalProduct product;
  int quantity;

  LocalCartItem({required this.product, this.quantity = 1});
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // ApiService instance
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Example: Fetch products from backend and print to console
    apiService.fetchProducts().then((products) {
      print('Fetched products from backend:');
      print(products);
    }).catchError((e) {
      print('Error fetching products: $e');
    });
  }
  int _selectedIndex = 0;

  List<LocalProduct> favoriteItems = [];
  List<LocalCartItem> cartItems = [];

  void toggleFavorite(LocalProduct product) {
    setState(() {
      if (favoriteItems.contains(product)) {
        favoriteItems.remove(product);
      } else {
        favoriteItems.add(product);
      }
    });
  }

  void addToCart(LocalProduct product) async {
    final cartService = Provider.of<CartService>(context, listen: false);
    final djangoAuthService = Provider.of<DjangoAuthService>(context, listen: false);
    
    if (djangoAuthService.isAuthenticated) {
      // Use Django backend for authenticated users
      final unifiedProduct = product.toProduct();
      final success = await cartService.addToCart(unifiedProduct.id, 1);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted && cartService.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartService.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Use local state for guest users - add to cart service's local cart
      final unifiedProduct = product.toProduct();
      cartService.addToLocalCart(unifiedProduct);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                // Navigate to login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DjangoAuthScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  void removeFromCart(LocalProduct product) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final djangoAuthService = Provider.of<DjangoAuthService>(context, listen: false);
    
    if (djangoAuthService.isAuthenticated) {
      // For authenticated users, this would be handled through the cart screen
      // directly with the cart service's removeFromCart method
    } else {
      final unifiedProduct = product.toProduct();
      cartService.removeFromLocalCart(unifiedProduct.id);
    }
  }

  void updateCartQuantity(LocalProduct product, int quantity) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final djangoAuthService = Provider.of<DjangoAuthService>(context, listen: false);
    
    if (djangoAuthService.isAuthenticated) {
      // For authenticated users, this would be handled through the cart screen
      // directly with the cart service's updateCartItem method
    } else {
      final unifiedProduct = product.toProduct();
      cartService.updateLocalCartQuantity(unifiedProduct.id, quantity);
    }
  }

  bool isFavorite(LocalProduct product) {
    return favoriteItems.contains(product);
  }

  int get totalCartItems {
    final cartService = Provider.of<CartService>(context, listen: false);
    return cartService.itemCount;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onToggleFavorite: toggleFavorite,
        onAddToCart: addToCart,
        isFavorite: isFavorite,
      ),
      CatalogScreen(
        onToggleFavorite: toggleFavorite,
        onAddToCart: addToCart,
        isFavorite: isFavorite,
      ),
      CartScreen(onStartShopping: () => _onItemTapped(1)),
      WishlistScreen(
        favoriteItems: favoriteItems,
        onToggleFavorite: toggleFavorite,
        onAddToCart: addToCart,
      ),
      const ProfileScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // For very large screens (desktop/TV), use a side navigation
        if (constraints.maxWidth >= 1200) {
          return Scaffold(
            body: Row(
              children: [
                // Side Navigation
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // App Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB6FF5B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.store, color: Colors.black, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tech Store',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Navigation Items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildSideNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                            _buildSideNavItem(1, Icons.grid_view_outlined, Icons.grid_view, 'Catalog'),
                            _buildSideNavItemWithBadge(2, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart', totalCartItems),
                            _buildSideNavItemWithBadge(3, Icons.favorite_border, Icons.favorite, 'Favorites', favoriteItems.length),
                            _buildSideNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }
        
        // For tablets and phones, use bottom navigation
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFFB6FF5B),
              unselectedItemColor: Colors.grey,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: constraints.maxWidth >= 768 ? 14 : 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: constraints.maxWidth >= 768 ? 13 : 12,
              ),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  activeIcon: Icon(Icons.grid_view),
                  label: 'Catalog',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      if (totalCartItems > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$totalCartItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (totalCartItems > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$totalCartItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.favorite_border),
                      if (favoriteItems.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${favoriteItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    children: [
                      const Icon(Icons.favorite),
                      if (favoriteItems.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${favoriteItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Favorites',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: const Color(0xFFB6FF5B).withOpacity(0.1),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? const Color(0xFFB6FF5B) : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
            fontSize: 16,
          ),
        ),
        onTap: () => _onItemTapped(index),
      ),
    );
  }

  Widget _buildSideNavItemWithBadge(int index, IconData icon, IconData activeIcon, String label, int badgeCount) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: const Color(0xFFB6FF5B).withOpacity(0.1),
        leading: Stack(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFFB6FF5B) : Colors.grey[600],
              size: 24,
            ),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
            fontSize: 16,
          ),
        ),
        onTap: () => _onItemTapped(index),
      ),
    );
  }
}
