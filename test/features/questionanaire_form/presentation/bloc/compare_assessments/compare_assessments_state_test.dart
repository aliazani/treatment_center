import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_state.dart';

@GenerateMocks([AssessmentFormEntity])
import 'compare_assessments_state_test.mocks.dart';

void main() {
  late MockAssessmentFormEntity assessmentA;
  late MockAssessmentFormEntity assessmentB;

  // Domain value‐objects for ComparisonResult
  late ItemComparison itemA;
  late ItemComparison itemB;
  late SectionComparison sectionA;
  late SectionComparison sectionB;
  late AssessmentOverviewComparison overviewA;
  late AssessmentOverviewComparison overviewB;
  late ComparisonStatistics statsA;
  late ComparisonStatistics statsB;
  late AssessmentComparisonResult resultA;
  late AssessmentComparisonResult resultB;

  setUp(() {
    assessmentA = MockAssessmentFormEntity();
    assessmentB = MockAssessmentFormEntity();
    when(assessmentA.id).thenReturn('1');
    when(assessmentB.id).thenReturn('2');

    itemA = const ItemComparison(
      itemId: 'i1',
      area: 'area1',
      firstValue: 'v1',
      secondValue: 'v2',
      type: ComparisonType.different,
      description: 'desc',
    );
    itemB = const ItemComparison(
      itemId: 'i2',
      area: 'area2',
      firstValue: null,
      secondValue: null,
      type: ComparisonType.unchanged,
      description: null,
    );

    sectionA = SectionComparison(
      sectionId: 's1',
      sectionTitle: 'Section 1',
      itemComparisons: [itemA],
      hasChanges: true,
    );
    sectionB = SectionComparison(
      sectionId: 's2',
      sectionTitle: 'Section 2',
      itemComparisons: [itemB],
      hasChanges: false,
    );

    overviewA = AssessmentOverviewComparison(
      firstFacilityName: 'Fac A',
      secondFacilityName: 'Fac B',
      firstAssessmentDate: DateTime(2025, 1, 1),
      secondAssessmentDate: DateTime(2025, 2, 1),
      firstAssessorName: 'Alice',
      secondAssessorName: 'Bob',
    );
    overviewB = AssessmentOverviewComparison(
      firstFacilityName: 'X',
      secondFacilityName: 'Y',
      firstAssessmentDate: DateTime(2024, 1, 1),
      secondAssessmentDate: DateTime(2024, 2, 1),
      firstAssessorName: 'X',
      secondAssessorName: 'Y',
    );

    statsA = const ComparisonStatistics(
      totalItems: 10,
      changedItems: 5,
      improvedItems: 3,
      declinedItems: 2,
      unchangedItems: 5,
      improvementPercentage: 30.0,
    );
    statsB = const ComparisonStatistics(
      totalItems: 20,
      changedItems: 0,
      improvedItems: 0,
      declinedItems: 0,
      unchangedItems: 20,
      improvementPercentage: 0.0,
    );

    resultA = AssessmentComparisonResult(
      sectionComparisons: [sectionA],
      overviewComparison: overviewA,
      statistics: statsA,
    );
    resultB = AssessmentComparisonResult(
      sectionComparisons: [sectionB],
      overviewComparison: overviewB,
      statistics: statsB,
    );
  });

  group('AssessmentComparisonState – Equatable implementation', () {
    test('Initial & Loading have empty props and are equal to themselves', () {
      expect(
        const AssessmentComparisonInitial(),
        equals(const AssessmentComparisonInitial()),
      );
      expect(const AssessmentComparisonInitial().props, isEmpty);

      expect(
        const AssessmentComparisonLoading(),
        equals(const AssessmentComparisonLoading()),
      );
      expect(const AssessmentComparisonLoading().props, isEmpty);
    });

    group('AssessmentSelectionLoaded', () {
      late List<AssessmentFormEntity> listA;
      late List<AssessmentFormEntity> listB;

      setUp(() {
        listA = [assessmentA];
        listB = [assessmentB];
      });

      test('equality with identical constructor args', () {
        final s1 = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentB,
        );
        final s2 = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentB,
        );
        expect(s1, equals(s2));
        expect(s1.props, [listA, assessmentA, assessmentB]);
      });

      test('inequality when any field differs', () {
        final base = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentB,
        );

        final diffList = AssessmentSelectionLoaded(
          availableAssessments: listB,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentB,
        );
        expect(base == diffList, isFalse);

        final diffFirst = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentB,
          secondSelectedAssessment: assessmentB,
        );
        expect(base == diffFirst, isFalse);

        final diffSecond = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentA,
        );
        expect(base == diffSecond, isFalse);
      });

      test('canCompare logic', () {
        // both selected, different ids => true
        final both = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentB,
        );
        expect(both.canCompare, isTrue);

        // one missing => false
        final oneNull = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: null,
        );
        expect(oneNull.canCompare, isFalse);

        // same id => false
        when(assessmentB.id).thenReturn('1');
        final sameId = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentB,
        );
        expect(sameId.canCompare, isFalse);
      });

      test('copyWith replaces and clears correctly', () {
        final orig = AssessmentSelectionLoaded(
          availableAssessments: listA,
          firstSelectedAssessment: assessmentA,
          secondSelectedAssessment: assessmentB,
        );
        final replaced = orig.copyWith(
          availableAssessments: listB,
          firstSelectedAssessment: assessmentB,
        );
        expect(
          replaced,
          equals(
            AssessmentSelectionLoaded(
              availableAssessments: listB,
              firstSelectedAssessment: assessmentB,
              secondSelectedAssessment: assessmentB,
            ),
          ),
        );

        final cleared = orig.copyWith(clearFirst: true, clearSecond: true);
        expect(cleared.firstSelectedAssessment, isNull);
        expect(cleared.secondSelectedAssessment, isNull);
      });
    });

    group('AssessmentComparisonLoaded', () {
      test('equality with identical constructor args', () {
        final l1 = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentB,
          comparisonResult: resultA,
        );
        final l2 = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentB,
          comparisonResult: resultA,
        );
        expect(l1, equals(l2));
        expect(l1.props, [
          assessmentA,
          assessmentB,
          resultA,
          <String>{},
          ComparisonFilter.all,
        ]);
      });

      test('inequality when any field differs', () {
        final base = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentB,
          comparisonResult: resultA,
        );

        final diffFirst = AssessmentComparisonLoaded(
          firstAssessment: assessmentB,
          secondAssessment: assessmentB,
          comparisonResult: resultA,
        );
        expect(base == diffFirst, isFalse);

        final diffSecond = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentA,
          comparisonResult: resultA,
        );
        expect(base == diffSecond, isFalse);

        final diffResult = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentB,
          comparisonResult: resultB,
        );
        expect(base == diffResult, isFalse);

        final diffSections = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentB,
          comparisonResult: resultA,
          expandedSections: {'x'},
        );
        expect(base == diffSections, isFalse);

        final diffFilter = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentB,
          comparisonResult: resultA,
          currentFilter: ComparisonFilter.differences,
        );
        expect(base == diffFilter, isFalse);
      });

      test('copyWith replaces fields correctly', () {
        final orig = AssessmentComparisonLoaded(
          firstAssessment: assessmentA,
          secondAssessment: assessmentB,
          comparisonResult: resultA,
        );
        final copy = orig.copyWith(
          firstAssessment: assessmentB,
          expandedSections: {'s'},
          currentFilter: ComparisonFilter.improved,
        );
        expect(
          copy,
          equals(
            AssessmentComparisonLoaded(
              firstAssessment: assessmentB,
              secondAssessment: assessmentB,
              comparisonResult: resultA,
              expandedSections: {'s'},
              currentFilter: ComparisonFilter.improved,
            ),
          ),
        );
      });
    });

    group('AssessmentComparisonError', () {
      test('equality and props', () {
        const err1 = AssessmentComparisonError(message: 'oops');
        const err2 = AssessmentComparisonError(message: 'oops');
        const errDiff = AssessmentComparisonError(message: 'fail');

        expect(err1, equals(err2));
        expect(err1.props, ['oops']);
        expect(err1 == errDiff, isFalse);
      });
    });

    group('Value Objects equality', () {
      test('ItemComparison equality/inequality', () {
        final a = itemA;
        final b = const ItemComparison(
          itemId: 'i1',
          area: 'area1',
          firstValue: 'v1',
          secondValue: 'v2',
          type: ComparisonType.different,
          description: 'desc',
        );
        final c = itemB;
        expect(a, equals(b));
        expect(a == c, isFalse);
      });

      test('SectionComparison equality/inequality', () {
        final a = sectionA;
        final b = SectionComparison(
          sectionId: 's1',
          sectionTitle: 'Section 1',
          itemComparisons: [itemA],
          hasChanges: true,
        );
        final c = sectionB;
        expect(a, equals(b));
        expect(a == c, isFalse);
      });

      test('AssessmentOverviewComparison equality/inequality', () {
        expect(overviewA, equals(overviewA));
        expect(overviewA == overviewB, isFalse);
      });

      test('ComparisonStatistics equality/inequality', () {
        expect(statsA, equals(statsA));
        expect(statsA == statsB, isFalse);
      });

      test('AssessmentComparisonResult equality/inequality', () {
        expect(resultA, equals(resultA));
        expect(resultA == resultB, isFalse);
      });
    });
  });
}
