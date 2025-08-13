import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.name,
    required super.stateCode,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      stateCode: json['state_code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'state_code': stateCode,
  };

  factory CityModel.fromEntity(CityEntity city) =>
      CityModel(id: city.id, name: city.name, stateCode: city.stateCode);
}
