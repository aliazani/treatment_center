import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_event.dart';

void main() {
  group('LoadCountryCodesEvent', () {
    test('props (defaults) and equality', () {
      const e1 = LoadCountryCodesEvent();
      const e2 = LoadCountryCodesEvent();

      expect(e1.props, [false, null, null]);
      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
    });

    test('props (with values) and inequality vs defaults', () {
      final us = CountryPhoneCodeEntity(
        country: 'United States',
        code: '+1',
        iso2: 'US',
        flag: '🇺🇸',
      );
      final e = LoadCountryCodesEvent(
        forceRefresh: true,
        initialCountryCode: us,
        initialPhoneNumber: '6505551234',
      );

      expect(e.props, [true, us, '6505551234']);

      const defaults = LoadCountryCodesEvent();
      expect(e == defaults, isFalse);
    });

    test('equality when all fields match', () {
      final cc = CountryPhoneCodeEntity(
        country: 'Italy',
        code: '+39',
        iso2: 'IT',
        flag: '🇮🇹',
      );

      final a = LoadCountryCodesEvent(
        forceRefresh: true,
        initialCountryCode: cc,
        initialPhoneNumber: '3401234567',
      );
      final b = LoadCountryCodesEvent(
        forceRefresh: true,
        initialCountryCode: cc,
        initialPhoneNumber: '3401234567',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('SelectCountryCodeEvent', () {
    test('props & equality', () {
      final it = CountryPhoneCodeEntity(
        country: 'Italy',
        code: '+39',
        iso2: 'IT',
        flag: '🇮🇹',
      );
      final e1 = SelectCountryCodeEvent(countryCode: it);
      final e2 = SelectCountryCodeEvent(countryCode: it);

      expect(e1.props, [it]);
      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
    });

    test('inequality when country code differs', () {
      final it = CountryPhoneCodeEntity(
        country: 'Italy',
        code: '+39',
        iso2: 'IT',
        flag: '🇮🇹',
      );
      final fr = CountryPhoneCodeEntity(
        country: 'France',
        code: '+33',
        iso2: 'FR',
        flag: '🇫🇷',
      );

      final a = SelectCountryCodeEvent(countryCode: it);
      final b = SelectCountryCodeEvent(countryCode: fr);

      expect(a == b, isFalse);
    });
  });

  group('UpdatePhoneNumberEvent', () {
    test('props & equality', () {
      const a = UpdatePhoneNumberEvent(phoneNumber: '1234567');
      const b = UpdatePhoneNumberEvent(phoneNumber: '1234567');

      expect(a.props, ['1234567']);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when phone changes', () {
      const a = UpdatePhoneNumberEvent(phoneNumber: '111');
      const b = UpdatePhoneNumberEvent(phoneNumber: '222');

      expect(a == b, isFalse);
    });
  });

  group('ResetPhoneInputEvent', () {
    test('props empty & all instances equal', () {
      const a = ResetPhoneInputEvent();
      const b = ResetPhoneInputEvent();

      expect(a.props, isEmpty);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
