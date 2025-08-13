import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate a MockAssessmentRepository
@GenerateMocks([AssessmentRepository])
import 'get_assessment_usecase_test.mocks.dart';

void main() {
  late GetAssessmentUsecase useCase;
  late MockAssessmentRepository mockRepository;

  // Provide a dummy Either<Failure, AssessmentFormEntity> for Mockito
  setUpAll(() {
    provideDummy<Either<Failure, AssessmentFormEntity>>(
      Right(TestAssessmentFixtures.createTestAssessmentForm(id: 'dummy')),
    );
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = GetAssessmentUsecase(mockRepository);
  });

  const tId = 'test-assessment-id';
  final tAssessment = TestAssessmentFixtures.createTestAssessmentForm(id: tId);

  group('GetAssessmentUsecase', () {
    test('returns ValidationFailure when assessmentId is empty', () async {
      // act
      final result = await useCase(const Params(assessmentId: ''));

      // assert
      expect(
        result,
        Left(ValidationFailure(message: 'Assessment ID cannot be empty')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('returns assessment when repository succeeds', () async {
      // arrange
      when(
        mockRepository.getAssessment(any),
      ).thenAnswer((_) async => Right(tAssessment));

      // act
      final result = await useCase(const Params(assessmentId: tId));

      // assert
      expect(result, Right(tAssessment));
      verify(mockRepository.getAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns failure when repository returns Left', () async {
      // arrange
      final failure = CacheFailure(message: 'Not found');
      when(
        mockRepository.getAssessment(any),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await useCase(const Params(assessmentId: tId));

      // assert
      expect(result, Left(failure));
      verify(mockRepository.getAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns ValidationFailure when repository throws', () async {
      // arrange
      when(mockRepository.getAssessment(any)).thenThrow(Exception('DB down'));

      // act
      final result = await useCase(const Params(assessmentId: tId));

      // assert
      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ValidationFailure;
      expect(
        failure.message,
        contains('Failed to get assessment: Exception: DB down'),
      );
      verify(mockRepository.getAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('Params', () {
    test('considers two Params with same id equal', () {
      expect(
        const Params(assessmentId: tId),
        equals(const Params(assessmentId: tId)),
      );
    });

    test('considers Params with different ids not equal', () {
      expect(
        const Params(assessmentId: 'id1'),
        isNot(const Params(assessmentId: 'id2')),
      );
    });
  });
}
