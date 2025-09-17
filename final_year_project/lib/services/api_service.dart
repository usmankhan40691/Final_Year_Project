import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ApiService {
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/products'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}
