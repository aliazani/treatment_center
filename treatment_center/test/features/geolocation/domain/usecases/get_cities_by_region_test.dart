import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_cities_by_region.dart';

import 'get_cities_by_region_test.mocks.dart';

@GenerateMocks([GeographicRepository])
void main() {
  late MockGeographicRepository repo;
  late GetCitiesByRegion usecase; // or GetCitiesByState if that’s the class name

  setUpAll(() {
    provideDummy<Either<Failure, List<CityEntity>>>(
      Right(const <CityEntity>[]),
    );
  });

  setUp(() {
    repo = MockGeographicRepository();
    usecase = GetCitiesByRegion(repo); // or GetCitiesByState(repo)
  });

  const city1 = CityEntity(id: 1, name: 'Milan', stateCode: 'IT-25');
  const city2 = CityEntity(id: 2, name: 'Bergamo', stateCode: 'IT-25');
  const cities = <CityEntity>[city1, city2];

  group('GetCitiesByState', () {
    test('forwards stateCode and returns Right(list) on success', () async {
      when(repo.getCitiesByState('IT-25'))
          .thenAnswer((_) async => Right(cities));

      final result =
          await usecase(const CitiesByStateParams(stateCode: 'IT-25'));

      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('Expected Right, got $l'),
        (r) {
          expect(r, hasLength(2));
          expect(r.first.name, 'Milan');
        },
      );
      verify(repo.getCitiesByState('IT-25')).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('returns Left(CacheFailure) when repository fails', () async {
      when(repo.getCitiesByState('IT-25'))
          .thenAnswer((_) async => Left(CacheFailure(message: 'cache oops')));

      final result =
          await usecase(const CitiesByStateParams(stateCode: 'IT-25'));

      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
      verify(repo.getCitiesByState('IT-25')).called(1);
    });
  });

  group('CitiesByStateParams (Equatable)', () {
    test('value equality with same stateCode', () {
      const a = CitiesByStateParams(stateCode: 'IT-25');
      const b = CitiesByStateParams(stateCode: 'IT-25');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different stateCode', () {
      const a = CitiesByStateParams(stateCode: 'IT-25');
      const b = CitiesByStateParams(stateCode: 'IR-23');
      expect(a == b, isFalse);
    });

    test('props contains [stateCode] in order', () {
      const a = CitiesByStateParams(stateCode: 'AF-BDS');
      expect(a.props, ['AF-BDS']);
    });
  });
}
