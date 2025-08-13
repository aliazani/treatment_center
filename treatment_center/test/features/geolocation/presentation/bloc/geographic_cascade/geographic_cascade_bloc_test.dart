import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_cities_by_region.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_countries.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_regions_by_country.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_bloc.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_event.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_state.dart';
import 'package:treatment_center/features/geolocation/presentation/widgets/geographic_dropdowns_widget.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

@GenerateMocks([GetCountries, GetRegionsByCountry, GetCitiesByRegion])
import 'geographic_cascade_bloc_test.mocks.dart';

class DummyFailure extends Failure {
  const DummyFailure() : super(message: 'some unknown error');
}

void main() {
  // Dummies for Either so Mockito doesn't choke if something is unstubbed
  provideDummy<Either<Failure, List<CountryEntity>>>(Right(<CountryEntity>[]));
  provideDummy<Either<Failure, List<RegionEntity>>>(Right(<RegionEntity>[]));
  provideDummy<Either<Failure, List<CityEntity>>>(Right(<CityEntity>[]));
  provideDummy<Either<Failure, void>>(const Right(null));

  // Provide dummy for NoParams to help with mock matching
  provideDummy<NoParams>(NoParams());

  late MockGetCountries mockGetCountries;
  late MockGetRegionsByCountry mockGetRegionsByCountry;
  late MockGetCitiesByRegion mockGetCitiesByRegion;

  late GeographicCascadeBloc bloc;

  // ---- Use REAL entity instances (no Mockito for entities) ----
  late CountryEntity italy;
  late RegionEntity lombardy;
  late CityEntity milan;

  setUp(() {
    mockGetCountries = MockGetCountries();
    mockGetRegionsByCountry = MockGetRegionsByCountry();
    mockGetCitiesByRegion = MockGetCitiesByRegion();

    bloc = GeographicCascadeBloc(
      mockGetCountries,
      mockGetRegionsByCountry,
      mockGetCitiesByRegion,
    );

    // Adjust these constructors if your entities differ
    italy = CountryEntity(
      name: 'Italy',
      iso2: 'IT',
      id: 1,
      emoji: '',
      phonecode: '',
    );
    lombardy = RegionEntity(
      name: 'Lombardy',
      stateCode: 'IT-25',
      id: 1,
      countryCode: '',
    );
    milan = CityEntity(name: 'Milan', id: 1, stateCode: '');
  });

  tearDown(() async {
    await bloc.close();
  });

  group('Initialize / Hydration', () {
    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'hydrate country only (savedCountry, no savedRegion) → completes after regions load',
      build: () {
        when(
          mockGetCountries.call(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        when(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Right(<RegionEntity>[lombardy]));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(savedCountryName: 'Italy'),
          ),
      expect:
          () => [
            // hydrating kicks off with a country target
            isA<GeographicCascadeState>()
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.hydrating,
                )
                .having((s) => s.targetCountryName, 'targetCountry', 'Italy')
                .having((s) => s.targetRegionName, 'targetRegion', null)
                .having((s) => s.targetCityName, 'targetCity', null),
            // countries loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCountries,
              'loadingCountries',
              true,
            ),
            // countries loaded
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCountries, 'loadingCountries', false)
                .having(
                  (s) => s.countries.first.name,
                  'first country',
                  'Italy',
                ),
            // country selected → regions loading
            isA<GeographicCascadeState>().having(
              (s) => s.selection.country?.name,
              'selected country',
              'Italy',
            ),
            isA<GeographicCascadeState>().having(
              (s) => s.loadingRegions,
              'loadingRegions',
              true,
            ),
            // regions loaded (no targetRegionName) → hydration completed & targets cleared
            isA<GeographicCascadeState>()
                .having((s) => s.loadingRegions, 'loadingRegions', false)
                .having(
                  (s) => s.regions.first.name,
                  'first region',
                  'Lombardy',
                ),
            isA<GeographicCascadeState>()
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.completed,
                )
                .having(
                  (s) => s.targetCountryName,
                  'targetCountry cleared',
                  null,
                )
                .having((s) => s.targetRegionName, 'targetRegion cleared', null)
                .having((s) => s.targetCityName, 'targetCity cleared', null),
          ],
      verify: (_) {
        verify(mockGetCountries.call(any)).called(1);
        verify(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
        verifyZeroInteractions(
          mockGetCitiesByRegion,
        ); // cities shouldn't be loaded
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'hydrate country+region only (no savedCity) → completes after cities load',
      build: () {
        when(
          mockGetCountries.call(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        when(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Right(<RegionEntity>[lombardy]));
        when(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).thenAnswer((_) async => Right(<CityEntity>[milan]));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(
              savedCountryName: 'Italy',
              savedRegionName: 'Lombardy',
              // savedCityName omitted on purpose
            ),
          ),
      expect:
          () => [
            // hydrating with country & region targets
            isA<GeographicCascadeState>()
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.hydrating,
                )
                .having((s) => s.targetCountryName, 'targetCountry', 'Italy')
                .having((s) => s.targetRegionName, 'targetRegion', 'Lombardy')
                .having((s) => s.targetCityName, 'targetCity', null),
            // countries loading → loaded
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCountries,
              'loadingCountries',
              true,
            ),
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCountries, 'loadingCountries', false)
                .having(
                  (s) => s.countries.first.name,
                  'first country',
                  'Italy',
                ),
            // country selected → regions loading → loaded
            isA<GeographicCascadeState>().having(
              (s) => s.selection.country?.name,
              'selected country',
              'Italy',
            ),
            isA<GeographicCascadeState>().having(
              (s) => s.loadingRegions,
              'loadingRegions',
              true,
            ),
            isA<GeographicCascadeState>()
                .having((s) => s.loadingRegions, 'loadingRegions', false)
                .having(
                  (s) => s.regions.first.name,
                  'first region',
                  'Lombardy',
                ),
            // region applied → cities loading → loaded
            isA<GeographicCascadeState>().having(
              (s) => s.selection.state?.name,
              'selected state',
              'Lombardy',
            ),
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCities,
              'loadingCities',
              true,
            ),
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCities, 'loadingCities', false)
                .having((s) => s.cities.first.name, 'first city', 'Milan'),
            // since no savedCityName and still hydrating → completed & targets cleared
            isA<GeographicCascadeState>()
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.completed,
                )
                .having(
                  (s) => s.selection.city,
                  'city remains unselected',
                  null,
                )
                .having(
                  (s) => s.targetCountryName,
                  'targetCountry cleared',
                  null,
                )
                .having((s) => s.targetRegionName, 'targetRegion cleared', null)
                .having((s) => s.targetCityName, 'targetCity cleared', null),
          ],
      verify: (_) {
        verify(mockGetCountries.call(any)).called(1);
        verify(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
        verify(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).called(1);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'init without saved values → loads countries and completes',
      build: () {
        // Use `any` matcher to handle NoParams equality issues
        when(
          mockGetCountries(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        return bloc;
      },
      act: (b) => b.add(const InitializeGeographicCascade()),
      expect:
          () => [
            predicate<GeographicCascadeState>(
              (s) =>
                  s.hydrationStatus == HydrationStatus.hydrating &&
                  s.targetCountryName == null &&
                  s.targetRegionName == null &&
                  s.targetCityName == null,
            ),
            predicate<GeographicCascadeState>(
              (s) =>
                  s.hydrationStatus == HydrationStatus.hydrating &&
                  s.loadingCountries,
            ),
            predicate<GeographicCascadeState>(
              (s) =>
                  s.hydrationStatus == HydrationStatus.hydrating &&
                  !s.loadingCountries &&
                  s.countries.length == 1 &&
                  s.countries.first.name == 'Italy',
            ),
            predicate<GeographicCascadeState>(
              (s) => s.hydrationStatus == HydrationStatus.completed,
            ),
          ],
      verify: (_) {
        verify(mockGetCountries(any)).called(1);
        verifyNoMoreInteractions(mockGetCountries);
        verifyZeroInteractions(mockGetRegionsByCountry);
        verifyZeroInteractions(mockGetCitiesByRegion);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'full hydration: country → region → city',
      build: () {
        when(
          mockGetCountries(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        when(
          mockGetRegionsByCountry(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Right(<RegionEntity>[lombardy]));
        when(
          mockGetCitiesByRegion(const CitiesByStateParams(stateCode: 'IT-25')),
        ).thenAnswer((_) async => Right(<CityEntity>[milan]));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(
              savedCountryName: 'italy',
              savedRegionName: 'LOMBARDY',
              savedCityName: 'Milan',
            ),
          ),
      expect:
          () => [
            predicate<GeographicCascadeState>(
              (s) =>
                  s.hydrationStatus == HydrationStatus.hydrating &&
                  s.targetCountryName == 'italy' &&
                  s.targetRegionName == 'LOMBARDY' &&
                  s.targetCityName == 'Milan',
            ),
            predicate<GeographicCascadeState>((s) => s.loadingCountries),
            predicate<GeographicCascadeState>(
              (s) => !s.loadingCountries && s.countries.first.name == 'Italy',
            ),
            // hydrated country selected
            predicate<GeographicCascadeState>(
              (s) =>
                  s.selection.country?.name == 'Italy' &&
                  s.selection.state == null &&
                  s.selection.city == null,
            ),
            // load regions
            predicate<GeographicCascadeState>((s) => s.loadingRegions),
            // regions loaded
            predicate<GeographicCascadeState>(
              (s) => !s.loadingRegions && s.regions.first.name == 'Lombardy',
            ),
            // hydrated region selected
            predicate<GeographicCascadeState>(
              (s) =>
                  s.selection.country?.name == 'Italy' &&
                  s.selection.state?.name == 'Lombardy' &&
                  s.cities.isEmpty,
            ),
            // load cities
            predicate<GeographicCascadeState>((s) => s.loadingCities),
            // cities loaded
            predicate<GeographicCascadeState>(
              (s) => !s.loadingCities && s.cities.first.name == 'Milan',
            ),
            // hydrated city selected → completed
            predicate<GeographicCascadeState>(
              (s) =>
                  s.hydrationStatus == HydrationStatus.completed &&
                  s.selection.country?.name == 'Italy' &&
                  s.selection.state?.name == 'Lombardy' &&
                  s.selection.city?.name == 'Milan',
            ),
          ],
      verify: (_) {
        verify(mockGetCountries(any)).called(1);
        verify(
          mockGetRegionsByCountry(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
        verify(
          mockGetCitiesByRegion(const CitiesByStateParams(stateCode: 'IT-25')),
        ).called(1);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'countries load failure → hydration failed',
      build: () {
        when(
          mockGetCountries(any),
        ).thenAnswer((_) async => Left(const DummyFailure()));
        return bloc;
      },
      act: (b) => b.add(const InitializeGeographicCascade()),
      expect:
          () => [
            predicate<GeographicCascadeState>(
              (s) => s.hydrationStatus == HydrationStatus.hydrating,
            ),
            predicate<GeographicCascadeState>((s) => s.loadingCountries),
            predicate<GeographicCascadeState>(
              (s) =>
                  s.hydrationStatus == HydrationStatus.failed &&
                  !s.loadingCountries &&
                  s.countriesError == 'Failed to load countries' &&
                  s.hydrationError == 'Could not load countries',
            ),
          ],
      verify: (_) {
        verify(mockGetCountries(any)).called(1);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'country target not found → hydration failed',
      build: () {
        // Use `.call(any)` to stub the callable use case; keeps Mockito happy.
        when(
          mockGetCountries.call(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(savedCountryName: 'NoLand'),
          ),
      expect:
          () => [
            // 1) hydrate starts
            isA<GeographicCascadeState>().having(
              (s) => s.hydrationStatus,
              'status',
              HydrationStatus.hydrating,
            ),
            // 2) countries loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCountries,
              'loadingCountries',
              true,
            ),
            // 3) countries loaded (Italy present), target mismatch handled
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCountries, 'loadingCountries', false)
                .having((s) => s.countries.length, 'countries length', 1)
                .having(
                  (s) => s.countries.first.name,
                  'first country',
                  'Italy',
                ),
            // 4) since savedCountryName 'NoLand' not found → fail hydration
            isA<GeographicCascadeState>()
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.failed,
                )
                // optional extra checks if your bloc sets these:
                .having((s) => s.selection.country, 'selected country', null),
          ],
      verify: (_) {
        verify(mockGetCountries.call(any)).called(1);
        verifyNoMoreInteractions(mockGetCountries);
        verifyZeroInteractions(mockGetRegionsByCountry);
        verifyZeroInteractions(mockGetCitiesByRegion);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'regions load failure → hydration failed',
      build: () {
        // Stub callable use cases with `.call`
        when(
          mockGetCountries.call(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        when(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Left(const DummyFailure()));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(savedCountryName: 'Italy'),
          ),
      expect:
          () => [
            // 1) Hydration starts
            isA<GeographicCascadeState>().having(
              (s) => s.hydrationStatus,
              'status',
              HydrationStatus.hydrating,
            ),

            // 2) Countries loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCountries,
              'loadingCountries',
              true,
            ),

            // 3) Countries loaded (Italy present)
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCountries, 'loadingCountries', false)
                .having((s) => s.countries.length, 'countries length', 1)
                .having(
                  (s) => s.countries.first.name,
                  'first country',
                  'Italy',
                ),

            // 4) Country selected (Italy), regions start loading
            isA<GeographicCascadeState>().having(
              (s) => s.selection.country?.name,
              'selected country',
              'Italy',
            ),

            isA<GeographicCascadeState>().having(
              (s) => s.loadingRegions,
              'loadingRegions',
              true,
            ),

            // 5) Regions load fails → hydration failed
            isA<GeographicCascadeState>()
                .having((s) => s.loadingRegions, 'loadingRegions', false)
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.failed,
                ),
          ],
      verify: (_) {
        verify(mockGetCountries.call(any)).called(1);
        verify(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockGetCountries);
        verifyNoMoreInteractions(mockGetRegionsByCountry);
        verifyZeroInteractions(mockGetCitiesByRegion);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'region target not found → hydration failed',
      build: () {
        when(
          mockGetCountries.call(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        when(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Right(<RegionEntity>[lombardy]));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(
              savedCountryName: 'Italy',
              savedRegionName: 'NotExisting',
            ),
          ),
      expect:
          () => [
            // hydration kicks off
            isA<GeographicCascadeState>().having(
              (s) => s.hydrationStatus,
              'status',
              HydrationStatus.hydrating,
            ),
            // countries loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCountries,
              'loadingCountries',
              true,
            ),
            // countries loaded
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCountries, 'loadingCountries', false)
                .having((s) => s.countries.length, 'countries length', 1)
                .having(
                  (s) => s.countries.first.name,
                  'first country',
                  'Italy',
                ),
            // country selected
            isA<GeographicCascadeState>().having(
              (s) => s.selection.country?.name,
              'selected country',
              'Italy',
            ),
            // regions loading (if your bloc toggles this flag)
            isA<GeographicCascadeState>().having(
              (s) => s.loadingRegions,
              'loadingRegions',
              true,
            ),
            // regions loaded but target region not found
            isA<GeographicCascadeState>()
                .having((s) => s.loadingRegions, 'loadingRegions', false)
                .having((s) => s.regions.length, 'regions length', 1),
            // hydration failed
            isA<GeographicCascadeState>().having(
              (s) => s.hydrationStatus,
              'status',
              HydrationStatus.failed,
            ),
          ],
      verify: (_) {
        verify(mockGetCountries.call(any)).called(1);
        verify(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockGetCountries);
        verifyNoMoreInteractions(mockGetRegionsByCountry);
        verifyZeroInteractions(mockGetCitiesByRegion);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'cities load failure → hydration failed',
      build: () {
        when(
          mockGetCountries.call(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        when(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Right(<RegionEntity>[lombardy]));
        when(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).thenAnswer((_) async => Left(const DummyFailure()));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(
              savedCountryName: 'Italy',
              savedRegionName: 'Lombardy',
            ),
          ),
      expect:
          () => [
            // hydration starts
            isA<GeographicCascadeState>().having(
              (s) => s.hydrationStatus,
              'status',
              HydrationStatus.hydrating,
            ),

            // countries loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCountries,
              'loadingCountries',
              true,
            ),

            // countries loaded
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCountries, 'loadingCountries', false)
                .having((s) => s.countries.length, 'countries length', 1)
                .having(
                  (s) => s.countries.first.name,
                  'first country',
                  'Italy',
                ),

            // country selected
            isA<GeographicCascadeState>().having(
              (s) => s.selection.country?.name,
              'selected country',
              'Italy',
            ),

            // regions loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingRegions,
              'loadingRegions',
              true,
            ),

            // (a) regions loaded, selection.state not set yet
            isA<GeographicCascadeState>()
                .having((s) => s.loadingRegions, 'loadingRegions', false)
                .having((s) => s.regions.length, 'regions length', 1)
                .having((s) => s.selection.state, 'selected state', null),

            // (b) now bloc applies target region → selection set
            isA<GeographicCascadeState>().having(
              (s) => s.selection.state?.name,
              'selected state',
              'Lombardy',
            ),

            // cities loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCities,
              'loadingCities',
              true,
            ),

            // cities load fails → hydration failed
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCities, 'loadingCities', false)
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.failed,
                ),
          ],
      verify: (_) {
        verify(mockGetCountries.call(any)).called(1);
        verify(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
        verify(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockGetCountries);
        verifyNoMoreInteractions(mockGetRegionsByCountry);
        verifyNoMoreInteractions(mockGetCitiesByRegion);
      },
    );
    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'city target not found → hydration failed',
      build: () {
        when(
          mockGetCountries.call(any),
        ).thenAnswer((_) async => Right(<CountryEntity>[italy]));
        when(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Right(<RegionEntity>[lombardy]));
        when(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).thenAnswer((_) async => Right(<CityEntity>[milan]));
        return bloc;
      },
      act:
          (b) => b.add(
            const InitializeGeographicCascade(
              savedCountryName: 'Italy',
              savedRegionName: 'Lombardy',
              savedCityName: 'NoCity',
            ),
          ),
      expect:
          () => [
            // hydration starts
            isA<GeographicCascadeState>().having(
              (s) => s.hydrationStatus,
              'status',
              HydrationStatus.hydrating,
            ),

            // countries loading
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCountries,
              'loadingCountries',
              true,
            ),

            // countries loaded
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCountries, 'loadingCountries', false)
                .having((s) => s.countries.length, 'countries length', 1)
                .having(
                  (s) => s.countries.first.name,
                  'first country',
                  'Italy',
                ),

            // country selected → regions loading
            isA<GeographicCascadeState>().having(
              (s) => s.selection.country?.name,
              'selected country',
              'Italy',
            ),
            isA<GeographicCascadeState>().having(
              (s) => s.loadingRegions,
              'loadingRegions',
              true,
            ),

            // (a) regions loaded, selection.state not set yet
            isA<GeographicCascadeState>()
                .having((s) => s.loadingRegions, 'loadingRegions', false)
                .having((s) => s.regions.length, 'regions length', 1)
                .having((s) => s.selection.state, 'selected state', null),

            // (b) region applied → cities loading
            isA<GeographicCascadeState>().having(
              (s) => s.selection.state?.name,
              'selected state',
              'Lombardy',
            ),
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCities,
              'loadingCities',
              true,
            ),

            // NEW: cities loaded but still hydrating (your index [8])
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCities, 'loadingCities', false)
                .having((s) => s.cities.length, 'cities length', 1)
                .having(
                  (s) => s.hydrationStatus,
                  'status',
                  HydrationStatus.hydrating,
                ),

            // THEN: target city not found → fail (your index [9])
            isA<GeographicCascadeState>().having(
              (s) => s.hydrationStatus,
              'status',
              HydrationStatus.failed,
            ),
          ],

      verify: (_) {
        verify(mockGetCountries.call(any)).called(1);
        verify(
          mockGetRegionsByCountry.call(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
        verify(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockGetCountries);
        verifyNoMoreInteractions(mockGetRegionsByCountry);
        verifyNoMoreInteractions(mockGetCitiesByRegion);
      },
    );
  });

  group('Manual selection', () {
    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'SelectCountry(null) → clears selection & lists, idles hydration',
      build: () => bloc,
      act: (b) => b.add(const SelectCountry(null)),
      expect:
          () => [
            predicate<GeographicCascadeState>(
              (s) =>
                  s.selection.country == null &&
                  s.selection.state == null &&
                  s.selection.city == null &&
                  s.regions.isEmpty &&
                  s.cities.isEmpty &&
                  s.hydrationStatus == HydrationStatus.idle,
            ),
          ],
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'SelectCountry(country) → updates selection, clears dependents, loads regions',
      build: () {
        when(
          mockGetRegionsByCountry(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).thenAnswer((_) async => Right(<RegionEntity>[lombardy]));
        return bloc;
      },
      act: (b) => b.add(SelectCountry(italy)),
      expect:
          () => [
            // 1) selection updated, dependents cleared (idle)
            isA<GeographicCascadeState>()
                .having((s) => s.selection.country?.name, 'country', 'Italy')
                .having((s) => s.selection.state, 'state', null)
                .having((s) => s.selection.city, 'city', null)
                .having((s) => s.regions.isEmpty, 'regions empty', true)
                .having((s) => s.cities.isEmpty, 'cities empty', true)
                .having(
                  (s) => s.hydrationStatus,
                  'hydration',
                  HydrationStatus.idle,
                ),

            // 2) intermediary duplicate (bloc emits the same state again)
            isA<GeographicCascadeState>().having(
              (s) => s.selection.country?.name,
              'country',
              'Italy',
            ),

            // 3) regions loaded (still idle)
            isA<GeographicCascadeState>()
                .having((s) => s.regions.length, 'regions count', 1)
                .having((s) => s.regions.first.name, 'first region', 'Lombardy')
                .having(
                  (s) => s.hydrationStatus,
                  'hydration',
                  HydrationStatus.idle,
                ),
          ],
      verify: (_) {
        verify(
          mockGetRegionsByCountry(
            const RegionsByCountryParams(countryCode: 'IT'),
          ),
        ).called(1);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'SelectRegion(null) → clears region & city, no cities load after clear',
      build: () {
        // When selecting Lombardy we will load cities -> must stub it
        when(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).thenAnswer((_) async => Right(<CityEntity>[milan]));
        return bloc;
      },
      seed:
          () => GeographicCascadeState(
            selection: GeographicSelection(country: italy),
            regions: [lombardy],
            cities: const [],
          ),
      act: (b) async {
        b.add(SelectRegion(lombardy)); // triggers cities load
        // give the bloc a tick to process async handler
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(
          const SelectRegion(null),
        ); // should clear state & city and not load cities
      },
      expect:
          () => [
            // 1) selection updated, cities cleared, start loading cities
            isA<GeographicCascadeState>()
                .having((s) => s.selection.country?.name, 'country', 'Italy')
                .having((s) => s.selection.state?.name, 'state', 'Lombardy')
                .having((s) => s.selection.city, 'city', null)
                .having((s) => s.cities.isEmpty, 'cities cleared', true),

            // 2) cities loaded for Lombardy
            isA<GeographicCascadeState>().having(
              (s) => s.loadingCities,
              'loadingCities',
              true,
            ),
            isA<GeographicCascadeState>()
                .having((s) => s.loadingCities, 'loadingCities', false)
                .having((s) => s.cities.length, 'cities length', 1),

            // 3) clearing selection: region & city become null, cities list emptied
            isA<GeographicCascadeState>()
                .having((s) => s.selection.country?.name, 'country', 'Italy')
                .having((s) => s.selection.state, 'state', null)
                .having((s) => s.selection.city, 'city', null)
                .having((s) => s.cities.isEmpty, 'cities cleared', true)
                .having(
                  (s) => s.hydrationStatus,
                  'hydration',
                  HydrationStatus.idle,
                ),
          ],
      verify: (_) {
        // Was called once when selecting Lombardy
        verify(
          mockGetCitiesByRegion.call(
            const CitiesByStateParams(stateCode: 'IT-25'),
          ),
        ).called(1);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'SelectRegion(region) → updates selection, clears cities, loads cities',
      build: () {
        when(
          mockGetCitiesByRegion(const CitiesByStateParams(stateCode: 'IT-25')),
        ).thenAnswer((_) async => Right(<CityEntity>[milan]));
        return bloc;
      },
      seed:
          () => GeographicCascadeState(
            selection: GeographicSelection(country: italy),
            regions: [lombardy],
          ),
      act: (b) => b.add(SelectRegion(lombardy)),
      expect:
          () => [
            // 1) selection updated, cities cleared (hydration stays idle)
            isA<GeographicCascadeState>()
                .having((s) => s.selection.country?.name, 'country', 'Italy')
                .having((s) => s.selection.state?.name, 'state', 'Lombardy')
                .having((s) => s.selection.city, 'city', null)
                .having((s) => s.cities.isEmpty, 'cities empty', true)
                .having(
                  (s) => s.hydrationStatus,
                  'hydration',
                  HydrationStatus.idle,
                ),

            // 2) duplicate emission (bloc re-emits same state)
            isA<GeographicCascadeState>().having(
              (s) => s.selection.state?.name,
              'state',
              'Lombardy',
            ),

            // 3) cities loaded (still idle, no loadingCities toggle)
            isA<GeographicCascadeState>()
                .having((s) => s.cities.length, 'cities count', 1)
                .having((s) => s.cities.first.name, 'first city', 'Milan')
                .having(
                  (s) => s.hydrationStatus,
                  'hydration',
                  HydrationStatus.idle,
                ),
          ],
      verify: (_) {
        verify(
          mockGetCitiesByRegion(const CitiesByStateParams(stateCode: 'IT-25')),
        ).called(1);
      },
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'SelectCity(city) → sets city on selection',
      build: () => bloc,
      seed:
          () => GeographicCascadeState(
            selection: GeographicSelection(country: italy, state: lombardy),
          ),
      act: (b) => b.add(SelectCity(milan)),
      expect:
          () => [
            predicate<GeographicCascadeState>(
              (s) =>
                  s.selection.country?.name == 'Italy' &&
                  s.selection.state?.name == 'Lombardy' &&
                  s.selection.city?.name == 'Milan',
            ),
          ],
    );

    blocTest<GeographicCascadeBloc, GeographicCascadeState>(
      'ResetGeographicCascade → initial state',
      build: () => bloc,
      seed:
          () => GeographicCascadeState(
            countries: [italy],
            regions: [lombardy],
            cities: [milan],
            selection: GeographicSelection(
              country: italy,
              state: lombardy,
              city: milan,
            ),
            hydrationStatus: HydrationStatus.completed,
            countriesError: 'x',
          ),
      act: (b) => b.add(const ResetGeographicCascade()),
      expect: () => [const GeographicCascadeState()],
    );
  });
}
