import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';

void main() {
  group('RegionEntity (Equatable)', () {
    const a1 = RegionEntity(
      id: 1,
      name: 'Lombardy',
      countryCode: 'IT',
      stateCode: 'IT-25',
    );
    const a2 = RegionEntity(
      id: 1,
      name: 'Lombardy',
      countryCode: 'IT',
      stateCode: 'IT-25',
    );
    const diffId = RegionEntity(
      id: 2,
      name: 'Lombardy',
      countryCode: 'IT',
      stateCode: 'IT-25',
    );
    const diffName = RegionEntity(
      id: 1,
      name: 'Tehran Province',
      countryCode: 'IT',
      stateCode: 'IT-25',
    );
    const diffCountryCode = RegionEntity(
      id: 1,
      name: 'Lombardy',
      countryCode: 'IR',
      stateCode: 'IT-25',
    );
    const diffStateCode = RegionEntity(
      id: 1,
      name: 'Lombardy',
      countryCode: 'IT',
      stateCode: '25',
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

    test('inequality by countryCode', () {
      expect(a1 == diffCountryCode, isFalse);
    });

    test('inequality by stateCode', () {
      expect(a1 == diffStateCode, isFalse);
    });

    test('props contains [id, name, countryCode, stateCode] in order', () {
      expect(a1.props, [1, 'Lombardy', 'IT', 'IT-25']);
    });

    test('deduplicates in Set based on value equality', () {
      final set = <RegionEntity>{};
      set.add(a1);
      set.add(a2);
      set.add(diffId);
      expect(set.length, 2); // a1 & a2 collapse, diffId is unique
      expect(set.contains(a1), isTrue);
      expect(set.contains(a2), isTrue);
      expect(set.contains(diffId), isTrue);
    });
  });
}
