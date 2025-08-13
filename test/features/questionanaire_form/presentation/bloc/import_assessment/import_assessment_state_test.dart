import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_state.dart';

import 'import_assessment_state_test.mocks.dart';

@GenerateMocks([AssessmentFormEntity])
void main() {
  late AssessmentFormEntity assessmentA;
  late AssessmentFormEntity assessmentB;

  setUp(() {
    assessmentA = MockAssessmentFormEntity();
    assessmentB = MockAssessmentFormEntity();
  });

  group('Equatable implementation', () {
    test('ImportInitial – value equality', () {
      expect(ImportAssessmentInitial(), equals(ImportAssessmentInitial()));
      expect(ImportAssessmentInitial().props, isEmpty);
    });

    test('ImportLoading – value equality', () {
      expect(ImportAssessmentLoading(), equals(ImportAssessmentLoading()));
      expect(ImportAssessmentLoading().props, isEmpty);
    });

    group('ImportSuccess', () {
      test('defaults & equality hold for identical values', () {
        final s1 = ImportAssessmentSuccess(
          assessment: assessmentA,
          statistics: {'rows': 1},
        );
        final s2 = ImportAssessmentSuccess(
          assessment: assessmentA,
          statistics: {'rows': 1},
        );

        expect(s1.message, 'Assessment imported successfully');
        expect(s1, equals(s2)); // identical assessment & stats
      });

      test('inequality when any field differs', () {
        final base = ImportAssessmentSuccess(
          assessment: assessmentA,
          statistics: {'rows': 1},
        );

        // different assessment
        final diffAssessment = ImportAssessmentSuccess(
          assessment: assessmentB,
          statistics: {'rows': 1},
        );
        expect(base == diffAssessment, isFalse);

        // different statistics
        final diffStats = ImportAssessmentSuccess(
          assessment: assessmentA,
          statistics: {'rows': 99},
        );
        expect(base == diffStats, isFalse);

        // different message
        final diffMsg = ImportAssessmentSuccess(
          assessment: assessmentA,
          statistics: {'rows': 1},
          message: 'custom',
        );
        expect(base == diffMsg, isFalse);
      });
    });

    group('ImportStatisticsLoaded', () {
      test('value equality honours statistics map', () {
        final a = ImportStatisticsLoaded(statistics: {'rows': 12});
        final b = ImportStatisticsLoaded(statistics: {'rows': 12});
        final c = ImportStatisticsLoaded(statistics: {'rows': 999});

        expect(a, equals(b));
        expect(a == c, isFalse);
      });
    });

    group('ImportFailure', () {
      test('value equality with and without errorCode', () {
        const failure1 = ImportAssessmentError(
          message: 'boom',
          errorCode: 'E1',
        );
        const failure2 = ImportAssessmentError(
          message: 'boom',
          errorCode: 'E1',
        );
        const failureDiffCode = ImportAssessmentError(
          message: 'boom',
          errorCode: 'E2',
        );
        const failureNoCode = ImportAssessmentError(message: 'boom');

        expect(failure1, equals(failure2));
        expect(failure1 == failureDiffCode, isFalse);
        expect(failure1 == failureNoCode, isFalse);
      });
    });
  });
}
