import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/presentation/widgets/geographic_dropdowns_widget.dart';

enum HydrationStatus { idle, hydrating, completed, failed }

class GeographicCascadeState extends Equatable {
  // Data
  final List<CountryEntity> countries;
  final List<RegionEntity> regions;
  final List<CityEntity> cities;
  final GeographicSelection selection;

  // Loading states
  final bool loadingCountries;
  final bool loadingRegions;
  final bool loadingCities;

  // Error states
  final String? countriesError;
  final String? regionsError;
  final String? citiesError;

  // Hydration state
  final HydrationStatus hydrationStatus;
  final String? hydrationError;

  // Track what we're trying to hydrate
  final String? targetCountryName;
  final String? targetRegionName;
  final String? targetCityName;

  const GeographicCascadeState({
    this.countries = const [],
    this.regions = const [],
    this.cities = const [],
    this.selection = const GeographicSelection(),
    this.loadingCountries = false,
    this.loadingRegions = false,
    this.loadingCities = false,
    this.countriesError,
    this.regionsError,
    this.citiesError,
    this.hydrationStatus = HydrationStatus.idle,
    this.hydrationError,
    this.targetCountryName,
    this.targetRegionName,
    this.targetCityName,
  });

  @override
  List<Object?> get props => [
    countries,
    regions,
    cities,
    selection,
    loadingCountries,
    loadingRegions,
    loadingCities,
    countriesError,
    regionsError,
    citiesError,
    hydrationStatus,
    hydrationError,
    targetCountryName,
    targetRegionName,
    targetCityName,
  ];

  GeographicCascadeState copyWith({
    List<CountryEntity>? countries,
    List<RegionEntity>? regions,
    List<CityEntity>? cities,
    GeographicSelection? selection,
    bool? loadingCountries,
    bool? loadingRegions,
    bool? loadingCities,
    String? countriesError,
    String? regionsError,
    String? citiesError,
    HydrationStatus? hydrationStatus,
    String? hydrationError,
    String? targetCountryName,
    String? targetRegionName,
    String? targetCityName,

    // Allow clearing errors
    bool clearCountriesError = false,
    bool clearRegionsError = false,
    bool clearCitiesError = false,
    bool clearHydrationError = false,
    bool clearTargets = false,
  }) {
    return GeographicCascadeState(
      countries: countries ?? this.countries,
      regions: regions ?? this.regions,
      cities: cities ?? this.cities,
      selection: selection ?? this.selection,
      loadingCountries: loadingCountries ?? this.loadingCountries,
      loadingRegions: loadingRegions ?? this.loadingRegions,
      loadingCities: loadingCities ?? this.loadingCities,
      countriesError:
          clearCountriesError ? null : (countriesError ?? this.countriesError),
      regionsError:
          clearRegionsError ? null : (regionsError ?? this.regionsError),
      citiesError: clearCitiesError ? null : (citiesError ?? this.citiesError),
      hydrationStatus: hydrationStatus ?? this.hydrationStatus,
      hydrationError:
          clearHydrationError ? null : (hydrationError ?? this.hydrationError),
      targetCountryName:
          clearTargets ? null : (targetCountryName ?? this.targetCountryName),
      targetRegionName:
          clearTargets ? null : (targetRegionName ?? this.targetRegionName),
      targetCityName:
          clearTargets ? null : (targetCityName ?? this.targetCityName),
    );
  }

  /// Convenience getters for UI
  bool get isInitialized => countries.isNotEmpty;
  bool get isHydrating => hydrationStatus == HydrationStatus.hydrating;
  bool get isHydrationComplete => hydrationStatus == HydrationStatus.completed;
  bool get hasHydrationFailed => hydrationStatus == HydrationStatus.failed;
  bool get hasAnyError =>
      countriesError != null ||
      regionsError != null ||
      citiesError != null ||
      hydrationError != null;
  bool get isLoading => loadingCountries || loadingRegions || loadingCities;

  @override
  String toString() {
    return 'GeographicCascadeState('
        'countries: ${countries.length}, '
        'regions: ${regions.length}, '
        'cities: ${cities.length}, '
        'selection: $selection, '
        'hydrationStatus: $hydrationStatus'
        ')';
  }
}
