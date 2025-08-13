import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate a MockAssessmentRepository
@GenerateMocks([AssessmentRepository])
import 'get_all_assessments_usecase_test.mocks.dart';

void main() {
  late GetAllAssessmentsUsecase useCase;
  late MockAssessmentRepository mockRepository;

  // Register a dummy Either<Failure, List<AssessmentFormEntity>>
  setUpAll(() {
    provideDummy<Either<Failure, List<AssessmentFormEntity>>>(
      Right(<AssessmentFormEntity>[]),
    );
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = GetAllAssessmentsUsecase(mockRepository);
  });

  // Prepare a sample list
  final tAssessment1 =
      TestAssessmentFixtures.createTestAssessmentForm(id: 'a1');
  final tAssessment2 =
      TestAssessmentFixtures.createTestAssessmentForm(id: 'a2');
  final tList = [tAssessment1, tAssessment2];

  group('GetAllAssessmentsUsecase', () {
    test('should return list of assessments when repository succeeds',
        () async {
      // arrange
      when(mockRepository.getAllAssessments())
          .thenAnswer((_) async => Right(tList));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, Right(tList));
      verify(mockRepository.getAllAssessments());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository returns Left', () async {
      // arrange
      final failure = CacheFailure(message: 'DB error');
      when(mockRepository.getAllAssessments())
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, Left(failure));
      verify(mockRepository.getAllAssessments());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when repository throws', () async {
      // arrange
      when(mockRepository.getAllAssessments())
          .thenThrow(Exception('oops'));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ValidationFailure;
      expect(
        failure.message,
        contains('Failed to get all assessments: Exception: oops'),
      );
      verify(mockRepository.getAllAssessments());
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('NoParams', () {
    test('should consider two NoParams equal', () {
      expect(const NoParams(), equals(const NoParams()));
    });

    test('should have consistent hashCode', () {
      expect(const NoParams().hashCode, equals(const NoParams().hashCode));
    });
  });
}
