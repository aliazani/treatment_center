import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_country_codes.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_bloc.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_event.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_state.dart';

@GenerateMocks([GetCountryCodesUsecase])
import 'phone_input_bloc_test.mocks.dart';

void main() {
  // Provide dummies so Mockito doesn’t complain when matching unstubbed calls
  provideDummy<Either<Failure, List<CountryPhoneCodeEntity>>>(
    Right(<CountryPhoneCodeEntity>[]),
  );
  provideDummy<NoParams>(NoParams());

  late MockGetCountryCodesUsecase mockGetCountryCodes;
  late PhoneInputBloc bloc;

  // Handy factory for entities (tweak fields if your constructor differs)
  CountryPhoneCodeEntity cc({
    required String country,
    required String code,
    required String iso2,
    String flag = '🏳️',
  }) => CountryPhoneCodeEntity(
    country: country,
    code: code,
    iso2: iso2,
    flag: flag,
  );

  late CountryPhoneCodeEntity italy; // +39
  late CountryPhoneCodeEntity france; // +33
  late CountryPhoneCodeEntity uzb; // +998 (to test longest-prefix over +99)
  late List<CountryPhoneCodeEntity> codes;

  setUp(() {
    mockGetCountryCodes = MockGetCountryCodesUsecase();
    bloc = PhoneInputBloc(getCountryCodesUsecase: mockGetCountryCodes);

    italy = cc(country: 'Italy', code: '+39', iso2: 'IT', flag: '🇮🇹');
    france = cc(country: 'France', code: '+33', iso2: 'FR', flag: '🇫🇷');
    uzb = cc(country: 'Uzbekistan', code: '+998', iso2: 'UZ', flag: '🇺🇿');
    codes = [italy, france, uzb];
  });

  tearDown(() async {
    await bloc.close();
  });

  group('LoadCountryCodesEvent', () {
    blocTest<PhoneInputBloc, PhoneInputState>(
      'emits Loading -> Loaded on success; auto-parses initialPhoneNumber starting with +',
      build: () {
        when(mockGetCountryCodes(any)).thenAnswer((_) async => Right(codes));
        return bloc;
      },
      act:
          (b) => b.add(
            const LoadCountryCodesEvent(initialPhoneNumber: '+39 3401234567'),
          ),
      expect:
          () => [
            isA<PhoneInputLoading>(),
            isA<PhoneInputLoaded>()
                .having(
                  (s) => s.countryCodes.length,
                  'codes length',
                  codes.length,
                )
                .having(
                  (s) => s.selectedCountryCode?.iso2,
                  'selected iso2',
                  'IT',
                )
                .having((s) => s.phoneNumber, 'number stripped', '3401234567')
                .having((s) => s.isValid, 'validity', true),
          ],
      verify: (_) {
        verify(mockGetCountryCodes(any)).called(1);
      },
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'uses cache on subsequent loads (no extra emission; usecase not called again)',
      build: () {
        when(mockGetCountryCodes(any)).thenAnswer((_) async => Right(codes));
        return bloc;
      },
      act: (b) async {
        b.add(const LoadCountryCodesEvent()); // first: loads & caches
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(const LoadCountryCodesEvent()); // second: uses cache
        await Future<void>.delayed(
          const Duration(milliseconds: 1),
        ); // let it process
      },
      // Only two emissions: Loading then Loaded
      expect: () => [isA<PhoneInputLoading>(), isA<PhoneInputLoaded>()],
      verify: (_) {
        // called once despite two events
        verify(mockGetCountryCodes(any)).called(1);
        verifyNoMoreInteractions(mockGetCountryCodes);
      },
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'forceRefresh bypasses cache (Loading emitted again and usecase called)',
      build: () {
        when(mockGetCountryCodes(any)).thenAnswer((_) async => Right(codes));
        return bloc;
      },
      act: (b) async {
        b.add(const LoadCountryCodesEvent()); // caches
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(const LoadCountryCodesEvent(forceRefresh: true));
      },
      expect:
          () => [
            isA<PhoneInputLoading>(),
            isA<PhoneInputLoaded>(),
            // force refresh
            isA<PhoneInputLoading>(),
            isA<PhoneInputLoaded>(),
          ],
      verify: (_) {
        verify(mockGetCountryCodes(any)).called(2);
      },
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'maps CacheFailure to friendly error message',
      build: () {
        when(
          mockGetCountryCodes(any),
        ).thenAnswer((_) async => Left(CacheFailure(message: 'Cache error')));
        return bloc;
      },
      act: (b) => b.add(const LoadCountryCodesEvent()),
      expect:
          () => [
            isA<PhoneInputLoading>(),
            isA<PhoneInputError>().having(
              (s) => s.message,
              'message',
              'Failed to load country codes from local storage. Please check your device storage.',
            ),
          ],
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'maps ServerFailure to friendly error message',
      build: () {
        when(
          mockGetCountryCodes(any),
        ).thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));
        return bloc;
      },
      act: (b) => b.add(const LoadCountryCodesEvent()),
      expect:
          () => [
            isA<PhoneInputLoading>(),
            isA<PhoneInputError>().having(
              (s) => s.message,
              'message',
              'Failed to load country codes from server. Please check your internet connection.',
            ),
          ],
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'maps NetworkFailure to friendly error message',
      build: () {
        when(mockGetCountryCodes(any)).thenAnswer(
          (_) async => Left(NetworkFailure(message: 'Network error')),
        );
        return bloc;
      },
      act: (b) => b.add(const LoadCountryCodesEvent()),
      expect:
          () => [
            isA<PhoneInputLoading>(),
            isA<PhoneInputError>().having(
              (s) => s.message,
              'message',
              'Network error occurred. Please check your internet connection.',
            ),
          ],
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'maps UnexpectedFailure to friendly error message',
      build: () {
        when(mockGetCountryCodes(any)).thenAnswer(
          (_) async => Left(UnexpectedFailure(message: 'Unexpected error')),
        );
        return bloc;
      },
      act: (b) => b.add(const LoadCountryCodesEvent()),
      expect:
          () => [
            isA<PhoneInputLoading>(),
            isA<PhoneInputError>().having(
              (s) => s.message,
              'message',
              'An unexpected error occurred while loading country codes.',
            ),
          ],
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'unexpected exception → PhoneInputError with exception text',
      build: () {
        when(mockGetCountryCodes(any)).thenThrow(Exception('boom'));
        return bloc;
      },
      act: (b) => b.add(const LoadCountryCodesEvent()),
      expect:
          () => [
            isA<PhoneInputLoading>(),
            isA<PhoneInputError>().having(
              (s) => s.message.startsWith(
                'Unexpected error loading country codes: Exception: boom',
              ),
              'contains exception',
              true,
            ),
          ],
    );
  });

  group('SelectCountryCodeEvent', () {
    blocTest<PhoneInputBloc, PhoneInputState>(
      'selects country and recomputes validity against current phone',
      build: () => bloc,
      seed:
          () => PhoneInputLoaded(
            countryCodes: codes,
            selectedCountryCode: null,
            phoneNumber: '1234567',
            isValid: false,
          ),
      act: (b) => b.add(SelectCountryCodeEvent(countryCode: italy)),
      expect:
          () => [
            isA<PhoneInputLoaded>()
                .having((s) => s.selectedCountryCode?.iso2, 'iso2', 'IT')
                .having((s) => s.isValid, 'validity', true),
          ],
    );
  });

  group('UpdatePhoneNumberEvent', () {
    blocTest<PhoneInputBloc, PhoneInputState>(
      'pastes full phone with + → auto-detects country and strips code; validates',
      build: () {
        when(mockGetCountryCodes(any)).thenAnswer((_) async => Right(codes));
        return bloc;
      },
      act: (b) async {
        // 1) Load to fill cache and move bloc to Loaded(null, '')
        b.add(const LoadCountryCodesEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        // 2) Paste full number with +
        b.add(const UpdatePhoneNumberEvent(phoneNumber: '+39 340 123 4567'));
      },
      // Skip the two emissions from the load (Loading, Loaded).
      skip: 2,
      wait: const Duration(milliseconds: 10),
      expect:
          () => [
            isA<PhoneInputLoaded>()
                .having((s) => s.selectedCountryCode?.iso2, 'iso2', 'IT')
                .having((s) => s.phoneNumber, 'stripped number', '3401234567')
                .having((s) => s.isValid, 'validity', true),
          ],
      verify: (_) {
        verify(mockGetCountryCodes(any)).called(1);
      },
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'updates phone without + → keeps selected country; validates length/digits',
      build: () => bloc,
      seed:
          () => PhoneInputLoaded(
            countryCodes: codes,
            selectedCountryCode: italy,
            phoneNumber: '',
            isValid: false,
          ),
      act: (b) => b.add(const UpdatePhoneNumberEvent(phoneNumber: '123')),
      expect:
          () => [
            isA<PhoneInputLoaded>()
                .having((s) => s.selectedCountryCode?.iso2, 'iso2', 'IT')
                .having((s) => s.phoneNumber, 'phone', '123')
                .having((s) => s.isValid, 'too short', false),
          ],
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'invalid when >15 digits',
      build: () => bloc,
      seed:
          () => PhoneInputLoaded(
            countryCodes: codes,
            selectedCountryCode: italy,
            phoneNumber: '',
            isValid: false,
          ),
      act:
          (b) => b.add(
            const UpdatePhoneNumberEvent(phoneNumber: '1234567890123456'),
          ),
      expect:
          () => [
            isA<PhoneInputLoaded>().having((s) => s.isValid, 'too long', false),
          ],
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'non-digits are ignored for validation',
      build: () => bloc,
      seed:
          () => PhoneInputLoaded(
            countryCodes: codes,
            selectedCountryCode: italy,
            phoneNumber: '',
            isValid: false,
          ),
      act:
          (b) =>
              b.add(const UpdatePhoneNumberEvent(phoneNumber: '123-45a-789')),
      expect:
          () => [
            isA<PhoneInputLoaded>().having(
              (s) => s.isValid,
              'non-digits stripped -> valid',
              true,
            ),
          ],
    );
  });

  group('ResetPhoneInputEvent', () {
    blocTest<PhoneInputBloc, PhoneInputState>(
      'clears selection & number, sets isValid=false, preserves isInitialized',
      build: () => bloc,
      seed:
          () => PhoneInputLoaded(
            countryCodes: codes,
            selectedCountryCode: italy,
            phoneNumber: '3401234567',
            isValid: true,
            isInitialized: true,
          ),
      act: (b) => b.add(const ResetPhoneInputEvent()),
      expect:
          () => [
            isA<PhoneInputLoaded>()
                .having(
                  (s) => s.selectedCountryCode,
                  'selectedCountryCode',
                  isNull,
                )
                .having((s) => s.phoneNumber, 'phoneNumber', '')
                .having((s) => s.isValid, 'isValid', false)
                .having(
                  (s) => s.isInitialized,
                  'isInitialized preserved',
                  true,
                ),
          ],
    );

    blocTest<PhoneInputBloc, PhoneInputState>(
      'does nothing when state is not PhoneInputLoaded',
      build: () => bloc, // initial state is PhoneInputInitial
      act: (b) => b.add(const ResetPhoneInputEvent()),
      expect: () => <PhoneInputState>[], // no emissions
    );
  });

  group('Getters', () {
    test(
      'getFullPhoneNumber / isInputComplete / currentCountryCode / currentPhoneNumber',
      () {
        final b = PhoneInputBloc(getCountryCodesUsecase: mockGetCountryCodes);
        addTearDown(b.close);

        b.emit(
          PhoneInputLoaded(
            countryCodes: codes,
            selectedCountryCode: italy,
            phoneNumber: '3401234567',
            isValid: true,
          ),
        );

        expect(b.getFullPhoneNumber(), '+393401234567');
        expect(b.isInputComplete, isTrue);
        expect(b.currentCountryCode?.iso2, 'IT');
        expect(b.currentPhoneNumber, '3401234567');

        // After reset-like state:
        b.emit(
          PhoneInputLoaded(
            countryCodes: codes,
            selectedCountryCode: null,
            phoneNumber: '',
            isValid: false,
          ),
        );
        expect(b.getFullPhoneNumber(), isNull);
        expect(b.isInputComplete, isFalse);
        expect(b.currentCountryCode, isNull);
        expect(b.currentPhoneNumber, '');
      },
    );
  });

  group('parseFullPhoneNumber', () {
    test('national format (no +) → no country inferred; digits only', () {
      final out = bloc.parseFullPhoneNumber('340-12 34 567', codes);
      expect(out.country, isNull);
      expect(out.number, '3401234567');
    });

    test('longest-prefix match prefers +998 over +99 when both exist', () {
      final extras = [
        cc(
          country: 'Kazakhstan',
          code: '+99',
          iso2: 'KZ',
        ), // pretend +99 exists to test ordering
        uzb,
      ];
      final out = bloc.parseFullPhoneNumber('+998 90 123 45 67', [
        ...codes,
        ...extras,
      ]);
      expect(out.country?.iso2, 'UZ');
      expect(out.number, '901234567');
    });

    test('unmatched + code → returns number without + and no country', () {
      final out = bloc.parseFullPhoneNumber('+777123', codes);
      expect(out.country, isNull);
      expect(out.number, '777123');
    });
  });
}
