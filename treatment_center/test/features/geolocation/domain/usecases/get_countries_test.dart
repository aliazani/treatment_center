import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_countries.dart';

import 'get_countries_test.mocks.dart';

@GenerateMocks([GeographicRepository])
void main() {
  late MockGeographicRepository repo;
  late GetCountries usecase;

  setUpAll(() {
    // Mockito needs a dummy Either for generated mocks
    provideDummy<Either<Failure, List<CountryEntity>>>(
      Right(const <CountryEntity>[]),
    );
  });

  setUp(() {
    repo = MockGeographicRepository();
    usecase = GetCountries(repo);
  });

  // Sample data
  const it = CountryEntity(
    id: 1,
    name: 'Italy',
    iso2: 'IT',
    emoji: '🇮🇹',
    phonecode: '39',
  );
  const ir = CountryEntity(
    id: 2,
    name: 'Iran',
    iso2: 'IR',
    emoji: '🇮🇷',
    phonecode: '98',
  );
  const countries = <CountryEntity>[it, ir];

  group('GetCountries', () {
    test('returns Right(list) on success and calls repository once', () async {
      // arrange
      when(repo.getCountries()).thenAnswer((_) async => Right(countries));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result.isRight(), isTrue);
      result.match((l) => fail('Expected Right, got $l'), (r) {
        expect(r, hasLength(2));
        expect(r.first.name, 'Italy');
        expect(r.last.iso2, 'IR');
      });
      verify(repo.getCountries()).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('returns Left(CacheFailure) when repository fails', () async {
      // arrange
      when(
        repo.getCountries(),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'cache oops')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
      verify(repo.getCountries()).called(1);
    });
  });
}
