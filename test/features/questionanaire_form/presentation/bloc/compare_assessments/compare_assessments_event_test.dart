import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_state.dart';

void main() {
  group('CompareAssessmentsEvent – Equatable implementation', () {
    group('LoadAssessmentsForComparison', () {
      test('value equality & empty props', () {
        expect(
          LoadAssessmentsForComparison(),
          equals(LoadAssessmentsForComparison()),
        );
        expect(LoadAssessmentsForComparison().props, isEmpty);
      });
    });

    group('SelectFirstAssessment', () {
      const id1 = 'first';
      const id2 = 'second';

      test('equality when assessmentId is the same', () {
        final a = SelectFirstAssessment(assessmentId: id1);
        final b = SelectFirstAssessment(assessmentId: id1);
        expect(a, equals(b));
        expect(a.props, [id1]);
      });

      test('inequality when assessmentId differs', () {
        final base = SelectFirstAssessment(assessmentId: id1);
        final diff = SelectFirstAssessment(assessmentId: id2);
        expect(base == diff, isFalse);
      });
    });

    group('SelectSecondAssessment', () {
      const id1 = 'one';
      const id2 = 'two';

      test('equality when assessmentId is the same', () {
        final a = SelectSecondAssessment(assessmentId: id1);
        final b = SelectSecondAssessment(assessmentId: id1);
        expect(a, equals(b));
        expect(a.props, [id1]);
      });

      test('inequality when assessmentId differs', () {
        final base = SelectSecondAssessment(assessmentId: id1);
        final diff = SelectSecondAssessment(assessmentId: id2);
        expect(base == diff, isFalse);
      });
    });

    group('CompareAssessments', () {
      test('value equality & empty props', () {
        expect(CompareAssessments(), equals(CompareAssessments()));
        expect(CompareAssessments().props, isEmpty);
      });
    });

    group('SwitchComparisonOrder', () {
      test('value equality & empty props', () {
        expect(SwitchComparisonOrder(), equals(SwitchComparisonOrder()));
        expect(SwitchComparisonOrder().props, isEmpty);
      });
    });

    group('ResetComparison', () {
      test('value equality & empty props', () {
        expect(ResetComparison(), equals(ResetComparison()));
        expect(ResetComparison().props, isEmpty);
      });
    });

    group('ToggleComparisonSection', () {
      const sectionA = 'secA';
      const sectionB = 'secB';

      test('equality when sectionId is the same', () {
        final a = ToggleComparisonSection(sectionId: sectionA);
        final b = ToggleComparisonSection(sectionId: sectionA);
        expect(a, equals(b));
        expect(a.props, [sectionA]);
      });

      test('inequality when sectionId differs', () {
        final base = ToggleComparisonSection(sectionId: sectionA);
        final diff = ToggleComparisonSection(sectionId: sectionB);
        expect(base == diff, isFalse);
      });
    });

    group('FilterComparisonByType', () {
      // Use two distinct enum values to test equality/inequality
      final filters = ComparisonFilter.values;
      assert(
        filters.length >= 2,
        'Need at least two ComparisonFilter values for this test',
      );

      final filterA = filters.first;
      final filterB = filters.last;

      test('equality when filter is the same', () {
        final a = FilterComparisonByType(filter: filterA);
        final b = FilterComparisonByType(filter: filterA);
        expect(a, equals(b));
        expect(a.props, [filterA]);
      });

      test('inequality when filter differs', () {
        final base = FilterComparisonByType(filter: filterA);
        final diff = FilterComparisonByType(filter: filterB);
        expect(base == diff, isFalse);
      });
    });
  });
}
