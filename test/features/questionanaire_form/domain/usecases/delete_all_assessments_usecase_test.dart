import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

@GenerateMocks([AssessmentRepository])
import 'delete_all_assessments_usecase_test.mocks.dart';

void main() {
  late DeleteAllAssessmentsUsecase useCase;
  late MockAssessmentRepository mockRepository;

  // Register dummy values for Mockito
  setUpAll(() {
    provideDummy<Either<Failure, bool>>(Right(true));
    provideDummy<Either<Failure, List<AssessmentFormEntity>>>(Right([]));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = DeleteAllAssessmentsUsecase(mockRepository);
  });

  // Test data
  const tConfirmationText = 'DELETE ALL';
  const tWrongConfirmationText = 'DELETE';

  // Create test assessments with different statuses
  final tDraftAssessment = _createTestAssessment(
    id: 'draft-1',
    isComplete: false,
    isSubmitted: false,
  );

  final tCompletedAssessment = _createTestAssessment(
    id: 'completed-1',
    isComplete: true,
    isSubmitted: false,
  );

  final tSubmittedAssessment = _createTestAssessment(
    id: 'submitted-1',
    isComplete: true,
    isSubmitted: true,
  );

  final tMixedAssessments = [
    tDraftAssessment,
    tCompletedAssessment,
    tSubmittedAssessment,
  ];

  group('DeleteAllAssessmentsUsecase', () {
    group('without filter', () {
      test('should delete all assessments when repository succeeds', () async {
        // arrange
        when(
          mockRepository.getAllAssessments(),
        ).thenAnswer((_) async => Right(tMixedAssessments));
        when(
          mockRepository.deleteAllAssessments(any),
        ).thenAnswer((_) async => Right(true));

        // act
        final result = await useCase(
          const DeleteAllAssessmentsParams(confirmationText: tConfirmationText),
        );

        // assert
        expect(result, Right(true));
        verify(mockRepository.getAllAssessments());
        verify(
          mockRepository.deleteAllAssessments([
            'draft-1',
            'completed-1',
            'submitted-1',
          ]),
        );
        verifyNoMoreInteractions(mockRepository);
      });

      test(
        'should return validation failure when confirmation text is invalid',
        () async {
          // arrange
          const params = DeleteAllAssessmentsParams(
            confirmationText: tWrongConfirmationText,
          );

          // act
          final result = await useCase(params);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<ValidationFailure>());
            expect(
              failure.message,
              'Invalid confirmation text. Type "DELETE ALL" to confirm.',
            );
          }, (_) => fail('Should return failure'));
          verifyNever(mockRepository.getAllAssessments());
          verifyNever(mockRepository.deleteAllAssessments(any));
        },
      );

      test(
        'should return failure when repository fails to get assessments',
        () async {
          // arrange
          final failure = CacheFailure(message: 'Failed to get assessments');
          when(
            mockRepository.getAllAssessments(),
          ).thenAnswer((_) async => Left(failure));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
            ),
          );

          // assert
          expect(result, Left(failure));
          verify(mockRepository.getAllAssessments());
          verifyNever(mockRepository.deleteAllAssessments(any));
        },
      );

      test(
        'should return validation failure when no assessments exist',
        () async {
          // arrange
          when(
            mockRepository.getAllAssessments(),
          ).thenAnswer((_) async => Right([]));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
            ),
          );

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'No assessments to delete.');
          }, (_) => fail('Should return failure'));
          verify(mockRepository.getAllAssessments());
          verifyNever(mockRepository.deleteAllAssessments(any));
        },
      );

      test(
        'should return failure when repository fails to delete assessments',
        () async {
          // arrange
          final deleteFailure = CacheFailure(message: 'Failed to delete');
          when(
            mockRepository.getAllAssessments(),
          ).thenAnswer((_) async => Right(tMixedAssessments));
          when(
            mockRepository.deleteAllAssessments(any),
          ).thenAnswer((_) async => Left(deleteFailure));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
            ),
          );

          // assert
          expect(result, Left(deleteFailure));
          verify(mockRepository.getAllAssessments());
          verify(
            mockRepository.deleteAllAssessments([
              'draft-1',
              'completed-1',
              'submitted-1',
            ]),
          );
          verifyNoMoreInteractions(mockRepository);
        },
      );
    });

    group('with filters', () {
      test(
        'should delete only draft assessments when filter is draft',
        () async {
          // arrange
          when(
            mockRepository.getAllAssessments(),
          ).thenAnswer((_) async => Right(tMixedAssessments));
          when(
            mockRepository.deleteAllAssessments(any),
          ).thenAnswer((_) async => Right(true));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
              filter: AssessmentFilterType.draft,
            ),
          );

          // assert
          expect(result, Right(true));
          verify(mockRepository.getAllAssessments());
          verify(mockRepository.deleteAllAssessments(['draft-1']));
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should delete only completed assessments when filter is completed',
        () async {
          // arrange
          when(
            mockRepository.getAllAssessments(),
          ).thenAnswer((_) async => Right(tMixedAssessments));
          when(
            mockRepository.deleteAllAssessments(any),
          ).thenAnswer((_) async => Right(true));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
              filter: AssessmentFilterType.completed,
            ),
          );

          // assert
          expect(result, Right(true));
          verify(mockRepository.getAllAssessments());
          verify(mockRepository.deleteAllAssessments(['completed-1']));
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should delete only submitted assessments when filter is submitted',
        () async {
          // arrange
          when(
            mockRepository.getAllAssessments(),
          ).thenAnswer((_) async => Right(tMixedAssessments));
          when(
            mockRepository.deleteAllAssessments(any),
          ).thenAnswer((_) async => Right(true));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
              filter: AssessmentFilterType.submitted,
            ),
          );

          // assert
          expect(result, Right(true));
          verify(mockRepository.getAllAssessments());
          verify(mockRepository.deleteAllAssessments(['submitted-1']));
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test('should delete all assessments when filter is all', () async {
        // arrange
        when(
          mockRepository.getAllAssessments(),
        ).thenAnswer((_) async => Right(tMixedAssessments));
        when(
          mockRepository.deleteAllAssessments(any),
        ).thenAnswer((_) async => Right(true));

        // act
        final result = await useCase(
          const DeleteAllAssessmentsParams(
            confirmationText: tConfirmationText,
            filter: AssessmentFilterType.all,
          ),
        );

        // assert
        expect(result, Right(true));
        verify(mockRepository.getAllAssessments());
        verify(
          mockRepository.deleteAllAssessments([
            'draft-1',
            'completed-1',
            'submitted-1',
          ]),
        );
        verifyNoMoreInteractions(mockRepository);
      });

      test(
        'should return validation failure when no assessments match filter',
        () async {
          // arrange
          final onlyDraftAssessments = [tDraftAssessment];
          when(
            mockRepository.getAllAssessments(),
          ).thenAnswer((_) async => Right(onlyDraftAssessments));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
              filter: AssessmentFilterType.submitted,
            ),
          );

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<ValidationFailure>());
            expect(
              failure.message,
              'No assessments match the specified filter.',
            );
          }, (_) => fail('Should return failure'));
          verify(mockRepository.getAllAssessments());
          verifyNever(mockRepository.deleteAllAssessments(any));
        },
      );
    });

    group('exception handling', () {
      test(
        'should return validation failure when exception is thrown',
        () async {
          // arrange
          when(
            mockRepository.getAllAssessments(),
          ).thenThrow(Exception('Unexpected error'));

          // act
          final result = await useCase(
            const DeleteAllAssessmentsParams(
              confirmationText: tConfirmationText,
            ),
          );

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<ValidationFailure>());
            expect(
              failure.message,
              contains('Failed to delete all assessments:'),
            );
          }, (_) => fail('Should return failure'));
          verify(mockRepository.getAllAssessments());
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test('should handle exception during deletion gracefully', () async {
        // arrange
        when(
          mockRepository.getAllAssessments(),
        ).thenAnswer((_) async => Right(tMixedAssessments));
        when(
          mockRepository.deleteAllAssessments(any),
        ).thenThrow(Exception('Delete failed'));

        // act
        final result = await useCase(
          const DeleteAllAssessmentsParams(confirmationText: tConfirmationText),
        );

        // assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            contains('Failed to delete all assessments:'),
          );
        }, (_) => fail('Should return failure'));
        verify(mockRepository.getAllAssessments());
        verify(
          mockRepository.deleteAllAssessments([
            'draft-1',
            'completed-1',
            'submitted-1',
          ]),
        );
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });

  group('DeleteAllAssessmentsParams', () {
    test('should hold the provided confirmation text and filter', () {
      const params = DeleteAllAssessmentsParams(
        confirmationText: tConfirmationText,
        filter: AssessmentFilterType.draft,
      );
      expect(params.confirmationText, tConfirmationText);
      expect(params.filter, AssessmentFilterType.draft);
    });

    test('supports value equality', () {
      const params1 = DeleteAllAssessmentsParams(
        confirmationText: tConfirmationText,
        filter: AssessmentFilterType.draft,
      );
      const params2 = DeleteAllAssessmentsParams(
        confirmationText: tConfirmationText,
        filter: AssessmentFilterType.draft,
      );
      const params3 = DeleteAllAssessmentsParams(
        confirmationText: tWrongConfirmationText,
        filter: AssessmentFilterType.draft,
      );
      const params4 = DeleteAllAssessmentsParams(
        confirmationText: tConfirmationText,
        filter: AssessmentFilterType.completed,
      );

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
      expect(params1, isNot(equals(params4)));
    });

    test('props should contain confirmation text and filter', () {
      const params = DeleteAllAssessmentsParams(
        confirmationText: tConfirmationText,
        filter: AssessmentFilterType.draft,
      );
      expect(params.props, [tConfirmationText, AssessmentFilterType.draft]);
    });
  });

  group('AssessmentFilterTypeExtension', () {
    test('should convert UI filter strings to AssessmentFilterType', () {
      expect(
        AssessmentFilterTypeExtension.fromUIFilter('AssessmentFilter.draft'),
        AssessmentFilterType.draft,
      );
      expect(
        AssessmentFilterTypeExtension.fromUIFilter(
          'AssessmentFilter.completed',
        ),
        AssessmentFilterType.completed,
      );
      expect(
        AssessmentFilterTypeExtension.fromUIFilter(
          'AssessmentFilter.submitted',
        ),
        AssessmentFilterType.submitted,
      );
    });

    test('should return all for null or unknown filter', () {
      expect(
        AssessmentFilterTypeExtension.fromUIFilter(null),
        AssessmentFilterType.all,
      );
      expect(
        AssessmentFilterTypeExtension.fromUIFilter('unknown'),
        AssessmentFilterType.all,
      );
      expect(
        AssessmentFilterTypeExtension.fromUIFilter(''),
        AssessmentFilterType.all,
      );
    });
  });
}

AssessmentFormEntity _createTestAssessment({
  required String id,
  required bool isComplete,
  required bool isSubmitted,
}) {
  final now = DateTime.now();

  // A rated item for completeness
  final ratedItem = AssessmentItemEntity(
    id: 1,
    itemNumber: 'item_1',
    sectionNumber: '2',
    area: 'Test Area',
    meetsTargetDescription: 'Meets target',
    partiallyMeetsDescription: 'Partially meets target',
    doesNotMeetDescription: 'Does not meet target',
    selectedRating: AssessmentRatingEntity.meetsTarget(), // rated
  );

  // An unrated item for drafts
  final unratedItem = AssessmentItemEntity(
    id: 2,
    itemNumber: 'item_2',
    sectionNumber: '2',
    area: 'Test Area',
    meetsTargetDescription: 'Meets target',
    partiallyMeetsDescription: 'Partially meets target',
    doesNotMeetDescription: 'Does not meet target',
  );

  // Sections 2–4 with rated items (complete)
  final s2 = AssessmentSectionEntity(
    id: 's2',
    sectionNumber: '2',
    title: 'S2',
    items: [ratedItem],
  );
  final s3 = AssessmentSectionEntity(
    id: 's3',
    sectionNumber: '3',
    title: 'S3',
    items: [ratedItem],
  );
  final s4 = AssessmentSectionEntity(
    id: 's4',
    sectionNumber: '4',
    title: 'S4',
    items: [ratedItem],
  );

  // For draft: S2 with an unrated item; omit S3/S4 to keep incomplete
  final draftSections = <AssessmentSectionEntity>[
    AssessmentSectionEntity(
      id: 's2',
      sectionNumber: '2',
      title: 'S2',
      items: [unratedItem],
    ),
  ];

  // Photo required for Section 1 to be fully complete (1.5)
  final photo = PhotoEntity(
    id: 'p1',
    filePath: '/tmp/p1.jpg',
    fileName: 'p1.jpg',
    source: PhotoSource.camera,
    fileSizeBytes: 1024,
    capturedAt: now,
  );

  return AssessmentFormEntity(
    id: id,
    assessorInfo: AssessorInfoEntity(
      name: 'Test Assessor',
      email: 'assessor@test.com',
      phoneNumber: '1234567890',
      assessmentDate: now,
    ),
    geoLocation: GeoLocationEntity(
      country: 'Test Country',
      regionProvince: 'Test Province',
      district: 'Test District',
      cityVillage: 'Test City',
      addressOrCoordinates: 'Test Address',
      locationType: FacilityLocationType.urban, // non-null for S1 completeness
    ),
    facilityIdentification: FacilityIdentificationEntity(
      facilityCode: 'FAC001',
      facilityName: 'Test Facility',
      managingAuthority: ManagingAuthorityType.government, // non-null
      directorName: 'Director',
      directorPhone: '0987654321',
      directorEmail: 'director@test.com',
      respondentName: 'Respondent',
      respondentPosition: 'Manager',
      structureType: FacilityStructureType.permanent, // non-null
      facilityType:
          FacilityType
              .screeningAndTemporaryIsolation, // triggers existingFacilityType
      existingFacilityType:
          ExistingFacilityType.firstReferralHospital, // satisfy S1 rule
    ),
    facilityServices: FacilityServicesEntity(
      hasOutpatientServices: true,
      hasInpatientServices: true,
      totalInpatientBeds: 50,
      icuBeds: 10,
      hasEmergencyUnit: true,
      hasIcuOrHighDependencyUnit: true,
    ),
    // NEW: make sections/photos depend on isComplete to satisfy new rules
    sections: isComplete ? [s2, s3, s4] : draftSections,
    photos: isComplete ? [photo] : const [], // photo makes S1 fully complete
    createdAt: now,
    updatedAt: now,
    isSubmitted: isSubmitted,
  );
}
