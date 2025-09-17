import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/user_profile.dart';

class ProfileService extends ChangeNotifier {
  UserProfile? _userProfile;
  String? _authToken;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get userProfile => _userProfile;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Set auth token
  void setAuthToken(String? token) {
    _authToken = token;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Set profile for testing
  void setProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  // Get headers with auth token
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Fetch user profile
  Future<bool> fetchProfile() async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/profile/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userProfile = UserProfile.fromJson(data);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to fetch profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _setError('Error fetching profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.put(
        Uri.parse('$apiBaseUrl/api/profile/'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userProfile = UserProfile.fromJson(data);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _setError('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(ChangePasswordRequest request) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.put(
        Uri.parse('$apiBaseUrl/api/change-password/'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['error'] ?? 'Failed to change password');
        return false;
      }
    } catch (e) {
      _setError('Error changing password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Settings Management
  Future<bool> updateNotificationSettings(UserSettings settings) async {
    try {
      _setLoading(true);
      _setError(null);

      // For now, just update locally
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(settings: settings);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Error updating settings: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh profile data
  Future<void> refreshProfileData() async {
    await fetchProfile();
  }

  // Clear all data (for logout)
  void clearAllData() {
    _userProfile = null;
    _authToken = null;
    _errorMessage = null;
    notifyListeners();
  }
}
