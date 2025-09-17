enum PlaceType {
  general,
  restaurant,
  gas_station,
  hospital,
  shopping,
  school,
  bank,
  pharmacy,
  hotel,
  park,
}

class PlaceModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final PlaceType type;
  final double? rating;
  final double? distance; // in meters
  final String? phoneNumber;
  final String? website;
  final List<String>? photos;
  final Map<String, dynamic>? additionalInfo;

  PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.rating,
    this.distance,
    this.phoneNumber,
    this.website,
    this.photos,
    this.additionalInfo,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: PlaceType.values.firstWhere(
        (e) => e.toString() == 'PlaceType.${json['type']}',
        orElse: () => PlaceType.general,
      ),
      rating: json['rating']?.toDouble(),
      distance: json['distance']?.toDouble(),
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      photos: json['photos']?.cast<String>(),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.toString().split('.').last,
      'rating': rating,
      'distance': distance,
      'phoneNumber': phoneNumber,
      'website': website,
      'photos': photos,
      'additionalInfo': additionalInfo,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case PlaceType.restaurant:
        return 'Restaurant';
      case PlaceType.gas_station:
        return 'Gas Station';
      case PlaceType.hospital:
        return 'Hospital';
      case PlaceType.shopping:
        return 'Shopping';
      case PlaceType.school:
        return 'School';
      case PlaceType.bank:
        return 'Bank';
      case PlaceType.pharmacy:
        return 'Pharmacy';
      case PlaceType.hotel:
        return 'Hotel';
      case PlaceType.park:
        return 'Park';
      default:
        return 'Place';
    }
  }

  String get distanceText {
    if (distance == null) return '';
    
    if (distance! < 1000) {
      return '${distance!.round()}m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(1)}km';
    }
  }
}

class Address {
  final String id;
  final String title;
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Address({
    required this.id,
    required this.title,
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phone,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      title: json['title'],
      fullName: json['fullName'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      phone: json['phone'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  String get formattedAddress {
    List<String> parts = [addressLine1];
    
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    
    parts.add('$city, $state $postalCode');
    parts.add(country);
    
    return parts.join('\n');
  }

  String get singleLineAddress {
    List<String> parts = [addressLine1];
    
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }
    
    parts.add('$city, $state $postalCode, $country');
    
    return parts.join(', ');
  }

  Address copyWith({
    String? id,
    String? title,
    String? fullName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class RouteModel {
  final String startAddress;
  final String endAddress;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final double distance; // in meters
  final int duration; // in seconds
  final List<RouteStep> steps;

  RouteModel({
    required this.startAddress,
    required this.endAddress,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.distance,
    required this.duration,
    required this.steps,
  });

  String get distanceText {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  String get durationText {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class RouteStep {
  final String instruction;
  final double distance;
  final int duration;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
  });
}
