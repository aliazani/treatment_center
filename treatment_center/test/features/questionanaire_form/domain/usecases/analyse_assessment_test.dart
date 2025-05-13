import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/analyse_assessment.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate mock for the repository
@GenerateMocks([AssessmentRepository])
import './analyse_assessment_test.mocks.dart';

void main() {
  late AnalyzeAssessment useCase;
  late MockAssessmentRepository mockRepository;
  final tAssessmentId = 'test-assessment-id';

  // Test fixtures
  final dummyAssessment = TestAssessmentFixtures.createTestAssessmentForm(
    id: 'dummy-id',
  );
  final tMixedRatingsAssessment =
      TestAssessmentFixtures.createMixedRatingsAssessment(id: tAssessmentId);
  final tPartiallyRatedAssessment =
      TestAssessmentFixtures.createPartiallyRatedAssessment(id: tAssessmentId);
  final tSubmittedAssessment = TestAssessmentFixtures.createSubmittedAssessment(
    id: tAssessmentId,
    submissionDate: DateTime(2024, 5, 1),
  );

  setUpAll(() {
    // Register a dummy value for Either<Failure, AssessmentForm>
    provideDummy<Either<Failure, AssessmentForm>>(Right(dummyAssessment));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = AnalyzeAssessment(mockRepository);
  });

  // Helper function to verify basic test setup
  void setUpSuccessfulGetAssessment(AssessmentForm assessment) {
    when(
      mockRepository.getAssessment(any),
    ).thenAnswer((_) async => Right(assessment));
  }

  // Helper function to analyze assessment and return the result
  Future<AssessmentAnalysis> analyzeAssessment() async {
    final result = await useCase(Params(assessmentId: tAssessmentId));
    expect(result.isRight(), true);
    return (result as Right<Failure, AssessmentAnalysis>).value;
  }

  // Helper function to verify common assertions after analysis
  void verifyBasicCalls() {
    verify(mockRepository.getAssessment(tAssessmentId));
    verifyNoMoreInteractions(mockRepository);
  }

  group('AnalyzeAssessment', () {
    test('should analyze assessment and return correct statistics', () async {
      // arrange
      setUpSuccessfulGetAssessment(tMixedRatingsAssessment);

      // act
      final analysis = await analyzeAssessment();

      // assert
      // Verify assessment identification
      expect(analysis.assessmentId, tAssessmentId);
      expect(
        analysis.facilityName,
        tMixedRatingsAssessment.facilityIdentification.facilityName,
      );
      expect(
        analysis.assessmentDate,
        tMixedRatingsAssessment.assessorInfo.assessmentDate,
      );
      expect(analysis.isSubmitted, tMixedRatingsAssessment.isSubmitted);
      expect(analysis.submissionDate, tMixedRatingsAssessment.submissionDate);

      // Verify counts
      final totalItems = tMixedRatingsAssessment.sections.fold<int>(
        0,
        (sum, section) => sum + section.items.length,
      );
      expect(analysis.totalItems, totalItems);
      expect(analysis.completedItems, totalItems);

      // Verify ratings distribution - check values match the fixture exactly
      expect(analysis.meetsTargetCount, 1); // 1 item with "Meets Target"
      expect(analysis.partiallyMeetsCount, 1); // 1 item with "Partially Meets"
      expect(analysis.doesNotMeetCount, 2); // 2 items with "Does Not Meet"
      expect(analysis.dontKnowCount, 1); // 1 item with "Don't Know"
      expect(analysis.notApplicableCount, 1); // 1 item with "Not Applicable"

      // Verify total counts match
      expect(
        analysis.meetsTargetCount +
            analysis.partiallyMeetsCount +
            analysis.doesNotMeetCount +
            analysis.dontKnowCount +
            analysis.notApplicableCount,
        analysis.completedItems,
      );

      // Verify completion percentage
      expect(analysis.completionPercentage, 100.0); // All items are rated

      verifyBasicCalls();
    });

    test('should analyze partially rated assessment correctly', () async {
      // arrange
      setUpSuccessfulGetAssessment(tPartiallyRatedAssessment);

      // act
      final analysis = await analyzeAssessment();

      // assert
      // Calculate expected values
      final totalItems = tPartiallyRatedAssessment.sections.fold<int>(
        0,
        (sum, section) => sum + section.items.length,
      );
      final expectedCompletedItems = tPartiallyRatedAssessment.sections
          .fold<int>(
            0,
            (sum, section) =>
                sum +
                section.items
                    .where((item) => item.selectedRating != null)
                    .length,
          );
      final expectedPercentage = (expectedCompletedItems / totalItems) * 100;

      // Verify counts
      expect(analysis.totalItems, totalItems);
      expect(analysis.completedItems, expectedCompletedItems);
      expect(analysis.meetsTargetCount, expectedCompletedItems);
      expect(analysis.partiallyMeetsCount, 0);
      expect(analysis.doesNotMeetCount, 0);
      expect(analysis.dontKnowCount, 0);
      expect(analysis.notApplicableCount, 0);
      expect(analysis.completionPercentage, expectedPercentage);

      verifyBasicCalls();
    });

    test('should handle submitted assessment correctly', () async {
      // arrange
      setUpSuccessfulGetAssessment(tSubmittedAssessment);

      // act
      final analysis = await analyzeAssessment();

      // assert
      expect(analysis.isSubmitted, true);
      expect(analysis.submissionDate, tSubmittedAssessment.submissionDate);

      verifyBasicCalls();
    });

    test(
      'should handle assessment with extreme section and item counts',
      () async {
        // arrange
        final largeAssessment = TestAssessmentFixtures.createTestAssessmentForm(
          id: tAssessmentId,
          sectionCount: 10,
          itemsPerSection: 15,
          withRatings: true,
        );
        setUpSuccessfulGetAssessment(largeAssessment);

        // act
        final analysis = await analyzeAssessment();

        // assert
        final expectedTotalItems = 10 * 15; // sectionCount * itemsPerSection
        expect(analysis.totalItems, expectedTotalItems);
        expect(analysis.completedItems, expectedTotalItems);
        expect(analysis.meetsTargetCount, expectedTotalItems);

        verifyBasicCalls();
      },
    );

    test('should handle assessment with custom item configuration', () async {
      // arrange
      final customAssessment = TestAssessmentFixtures.createCustomAssessment(
        id: tAssessmentId,
      );
      setUpSuccessfulGetAssessment(customAssessment);

      // act
      final analysis = await analyzeAssessment();

      // assert
      expect(analysis.totalItems, 4);
      expect(analysis.completedItems, 3); // One item has no rating
      expect(analysis.meetsTargetCount, 1);
      expect(analysis.partiallyMeetsCount, 1);
      expect(analysis.doesNotMeetCount, 1);
      expect(analysis.dontKnowCount, 0);
      expect(analysis.notApplicableCount, 0);
      expect(analysis.completionPercentage, 75.0); // 3/4 = 75%

      verifyBasicCalls();
    });

    test('should return failure when getAssessment fails', () async {
      // arrange
      when(mockRepository.getAssessment(any)).thenAnswer(
        (_) async => const Left(CacheFailure(message: 'Cache error')),
      );

      // act
      final result = await useCase(Params(assessmentId: tAssessmentId));

      // assert
      expect(result, const Left(CacheFailure(message: 'Cache error')));
      verifyBasicCalls();
    });

    test('should handle exceptions and return ValidationFailure', () async {
      // arrange
      when(
        mockRepository.getAssessment(any),
      ).thenThrow(Exception('Test exception'));

      // act
      final result = await useCase(Params(assessmentId: tAssessmentId));

      // assert
      expect(result.isLeft(), true);
      final failure = (result as Left).value as ValidationFailure;
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('Test exception'));

      verifyBasicCalls();
    });

    test('should handle assessment with no items', () async {
      // arrange
      final emptyAssessment = TestAssessmentFixtures.createTestAssessmentForm(
        id: tAssessmentId,
        sectionCount: 0,
      );
      setUpSuccessfulGetAssessment(emptyAssessment);

      // act
      final analysis = await analyzeAssessment();

      // assert - verify all counts are zero
      expect(analysis.totalItems, 0);
      expect(analysis.completedItems, 0);
      expect(analysis.meetsTargetCount, 0);
      expect(analysis.partiallyMeetsCount, 0);
      expect(analysis.doesNotMeetCount, 0);
      expect(analysis.dontKnowCount, 0);
      expect(analysis.notApplicableCount, 0);
      expect(analysis.completionPercentage, 0.0);

      verifyBasicCalls();
    });

    test('should handle assessment with sections but no items', () async {
      // arrange
      final assessmentWithEmptySections =
          TestAssessmentFixtures.createAssessmentWithEmptySections(
            id: tAssessmentId,
          );
      setUpSuccessfulGetAssessment(assessmentWithEmptySections);

      // act
      final analysis = await analyzeAssessment();

      // assert - verify all counts are zero
      expect(analysis.totalItems, 0);
      expect(analysis.completedItems, 0);
      expect(analysis.meetsTargetCount, 0);
      expect(analysis.partiallyMeetsCount, 0);
      expect(analysis.doesNotMeetCount, 0);
      expect(analysis.dontKnowCount, 0);
      expect(analysis.notApplicableCount, 0);
      expect(analysis.completionPercentage, 0.0);

      verifyBasicCalls();
    });
  });

  group('AssessmentAnalysis Equality', () {
    test(
      'two AssessmentAnalysis instances with same values should be equal',
      () {
        // arrange
        final baseAnalysis = TestAssessmentFixtures.createTestAnalysis();
        final sameAnalysis = TestAssessmentFixtures.createTestAnalysis();

        // assert
        expect(baseAnalysis, equals(sameAnalysis));
      },
    );

    test(
      'two AssessmentAnalysis instances with different values should not be equal',
      () {
        // arrange
        final baseAnalysis = TestAssessmentFixtures.createTestAnalysis();
        final differentAnalysis = TestAssessmentFixtures.createTestAnalysis(
          assessmentId: 'different-id',
        );

        // assert
        expect(baseAnalysis, isNot(equals(differentAnalysis)));
      },
    );

    test('all fields in props are considered for equality', () {
      // arrange
      final baseAnalysis = TestAssessmentFixtures.createTestAnalysis();

      // Test each field variation individually
      final variations = {
        'assessmentId': TestAssessmentFixtures.createTestAnalysis(
          assessmentId: 'different-id',
        ),
        'facilityName': TestAssessmentFixtures.createTestAnalysis(
          facilityName: 'Different Facility',
        ),
        'assessmentDate': TestAssessmentFixtures.createTestAnalysis(
          assessmentDate: DateTime(2023, 6, 10),
        ),
        'completionPercentage': TestAssessmentFixtures.createTestAnalysis(
          completionPercentage: 80.0,
        ),
        'isSubmitted': TestAssessmentFixtures.createTestAnalysis(
          isSubmitted: false,
        ),
        'totalItems': TestAssessmentFixtures.createTestAnalysis(totalItems: 15),
        'completedItems': TestAssessmentFixtures.createTestAnalysis(
          completedItems: 9,
        ),
        'meetsTargetCount': TestAssessmentFixtures.createTestAnalysis(
          meetsTargetCount: 6,
        ),
        'partiallyMeetsCount': TestAssessmentFixtures.createTestAnalysis(
          partiallyMeetsCount: 3,
        ),
        'doesNotMeetCount': TestAssessmentFixtures.createTestAnalysis(
          doesNotMeetCount: 2,
        ),
        'dontKnowCount': TestAssessmentFixtures.createTestAnalysis(
          dontKnowCount: 1,
        ),
        'notApplicableCount': TestAssessmentFixtures.createTestAnalysis(
          notApplicableCount: 1,
        ),
        'submissionDate': TestAssessmentFixtures.createTestAnalysis(
          submissionDate: DateTime(2023, 5, 20),
        ),
      };

      // Check that each variation is not equal to the base
      variations.forEach((fieldName, variant) {
        expect(
          baseAnalysis,
          isNot(equals(variant)),
          reason: 'Failed for field: $fieldName',
        );
      });
    });
  });

  group('Params Equality', () {
    test('two Params with same assessmentId should be equal', () {
      // arrange
      final params1 = Params(assessmentId: 'test-id');
      final params2 = Params(assessmentId: 'test-id');

      // assert
      expect(params1, equals(params2));
    });

    test('two Params with different assessmentId should not be equal', () {
      // arrange
      final params1 = Params(assessmentId: 'test-id-1');
      final params2 = Params(assessmentId: 'test-id-2');

      // assert
      expect(params1, isNot(equals(params2)));
    });
  });
}
