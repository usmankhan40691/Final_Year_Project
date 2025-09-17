import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/product_model.dart';

class ProductService {
  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<Product>> fetchProducts({
    String? category,
    bool? featured,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (category != null) queryParams['category'] = category;
      if (featured != null) queryParams['featured'] = featured.toString();
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$apiBaseUrl/api/products/').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];
        return results.map((json) => Product.fromJson(json)).toList();
      } else {
        print('Failed to fetch products: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    
    // Return demo products if backend fails
    return _getDemoProducts();
  }

  Future<Product?> fetchProduct(int productId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/products/$productId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      }
    } catch (e) {
      print('Error fetching product: $e');
    }
    
    return null;
  }

  Future<List<String>> fetchCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/categories/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];
        return results.map((category) => category['name'] as String).toList();
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    
    // Return demo categories if backend fails
    return ['Phones', 'Laptops', 'Headphones', 'Speakers', 'Cameras', 'Smartwatches', 'Accessories', 'Gaming'];
  }

  List<Product> _getDemoProducts() {
    return [
      Product.createLocal(
        id: 1001,
        name: 'iPhone 15 Pro Max',
        category: 'Phones',
        price: 134900.0,
        oldPrice: 149900.0,
        description: 'Latest iPhone with titanium design and A17 Pro chip',
        image: 'assets/images/phone1.jpg',
        rating: 4.8,
        reviews: 2456,
      ),
      Product.createLocal(
        id: 1002,
        name: 'Samsung Galaxy S24 Ultra',
        category: 'Phones',
        price: 124999.0,
        oldPrice: 134999.0,
        description: 'Premium Android phone with S Pen and 200MP camera',
        image: 'assets/images/phone2.jpg',
        rating: 4.7,
        reviews: 1823,
      ),
      Product.createLocal(
        id: 1003,
        name: 'MacBook Pro 14" M3',
        category: 'Laptops',
        price: 199900.0,
        oldPrice: 219900.0,
        description: 'Powerful laptop for professionals with M3 chip',
        image: 'assets/images/laptop1.jpg',
        rating: 4.9,
        reviews: 987,
      ),
      Product.createLocal(
        id: 1004,
        name: 'Dell XPS 13',
        category: 'Laptops',
        price: 89999.0,
        oldPrice: 99999.0,
        description: 'Ultra-portable Windows laptop with InfinityEdge display',
        image: 'assets/images/laptop2.jpg',
        rating: 4.6,
        reviews: 654,
      ),
      Product.createLocal(
        id: 1005,
        name: 'Sony WH-1000XM5',
        category: 'Headphones',
        price: 29990.0,
        oldPrice: 34990.0,
        description: 'Industry-leading noise canceling wireless headphones',
        image: 'assets/images/headphone1.jpg',
        rating: 4.8,
        reviews: 3421,
      ),
      Product.createLocal(
        id: 1006,
        name: 'Apple AirPods Pro (2nd gen)',
        category: 'Headphones',
        price: 24900.0,
        description: 'Wireless earbuds with active noise cancellation',
        image: 'assets/images/headphone2.jpg',
        rating: 4.7,
        reviews: 5432,
      ),
      Product.createLocal(
        id: 1007,
        name: 'Canon EOS R5',
        category: 'Cameras',
        price: 329999.0,
        oldPrice: 359999.0,
        description: 'Full-frame mirrorless camera with 45MP sensor',
        image: 'assets/images/camera1.jpg',
        rating: 4.9,
        reviews: 234,
      ),
      Product.createLocal(
        id: 1008,
        name: 'Apple Watch Series 9',
        category: 'Smartwatches',
        price: 41900.0,
        oldPrice: 45900.0,
        description: 'Advanced health and fitness smartwatch',
        image: 'assets/images/watch1.jpg',
        rating: 4.6,
        reviews: 1876,
      ),
      Product.createLocal(
        id: 1009,
        name: 'JBL Charge 5',
        category: 'Speakers',
        price: 12999.0,
        oldPrice: 15999.0,
        description: 'Portable Bluetooth speaker with powerbank feature',
        image: 'assets/images/speaker1.jpg',
        rating: 4.5,
        reviews: 2109,
      ),
      Product.createLocal(
        id: 1010,
        name: 'PlayStation 5 DualSense Controller',
        category: 'Gaming',
        price: 5999.0,
        description: 'Wireless controller with haptic feedback',
        image: 'assets/images/accessories1.jpg',
        rating: 4.8,
        reviews: 3456,
      ),
    ];
  }

  List<Product> getProductsByCategory(String category) {
    final allProducts = _getDemoProducts();
    return allProducts.where((product) => product.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<Product> getFeaturedProducts() {
    return _getDemoProducts().take(6).toList();
  }

  List<Product> searchProducts(String query) {
    final allProducts = _getDemoProducts();
    final lowerQuery = query.toLowerCase();
    return allProducts.where((product) => 
      product.name.toLowerCase().contains(lowerQuery) ||
      product.description.toLowerCase().contains(lowerQuery) ||
      product.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}