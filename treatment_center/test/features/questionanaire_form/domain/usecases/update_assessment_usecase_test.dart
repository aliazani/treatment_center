import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/update_assessment_usecase.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate mock for the repository
@GenerateMocks([AssessmentRepository])
import 'update_assessment_usecase_test.mocks.dart';

void main() {
  late UpdateAssessmentUsecase useCase;
  late MockAssessmentRepository mockRepository;

  setUpAll(() {
    // Provide dummy Either types
    provideDummy<Either<Failure, AssessmentFormEntity>>(
      Right(TestAssessmentFixtures.createTestAssessmentForm(id: 'dummy')),
    );
    provideDummy<Either<Failure, bool>>(const Right(true));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = UpdateAssessmentUsecase(mockRepository);
  });

  const tId = 'test-assessment-id';
  final tAssessment = TestAssessmentFixtures.createTestAssessmentForm(id: tId);

  final tUpdatedAssessorInfo = AssessorInfoEntity(
    name: 'New Name',
    email: 'new@example.com',
    phoneNumber: '555-1234',
    assessmentDate: DateTime(2023, 1, 1),
  );
  final tUpdatedAssessment = tAssessment.copyWith(
    assessorInfo: tUpdatedAssessorInfo,
  );

  group('UpdateAssessmentUsecase', () {
    test('returns ValidationFailure if assessmentId is empty', () async {
      final result = await useCase(
        Params(
          assessmentId: '',
          updateFunction: (a) => a,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Assessment ID cannot be empty')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('returns failure when getAssessment fails', () async {
      when(mockRepository.getAssessment(any)).thenAnswer(
        (_) async => const Left(CacheFailure(message: 'Cache error')),
      );

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (a) => a,
        ),
      );

      expect(result, const Left(CacheFailure(message: 'Cache error')));
      verify(mockRepository.getAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns original assessment when updateFunction makes no changes',
        () async {
      when(mockRepository.getAssessment(any))
          .thenAnswer((_) async => Right(tAssessment));

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (a) => a,
        ),
      );

      expect(result, Right(tAssessment));
      verify(mockRepository.getAssessment(tId));
      verifyNever(mockRepository.saveAssessment(any));
      verifyNoMoreInteractions(mockRepository);
    });

    test('updates and saves when repository operations succeed', () async {
      when(mockRepository.getAssessment(any))
          .thenAnswer((_) async => Right(tAssessment));
      when(mockRepository.saveAssessment(any))
          .thenAnswer((_) async => const Right(true));

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (_) => tUpdatedAssessment,
        ),
      );

      expect(result, Right(tUpdatedAssessment));
      verify(mockRepository.getAssessment(tId));
      verify(mockRepository.saveAssessment(tUpdatedAssessment));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns failure when saveAssessment fails', () async {
      when(mockRepository.getAssessment(any))
          .thenAnswer((_) async => Right(tAssessment));
      when(mockRepository.saveAssessment(any)).thenAnswer(
        (_) async => const Left(CacheFailure(message: 'Save error')),
      );

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (_) => tUpdatedAssessment,
        ),
      );

      expect(result, const Left(CacheFailure(message: 'Save error')));
      verify(mockRepository.getAssessment(tId));
      verify(mockRepository.saveAssessment(tUpdatedAssessment));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns ValidationFailure when saveAssessment returns false',
        () async {
      when(mockRepository.getAssessment(any))
          .thenAnswer((_) async => Right(tAssessment));
      when(mockRepository.saveAssessment(any))
          .thenAnswer((_) async => const Right(false));

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (_) => tUpdatedAssessment,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Failed to save assessment')),
      );
      verify(mockRepository.getAssessment(tId));
      verify(mockRepository.saveAssessment(tUpdatedAssessment));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns ValidationFailure when validator returns an error',
        () async {
      when(mockRepository.getAssessment(any))
          .thenAnswer((_) async => Right(tAssessment));

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (_) => tUpdatedAssessment,
          validator: (_) => 'Invalid update',
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Invalid update')),
      );
      verify(mockRepository.getAssessment(tId));
      verifyNever(mockRepository.saveAssessment(any));
      verifyNoMoreInteractions(mockRepository);
    });

    test('applies validator success path and saves', () async {
      when(mockRepository.getAssessment(any))
          .thenAnswer((_) async => Right(tAssessment));
      when(mockRepository.saveAssessment(any))
          .thenAnswer((_) async => const Right(true));

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (_) => tUpdatedAssessment,
          validator: (_) => null,
        ),
      );

      expect(result, Right(tUpdatedAssessment));
      verify(mockRepository.getAssessment(tId));
      verify(mockRepository.saveAssessment(tUpdatedAssessment));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns ValidationFailure when updateFunction throws', () async {
      when(mockRepository.getAssessment(any))
          .thenAnswer((_) async => Right(tAssessment));

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (_) => throw Exception('boom'),
        ),
      );

      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ValidationFailure;
      expect(failure.message, contains('Error applying update'));
      verify(mockRepository.getAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns ValidationFailure when getAssessment throws', () async {
      when(mockRepository.getAssessment(any))
          .thenThrow(Exception('repo down'));

      final result = await useCase(
        Params(
          assessmentId: tId,
          updateFunction: (_) => tUpdatedAssessment,
        ),
      );

      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ValidationFailure;
      expect(failure.message, contains('Failed to update assessment'));
      verify(mockRepository.getAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('Params equality', () {
    test('two Params with same values are equal', () {
      AssessmentFormEntity updateFn(AssessmentFormEntity a) => a;
      String? validator(AssessmentFormEntity a) => null;

      final p1 = Params(
        assessmentId: tId,
        updateFunction: updateFn,
        validator: validator,
      );
      final p2 = Params(
        assessmentId: tId,
        updateFunction: updateFn,
        validator: validator,
      );
      expect(p1, equals(p2));
    });

    test('Params with different assessmentId are not equal', () {
      AssessmentFormEntity updateFn(AssessmentFormEntity a) => a;

      final p1 = Params(
        assessmentId: 'one',
        updateFunction: updateFn,
      );
      final p2 = Params(
        assessmentId: 'two',
        updateFunction: updateFn,
      );
      expect(p1, isNot(equals(p2)));
    });
  });
}
