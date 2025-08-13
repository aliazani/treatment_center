import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';

abstract class GeographicCascadeEvent extends Equatable {
  const GeographicCascadeEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the cascade with optional saved values for hydration
class InitializeGeographicCascade extends GeographicCascadeEvent {
  final String? savedCountryName;
  final String? savedRegionName;
  final String? savedCityName;

  const InitializeGeographicCascade({
    this.savedCountryName,
    this.savedRegionName,
    this.savedCityName,
  });

  @override
  List<Object?> get props => [savedCountryName, savedRegionName, savedCityName];
}

/// User manually selects a country
class SelectCountry extends GeographicCascadeEvent {
  final CountryEntity? country;

  const SelectCountry(this.country);

  @override
  List<Object?> get props => [country];
}

/// User manually selects a region
class SelectRegion extends GeographicCascadeEvent {
  final RegionEntity? region;

  const SelectRegion(this.region);

  @override
  List<Object?> get props => [region];
}

/// User manually selects a city
class SelectCity extends GeographicCascadeEvent {
  final CityEntity? city;

  const SelectCity(this.city);

  @override
  List<Object?> get props => [city];
}

/// Reset the entire cascade
class ResetGeographicCascade extends GeographicCascadeEvent {
  const ResetGeographicCascade();
}

/// Internal events (not exposed to UI)
class LoadCountries extends GeographicCascadeEvent {
  const LoadCountries();
}

class LoadRegions extends GeographicCascadeEvent {
  final CountryEntity country;

  const LoadRegions(this.country);

  @override
  List<Object?> get props => [country];
}

class LoadCities extends GeographicCascadeEvent {
  final RegionEntity region;

  const LoadCities(this.region);

  @override
  List<Object?> get props => [region];
}
