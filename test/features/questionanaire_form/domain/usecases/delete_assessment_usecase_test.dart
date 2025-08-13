import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

@GenerateMocks([AssessmentRepository])
import 'delete_assessment_usecase_test.mocks.dart';

void main() {
  late DeleteAssessmentUsecase useCase;
  late MockAssessmentRepository mockRepository;

  // Register a dummy Either<Failure, void> for Mockito
  setUpAll(() {
    provideDummy<Either<Failure, bool>>(Right(true));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = DeleteAssessmentUsecase(mockRepository);
  });

  const tId = 'test-assessment-id';

  group('DeleteAssessmentUsecase', () {
    test('should delete assessment when repository succeeds', () async {
      // arrange
      when(mockRepository.deleteAssessment(any))
          .thenAnswer((_) async => Right(true));

      // act
      final result = await useCase(DeleteAssessmentParams(id: tId));

      // assert
      expect(result, Right(true));
      verify(mockRepository.deleteAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      final failure = CacheFailure(message: 'Delete error');
      when(mockRepository.deleteAssessment(any))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await useCase(DeleteAssessmentParams(id: tId));

      // assert
      expect(result, Left(failure));
      verify(mockRepository.deleteAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate exception when repository throws', () {
      // arrange
      when(mockRepository.deleteAssessment(any))
          .thenThrow(Exception('Unexpected'));

      // act / assert
      expect(
        () => useCase(DeleteAssessmentParams(id: tId)),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.deleteAssessment(tId));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeleteAssessmentParams', () {
    test('should hold the provided id', () {
      final params = DeleteAssessmentParams(id: tId);
      expect(params.id, tId);
    });
  });
}
