import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/validation_result_entity.dart';

void main() {
  group('ValidationResultEntity', () {
    test('valid(): isValid true, other fields null, userMessage empty', () {
      const r = ValidationResultEntity.valid();
      expect(r.isValid, isTrue);
      expect(r.incompleteFieldName, isNull);
      expect(r.incompleteFieldMessage, isNull);
      expect(r.subsectionName, isNull);
      expect(r.userMessage, equals(''));
    });

    test('invalid(): sets fields and isValid=false', () {
      const r = ValidationResultEntity.invalid(
        fieldName: 'Phone number',
        message: 'Phone number is required',
        subsection: 'Assessor Info',
      );
      expect(r.isValid, isFalse);
      expect(r.incompleteFieldName, 'Phone number');
      expect(r.incompleteFieldMessage, 'Phone number is required');
      expect(r.subsectionName, 'Assessor Info');
    });

    test('userMessage uses subsection when provided (overrides message)', () {
      const r = ValidationResultEntity.invalid(
        fieldName: 'Phone number',
        message: 'Phone number is required',
        subsection: 'Assessor Info',
      );
      expect(r.userMessage, 'Please complete "Phone number" in Assessor Info');
    });

    test('userMessage uses message when no subsection', () {
      const r = ValidationResultEntity.invalid(
        fieldName: 'Country',
        message: 'Select a country',
      );
      expect(r.userMessage, 'Select a country');
    });

    test(
      'userMessage falls back to default when message is null (via base ctor)',
      () {
        const r = ValidationResultEntity(
          isValid: false,
          incompleteFieldName: 'Email',
          // incompleteFieldMessage intentionally null
        );
        expect(r.userMessage, 'Please complete the required field: Email');
      },
    );

    group('Equatable', () {
      test('two valid() instances are equal', () {
        expect(
          const ValidationResultEntity.valid(),
          equals(const ValidationResultEntity.valid()),
        );
      });

      test('two identical invalid() instances are equal', () {
        const a = ValidationResultEntity.invalid(
          fieldName: 'A',
          message: 'msg',
          subsection: 'Sub',
        );
        const b = ValidationResultEntity.invalid(
          fieldName: 'A',
          message: 'msg',
          subsection: 'Sub',
        );
        expect(a, equals(b));
      });

      test('different message -> not equal', () {
        const a = ValidationResultEntity.invalid(fieldName: 'A', message: 'x');
        const b = ValidationResultEntity.invalid(fieldName: 'A', message: 'y');
        expect(a, isNot(b));
      });

      test('different fieldName -> not equal', () {
        const a = ValidationResultEntity.invalid(fieldName: 'A', message: 'm');
        const b = ValidationResultEntity.invalid(fieldName: 'B', message: 'm');
        expect(a, isNot(b));
      });

      test('different subsection -> not equal', () {
        const a = ValidationResultEntity.invalid(
          fieldName: 'A',
          message: 'm',
          subsection: 'S1',
        );
        const b = ValidationResultEntity.invalid(
          fieldName: 'A',
          message: 'm',
          subsection: 'S2',
        );
        expect(a, isNot(b));
      });
    });
  });
  group('ValidationResultEntity.invalid (runtime)', () {
    test('populates fields without subsection and executes redirect', () {
      // runtime strings prevent const construction
      final fieldName = 'Email ${DateTime.now().microsecondsSinceEpoch}';
      final message =
          'Email is required ${DateTime.now().microsecondsSinceEpoch}';

      // NOTE: no `const` here
      final r = ValidationResultEntity.invalid(
        fieldName: fieldName,
        message: message,
      );

      expect(r.isValid, isFalse);
      expect(r.incompleteFieldName, fieldName);
      expect(r.incompleteFieldMessage, message);
      expect(r.subsectionName, isNull);
      expect(r.userMessage, message);
    });

    test('populates fields with subsection and executes redirect', () {
      final fieldName = 'Phone number ${DateTime.now().microsecondsSinceEpoch}';
      final message =
          'Phone number is required ${DateTime.now().microsecondsSinceEpoch}';
      final subsection =
          'Assessor Info ${DateTime.now().microsecondsSinceEpoch}';

      final r = ValidationResultEntity.invalid(
        fieldName: fieldName,
        message: message,
        subsection: subsection,
      );

      expect(r.isValid, isFalse);
      expect(r.incompleteFieldName, fieldName);
      expect(r.incompleteFieldMessage, message);
      expect(r.subsectionName, subsection);
      expect(r.userMessage, 'Please complete "$fieldName" in $subsection');
    });
  });

  group('still keep some const-based equality tests', () {
    test('two identical invalid() instances are equal (const ok here)', () {
      const a = ValidationResultEntity.invalid(
        fieldName: 'A',
        message: 'm',
        subsection: 'S',
      );
      const b = ValidationResultEntity.invalid(
        fieldName: 'A',
        message: 'm',
        subsection: 'S',
      );
      expect(a, equals(b));
    });
  });
}
