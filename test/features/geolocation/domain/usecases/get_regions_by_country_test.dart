import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_regions_by_country.dart';

import 'get_regions_by_country_test.mocks.dart';

@GenerateMocks([GeographicRepository])
void main() {
  late MockGeographicRepository repo;
  late GetRegionsByCountry usecase;

  setUpAll(() {
    provideDummy<Either<Failure, List<RegionEntity>>>(
      Right(const <RegionEntity>[]),
    );
  });

  setUp(() {
    repo = MockGeographicRepository();
    usecase = GetRegionsByCountry(repo);
  });

  // Sample data
  const r1 = RegionEntity(
    id: 1,
    name: 'Lombardy',
    countryCode: 'IT',
    stateCode: 'IT-25',
  );
  const r2 = RegionEntity(
    id: 2,
    name: 'Lazio',
    countryCode: 'IT',
    stateCode: 'IT-62',
  );
  const regions = <RegionEntity>[r1, r2];

  group('GetRegionsByCountry', () {
    test('forwards countryCode and returns Right(list) on success', () async {
      // arrange
      when(
        repo.getStatesByCountry('IT'),
      ).thenAnswer((_) async => Right(regions));

      // act
      final result = await usecase(
        const RegionsByCountryParams(countryCode: 'IT'),
      );

      // assert
      expect(result.isRight(), isTrue);
      result.match((l) => fail('Expected Right, got $l'), (r) {
        expect(r, hasLength(2));
        expect(r.first.name, 'Lombardy');
        expect(r.last.stateCode, 'IT-62');
      });
      verify(repo.getStatesByCountry('IT')).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('returns Left(CacheFailure) when repository fails', () async {
      // arrange
      when(
        repo.getStatesByCountry('IT'),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'cache oops')));

      // act
      final result = await usecase(
        const RegionsByCountryParams(countryCode: 'IT'),
      );

      // assert
      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
      verify(repo.getStatesByCountry('IT')).called(1);
    });
  });

  group('RegionsByCountryParams (Equatable)', () {
    test('value equality with same countryCode', () {
      const a = RegionsByCountryParams(countryCode: 'IT');
      const b = RegionsByCountryParams(countryCode: 'IT');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different countryCode', () {
      const a = RegionsByCountryParams(countryCode: 'IT');
      const b = RegionsByCountryParams(countryCode: 'IR');
      expect(a == b, isFalse);
    });

    test('props contains [countryCode] in order', () {
      const p = RegionsByCountryParams(countryCode: 'IT');
      expect(p.props, ['IT']);
    });
  });
}
