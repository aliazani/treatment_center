import 'package:treatment_center/features/geolocation/data/models/city_model.dart';
import 'package:treatment_center/features/geolocation/data/models/country_model.dart';
import 'package:treatment_center/features/geolocation/data/models/region_model.dart';

abstract class GeographicLocalDataSource {
  /// Gets the cached [CountryModel] list from assets
  /// Throws [CacheException] if loading fails
  Future<List<CountryModel>> getCountries();

  /// Gets the cached [RegionModel] list from assets
  /// Throws [CacheException] if loading fails
  Future<List<RegionModel>> getStates();

  /// Gets the cached [CityModel] list from assets
  /// Throws [CacheException] if loading fails
  Future<List<CityModel>> getCities();
}
