import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_phone_code_by_country.dart';

import 'get_phone_code_by_country_test.mocks.dart';

@GenerateMocks([GeographicRepository])
void main() {
  late MockGeographicRepository repo;
  late GetPhoneCodeByCountry usecase;

  setUpAll(() {
    // Mockito needs a dummy Either for generated mocks with this return type
    provideDummy<Either<Failure, CountryPhoneCodeEntity?>>(
      const Right<Failure, CountryPhoneCodeEntity?>(null),
    );
  });

  setUp(() {
    repo = MockGeographicRepository();
    usecase = GetPhoneCodeByCountry(repo);
  });

  // Sample entity
  const iran = CountryPhoneCodeEntity(
    country: 'Iran',
    code: '+98',
    flag: '🇮🇷',
    iso2: 'IR',
  );

  group('GetPhoneCodeByCountry', () {
    test('forwards countryName and returns Right(entity) when found', () async {
      // arrange
      when(
        repo.getPhoneCodeByCountry('Iran'),
      ).thenAnswer((_) async => const Right(iran));

      // act
      final result = await usecase(
        const PhoneCodeByCountryParams(countryName: 'Iran'),
      );

      // assert
      expect(result.isRight(), isTrue);
      result.match((l) => fail('Expected Right, got $l'), (r) {
        expect(r, isNotNull);
        expect(r!.country, 'Iran');
        expect(r.code, '+98');
        expect(r.iso2, 'IR');
      });
      verify(repo.getPhoneCodeByCountry('Iran')).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('returns Right(null) when not found', () async {
      // arrange
      when(
        repo.getPhoneCodeByCountry('Narnia'),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(
        const PhoneCodeByCountryParams(countryName: 'Narnia'),
      );

      // assert
      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('Expected Right, got $l'),
        (r) => expect(r, isNull),
      );
      verify(repo.getPhoneCodeByCountry('Narnia')).called(1);
    });

    test('returns Left(CacheFailure) when repository fails', () async {
      // arrange
      when(
        repo.getPhoneCodeByCountry('Italy'),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'cache oops')));

      // act
      final result = await usecase(
        const PhoneCodeByCountryParams(countryName: 'Italy'),
      );

      // assert
      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
      verify(repo.getPhoneCodeByCountry('Italy')).called(1);
    });
  });

  group('PhoneCodeByCountryParams (Equatable)', () {
    test('value equality with same countryName', () {
      const a = PhoneCodeByCountryParams(countryName: 'Iran');
      const b = PhoneCodeByCountryParams(countryName: 'Iran');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different countryName', () {
      const a = PhoneCodeByCountryParams(countryName: 'Iran');
      const b = PhoneCodeByCountryParams(countryName: 'Italy');
      expect(a == b, isFalse);
    });

    test('props contains [countryName] in order', () {
      const p = PhoneCodeByCountryParams(countryName: 'Italy');
      expect(p.props, ['Italy']);
    });
  });
}
