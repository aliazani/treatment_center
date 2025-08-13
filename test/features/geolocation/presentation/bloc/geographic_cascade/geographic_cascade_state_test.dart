import 'package:flutter_test/flutter_test.dart';

import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_state.dart';
import 'package:treatment_center/features/geolocation/presentation/widgets/geographic_dropdowns_widget.dart';


void main() {
  group('GeographicCascadeState', () {
    test('default constructor has expected defaults', () {
      const state = GeographicCascadeState();

      expect(state.countries, isEmpty);
      expect(state.regions, isEmpty);
      expect(state.cities, isEmpty);
      expect(state.selection, equals(const GeographicSelection()));
      expect(state.loadingCountries, isFalse);
      expect(state.loadingRegions, isFalse);
      expect(state.loadingCities, isFalse);
      expect(state.countriesError, isNull);
      expect(state.regionsError, isNull);
      expect(state.citiesError, isNull);
      expect(state.hydrationStatus, HydrationStatus.idle);
      expect(state.hydrationError, isNull);
      expect(state.targetCountryName, isNull);
      expect(state.targetRegionName, isNull);
      expect(state.targetCityName, isNull);

      // convenience getters
      expect(state.isInitialized, isFalse);
      expect(state.isHydrating, isFalse);
      expect(state.isHydrationComplete, isFalse);
      expect(state.hasHydrationFailed, isFalse);
      expect(state.hasAnyError, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('equatable equality with identical references', () {
      final countries = [CountryFake()];
      final regions = [RegionFake()];
      final cities = [CityFake()];
      const selection = GeographicSelection();

      final a = GeographicCascadeState(
        countries: countries,
        regions: regions,
        cities: cities,
        selection: selection,
        loadingCountries: true,
        loadingRegions: false,
        loadingCities: true,
        countriesError: 'errC',
        regionsError: 'errR',
        citiesError: 'errCi',
        hydrationStatus: HydrationStatus.hydrating,
        hydrationError: 'hErr',
        targetCountryName: 'Italy',
        targetRegionName: 'Lombardy',
        targetCityName: 'Milan',
      );

      // Use the SAME list and selection references to satisfy Equatable equality
      final b = GeographicCascadeState(
        countries: countries,
        regions: regions,
        cities: cities,
        selection: selection,
        loadingCountries: true,
        loadingRegions: false,
        loadingCities: true,
        countriesError: 'errC',
        regionsError: 'errR',
        citiesError: 'errCi',
        hydrationStatus: HydrationStatus.hydrating,
        hydrationError: 'hErr',
        targetCountryName: 'Italy',
        targetRegionName: 'Lombardy',
        targetCityName: 'Milan',
      );

      expect(a, equals(b));
      // spot-check props ordering/content
      expect(a.props.first, same(countries));
    });

    test('equatable inequality when a single field differs', () {
      final base = GeographicCascadeState(countries: [CountryFake()]);

      expect(base, isNot(equals(base.copyWith(loadingCountries: true))));
    });

    test('copyWith overrides simple fields', () {
      const base = GeographicCascadeState();

      final next = base.copyWith(
        countries: [CountryFake()],
        regions: [RegionFake()],
        cities: [CityFake()],
        selection: const GeographicSelection(),
        loadingCountries: true,
        loadingRegions: true,
        loadingCities: true,
        countriesError: 'C',
        regionsError: 'R',
        citiesError: 'Ci',
        hydrationStatus: HydrationStatus.hydrating,
        hydrationError: 'H',
        targetCountryName: 'Italy',
        targetRegionName: 'Lombardy',
        targetCityName: 'Milan',
      );

      expect(next.countries, isNotEmpty);
      expect(next.regions, isNotEmpty);
      expect(next.cities, isNotEmpty);
      expect(next.loadingCountries, isTrue);
      expect(next.loadingRegions, isTrue);
      expect(next.loadingCities, isTrue);
      expect(next.countriesError, 'C');
      expect(next.regionsError, 'R');
      expect(next.citiesError, 'Ci');
      expect(next.hydrationStatus, HydrationStatus.hydrating);
      expect(next.hydrationError, 'H');
      expect(next.targetCountryName, 'Italy');
      expect(next.targetRegionName, 'Lombardy');
      expect(next.targetCityName, 'Milan');

      // convenience getters reflect new state
      expect(next.isInitialized, isTrue);
      expect(next.isHydrating, isTrue);
      expect(next.isLoading, isTrue);
      expect(next.hasAnyError, isTrue);
    });

    test('copyWith clear flags nullify respective fields', () {
      final seeded = GeographicCascadeState(
        countriesError: 'C',
        regionsError: 'R',
        citiesError: 'Ci',
        hydrationError: 'H',
        targetCountryName: 'Italy',
        targetRegionName: 'Lombardy',
        targetCityName: 'Milan',
      );

      final cleared = seeded.copyWith(
        clearCountriesError: true,
        clearRegionsError: true,
        clearCitiesError: true,
        clearHydrationError: true,
        clearTargets: true,
      );

      expect(cleared.countriesError, isNull);
      expect(cleared.regionsError, isNull);
      expect(cleared.citiesError, isNull);
      expect(cleared.hydrationError, isNull);
      expect(cleared.targetCountryName, isNull);
      expect(cleared.targetRegionName, isNull);
      expect(cleared.targetCityName, isNull);
    });

    test('copyWith respects clear flags even if new values provided', () {
      final seeded = GeographicCascadeState(
        countriesError: 'oldC',
        regionsError: 'oldR',
        citiesError: 'oldCi',
        hydrationError: 'oldH',
        targetCountryName: 'OldCountry',
        targetRegionName: 'OldRegion',
        targetCityName: 'OldCity',
      );

      // Even if we pass new values, clear flags should win and set to null
      final cleared = seeded.copyWith(
        countriesError: 'newC',
        regionsError: 'newR',
        citiesError: 'newCi',
        hydrationError: 'newH',
        targetCountryName: 'NewCountry',
        targetRegionName: 'NewRegion',
        targetCityName: 'NewCity',
        clearCountriesError: true,
        clearRegionsError: true,
        clearCitiesError: true,
        clearHydrationError: true,
        clearTargets: true,
      );

      expect(cleared.countriesError, isNull);
      expect(cleared.regionsError, isNull);
      expect(cleared.citiesError, isNull);
      expect(cleared.hydrationError, isNull);
      expect(cleared.targetCountryName, isNull);
      expect(cleared.targetRegionName, isNull);
      expect(cleared.targetCityName, isNull);
    });

    test('toString summarizes counts and status', () {
      final s =
          GeographicCascadeState(
            countries: [CountryFake()],
            regions: [RegionFake()],
            cities: [CityFake()],
            hydrationStatus: HydrationStatus.completed,
          ).toString();

      expect(s, contains('countries: 1'));
      expect(s, contains('regions: 1'));
      expect(s, contains('cities: 1'));
      expect(s, contains('hydrationStatus: HydrationStatus.completed'));
    });
  });
}

// ---- Lightweight fakes (no stubbing needed) ----
class CountryFake extends Fake implements CountryEntity {}

class RegionFake extends Fake implements RegionEntity {}

class CityFake extends Fake implements CityEntity {}