import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/features/geolocation/data/datasources/geographic_local_data_source.dart';
import 'package:treatment_center/features/geolocation/data/models/city_model.dart';
import 'package:treatment_center/features/geolocation/data/models/country_model.dart';
import 'package:treatment_center/features/geolocation/data/models/region_model.dart';

class GeographicLocalDataSourceImpl implements GeographicLocalDataSource {
  GeographicLocalDataSourceImpl({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;

  static List<CountryModel>? _cachedCountries;
  static List<RegionModel>? _cachedStates;
  static List<CityModel>? _cachedCities;

  @override
  Future<List<CountryModel>> getCountries() async {
    if (_cachedCountries != null) return _cachedCountries!;
    try {
      final raw = await _bundle.loadString('assets/geolocation/countries.json');
      final list =
          (json.decode(raw) as List)
              .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
              .toList();
      return _cachedCountries = list;
    } catch (_) {
      throw CacheException(
        message: 'Failed to load countries from assets',
        s: null,
      );
    }
  }

  @override
  Future<List<RegionModel>> getStates() async {
    if (_cachedStates != null) return _cachedStates!;
    try {
      final raw = await _bundle.loadString('assets/geolocation/states.json');
      final list =
          (json.decode(raw) as List)
              .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
              .toList();
      return _cachedStates = list;
    } catch (_) {
      throw CacheException(
        message: 'Failed to load states from assets',
        s: null,
      );
    }
  }

  @override
  Future<List<CityModel>> getCities() async {
    if (_cachedCities != null) return _cachedCities!;
    try {
      final raw = await _bundle.loadString('assets/geolocation/cities.json');
      final list =
          (json.decode(raw) as List)
              .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
              .toList();
      return _cachedCities = list;
    } catch (_) {
      throw CacheException(
        message: 'Failed to load cities from assets',
        s: null,
      );
    }
  }

  @visibleForTesting
  static void clearCaches() {
    _cachedCountries = null;
    _cachedStates = null;
    _cachedCities = null;
  }
}
