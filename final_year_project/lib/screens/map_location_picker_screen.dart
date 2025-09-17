import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../models/location_models.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final Address? initialAddress;
  final LatLng? initialLocation;

  const MapLocationPickerScreen({
    super.key,
    this.initialAddress,
    this.initialLocation,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Address? _selectedAddress;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  List<PlaceModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingAddress = false;

  static const LatLng _defaultLocation = LatLng(25.2048, 55.2708); // Dubai default

  @override
  void initState() {
    super.initState();
    
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
    }
    
    if (widget.initialAddress != null) {
      _selectedAddress = widget.initialAddress;
      _searchController.text = widget.initialAddress!.singleLineAddress;
    }
    
    if (_selectedLocation != null) {
      _addMarker(_selectedLocation!);
    }
    
    // Get current location if no initial location provided
    if (widget.initialLocation == null && widget.initialAddress == null) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    try {
      final success = await locationService.getCurrentLocation();
      if (success && locationService.currentPosition != null) {
        final currentPos = LatLng(
          locationService.currentPosition!.latitude,
          locationService.currentPosition!.longitude,
        );
        setState(() {
          _selectedLocation = currentPos;
          _selectedAddress = locationService.currentAddress;
        });
        _addMarker(currentPos);
        
        if (locationService.currentAddress != null) {
          _searchController.text = locationService.currentAddress!.singleLineAddress;
        }
        
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(currentPos, 15),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
            });
            _getAddressFromCoordinates(newPosition);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      };
    });
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });
    
    try {
      // For now, create a simplified address
      final address = Address(
        id: 'selected_location',
        title: 'Selected Location',
        fullName: 'Selected Location',
        addressLine1: 'Lat: ${location.latitude.toStringAsFixed(6)}',
        addressLine2: 'Lng: ${location.longitude.toStringAsFixed(6)}',
        city: 'Unknown',
        state: 'Unknown',
        postalCode: '00000',
        country: 'Unknown',
        latitude: location.latitude,
        longitude: location.longitude,
        isDefault: false,
      );
      
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _searchController.text = '${address.addressLine1}, ${address.addressLine2}';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting address: $e')),
        );
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final locationService = Provider.of<LocationService>(context, listen: false);
    try {
      final results = await locationService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching places: $e')),
        );
      }
    }
  }

  void _selectSearchResult(PlaceModel place) {
    final newLocation = LatLng(place.latitude, place.longitude);
    
    setState(() {
      _selectedLocation = newLocation;
      _searchResults = [];
      _searchController.text = place.name;
    });
    
    _addMarker(newLocation);
    _getAddressFromCoordinates(newLocation);
    
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 15),
      );
    }
    
    FocusScope.of(context).unfocus();
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _addMarker(position);
    _getAddressFromCoordinates(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pick Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'location': _selectedLocation,
                  'address': _selectedAddress,
                });
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFFB6FF5B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    prefixIcon: _isSearching 
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFB6FF5B)),
                    ),
                  ),
                  onChanged: _searchLocation,
                ),
                
                // Search Results
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length > 5 ? 5 : _searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(place.name),
                          subtitle: Text(place.address),
                          onTap: () => _selectSearchResult(place),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ?? _defaultLocation,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_selectedLocation != null) {
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                  );
                }
              },
              onTap: _onMapTap,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),
          ),
          
          // Bottom Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedLocation != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFB6FF5B)),
                      const SizedBox(width: 8),
                      const Text(
                        'Selected Location:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_isLoadingAddress) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (_selectedAddress != null) ...[
                    Text(
                      _selectedAddress!.singleLineAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                      'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use Current Location'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB6FF5B),
                          side: const BorderSide(color: Color(0xFFB6FF5B)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_selectedLocation != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'location': _selectedLocation,
                              'address': _selectedAddress,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB6FF5B),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Confirm Location'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
