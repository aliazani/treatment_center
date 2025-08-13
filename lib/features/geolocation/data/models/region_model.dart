import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';

class RegionModel extends RegionEntity {
  const RegionModel({
    required super.id,
    required super.name,
    required super.countryCode,
    required super.stateCode,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
    id: json['id'] as int,
    name: json['name'] as String,
    countryCode: json['country_code'] as String,
    stateCode: json['iso3166_2'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country_code': countryCode,
    'iso3166_2': stateCode,
  };

  factory RegionModel.fromEntity(RegionEntity state) => RegionModel(
    id: state.id,
    name: state.name,
    countryCode: state.countryCode,
    stateCode: state.stateCode,
  );
}
