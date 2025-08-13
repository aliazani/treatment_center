import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';

class GeoLocationModel extends GeoLocationEntity {
  const GeoLocationModel({
    required super.country,
    required super.regionProvince,
    required super.district,
    required super.cityVillage,
    required super.addressOrCoordinates,
    required super.latitude,
    required super.longitude,
    required super.locationType,
  });

  /// Factory constructor to create GeoLocationModel from JSON
  /// Used for deserializing data from APIs or local storage
  factory GeoLocationModel.fromJson(Map<String, dynamic> json) {
    return GeoLocationModel(
      country: json['country'] ?? '',
      regionProvince: json['region_province'] ?? '',
      district: json['district'] ?? '',
      cityVillage: json['city_village'] ?? '',
      addressOrCoordinates: json['address_or_coordinates'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationType:
          json['location_type'] != null
              ? FacilityLocationType.values[json['location_type']]
              : FacilityLocationType.urban,
    );
  }

  /// Factory constructor to create GeoLocationModel from GeoLocationEntity
  /// Useful for converting domain entities to data models
  factory GeoLocationModel.fromEntity(GeoLocationEntity location) {
    return GeoLocationModel(
      country: location.country,
      regionProvince: location.regionProvince,
      district: location.district,
      cityVillage: location.cityVillage,
      addressOrCoordinates: location.addressOrCoordinates,
      latitude: location.latitude,
      longitude: location.longitude,
      locationType: location.locationType,
    );
  }

  /// Converts GeoLocationModel back to GeoLocationEntity
  /// Useful for converting data models to domain entities
  GeoLocationEntity toEntity() {
    return GeoLocationEntity(
      country: country,
      regionProvince: regionProvince,
      district: district,
      cityVillage: cityVillage,
      addressOrCoordinates: addressOrCoordinates,
      latitude: latitude,
      longitude: longitude,
      locationType: locationType,
    );
  }

  /// Converts GeoLocationModel to JSON
  /// Used for serializing data to APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'region_province': regionProvince,
      'district': district,
      'city_village': cityVillage,
      'address_or_coordinates': addressOrCoordinates,
      'latitude': latitude,
      'longitude': longitude,
      'location_type': locationType?.index,
    };
  }
}
