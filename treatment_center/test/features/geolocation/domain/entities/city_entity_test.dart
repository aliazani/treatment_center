import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';

void main() {
  group('CityEntity (Equatable)', () {
    const a1 = CityEntity(id: 1, name: 'Milan', stateCode: 'IT-25');
    const a2 = CityEntity(id: 1, name: 'Milan', stateCode: 'IT-25');
    const b = CityEntity(id: 2, name: 'Milan', stateCode: 'IT-25');
    const c = CityEntity(id: 1, name: 'Milano', stateCode: 'IT-25');
    const d = CityEntity(id: 1, name: 'Milan', stateCode: '25');

    test('value equality: same fields -> equal', () {
      expect(a1, equals(a2));
      expect(a1 == a2, isTrue);
    });

    test('hashCode: same fields -> equal hashCodes', () {
      expect(a1.hashCode, equals(a2.hashCode));
    });

    test('inequality by id', () {
      expect(a1 == b, isFalse);
    });

    test('inequality by name', () {
      expect(a1 == c, isFalse);
    });

    test('inequality by stateCode', () {
      expect(a1 == d, isFalse);
    });

    test('props contains [id, name, stateCode] in order', () {
      expect(a1.props, [1, 'Milan', 'IT-25']);
    });

    test('deduplicates in Set based on value', () {
      final set = <CityEntity>{};
      set.addAll([a1, a2, b]);
      expect(set.length, 2); // a1 and a2 collapse; b is distinct
      expect(set.contains(a1), isTrue);
      expect(set.contains(a2), isTrue);
      expect(set.contains(b), isTrue);
    });
  });
}
