import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';

void main() {
  group('CountryEntity (Equatable)', () {
    const a1 = CountryEntity(
      id: 1,
      name: 'Italy',
      iso2: 'IT',
      emoji: '🇮🇹',
      phonecode: '39',
    );
    const a2 = CountryEntity(
      id: 1,
      name: 'Italy',
      iso2: 'IT',
      emoji: '🇮🇹',
      phonecode: '39',
    );
    const diffId = CountryEntity(
      id: 2,
      name: 'Italy',
      iso2: 'IT',
      emoji: '🇮🇹',
      phonecode: '39',
    );
    const diffName = CountryEntity(
      id: 1,
      name: 'Iran',
      iso2: 'IT',
      emoji: '🇮🇹',
      phonecode: '39',
    );
    const diffIso2 = CountryEntity(
      id: 1,
      name: 'Italy',
      iso2: 'IR',
      emoji: '🇮🇹',
      phonecode: '39',
    );
    const diffEmoji = CountryEntity(
      id: 1,
      name: 'Italy',
      iso2: 'IT',
      emoji: '🇮🇷',
      phonecode: '39',
    );
    const diffPhone = CountryEntity(
      id: 1,
      name: 'Italy',
      iso2: 'IT',
      emoji: '🇮🇹',
      phonecode: '98',
    );

    test('value equality: same fields -> equal', () {
      expect(a1, equals(a2));
      expect(a1 == a2, isTrue);
    });

    test('hashCode: same fields -> equal hashCodes', () {
      expect(a1.hashCode, equals(a2.hashCode));
    });

    test('inequality by id', () {
      expect(a1 == diffId, isFalse);
    });

    test('inequality by name', () {
      expect(a1 == diffName, isFalse);
    });

    test('inequality by iso2', () {
      expect(a1 == diffIso2, isFalse);
    });

    test('inequality by emoji', () {
      expect(a1 == diffEmoji, isFalse);
    });

    test('inequality by phonecode', () {
      expect(a1 == diffPhone, isFalse);
    });

    test('props contains [id, name, iso2, emoji, phonecode] in order', () {
      expect(a1.props, [1, 'Italy', 'IT', '🇮🇹', '39']);
    });

    test('deduplicates in Set based on value equality', () {
      final set = <CountryEntity>{};
      set.addAll([a1, a2, diffId]);
      expect(set.length, 2); // a1 & a2 collapse, diffId is unique
      expect(set.contains(a1), isTrue);
      expect(set.contains(a2), isTrue);
      expect(set.contains(diffId), isTrue);
    });
  });
}
