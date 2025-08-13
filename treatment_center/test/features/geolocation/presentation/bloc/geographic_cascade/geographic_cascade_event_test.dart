import 'package:flutter_test/flutter_test.dart';

import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_event.dart';

void main() {
  group('GeographicCascadeEvent (Equatable)', () {
    test('InitializeGeographicCascade equality with same values', () {
      const a = InitializeGeographicCascade(
        savedCountryName: 'Italy',
        savedRegionName: 'Lombardy',
        savedCityName: 'Milan',
      );
      const b = InitializeGeographicCascade(
        savedCountryName: 'Italy',
        savedRegionName: 'Lombardy',
        savedCityName: 'Milan',
      );
      expect(a, equals(b));
      expect(a.props, ['Italy', 'Lombardy', 'Milan']);
    });

    test('InitializeGeographicCascade inequality with different values', () {
      const a = InitializeGeographicCascade(
        savedCountryName: 'Italy',
        savedRegionName: 'Lombardy',
        savedCityName: 'Milan',
      );
      const b = InitializeGeographicCascade(
        savedCountryName: 'Iran',
        savedRegionName: 'Tehran',
        savedCityName: 'Tehran',
      );
      expect(a, isNot(equals(b)));
    });

    test('SelectCountry equality uses the same CountryEntity instance', () {
      final c = CountryFake();
      expect(SelectCountry(c), equals(SelectCountry(c)));
    });

    test('SelectCountry inequality with different CountryEntity instances', () {
      expect(
        SelectCountry(CountryFake()),
        isNot(equals(SelectCountry(CountryFake()))),
      );
    });

    test('SelectCountry supports null and equals with null', () {
      const a = SelectCountry(null);
      const b = SelectCountry(null);
      expect(a, equals(b));
      expect(a.props, [null]);
    });

    test('SelectRegion equality/inequality mirrors RegionEntity instance', () {
      final r = RegionFake();
      expect(SelectRegion(r), equals(SelectRegion(r)));
      expect(
        SelectRegion(RegionFake()),
        isNot(equals(SelectRegion(RegionFake()))),
      );
    });

    test('SelectCity equality/inequality mirrors CityEntity instance', () {
      final c = CityFake();
      expect(SelectCity(c), equals(SelectCity(c)));
      expect(SelectCity(CityFake()), isNot(equals(SelectCity(CityFake()))));
    });

    test('ResetGeographicCascade instances are equal (stateless)', () {
      expect(
        const ResetGeographicCascade(),
        equals(const ResetGeographicCascade()),
      );
      expect(const ResetGeographicCascade().props, isEmpty);
    });

    test('LoadCountries instances are equal (stateless)', () {
      expect(const LoadCountries(), equals(const LoadCountries()));
      expect(const LoadCountries().props, isEmpty);
    });

    test('LoadRegions equality/inequality mirrors CountryEntity instance', () {
      final c = CountryFake();
      expect(LoadRegions(c), equals(LoadRegions(c)));
      expect(
        LoadRegions(CountryFake()),
        isNot(equals(LoadRegions(CountryFake()))),
      );
    });

    test('LoadCities equality/inequality mirrors RegionEntity instance', () {
      final r = RegionFake();
      expect(LoadCities(r), equals(LoadCities(r)));
      expect(LoadCities(RegionFake()), isNot(equals(LoadCities(RegionFake()))));
    });
  });
}

// ---- Fakes using mockito ----
class CountryFake extends Fake implements CountryEntity {}

class RegionFake extends Fake implements RegionEntity {}

class CityFake extends Fake implements CityEntity {}
