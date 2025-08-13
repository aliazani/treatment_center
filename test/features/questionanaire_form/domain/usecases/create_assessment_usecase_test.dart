import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/create_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

@GenerateMocks([AssessmentRepository])
import 'create_assessment_usecase_test.mocks.dart';

void main() {
  late CreateAssessmentUsecase useCase;
  late MockAssessmentRepository mockRepository;

  // Register dummy values for Either types
  setUpAll(() {
    provideDummy<Either<Failure, bool>>(const Right(true));
    provideDummy<Either<Failure, AssessmentFormEntity>>(
      Right(TestAssessmentFixtures.createTestAssessmentForm(id: 'dummy')),
    );
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = CreateAssessmentUsecase(mockRepository);
  });

  // Extract a full fixture to reuse its parts for Params
  final fixture = TestAssessmentFixtures.createTestAssessmentForm(id: 'dummy');
  final tAssessorInfo = fixture.assessorInfo;
  final tGeoLocation = fixture.geoLocation;
  final tFacilityIdentification = fixture.facilityIdentification;
  final tFacilityServices = fixture.facilityServices;
  final tSections = fixture.sections;
  final tNotes = 'Some optional notes';

  group('CreateAssessmentUsecase', () {
    test(
      'should create new assessment when repository saves successfully',
      () async {
        // arrange
        when(
          mockRepository.saveAssessment(any),
        ).thenAnswer((_) async => const Right(true));

        // act
        final result = await useCase(
          Params(
            assessorInfo: tAssessorInfo,
            geoLocation: tGeoLocation,
            facilityIdentification: tFacilityIdentification,
            facilityServices: tFacilityServices,
            sections: tSections,
            notes: tNotes,
          ),
        );

        // assert
        expect(result.isRight(), isTrue);
        final created = (result as Right).value;
        // ID should be generated and non-empty
        expect(created.id, isNotEmpty);
        // All other fields should match input
        expect(created.assessorInfo, equals(tAssessorInfo));
        expect(created.geoLocation, equals(tGeoLocation));
        expect(created.facilityIdentification, equals(tFacilityIdentification));
        expect(created.facilityServices, equals(tFacilityServices));
        expect(created.sections, equals(tSections));
        expect(created.notes, equals(tNotes));
        // Verify it was saved
        verify(mockRepository.saveAssessment(created));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return failure when repository.saveAssessment returns false',
      () async {
        // arrange
        when(
          mockRepository.saveAssessment(any),
        ).thenAnswer((_) async => const Right(false));

        // act
        final result = await useCase(
          Params(
            assessorInfo: tAssessorInfo,
            geoLocation: tGeoLocation,
            facilityIdentification: tFacilityIdentification,
            facilityServices: tFacilityServices,
            sections: tSections,
            notes: tNotes,
          ),
        );

        // assert
        expect(
          result,
          Left(ValidationFailure(message: 'Failed to save the new assessment')),
        );
        verify(mockRepository.saveAssessment(any));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return failure when repository.saveAssessment fails',
      () async {
        // arrange
        when(mockRepository.saveAssessment(any)).thenAnswer(
          (_) async => const Left(CacheFailure(message: 'DB error')),
        );

        // act
        final result = await useCase(
          Params(
            assessorInfo: tAssessorInfo,
            geoLocation: tGeoLocation,
            facilityIdentification: tFacilityIdentification,
            facilityServices: tFacilityServices,
            sections: tSections,
            notes: tNotes,
          ),
        );

        // assert
        expect(result, const Left(CacheFailure(message: 'DB error')));
        verify(mockRepository.saveAssessment(any));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ValidationFailure on empty assessor name', () async {
      // create a bad AssessorInfoEntity with empty name
      final badInfo = AssessorInfoEntity(
        name: '',
        email: tAssessorInfo.email,
        phoneNumber: tAssessorInfo.phoneNumber,
        assessmentDate: tAssessorInfo.assessmentDate,
      );

      final result = await useCase(
        Params(
          assessorInfo: badInfo,
          geoLocation: tGeoLocation,
          facilityIdentification: tFacilityIdentification,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Assessor name is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure on empty assessor email', () async {
      // empty email
      final badInfo = AssessorInfoEntity(
        name: tAssessorInfo.name,
        email: '',
        phoneNumber: tAssessorInfo.phoneNumber,
        assessmentDate: tAssessorInfo.assessmentDate,
      );

      final result = await useCase(
        Params(
          assessorInfo: badInfo,
          geoLocation: tGeoLocation,
          facilityIdentification: tFacilityIdentification,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Assessor email is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure on invalid email format', () async {
      // malformed email
      final badInfo = AssessorInfoEntity(
        name: tAssessorInfo.name,
        email: 'not-an-email',
        phoneNumber: tAssessorInfo.phoneNumber,
        assessmentDate: tAssessorInfo.assessmentDate,
      );

      final result = await useCase(
        Params(
          assessorInfo: badInfo,
          geoLocation: tGeoLocation,
          facilityIdentification: tFacilityIdentification,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Assessor email format is invalid')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure on empty facility name', () async {
      // bad facility name
      final badFacility = FacilityIdentificationEntity(
        facilityName: '',
        facilityCode: tFacilityIdentification.facilityCode,
        managingAuthority: null,
        directorName: '',
        directorPhone: '',
        directorEmail: '',
        respondentName: '',
        respondentPosition: '',
        structureType: null,
        facilityType: null,
      );

      final result = await useCase(
        Params(
          assessorInfo: tAssessorInfo,
          geoLocation: tGeoLocation,
          facilityIdentification: badFacility,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Facility name is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure on empty facility code', () async {
      // bad facility code
      final badFacility = FacilityIdentificationEntity(
        facilityName: tFacilityIdentification.facilityName,
        facilityCode: '',
        managingAuthority: null,
        directorName: '',
        directorPhone: '',
        directorEmail: '',
        respondentName: '',
        respondentPosition: '',
        structureType: null,
        facilityType: null,
      );

      final result = await useCase(
        Params(
          assessorInfo: tAssessorInfo,
          geoLocation: tGeoLocation,
          facilityIdentification: badFacility,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Facility code is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure on empty country', () async {
      // bad geo country
      final badGeo = GeoLocationEntity(
        country: '',
        regionProvince: tGeoLocation.regionProvince,
        latitude: tGeoLocation.latitude,
        longitude: tGeoLocation.longitude,
        district: '',
        cityVillage: '',
        addressOrCoordinates: '',
        locationType: null,
      );

      final result = await useCase(
        Params(
          assessorInfo: tAssessorInfo,
          geoLocation: badGeo,
          facilityIdentification: tFacilityIdentification,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(result, Left(ValidationFailure(message: 'Country is required')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure on empty region/province', () async {
      // bad geo region/province
      final badGeo = GeoLocationEntity(
        country: tGeoLocation.country,
        regionProvince: '',
        latitude: tGeoLocation.latitude,
        longitude: tGeoLocation.longitude,
        district: '',
        cityVillage: '',
        addressOrCoordinates: '',
        locationType: null,
      );

      final result = await useCase(
        Params(
          assessorInfo: tAssessorInfo,
          geoLocation: badGeo,
          facilityIdentification: tFacilityIdentification,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(
        result,
        Left(ValidationFailure(message: 'Region/Province is required')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when no sections provided', () async {
      final result = await useCase(
        Params(
          assessorInfo: tAssessorInfo,
          geoLocation: tGeoLocation,
          facilityIdentification: tFacilityIdentification,
          facilityServices: tFacilityServices,
          sections: const [],
        ),
      );

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

    test(
      'should return ValidationFailure when a section has no items',
      () async {
        final emptySection = AssessmentSectionEntity(
          id: '',
          sectionNumber: '',
          title: 'Empty',
          items: [],
        );
        final result = await useCase(
          Params(
            assessorInfo: tAssessorInfo,
            geoLocation: tGeoLocation,
            facilityIdentification: tFacilityIdentification,
            facilityServices: tFacilityServices,
            sections: [emptySection],
          ),
        );

        expect(
          result,
          Left(
            ValidationFailure(
              message: 'Section "Empty" must have at least one item',
            ),
          ),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test('should return ValidationFailure when repository throws', () async {
      when(
        mockRepository.saveAssessment(any),
      ).thenThrow(Exception('Unexpected'));

      final result = await useCase(
        Params(
          assessorInfo: tAssessorInfo,
          geoLocation: tGeoLocation,
          facilityIdentification: tFacilityIdentification,
          facilityServices: tFacilityServices,
          sections: tSections,
        ),
      );

      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ValidationFailure;
      expect(failure.message, contains('Failed to create assessment'));
      verify(mockRepository.saveAssessment(any));
    });
  });

  group('Params', () {
    test('should treat two identical Params as equal', () {
      final params1 = Params(
        assessorInfo: tAssessorInfo,
        geoLocation: tGeoLocation,
        facilityIdentification: tFacilityIdentification,
        facilityServices: tFacilityServices,
        sections: tSections,
        notes: tNotes,
      );
      final params2 = Params(
        assessorInfo: tAssessorInfo,
        geoLocation: tGeoLocation,
        facilityIdentification: tFacilityIdentification,
        facilityServices: tFacilityServices,
        sections: tSections,
        notes: tNotes,
      );
      expect(params1, equals(params2));
    });

    test('should treat Params with different notes as not equal', () {
      final params1 = Params(
        assessorInfo: tAssessorInfo,
        geoLocation: tGeoLocation,
        facilityIdentification: tFacilityIdentification,
        facilityServices: tFacilityServices,
        sections: tSections,
        notes: 'A',
      );
      final params2 = Params(
        assessorInfo: tAssessorInfo,
        geoLocation: tGeoLocation,
        facilityIdentification: tFacilityIdentification,
        facilityServices: tFacilityServices,
        sections: tSections,
        notes: 'B',
      );
      expect(params1, isNot(params2));
    });
  });
}
