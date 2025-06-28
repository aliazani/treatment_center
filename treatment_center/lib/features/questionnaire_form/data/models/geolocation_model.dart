import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';

class GeoLocationModel extends GeoLocationEntity {
  const GeoLocationModel({
    required super.country,
    required super.regionProvince,
    required super.district,
    required super.cityVillage,
    required super.addressOrCoordinates,
    required super.locationType,
  });

  factory GeoLocationModel.fromJson(Map<String, dynamic> json) {
    return GeoLocationModel(
      country: json['country'],
      regionProvince: json['region_province'],
      district: json['district'],
      cityVillage: json['city_village'],
      addressOrCoordinates: json['address_or_coordinates'],
      locationType: FacilityLocationType.values[json['location_type']],
    );
  }

  factory GeoLocationModel.fromEntity(GeoLocationEntity location) {
    return GeoLocationModel(
      country: location.country,
      regionProvince: location.regionProvince,
      district: location.district,
      cityVillage: location.cityVillage,
      addressOrCoordinates: location.addressOrCoordinates,
      locationType: location.locationType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'region_province': regionProvince,
      'district': district,
      'city_village': cityVillage,
      'address_or_coordinates': addressOrCoordinates,
      'location_type': locationType.index,
    };
  }
}
