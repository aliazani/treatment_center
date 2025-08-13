import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';

void main() {
  group('CountryPhoneCodeEntity (Equatable)', () {
    const a1 = CountryPhoneCodeEntity(
      country: 'Italy',
      code: '+39',
      flag: '🇮🇹',
      iso2: 'IT',
    );
    const a2 = CountryPhoneCodeEntity(
      country: 'Italy',
      code: '+39',
      flag: '🇮🇹',
      iso2: 'IT',
    );
    const diffCountry = CountryPhoneCodeEntity(
      country: 'Iran',
      code: '+39',
      flag: '🇮🇹',
      iso2: 'IT',
    );
    const diffCode = CountryPhoneCodeEntity(
      country: 'Italy',
      code: '+98',
      flag: '🇮🇹',
      iso2: 'IT',
    );
    const diffFlag = CountryPhoneCodeEntity(
      country: 'Italy',
      code: '+39',
      flag: '🇮🇷',
      iso2: 'IT',
    );
    const diffIso2 = CountryPhoneCodeEntity(
      country: 'Italy',
      code: '+39',
      flag: '🇮🇹',
      iso2: 'IR',
    );

    test('value equality: same fields -> equal', () {
      expect(a1, equals(a2));
      expect(a1 == a2, isTrue);
    });

    test('hashCode: same fields -> equal hashCodes', () {
      expect(a1.hashCode, equals(a2.hashCode));
    });

    test('inequality by country', () {
      expect(a1 == diffCountry, isFalse);
    });

    test('inequality by code', () {
      expect(a1 == diffCode, isFalse);
    });

    test('inequality by flag', () {
      expect(a1 == diffFlag, isFalse);
    });

    test('inequality by iso2', () {
      expect(a1 == diffIso2, isFalse);
    });

    test('props contains [country, code, flag, iso2] in order', () {
      expect(a1.props, ['Italy', '+39', '🇮🇹', 'IT']);
    });

    test('deduplicates in Set based on value equality', () {
      final set = <CountryPhoneCodeEntity>{};
      set.addAll([a1, a2, diffCountry]);
      expect(set.length, 2); // a1 & a2 collapse, diffCountry is unique
      expect(set.contains(a1), isTrue);
      expect(set.contains(a2), isTrue);
      expect(set.contains(diffCountry), isTrue);
    });
  });
}
