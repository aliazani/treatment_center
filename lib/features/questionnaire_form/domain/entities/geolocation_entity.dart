import 'package:equatable/equatable.dart';

/// Facility location type enum
enum FacilityLocationType { urban, periUrban, rural }

/// Represents geographical location information of the facility
class GeoLocationEntity extends Equatable {
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

  /// Latitude coordinate (NEW FIELD)
  final double? latitude;

  /// Longitude coordinate (NEW FIELD)
  final double? longitude;

  /// Type of location (urban, peri-urban, rural)
  final FacilityLocationType? locationType;

  const GeoLocationEntity({
    required this.country,
    required this.regionProvince,
    required this.district,
    required this.cityVillage,
    required this.addressOrCoordinates,
    this.latitude, // NEW FIELD
    this.longitude, // NEW FIELD
    required this.locationType,
  });

  @override
  List<Object?> get props => [
    country,
    regionProvince,
    district,
    cityVillage,
    addressOrCoordinates,
    latitude, // NEW FIELD
    longitude, // NEW FIELD
    locationType,
  ];
}
