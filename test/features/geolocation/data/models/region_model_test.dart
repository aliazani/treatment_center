import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/data/models/region_model.dart'; // adjust if needed

void main() {
  group('RegionModel', () {
    final validJson = {
      'id': 10,
      'name': 'Lombardy',
      'country_code': 'IT',
      'iso3166_2': 'IT-25',
    };

    test('fromJson returns a proper RegionModel', () {
      final model = RegionModel.fromJson(validJson);

      expect(model.id, 10);
      expect(model.name, 'Lombardy');
      expect(model.countryCode, 'IT');
      expect(model.stateCode, 'IT-25');
    });

    test('toJson returns matching snake_case keys', () {
      const model = RegionModel(
        id: 10,
        name: 'Lombardy',
        countryCode: 'IT',
        stateCode: 'IT-25',
      );

      expect(model.toJson(), equals(validJson));
    });

    test('fromEntity copies fields correctly', () {
      const entity = RegionEntity(
        id: 20,
        name: 'Tehran Province',
        countryCode: 'IR',
        stateCode: 'IR-23',
      );

      final model = RegionModel.fromEntity(entity);

      expect(model.id, 20);
      expect(model.name, 'Tehran Province');
      expect(model.countryCode, 'IR');
      expect(model.stateCode, 'IR-23');
    });

    test('round-trip: fromJson(...).toJson() equals original json', () {
      final model = RegionModel.fromJson(validJson);
      expect(model.toJson(), equals(validJson));
    });

    test('fromJson throws when a required key is missing', () {
      final missingKeyJson = {
        // 'id': 10, // missing
        'name': 'Lombardy',
        'country_code': 'IT',
        'iso3166_2': 'IT-25',
      };

      expect(
        () => RegionModel.fromJson(missingKeyJson),
        throwsA(isA<TypeError>()),
      );
    });

    test('fromJson throws when a value has wrong type', () {
      final wrongTypeJson = {
        'id': '10', // should be int
        'name': 'Lombardy',
        'country_code': 'IT',
        'iso3166_2': 'IT-25',
      };

      expect(
        () => RegionModel.fromJson(wrongTypeJson),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
