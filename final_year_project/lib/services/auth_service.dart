import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _jwtToken;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get jwtToken => _jwtToken;

  AuthService() {
    _loadUserFromStorage();
    _loadJwtToken();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = User.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<void> _loadJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _jwtToken = prefs.getString('jwt_token');
      
      // Check if token is expired
      if (_jwtToken != null && JwtDecoder.isExpired(_jwtToken!)) {
        await _removeJwtToken();
        await logout();
      }
    } catch (e) {
      debugPrint('Error loading JWT token: $e');
    }
  }

  Future<void> _saveJwtToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      _jwtToken = token;
    } catch (e) {
      debugPrint('Error saving JWT token: $e');
    }
  }

  Future<void> _removeJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      _jwtToken = null;
    } catch (e) {
      debugPrint('Error removing JWT token: $e');
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

  Future<void> _removeUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
    } catch (e) {
      debugPrint('Error removing user from storage: $e');
    }
  }

  // Password hashing utility - used for production API integration
  // ignore: unused_element
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would make an API call here
      // For demo purposes, we'll simulate authentication
      // final hashedPassword = _hashPassword(password);
      
      // Simulate checking credentials (in real app, this would be server-side)
      if (email.isNotEmpty && password.length >= 6) {
        // Create user object (in real app, this would come from API response)
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: _extractNameFromEmail(email),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _currentUser = user;
        await _saveUserToStorage(user);
        
        // Simulate JWT token (in real app, this would come from API)
        final fakeToken = _generateFakeJwtToken(user);
        await _saveJwtToken(fakeToken);
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An error occurred during login');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _setLoading(false);
        return false; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // In real app, you would send the googleAuth.idToken to your backend
      // to verify and create/login the user
      
      final user = User(
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName ?? _extractNameFromEmail(googleUser.email),
        profileImage: googleUser.photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _currentUser = user;
      await _saveUserToStorage(user);
      
      // Simulate JWT token
      final fakeToken = _generateFakeJwtToken(user);
      await _saveJwtToken(fakeToken);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Google sign-in failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      debugPrint('Biometric check error: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Get available biometrics error: $e');
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      _setError('Biometric authentication failed');
      return false;
    }
  }

  String _generateFakeJwtToken(User user) {
    // This is a fake JWT token for demo purposes
    // In real app, this would come from your backend
    final header = base64Encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
    final payload = base64Encode(utf8.encode(jsonEncode({
      'user_id': user.id,
      'email': user.email,
      'exp': DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    })));
    final signature = base64Encode(utf8.encode('fake_signature'));
    
    return '$header.$payload.$signature';
  }

  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would make an API call here
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
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
        _setError('Please fill all fields correctly');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An error occurred during signup');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      await _removeUserFromStorage();
      await _removeJwtToken();
      _currentUser = null;
      _setError(null);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('An error occurred during logout');
      _setLoading(false);
    }
  }

  Future<bool> refreshToken() async {
    if (_jwtToken == null) return false;
    
    try {
      // In real app, you would call your backend to refresh the token
      // For demo, we'll generate a new fake token
      if (_currentUser != null) {
        final newToken = _generateFakeJwtToken(_currentUser!);
        await _saveJwtToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        profileImage: profileImage ?? _currentUser!.profileImage,
        updatedAt: DateTime.now(),
      );

      _currentUser = updatedUser;
      await _saveUserToStorage(updatedUser);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addAddress(Address address) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedAddresses = List<Address>.from(_currentUser!.addresses);
      
      // If this is the first address or marked as default, make it default
      if (updatedAddresses.isEmpty || address.isDefault) {
        // Remove default from other addresses
        for (var addr in updatedAddresses) {
          if (addr.isDefault) {
            final index = updatedAddresses.indexOf(addr);
            updatedAddresses[index] = Address(
              id: addr.id,
              title: addr.title,
              fullName: addr.fullName,
              addressLine1: addr.addressLine1,
              addressLine2: addr.addressLine2,
              city: addr.city,
              state: addr.state,
              postalCode: addr.postalCode,
              country: addr.country,
              phone: addr.phone,
              isDefault: false,
            );
          }
        }
      }

      updatedAddresses.add(address);

      final updatedUser = _currentUser!.copyWith(
        addresses: updatedAddresses,
        updatedAt: DateTime.now(),
      );

      _currentUser = updatedUser;
      await _saveUserToStorage(updatedUser);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add address');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addPaymentMethod(PaymentMethod paymentMethod) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedPaymentMethods = List<PaymentMethod>.from(_currentUser!.paymentMethods);
      
      // If this is the first payment method or marked as default, make it default
      if (updatedPaymentMethods.isEmpty || paymentMethod.isDefault) {
        // Remove default from other payment methods
        for (int i = 0; i < updatedPaymentMethods.length; i++) {
          if (updatedPaymentMethods[i].isDefault) {
            updatedPaymentMethods[i] = PaymentMethod(
              id: updatedPaymentMethods[i].id,
              type: updatedPaymentMethods[i].type,
              title: updatedPaymentMethods[i].title,
              cardNumber: updatedPaymentMethods[i].cardNumber,
              expiryMonth: updatedPaymentMethods[i].expiryMonth,
              expiryYear: updatedPaymentMethods[i].expiryYear,
              cardHolderName: updatedPaymentMethods[i].cardHolderName,
              cardType: updatedPaymentMethods[i].cardType,
              isDefault: false,
            );
          }
        }
      }

      updatedPaymentMethods.add(paymentMethod);

      final updatedUser = _currentUser!.copyWith(
        paymentMethods: updatedPaymentMethods,
        updatedAt: DateTime.now(),
      );

      _currentUser = updatedUser;
      await _saveUserToStorage(updatedUser);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add payment method');
      _setLoading(false);
      return false;
    }
  }

  String _extractNameFromEmail(String email) {
    final username = email.split('@')[0];
    return username.split('.').map((part) => 
      part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : part
    ).join(' ');
  }

  void clearError() {
    _setError(null);
  }
}
