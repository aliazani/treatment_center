import 'package:equatable/equatable.dart';

/// Facility location type enum
enum FacilityLocationType {
  urban,
  periUrban,
  rural,
}

/// Represents geographical location information of the facility
class GeoLocation extends Equatable {
  /// Country where the facility is located
  final String country;
  
  /// Region or province name
  final String regionProvince;
  
  /// District name
  final String district;
  
  /// City, village, clan or locality name
  final String cityVillage;
  
  /// Physical address or GPS coordinates of the facility
  final String addressOrCoordinates;
  
  /// Type of location (urban, peri-urban, rural)
  final FacilityLocationType locationType;

  const GeoLocation({
    required this.country,
    required this.regionProvince,
    required this.district,
    required this.cityVillage,
    required this.addressOrCoordinates,
    required this.locationType,
  });

  @override
  List<Object> get props => [
    country, 
    regionProvince, 
    district, 
    cityVillage, 
    addressOrCoordinates, 
    locationType
  ];
}