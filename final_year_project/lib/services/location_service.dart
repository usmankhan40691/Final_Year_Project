import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location_models.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  Address? _currentAddress;
  bool _isLoading = false;
  String? _errorMessage;
  List<Address> _savedAddresses = [];
  List<PlaceModel> _searchResults = [];

  Position? get currentPosition => _currentPosition;
  Address? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Address> get savedAddresses => _savedAddresses;
  List<PlaceModel> get searchResults => _searchResults;

  LocationService() {
    _loadSavedAddresses();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString('saved_addresses');
      if (addressesJson != null) {
        final List<dynamic> addressesList = jsonDecode(addressesJson);
        _savedAddresses = addressesList.map((item) => Address.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved addresses: $e');
    }
  }

  Future<void> _saveSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(_savedAddresses.map((item) => item.toJson()).toList());
      await prefs.setString('saved_addresses', addressesJson);
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setError('Location services are disabled');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setError('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setError('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  Future<bool> getCurrentLocation() async {
    _setLoading(true);
    _setError(null);

    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        _setLoading(false);
        return false;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      if (_currentPosition != null) {
        await _getAddressFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      _setLoading(false);
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Failed to get current location: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = Address(
          id: 'current_location',
          title: 'Current Location',
          fullName: 'Current Location',
          addressLine1: '${placemark.street ?? ''} ${placemark.subThoroughfare ?? ''}'.trim(),
          addressLine2: placemark.subLocality ?? '',
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          postalCode: placemark.postalCode ?? '',
          country: placemark.country ?? '',
          latitude: latitude,
          longitude: longitude,
          isDefault: false,
        );
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
    }
  }

  Future<List<PlaceModel>> searchPlaces(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return [];
    }

    _setLoading(true);
    _setError(null);

    try {
      // Use geocoding to search for places
      List<Location> locations = await locationFromAddress(query);
      
      List<PlaceModel> results = [];
      
      for (Location location in locations) {
        // Get detailed address information
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final place = PlaceModel(
            id: '${location.latitude}_${location.longitude}',
            name: placemark.name ?? query,
            address: _formatPlacemarkAddress(placemark),
            latitude: location.latitude,
            longitude: location.longitude,
            type: PlaceType.general,
          );
          results.add(place);
        }
      }

      _searchResults = results;
      _setLoading(false);
      notifyListeners();
      return results;

    } catch (e) {
      _setError('Failed to search places: ${e.toString()}');
      _setLoading(false);
      return [];
    }
  }

  String _formatPlacemarkAddress(Placemark placemark) {
    List<String> addressParts = [];
    
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }
    
    return addressParts.join(', ');
  }

  Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return 0.0;
    }
  }

  Future<List<PlaceModel>> findNearbyPlaces({
    required double latitude,
    required double longitude,
    required PlaceType type,
    double radiusInKm = 5.0,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // In a real app, you would use Google Places API or similar service
      // For demo purposes, we'll simulate some nearby places
      await Future.delayed(const Duration(seconds: 1));

      List<PlaceModel> nearbyPlaces = _generateNearbyPlaces(
        latitude,
        longitude,
        type,
        radiusInKm,
      );

      _setLoading(false);
      notifyListeners();
      return nearbyPlaces;

    } catch (e) {
      _setError('Failed to find nearby places: ${e.toString()}');
      _setLoading(false);
      return [];
    }
  }

  List<PlaceModel> _generateNearbyPlaces(
    double centerLat,
    double centerLng,
    PlaceType type,
    double radiusInKm,
  ) {
    // Simulate nearby places for demo
    List<PlaceModel> places = [];
    
    switch (type) {
      case PlaceType.restaurant:
        places = [
          PlaceModel(
            id: 'rest1',
            name: 'Pizza Palace',
            address: '123 Main St',
            latitude: centerLat + 0.001,
            longitude: centerLng + 0.001,
            type: PlaceType.restaurant,
            rating: 4.5,
            distance: 150,
          ),
          PlaceModel(
            id: 'rest2',
            name: 'Burger Barn',
            address: '456 Oak Ave',
            latitude: centerLat - 0.002,
            longitude: centerLng + 0.002,
            type: PlaceType.restaurant,
            rating: 4.2,
            distance: 300,
          ),
        ];
        break;
      case PlaceType.gas_station:
        places = [
          PlaceModel(
            id: 'gas1',
            name: 'Shell Station',
            address: '789 Broadway',
            latitude: centerLat + 0.003,
            longitude: centerLng - 0.001,
            type: PlaceType.gas_station,
            rating: 3.8,
            distance: 400,
          ),
        ];
        break;
      case PlaceType.hospital:
        places = [
          PlaceModel(
            id: 'hosp1',
            name: 'City Hospital',
            address: '321 Health St',
            latitude: centerLat - 0.001,
            longitude: centerLng - 0.002,
            type: PlaceType.hospital,
            rating: 4.0,
            distance: 250,
          ),
        ];
        break;
      default:
        break;
    }

    return places;
  }

  Future<bool> saveAddress(Address address) async {
    try {
      // Check if address already exists
      final existingIndex = _savedAddresses.indexWhere((a) => a.id == address.id);
      
      if (existingIndex != -1) {
        _savedAddresses[existingIndex] = address;
      } else {
        _savedAddresses.add(address);
      }

      await _saveSavedAddresses();
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Failed to save address: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      _savedAddresses.removeWhere((address) => address.id == addressId);
      await _saveSavedAddresses();
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Failed to delete address: ${e.toString()}');
      return false;
    }
  }

  Set<Marker> createMarkersFromPlaces(List<PlaceModel> places) {
    return places.map((place) => Marker(
      markerId: MarkerId(place.id),
      position: LatLng(place.latitude, place.longitude),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: place.address,
      ),
      icon: _getMarkerIcon(place.type),
    )).toSet();
  }

  BitmapDescriptor _getMarkerIcon(PlaceType type) {
    // In a real app, you would return custom icons based on place type
    switch (type) {
      case PlaceType.restaurant:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case PlaceType.gas_station:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case PlaceType.hospital:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case PlaceType.shopping:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
