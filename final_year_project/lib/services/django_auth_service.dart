import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../api_config.dart';
import '../models/user_model.dart';

class DjangoAuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _accessToken != null;
  String? get accessToken => _accessToken;

  DjangoAuthService() {
    _loadUserFromStorage();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load tokens
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      
      // Load user data
      final userJson = prefs.getString('current_user');
      
      if (userJson != null && _accessToken != null) {
        // Check if token is expired
        if (JwtDecoder.isExpired(_accessToken!)) {
          // Try to refresh token
          final refreshed = await _refreshAccessToken();
          if (!refreshed) {
            await _clearStorage();
            return;
          }
        }
        
        final userMap = jsonDecode(userJson);
        _currentUser = User.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
      await _clearStorage();
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      _accessToken = accessToken;
      _refreshToken = refreshToken;
    } catch (e) {
      debugPrint('Error saving tokens: $e');
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('current_user');
      _accessToken = null;
      _refreshToken = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/token/refresh/'),
        headers: _getHeaders(),
        body: jsonEncode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', newAccessToken);
        _accessToken = newAccessToken;
        
        return true;
      } else {
        debugPrint('Token refresh failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/register/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': email.split('@')[0], // Use email prefix as username
          'email': email,
          'password': password,
          'first_name': name.split(' ')[0],
          'last_name': name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '',
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success']) {
        // Save tokens
        await _saveTokens(
          responseData['tokens']['access'],
          responseData['tokens']['refresh'],
        );

        // Create user object from response
        final userData = responseData['user'];
        final user = User(
          id: userData['id'].toString(),
          email: userData['email'],
          name: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _currentUser = user;
        await _saveUserToStorage(user);
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        String errorMessage = 'Registration failed';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is Map) {
            errorMessage = errors.values.first.toString();
          }
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
        
        _setError(errorMessage);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: Please check your connection');
      _setLoading(false);
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/login/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        // Save tokens
        await _saveTokens(
          responseData['tokens']['access'],
          responseData['tokens']['refresh'],
        );

        // Create user object from response
        final userData = responseData['user'];
        final user = User(
          id: userData['id'].toString(),
          email: userData['email'],
          name: userData['username'], // Django returns username, but we can update this
          createdAt: DateTime.now(), // You might want to parse actual dates from response
          updatedAt: DateTime.now(),
        );

        _currentUser = user;
        await _saveUserToStorage(user);
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        String errorMessage = 'Login failed';
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
        
        _setError(errorMessage);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: Please check your connection');
      _setLoading(false);
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    _setLoading(true);

    try {
      if (_refreshToken != null) {
        // Call logout endpoint to blacklist token
        await http.post(
          Uri.parse('$apiBaseUrl/api/logout/'),
          headers: _getHeaders(requiresAuth: true),
          body: jsonEncode({'refresh_token': _refreshToken}),
        );
      }

      await _clearStorage();
      _setError(null);
      _setLoading(false);
      return true;
    } catch (e) {
      // Even if API call fails, clear local storage
      await _clearStorage();
      _setLoading(false);
      debugPrint('Logout error: $e');
      return true; // Return true because local logout succeeded
    }
  }

  Future<bool> fetchUserProfile() async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _setError(null);

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/profile/'),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          final userData = responseData['user'];
          final user = User(
            id: userData['id'].toString(),
            email: userData['email'],
            name: userData['username'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          _currentUser = user;
          await _saveUserToStorage(user);
          
          _setLoading(false);
          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return fetchUserProfile(); // Retry with new token
        } else {
          await _clearStorage();
        }
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to fetch profile');
      _setLoading(false);
      debugPrint('Fetch profile error: $e');
      return false;
    }
  }

  Future<bool> isTokenValid() async {
    if (_accessToken == null) return false;
    
    try {
      return !JwtDecoder.isExpired(_accessToken!);
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }

  // Method to check server connectivity
  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/register/'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 5));
      
      // For register endpoint, we expect 405 Method Not Allowed for GET request
      // This means the server is running and responding
      return response.statusCode == 405 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Server connection error: $e');
      return false;
    }
  }
}