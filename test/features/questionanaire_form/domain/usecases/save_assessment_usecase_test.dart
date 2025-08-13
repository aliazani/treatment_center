import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/save_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate a MockAssessmentRepository
@GenerateMocks([AssessmentRepository])
import 'save_assessment_usecase_test.mocks.dart';

void main() {
  late SaveAssessmentUsecase useCase;
  late MockAssessmentRepository mockRepository;

  // Dummy for Either<Failure,bool>
  setUpAll(() {
    provideDummy<Either<Failure, bool>>(const Right(true));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = SaveAssessmentUsecase(mockRepository);
  });

  // A valid assessment fixture
  final tValid = TestAssessmentFixtures.createTestAssessmentForm(
    id: 'valid-id',
  );

  group('SaveAssessmentUsecase', () {
    test(
      'should save successfully when repository returns Right(true)',
      () async {
        // arrange
        when(
          mockRepository.saveAssessment(any),
        ).thenAnswer((_) async => const Right(true));

        // act
        final result = await useCase(Params(assessment: tValid));

        // assert
        expect(result, const Right(true));
        verify(mockRepository.saveAssessment(tValid));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return Right(false) when repository returns Right(false)',
      () async {
        // arrange
        when(
          mockRepository.saveAssessment(any),
        ).thenAnswer((_) async => const Right(false));

        // act
        final result = await useCase(Params(assessment: tValid));

        // assert
        expect(result, const Right(false));
        verify(mockRepository.saveAssessment(tValid));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should propagate repository failure', () async {
      // arrange
      final failure = CacheFailure(message: 'DB error');
      when(
        mockRepository.saveAssessment(any),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await useCase(Params(assessment: tValid));

      // assert
      expect(result, Left(failure));
      verify(mockRepository.saveAssessment(tValid));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when repository throws', () async {
      // arrange
      when(mockRepository.saveAssessment(any)).thenThrow(Exception('oops'));

      // act
      final result = await useCase(Params(assessment: tValid));

      // assert
      expect(result.isLeft(), isTrue);
      final left = result as Left;
      expect(
        (left.value as ValidationFailure).message,
        contains('Failed to save assessment: Exception: oops'),
      );
      verify(mockRepository.saveAssessment(tValid));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should validate empty assessment ID', () async {
      final bad = tValid.copyWith(id: '');
      final result = await useCase(Params(assessment: bad));

      expect(
        result,
        Left(ValidationFailure(message: 'Assessment ID cannot be empty')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should validate empty assessor name', () async {
      final badAssessor = AssessorInfoEntity(
        name: '',
        email: tValid.assessorInfo.email,
        phoneNumber: tValid.assessorInfo.phoneNumber,
        assessmentDate: tValid.assessorInfo.assessmentDate,
      );
      final bad = tValid.copyWith(assessorInfo: badAssessor);
      final result = await useCase(Params(assessment: bad));

      expect(
        result,
        Left(ValidationFailure(message: 'Assessor name is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should validate empty assessor email', () async {
      final badAssessor = AssessorInfoEntity(
        name: tValid.assessorInfo.name,
        email: '',
        phoneNumber: tValid.assessorInfo.phoneNumber,
        assessmentDate: tValid.assessorInfo.assessmentDate,
      );
      final bad = tValid.copyWith(assessorInfo: badAssessor);
      final result = await useCase(Params(assessment: bad));

      expect(
        result,
        Left(ValidationFailure(message: 'Assessor email is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should validate empty facility name', () async {
      final origFac = tValid.facilityIdentification;
      final badFac = FacilityIdentificationEntity(
        facilityName: '',
        facilityCode: origFac.facilityCode,
        // if there are other required fields, copy them from origFac:
        managingAuthority: origFac.managingAuthority,
        directorName: origFac.directorName,
        directorPhone: origFac.directorPhone,
        directorEmail: origFac.directorEmail,
        respondentName: origFac.respondentName,
        respondentPosition: origFac.respondentPosition,
        structureType: origFac.structureType,
        facilityType: origFac.facilityType,
      );
      final bad = tValid.copyWith(facilityIdentification: badFac);
      final result = await useCase(Params(assessment: bad));

      expect(
        result,
        Left(ValidationFailure(message: 'Facility name is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should validate empty facility code', () async {
      final origFac = tValid.facilityIdentification;
      final badFac = FacilityIdentificationEntity(
        facilityName: origFac.facilityName,
        facilityCode: '',
        managingAuthority: origFac.managingAuthority,
        directorName: origFac.directorName,
        directorPhone: origFac.directorPhone,
        directorEmail: origFac.directorEmail,
        respondentName: origFac.respondentName,
        respondentPosition: origFac.respondentPosition,
        structureType: origFac.structureType,
        facilityType: origFac.facilityType,
      );
      final bad = tValid.copyWith(facilityIdentification: badFac);
      final result = await useCase(Params(assessment: bad));

      expect(
        result,
        Left(ValidationFailure(message: 'Facility code is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should validate empty sections list', () async {
      final bad = tValid.copyWith(sections: const []);
      final result = await useCase(Params(assessment: bad));

      expect(
        result,
        Left(
          ValidationFailure(
            message: 'Assessment must have at least one section',
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });
  });

  group('Params', () {
    test('should consider two Params with same assessment equal', () {
      final p1 = Params(assessment: tValid);
      final p2 = Params(assessment: tValid);
      expect(p1, equals(p2));
    });

    test('should consider Params with different assessment not equal', () {
      final other = tValid.copyWith(id: 'other-id');
      final p1 = Params(assessment: tValid);
      final p2 = Params(assessment: other);
      expect(p1, isNot(equals(p2)));
    });
  });
}
