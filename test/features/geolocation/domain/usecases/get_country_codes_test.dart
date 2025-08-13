import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_country_codes.dart';

import 'get_country_codes_test.mocks.dart';

@GenerateMocks([GeographicRepository])
void main() {
  late MockGeographicRepository repo;
  late GetCountryCodesUsecase usecase;

  setUpAll(() {
    // Mockito sometimes needs a dummy for Either return types
    provideDummy<Either<Failure, List<CountryPhoneCodeEntity>>>(
      Right(const <CountryPhoneCodeEntity>[]),
    );
  });

  setUp(() {
    repo = MockGeographicRepository();
    usecase = GetCountryCodesUsecase(repo);
  });

  // Sample data
  const it = CountryPhoneCodeEntity(
    country: 'Italy',
    code: '+39',
    flag: '🇮🇹',
    iso2: 'IT',
  );
  const ir = CountryPhoneCodeEntity(
    country: 'Iran',
    code: '+98',
    flag: '🇮🇷',
    iso2: 'IR',
  );
  const list = <CountryPhoneCodeEntity>[ir, it];

  group('GetCountryCodes', () {
    test('returns Right(list) on success and calls repo once', () async {
      // arrange
      when(repo.getCountryCodes()).thenAnswer((_) async => Right(list));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result.isRight(), isTrue);
      result.match((l) => fail('Expected Right, got $l'), (r) {
        expect(r, hasLength(2));
        expect(
          r.first.country,
          'Iran',
        ); // assuming list order preserved from repo
        expect(r.last.iso2, 'IT');
      });
      verify(repo.getCountryCodes()).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('returns Left(CacheFailure) when repository fails', () async {
      // arrange
      when(
        repo.getCountryCodes(),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'cache oops')));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result.isLeft(), isTrue);
      result.match(
        (l) => expect(l, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
      verify(repo.getCountryCodes()).called(1);
    });
  });
}
