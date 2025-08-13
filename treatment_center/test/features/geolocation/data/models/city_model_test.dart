import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/data/models/city_model.dart';

void main() {
  group('CityModel', () {
    final validJson = {'id': 1, 'name': 'Milan', 'state_code': 'MI'};

    test('fromJson returns a proper CityModel', () {
      final model = CityModel.fromJson(validJson);

      expect(model.id, 1);
      expect(model.name, 'Milan');
      expect(model.stateCode, 'MI');
    });

    test('toJson returns snake_case keys matching input json', () {
      final model = CityModel(id: 1, name: 'Milan', stateCode: 'MI');

      expect(model.toJson(), equals(validJson));
    });

    test('fromEntity copies fields correctly', () {
      const entity = CityEntity(id: 7, name: 'Tehran', stateCode: 'TEH');
      final model = CityModel.fromEntity(entity);

      expect(model.id, 7);
      expect(model.name, 'Tehran');
      expect(model.stateCode, 'TEH');
    });

    test('round-trip: fromJson(...).toJson() equals original json', () {
      final model = CityModel.fromJson(validJson);
      expect(model.toJson(), equals(validJson));
    });

    test('fromJson throws when a required key is missing', () {
      final badJson = {
        // 'id': 1,  // missing
        'name': 'Milan',
        'state_code': 'MI',
      };

      expect(() => CityModel.fromJson(badJson), throwsA(isA<TypeError>()));
    });

    test('fromJson throws when a value has wrong type', () {
      final badJson = {
        'id': '1', // wrong type
        'name': 'Milan',
        'state_code': 'MI',
      };

      expect(() => CityModel.fromJson(badJson), throwsA(isA<TypeError>()));
    });
  });
}
