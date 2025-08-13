import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';

class CountryModel extends CountryEntity {
  const CountryModel({
    required super.id,
    required super.name,
    required super.iso2,
    required super.emoji,
    required super.phonecode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
    id: json['id'] as int,
    name: json['name'] as String,
    iso2: json['iso2'] as String,
    emoji: json['emoji'] as String,
    phonecode: json['phonecode'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iso2': iso2,
    'emoji': emoji,
    'phonecode': phonecode,
  };

  factory CountryModel.fromEntity(CountryEntity country) => CountryModel(
    id: country.id,
    name: country.name,
    iso2: country.iso2,
    emoji: country.emoji,
    phonecode: country.phonecode,
  );
}
