import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_event.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ImportOptions])
import 'import_assessment_event_test.mocks.dart';

void main() {
  late ImportOptions optsA;
  late ImportOptions optsB;

  setUp(() {
    optsA = MockImportOptions();
    optsB = MockImportOptions();
  });

  group('Equatable implementation', () {
    group('ImportAssessmentFromFileEvent', () {
      test('value equality for identical values', () {
        const path = '/tmp/file.json';

        final e1 = ImportAssessmentFromFileEvent(
          filePath: path,
          format: 'json',
          options: optsA,
          saveAfterImport: true,
        );

        final e2 = ImportAssessmentFromFileEvent(
          filePath: path,
          format: 'json',
          options: optsA,
          saveAfterImport: true,
        );

        expect(e1, equals(e2));
      });

      test('inequality when any prop differs', () {
        const path = '/tmp/file.json';

        final base = ImportAssessmentFromFileEvent(
          filePath: path,
          format: 'json',
          options: optsA,
          saveAfterImport: true,
        );

        // different path
        final diffPath = ImportAssessmentFromFileEvent(
          filePath: '/other.json',
          format: 'json',
          options: optsA,
          saveAfterImport: true,
        );
        expect(base == diffPath, isFalse);

        // different format
        final diffFormat = ImportAssessmentFromFileEvent(
          filePath: path,
          format: 'yaml',
          options: optsA,
          saveAfterImport: true,
        );
        expect(base == diffFormat, isFalse);

        // different options instance
        final diffOpts = ImportAssessmentFromFileEvent(
          filePath: path,
          format: 'json',
          options: optsB,
          saveAfterImport: true,
        );
        expect(base == diffOpts, isFalse);

        // different saveAfterImport flag
        final diffSave = ImportAssessmentFromFileEvent(
          filePath: path,
          format: 'json',
          options: optsA,
          saveAfterImport: false,
        );
        expect(base == diffSave, isFalse);
      });
    });

    group('ImportAssessmentFromExcelEvent', () {
      const path = '/tmp/file.xlsx';

      test('defaults & equality', () {
        final a = ImportAssessmentFromExcelEvent(filePath: path);
        final b = ImportAssessmentFromExcelEvent(filePath: path);
        expect(a.importSectionDetails, isTrue);
        expect(a.validateAfterImport, isTrue);
        expect(a.saveAfterImport, isFalse);
        expect(a, equals(b));
      });

      test('inequality when flags differ', () {
        final base = ImportAssessmentFromExcelEvent(filePath: path);

        final noSection = ImportAssessmentFromExcelEvent(
          filePath: path,
          importSectionDetails: false,
        );
        expect(base == noSection, isFalse);

        final noValidate = ImportAssessmentFromExcelEvent(
          filePath: path,
          validateAfterImport: false,
        );
        expect(base == noValidate, isFalse);

        final doSave = ImportAssessmentFromExcelEvent(
          filePath: path,
          saveAfterImport: true,
        );
        expect(base == doSave, isFalse);
      });
    });

    group('GetImportStatisticsEvent', () {
      const path = '/tmp/file.csv';

      test('equality & inequality', () {
        final a = GetImportStatisticsEvent(filePath: path, format: 'csv');
        final b = GetImportStatisticsEvent(filePath: path, format: 'csv');
        final c = GetImportStatisticsEvent(filePath: path, format: 'xml');

        expect(a, equals(b));
        expect(a == c, isFalse);
      });
    });

    test('ResetImportStateEvent – value equality', () {
      expect(ResetImportStateEvent(), equals(ResetImportStateEvent()));
      expect(ResetImportStateEvent().props, isEmpty);
    });
  });

  group('ImportAssessmentFromExcelBytes', () {
    test('value equality for identical values', () {
      final bytes1 = Uint8List.fromList([1, 2, 3]);
      final bytes2 = Uint8List.fromList([1, 2, 3]);
      const name = 'test.xlsx';

      final e1 = ImportAssessmentFromExcelBytes(
        bytes: bytes1,
        originalName: name,
        saveAfterImport: true,
      );
      final e2 = ImportAssessmentFromExcelBytes(
        bytes: bytes2,
        originalName: name,
        saveAfterImport: true,
      );

      expect(e1, equals(e2));
    });

    test('inequality when any prop differs', () {
      final bytesA = Uint8List.fromList([1, 2, 3]);
      final bytesB = Uint8List.fromList([4, 5, 6]);
      const name = 'test.xlsx';

      final base = ImportAssessmentFromExcelBytes(
        bytes: bytesA,
        originalName: name,
        saveAfterImport: true,
      );

      final diffBytes = ImportAssessmentFromExcelBytes(
        bytes: bytesB,
        originalName: name,
        saveAfterImport: true,
      );
      expect(base == diffBytes, isFalse);

      final diffName = ImportAssessmentFromExcelBytes(
        bytes: bytesA,
        originalName: 'other.xlsx',
        saveAfterImport: true,
      );
      expect(base == diffName, isFalse);

      final diffSave = ImportAssessmentFromExcelBytes(
        bytes: bytesA,
        originalName: name,
        saveAfterImport: false,
      );
      expect(base == diffSave, isFalse);
    });
  });
}
