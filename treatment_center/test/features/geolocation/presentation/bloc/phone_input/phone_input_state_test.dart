import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_state.dart';

void main() {
  // Sample entities
  const it = CountryPhoneCodeEntity(
    country: 'Italy',
    code: '+39',
    flag: '🇮🇹',
    iso2: 'IT',
  );

  const fr = CountryPhoneCodeEntity(
    country: 'France',
    code: '+33',
    flag: '🇫🇷',
    iso2: 'FR',
  );

  group('PhoneInputInitial', () {
    test('equatable: two instances are equal', () {
      expect(const PhoneInputInitial(), equals(const PhoneInputInitial()));
    });
  });

  group('PhoneInputLoading', () {
    test('equatable: two instances are equal', () {
      expect(const PhoneInputLoading(), equals(const PhoneInputLoading()));
    });
  });

  group('PhoneInputLoaded', () {
    test('defaults: isInitialized is false by default', () {
      final s = PhoneInputLoaded(
        countryCodes: const [it, fr],
        selectedCountryCode: it,
        phoneNumber: '',
        isValid: false,
      );
      expect(s.isInitialized, isFalse);
    });

    test('equatable: same values with same list instance -> equal', () {
      final list = [it, fr];
      final a = PhoneInputLoaded(
        countryCodes: list,
        selectedCountryCode: it,
        phoneNumber: '123',
        isValid: true,
        isInitialized: true,
      );
      final b = PhoneInputLoaded(
        countryCodes: list, // same reference
        selectedCountryCode: it,
        phoneNumber: '123',
        isValid: true,
        isInitialized: true,
      );
      expect(a, equals(b));
    });

    test('equatable: same contents but different list instances -> equal', () {
      final a = PhoneInputLoaded(
        countryCodes: [it, fr],
        selectedCountryCode: it,
        phoneNumber: '123',
        isValid: true,
        isInitialized: true,
      );
      final b = PhoneInputLoaded(
        countryCodes: [it, fr], // different instance, same contents
        selectedCountryCode: it,
        phoneNumber: '123',
        isValid: true,
        isInitialized: true,
      );
      expect(a, equals(b)); // <- deep equality on lists
    });

    test(
      'equatable: mutating a list after construction changes equality (avoid by using unmodifiable)',
      () {
        final list = [it, fr];
        final a = PhoneInputLoaded(
          countryCodes: list,
          selectedCountryCode: it,
          phoneNumber: '123',
          isValid: true,
          isInitialized: true,
        );

        // mutate list AFTER state creation
        list.add(
          const CountryPhoneCodeEntity(
            country: 'Uzbekistan',
            code: '+998',
            flag: '🇺🇿',
            iso2: 'UZ',
          ),
        );

        final b = PhoneInputLoaded(
          countryCodes: [it, fr], // original 2 items
          selectedCountryCode: it,
          phoneNumber: '123',
          isValid: true,
          isInitialized: true,
        );

        expect(a == b, isFalse); // contents differ now
      },
    );

    test('copyWith: no args returns an equal state (same list ref)', () {
      final list = [it, fr];
      final s = PhoneInputLoaded(
        countryCodes: list,
        selectedCountryCode: it,
        phoneNumber: '123',
        isValid: true,
        isInitialized: false,
      );

      final c = s.copyWith();
      expect(c, equals(s));
    });

    test('copyWith: updates individual fields', () {
      final s = PhoneInputLoaded(
        countryCodes: const [it],
        selectedCountryCode: it,
        phoneNumber: '123',
        isValid: false,
        isInitialized: false,
      );

      final c = s.copyWith(
        countryCodes: const [it, fr],
        selectedCountryCode: fr,
        phoneNumber: '456',
        isValid: true,
        isInitialized: true,
      );

      expect(c.countryCodes, equals(const [it, fr]));
      expect(c.selectedCountryCode, equals(fr));
      expect(c.phoneNumber, equals('456'));
      expect(c.isValid, isTrue);
      expect(c.isInitialized, isTrue);
    });

    test('copyWith: omitting selectedCountryCode keeps the original value', () {
      final s = PhoneInputLoaded(
        countryCodes: const [it, fr],
        selectedCountryCode: it,
        phoneNumber: '',
        isValid: false,
      );

      final c = s.copyWith(phoneNumber: '999');
      expect(c.selectedCountryCode, equals(it)); // unchanged
      expect(c.phoneNumber, equals('999'));
    });

    test('copyWith: selectedCountryCode can be explicitly set to null', () {
      final s = PhoneInputLoaded(
        countryCodes: const [it, fr],
        selectedCountryCode: it,
        phoneNumber: '',
        isValid: false,
      );

      // Thanks to the sentinel, passing null sets it to null (not "keep")
      final c = s.copyWith(selectedCountryCode: null);
      expect(c.selectedCountryCode, isNull);
    });
  });

  group('PhoneInputError', () {
    test('equatable: same message -> equal', () {
      expect(
        const PhoneInputError(message: 'Boom'),
        equals(const PhoneInputError(message: 'Boom')),
      );
    });

    test('equatable: different message -> not equal', () {
      expect(
        const PhoneInputError(message: 'A'),
        isNot(const PhoneInputError(message: 'B')),
      );
    });
  });
}
