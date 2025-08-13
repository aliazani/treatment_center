import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/data/models/country_model.dart';

void main() {
  group('CountryModel', () {
    final validJson = {
      'id': 1,
      'name': 'Italy',
      'iso2': 'IT',
      'emoji': '🇮🇹',
      'phonecode': '39',
    };

    test('fromJson returns a proper CountryModel', () {
      final model = CountryModel.fromJson(validJson);

      expect(model.id, 1);
      expect(model.name, 'Italy');
      expect(model.iso2, 'IT');
      expect(model.emoji, '🇮🇹');
      expect(model.phonecode, '39');
    });

    test('toJson returns matching map', () {
      final model = CountryModel(
        id: 1,
        name: 'Italy',
        iso2: 'IT',
        emoji: '🇮🇹',
        phonecode: '39',
      );

      expect(model.toJson(), equals(validJson));
    });

    test('fromEntity copies all fields correctly', () {
      const entity = CountryEntity(
        id: 2,
        name: 'Iran',
        iso2: 'IR',
        emoji: '🇮🇷',
        phonecode: '98',
      );

      final model = CountryModel.fromEntity(entity);

      expect(model.id, 2);
      expect(model.name, 'Iran');
      expect(model.iso2, 'IR');
      expect(model.emoji, '🇮🇷');
      expect(model.phonecode, '98');
    });

    test('round-trip: fromJson(...).toJson() equals original json', () {
      final model = CountryModel.fromJson(validJson);
      expect(model.toJson(), equals(validJson));
    });

    test('fromJson throws when a required key is missing', () {
      final badJson = {
        // 'id': 1, // missing id
        'name': 'Italy',
        'iso2': 'IT',
        'emoji': '🇮🇹',
        'phonecode': '39',
      };

      expect(() => CountryModel.fromJson(badJson), throwsA(isA<TypeError>()));
    });

    test('fromJson throws when a value has wrong type', () {
      final badJson = {
        'id': '1', // wrong type
        'name': 'Italy',
        'iso2': 'IT',
        'emoji': '🇮🇹',
        'phonecode': '39',
      };

      expect(() => CountryModel.fromJson(badJson), throwsA(isA<TypeError>()));
    });
  });
}
