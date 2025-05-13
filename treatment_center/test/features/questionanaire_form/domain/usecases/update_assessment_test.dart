import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/update_assessment.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate mock for the repository
@GenerateMocks([AssessmentRepository])
import 'update_assessment_test.mocks.dart';

void main() {
  late UpdateAssessment useCase;
  late MockAssessmentRepository mockRepository;

  setUpAll(() {
    // Register dummy values for the Either types used in this test file
    provideDummy<Either<Failure, AssessmentForm>>(
      Right(TestAssessmentFixtures.createTestAssessmentForm(id: 'dummy-id')),
    );
    provideDummy<Either<Failure, bool>>(const Right(true));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = UpdateAssessment(mockRepository);
  });

  final tAssessmentId = 'test-assessment-id';
  final tAssessment = TestAssessmentFixtures.createTestAssessmentForm(
    id: tAssessmentId,
  );

  // Create a new assessor info for testing updates
  final tUpdatedAssessorInfo = AssessorInfo(
    name: 'Updated Name',
    email: 'updated@example.com',
    phoneNumber: '987654321',
    assessmentDate: DateTime(2023, 6, 15),
  );

  // Assessment with updated assessor info
  final tUpdatedAssessment = tAssessment.copyWith(
    assessorInfo: tUpdatedAssessorInfo,
  );

  group('UpdateAssessment', () {
    test(
      'should update assessment when repository operations succeed',
      () async {
        // arrange
        when(
          mockRepository.getAssessment(any),
        ).thenAnswer((_) async => Right(tAssessment));
        when(
          mockRepository.saveAssessment(any),
        ).thenAnswer((_) async => const Right(true));

        // Prepare update function
        final updateFunction =
            (AssessmentForm assessment) =>
                assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);

        // act
        final result = await useCase(
          Params(assessmentId: tAssessmentId, updateFunction: updateFunction),
        );

        // assert
        expect(result, Right(tUpdatedAssessment));
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(tUpdatedAssessment));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return failure when getAssessment fails', () async {
      // arrange
      when(mockRepository.getAssessment(any)).thenAnswer(
        (_) async => const Left(CacheFailure(message: 'Cache error')),
      );

      // Prepare update function
      final updateFunction =
          (AssessmentForm assessment) =>
              assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);

      // act
      final result = await useCase(
        Params(assessmentId: tAssessmentId, updateFunction: updateFunction),
      );

      // assert
      expect(result, const Left(CacheFailure(message: 'Cache error')));
      verify(mockRepository.getAssessment(tAssessmentId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when saveAssessment fails', () async {
      // arrange
      when(
        mockRepository.getAssessment(any),
      ).thenAnswer((_) async => Right(tAssessment));
      when(mockRepository.saveAssessment(any)).thenAnswer(
        (_) async => const Left(CacheFailure(message: 'Cache error')),
      );

      // Prepare update function
      final updateFunction =
          (AssessmentForm assessment) =>
              assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);

      // act
      final result = await useCase(
        Params(assessmentId: tAssessmentId, updateFunction: updateFunction),
      );

      // assert
      expect(result, const Left(CacheFailure(message: 'Cache error')));
      verify(mockRepository.getAssessment(tAssessmentId));
      verify(mockRepository.saveAssessment(tUpdatedAssessment));
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return ValidationFailure when validator function returns error message',
      () async {
        // arrange
        when(
          mockRepository.getAssessment(any),
        ).thenAnswer((_) async => Right(tAssessment));

        // Prepare update function and validator
        final updateFunction =
            (AssessmentForm assessment) =>
                assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);
        final validator =
            (AssessmentForm assessment) => 'Validation error message';

        // act
        final result = await useCase(
          Params(
            assessmentId: tAssessmentId,
            updateFunction: updateFunction,
            validator: validator,
          ),
        );

        // assert
        expect(
          result,
          Left(ValidationFailure(message: 'Validation error message')),
        );
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ValidationFailure when update function throws an exception',
      () async {
        // arrange
        when(
          mockRepository.getAssessment(any),
        ).thenAnswer((_) async => Right(tAssessment));

        // Prepare update function that throws
        final updateFunction =
            (AssessmentForm assessment) => throw Exception('Update error');

        // act
        final result = await useCase(
          Params(assessmentId: tAssessmentId, updateFunction: updateFunction),
        );

        // assert
        expect(result.isLeft(), true);
        final failure = (result as Left).value as ValidationFailure;
        expect(failure.message, contains('Error applying update'));
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    // NEW TESTS FOR IMPROVED COVERAGE

    test(
      'should return ValidationFailure when assessment ID is empty',
      () async {
        // Prepare update function
        final updateFunction =
            (AssessmentForm assessment) =>
                assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);

        // act
        final result = await useCase(
          Params(assessmentId: '', updateFunction: updateFunction),
        );

        // assert
        expect(
          result,
          Left(ValidationFailure(message: 'Assessment ID cannot be empty')),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test('should skip saving when update function makes no changes', () async {
      // arrange
      when(
        mockRepository.getAssessment(any),
      ).thenAnswer((_) async => Right(tAssessment));

      // Prepare update function that returns the same assessment
      final updateFunction = (AssessmentForm assessment) => assessment;

      // act
      final result = await useCase(
        Params(assessmentId: tAssessmentId, updateFunction: updateFunction),
      );

      // assert
      expect(result, Right(tAssessment));
      verify(mockRepository.getAssessment(tAssessmentId));
      // Verify that saveAssessment was never called
      verifyNever(mockRepository.saveAssessment(any));
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return ValidationFailure when saveAssessment returns false',
      () async {
        // arrange
        when(
          mockRepository.getAssessment(any),
        ).thenAnswer((_) async => Right(tAssessment));
        when(
          mockRepository.saveAssessment(any),
        ).thenAnswer((_) async => const Right(false));

        // Prepare update function
        final updateFunction =
            (AssessmentForm assessment) =>
                assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);

        // act
        final result = await useCase(
          Params(assessmentId: tAssessmentId, updateFunction: updateFunction),
        );

        // assert
        expect(
          result,
          Left(ValidationFailure(message: 'Failed to save assessment')),
        );
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(tUpdatedAssessment));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should process assessment correctly when validator returns null (success)',
      () async {
        // arrange
        when(
          mockRepository.getAssessment(any),
        ).thenAnswer((_) async => Right(tAssessment));
        when(
          mockRepository.saveAssessment(any),
        ).thenAnswer((_) async => const Right(true));

        // Prepare update function and successful validator
        final updateFunction =
            (AssessmentForm assessment) =>
                assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);
        final validator =
            (AssessmentForm assessment) => null; // No error = success

        // act
        final result = await useCase(
          Params(
            assessmentId: tAssessmentId,
            updateFunction: updateFunction,
            validator: validator,
          ),
        );

        // assert
        expect(result, Right(tUpdatedAssessment));
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(tUpdatedAssessment));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ValidationFailure when repository.getAssessment throws',
      () async {
        // arrange
        when(
          mockRepository.getAssessment(any),
        ).thenThrow(Exception('Repository error'));

        // Prepare update function
        final updateFunction =
            (AssessmentForm assessment) =>
                assessment.copyWith(assessorInfo: tUpdatedAssessorInfo);

        // act
        final result = await useCase(
          Params(assessmentId: tAssessmentId, updateFunction: updateFunction),
        );

        // assert
        expect(result.isLeft(), true);
        final failure = (result as Left).value as ValidationFailure;
        expect(failure.message, contains('Failed to update assessment'));
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });

  group('Params', () {
    test('should consider two Params with same values equal', () {
      // arrange
      final updateFunction = (AssessmentForm assessment) => assessment;
      final validator = (AssessmentForm assessment) => null;

      final params1 = Params(
        assessmentId: tAssessmentId,
        updateFunction: updateFunction,
        validator: validator,
      );

      final params2 = Params(
        assessmentId: tAssessmentId,
        updateFunction: updateFunction,
        validator: validator,
      );

      // assert
      expect(params1, equals(params2));
    });

    test('should consider Params with different assessmentId not equal', () {
      // arrange
      final updateFunction = (AssessmentForm assessment) => assessment;

      final params1 = Params(
        assessmentId: 'id1',
        updateFunction: updateFunction,
      );

      final params2 = Params(
        assessmentId: 'id2',
        updateFunction: updateFunction,
      );

      // assert
      expect(params1, isNot(equals(params2)));
    });
  });
}
