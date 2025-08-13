import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';

import 'package:treatment_center/features/geolocation/data/datasources/geographic_local_data_source.dart';
import 'package:treatment_center/features/geolocation/data/models/city_model.dart';
import 'package:treatment_center/features/geolocation/data/models/country_model.dart';
import 'package:treatment_center/features/geolocation/data/models/region_model.dart';

import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/data/repositories/geographic_repository_impl.dart';

import 'geographic_repository_impl_test.mocks.dart';

@GenerateMocks([GeographicLocalDataSource])
void main() {
  late GeographicRepositoryImpl repo;
  late MockGeographicLocalDataSource local;

  setUp(() {
    local = MockGeographicLocalDataSource();
    repo = GeographicRepositoryImpl(localDataSource: local);
  });

  // ----- Sample data (Models implement the domain entity interfaces) -----
  final it = CountryModel(
    id: 1,
    name: 'Italy',
    iso2: 'IT',
    emoji: '🇮🇹',
    phonecode: '39',
  );
  final ir = CountryModel(
    id: 2,
    name: 'Iran',
    iso2: 'IR',
    emoji: '🇮🇷',
    phonecode: '98',
  );

  final lombardy = RegionModel(
    id: 10,
    name: 'Lombardy',
    countryCode: 'IT',
    stateCode: 'IT-25',
  );
  final tehranProv = RegionModel(
    id: 11,
    name: 'Tehran Province',
    countryCode: 'IR',
    stateCode: 'IR-23',
  );

  // City codes crafted to exercise normalization logic
  final milan = CityModel(
    id: 100,
    name: 'Milan',
    stateCode: '25', // matches input "25"
  );
  final bdsCity = CityModel(
    id: 101,
    name: 'Bodoshan',
    stateCode: 'bds', // matches input "AF-BDS"
  );
  final tehranCity = CityModel(
    id: 102,
    name: 'Tehran',
    stateCode: 'IR-23', // will NOT match normalized "23"
  );

  group('getCountries', () {
    test('returns Right(list) on success', () async {
      when(local.getCountries()).thenAnswer((_) async => [it, ir]);

      final res = await repo.getCountries();

      expect(res.isRight(), isTrue);
      res.match((l) => fail('Expected Right, got $l'), (r) {
        expect(r, hasLength(2));
        expect(r.first.name, 'Italy');
      });
      verify(local.getCountries()).called(1);
      verifyNoMoreInteractions(local);
    });

    test('CacheException -> CacheFailure', () async {
      when(
        local.getCountries(),
      ).thenThrow(CacheException(message: 'x', s: null));

      final res = await repo.getCountries();

      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('Unexpected -> UnexpectedFailure', () async {
      when(local.getCountries()).thenThrow(ArgumentError('boom'));

      final res = await repo.getCountries();

      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getStates', () {
    test('Right(list) on success', () async {
      when(local.getStates()).thenAnswer((_) async => [lombardy, tehranProv]);

      final res = await repo.getStates();

      expect(res.isRight(), isTrue);
      res.match((_) => fail('Expected Right'), (r) {
        expect(r, hasLength(2));
        expect(r.first.name, 'Lombardy');
      });
    });

    test('CacheException -> CacheFailure', () async {
      when(local.getStates()).thenThrow(CacheException(message: '', s: null));

      final res = await repo.getStates();
      expect(res.getLeft().toNullable(), isA<CacheFailure>());
    });
    test('Unexpected -> UnexpectedFailure', () async {
      when(local.getStates()).thenThrow(StateError('boom'));
      final res = await repo.getStates();
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getCities', () {
    test('Right(list) on success', () async {
      when(local.getCities()).thenAnswer((_) async => [milan, tehranCity]);

      final res = await repo.getCities();

      expect(res.isRight(), isTrue);
      res.match((_) => fail('Expected Right'), (r) => expect(r, hasLength(2)));
    });

    test('CacheException -> CacheFailure', () async {
      when(local.getCities()).thenThrow(CacheException(message: '', s: null));

      final res = await repo.getCities();
      expect(res.getLeft().toNullable(), isA<CacheFailure>());
    });
    test('Unexpected -> UnexpectedFailure', () async {
      when(local.getCities()).thenThrow(ArgumentError('yikes'));
      final res = await repo.getCities();
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getStatesByCountry', () {
    test('filters by countryCode', () async {
      when(local.getStates()).thenAnswer((_) async => [lombardy, tehranProv]);

      final res = await repo.getStatesByCountry('IT');

      res.match((l) => fail('Expected Right'), (r) {
        expect(r, hasLength(1));
        expect(r.single.name, 'Lombardy');
      });
    });

    test('CacheException -> CacheFailure', () async {
      when(local.getStates()).thenThrow(CacheException(message: '', s: null));

      final res = await repo.getStatesByCountry('IT');
      expect(res.getLeft().toNullable(), isA<CacheFailure>());
    });
    test('Unexpected -> UnexpectedFailure', () async {
      when(local.getStates()).thenThrow(Exception('kaboom'));
      final res = await repo.getStatesByCountry('IT');
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getCitiesByState', () {
    test('matches plain state code (no hyphen)', () async {
      when(
        local.getCities(),
      ).thenAnswer((_) async => [milan, bdsCity, tehranCity]);

      final res = await repo.getCitiesByState('25');

      res.match((l) => fail('Expected Right'), (r) {
        expect(r.map((c) => c.name), contains('Milan'));
        expect(r.every((c) => c.stateCode.toLowerCase() == '25'), isTrue);
      });
    });

    test(
      'normalizes hyphenated code to last segment (case-insensitive)',
      () async {
        when(
          local.getCities(),
        ).thenAnswer((_) async => [milan, bdsCity, tehranCity]);

        final res = await repo.getCitiesByState('AF-BDS');

        res.match((l) => fail('Expected Right'), (r) {
          expect(r, hasLength(1));
          expect(r.single.name, 'Bodoshan');
        });
      },
    );

    test('CacheException -> CacheFailure', () async {
      when(local.getCities()).thenThrow(CacheException(message: '', s: null));

      final res = await repo.getCitiesByState('IT-25');
      expect(res.getLeft().toNullable(), isA<CacheFailure>());
    });
    test('Unexpected -> UnexpectedFailure', () async {
      when(local.getCities()).thenThrow(FormatException('nope'));
      final res = await repo.getCitiesByState('AF-BDS');
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getCountryCodes', () {
    test('maps → CountryPhoneCodeEntity and sorts by country name', () async {
      // Reverse order to ensure sorting occurs
      when(local.getCountries()).thenAnswer((_) async => [ir, it]);

      final res = await repo.getCountryCodes();

      res.match((l) => fail('Expected Right'), (r) {
        expect(r, hasLength(2));
        // Sorted ascending by country name: Iran, Italy
        expect(r.first.country, 'Iran');
        expect(r.first.code, '+98');
        expect(r.first.flag, '🇮🇷');
        expect(r.first.iso2, 'IR');

        expect(r.last.country, 'Italy');
        expect(r.last.code, '+39');
        expect(r.last.flag, '🇮🇹');
        expect(r.last.iso2, 'IT');
      });
    });

    test('CacheException -> CacheFailure', () async {
      when(
        local.getCountries(),
      ).thenThrow(CacheException(message: '', s: null));

      final res = await repo.getCountryCodes();
      expect(res.getLeft().toNullable(), isA<CacheFailure>());
    });
    test('Unexpected -> UnexpectedFailure', () async {
      when(local.getCountries()).thenThrow(UnsupportedError('ouch'));
      final res = await repo.getCountryCodes();
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getPhoneCodeByCountry', () {
    test('Right(entity) when country exists (case-insensitive)', () async {
      when(local.getCountries()).thenAnswer((_) async => [it, ir]);

      final res = await repo.getPhoneCodeByCountry('iran');

      res.match((l) => fail('Expected Right'), (r) {
        expect(r, isA<CountryPhoneCodeEntity?>());
        final v = r!;
        expect(v.country, 'Iran');
        expect(v.code, '+98');
        expect(v.flag, '🇮🇷');
        expect(v.iso2, 'IR');
      });
    });

    test('Right(null) when not found', () async {
      when(local.getCountries()).thenAnswer((_) async => [it]);

      final res = await repo.getPhoneCodeByCountry('Narnia');

      res.match((l) => fail('Expected Right'), (r) => expect(r, isNull));
    });

    test('CacheException -> CacheFailure', () async {
      when(
        local.getCountries(),
      ).thenThrow(CacheException(message: '', s: null));

      final res = await repo.getPhoneCodeByCountry('Italy');
      expect(res.getLeft().toNullable(), isA<CacheFailure>());
    });
    test('Unexpected -> UnexpectedFailure', () async {
      when(local.getCountries()).thenThrow(FormatException('weird'));
      final res = await repo.getPhoneCodeByCountry('Italy');
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
