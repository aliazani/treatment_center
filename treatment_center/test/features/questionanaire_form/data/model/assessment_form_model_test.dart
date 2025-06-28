import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';

void main() {
  // Shared test data
  final testDate = DateTime(2023, 5, 10);
  final testSubmitDate = DateTime(2023, 5, 15);
  final testCreatedAt = DateTime(2023, 5, 8, 10, 30);
  final testUpdatedAt = DateTime(2023, 5, 9, 14, 45);

  // Nested model instances
  final tAssessorInfoModel = AssessorInfoModel(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phoneNumber: '1234567890',
    assessmentDate: testDate,
  );

  final tGeoLocationModel = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'San Francisco',
    cityVillage: 'San Francisco',
    addressOrCoordinates: '123 Main St',
    locationType: FacilityLocationType.urban,
  );

  final tFacilityIdModel = FacilityIdentificationModel(
    facilityCode: 'F12345',
    facilityName: 'City Hospital',
    managingAuthority: ManagingAuthorityType.government,
    directorName: 'Dr. Jane Smith',
    directorPhone: '5551234567',
    directorEmail: 'jsmith@cityhospital.org',
    respondentName: 'John Doe',
    respondentPosition: 'Facility Manager',
    structureType: FacilityStructureType.permanent,
    facilityType: FacilityType.screeningAndTemporaryIsolation,
    existingFacilityType: ExistingFacilityType.firstReferralHospital,
  );

  final tFacilityServicesModel = FacilityServicesModel(
    hasOutpatientServices: true,
    hasInpatientServices: true,
    totalInpatientBeds: 100,
    icuBeds: 20,
    hasEmergencyUnit: true,
    hasIcuOrHighDependencyUnit: true,
  );

  // Items and section
  final tItemModel1 = AssessmentItemModel(
    id: 'item_1',
    sectionNumber: '2.1',
    area: 'Area 1',
    meetsTargetDescription: 'Meets description 1',
    partiallyMeetsDescription: 'Partially meets description 1',
    doesNotMeetDescription: 'Does not meet description 1',
    selectedRating: AssessmentRatingModel.meetsTarget(),
  );

  final tItemModel2 = AssessmentItemModel(
    id: 'item_2',
    sectionNumber: '2.1',
    area: 'Area 2',
    meetsTargetDescription: 'Meets description 2',
    partiallyMeetsDescription: 'Partially meets description 2',
    doesNotMeetDescription: 'Does not meet description 2',
  );

  final tSectionModel = AssessmentSectionModel(
    id: 'section_1',
    sectionNumber: '2.1',
    title: 'Facility Access and Flow',
    description: 'This section evaluates facility access',
    items: [tItemModel1, tItemModel2],
  );

  // Main form model
  final tAssessmentFormModel = AssessmentFormModel(
    id: 'assessment_1',
    assessorInfo: tAssessorInfoModel,
    geoLocation: tGeoLocationModel,
    facilityIdentification: tFacilityIdModel,
    facilityServices: tFacilityServicesModel,
    sections: [tSectionModel],
    notes: 'These are assessment notes',
    isSubmitted: false,
    submissionDate: null,
    createdAt: testCreatedAt,
    updatedAt: testUpdatedAt,
  );

  group('AssessmentFormModel', () {
    test('is a subclass of AssessmentForm', () {
      // Arrange
      final model = tAssessmentFormModel;
      // Act & Assert
      expect(model, isA<AssessmentFormEntity>());
    });

    group('create factory constructor', () {
      test('should create with current timestamps', () {
        // Arrange
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = AssessmentFormModel.create(
          id: 'new',
          assessorInfo: tAssessorInfoModel,
          geoLocation: tGeoLocationModel,
          facilityIdentification: tFacilityIdModel,
          facilityServices: tFacilityServicesModel,
          sections: [tSectionModel],
        );
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.createdAt.isBefore(after), true);
        expect(result.updatedAt, result.createdAt);
      });

      test('should use provided submission params', () {
        // Arrange
        final submissionDate = testSubmitDate;
        // Act
        final result = AssessmentFormModel.create(
          id: 'custom',
          assessorInfo: tAssessorInfoModel,
          geoLocation: tGeoLocationModel,
          facilityIdentification: tFacilityIdModel,
          facilityServices: tFacilityServicesModel,
          sections: [tSectionModel],
          notes: 'note',
          isSubmitted: true,
          submissionDate: submissionDate,
        );
        // Assert
        expect(result.isSubmitted, true);
        expect(result.submissionDate, submissionDate);
      });
    });

    group('fromJson/toJson', () {
      final jsonMap = tAssessmentFormModel.toJson();

      test('round-trips data accurately', () {
        // Arrange and Act
        final result = AssessmentFormModel.fromJson(jsonMap);
        // Assert
        expect(result.id, tAssessmentFormModel.id);
        expect(
          result.assessorInfo.name,
          tAssessmentFormModel.assessorInfo.name,
        );
        expect(result.sections.length, 1);
      });

      test('parses nested objects correctly', () {
        // Arrange and Act
        final result = AssessmentFormModel.fromJson(jsonMap);
        // Assert
        expect(result.geoLocation.country, 'United States');
        expect(result.sections[0].items[0].selectedRating?.value, 3);
      });

      group('_parseDateTime edge cases', () {
        test('handles invalid and null', () {
          // Arrange
          final map =
              Map<String, dynamic>.from(jsonMap)
                ..['created_at'] = 'bad'
                ..['updated_at'] = null
                ..['submission_date'] = '';
          final before = DateTime.now().subtract(Duration(milliseconds: 10));
          // Act
          final result = AssessmentFormModel.fromJson(map);
          final after = DateTime.now().add(Duration(milliseconds: 10));
          // Assert
          expect(result.createdAt.isAfter(before), true);
          expect(result.updatedAt.isBefore(after), true);
          expect(result.submissionDate, isNull);
        });

        test('handles valid ISO strings', () {
          // Arrange
          final iso = '2023-12-25T15:30:45.123Z';
          final map =
              Map<String, dynamic>.from(jsonMap)
                ..['created_at'] = iso
                ..['updated_at'] = iso
                ..['submission_date'] = iso;
          // Act
          final result = AssessmentFormModel.fromJson(map);
          // Assert
          expect(result.createdAt, DateTime.parse(iso));
          expect(result.submissionDate, DateTime.parse(iso));
        });
      });
    });

    group('fromEntity with entity objects', () {
      test('converts all entity types to models', () {
        // Arrange
        // Create entity objects (not model objects)
        final entityAssessorInfo = AssessorInfoEntity(
          name: 'Entity Assessor',
          email: 'entity@test.com',
          phoneNumber: '+123456789',
          assessmentDate: DateTime(2023, 7, 1),
        );

        final entityGeoLocation = GeoLocationEntity(
          country: 'Entity Country',
          regionProvince: 'Entity Region',
          district: 'Entity District',
          cityVillage: 'Entity City',
          addressOrCoordinates: 'Entity Address',
          locationType: FacilityLocationType.rural,
        );

        final entityFacilityId = FacilityIdentificationEntity(
          facilityCode: 'ENT001',
          facilityName: 'Entity Hospital',
          managingAuthority: ManagingAuthorityType.privateForProfit,
          directorName: 'Dr. Entity',
          directorPhone: '+987654321',
          directorEmail: 'entity.director@test.com',
          respondentName: 'Entity Respondent',
          respondentPosition: 'Entity Position',
          structureType: FacilityStructureType.temporaryMediumTerm,
          facilityType: FacilityType.standaloneTreatmentCenter,
          existingFacilityType:
              ExistingFacilityType.regionalProvincialReferralHospital,
        );

        final entityFacilityServices = FacilityServicesEntity(
          hasOutpatientServices: false,
          hasInpatientServices: true,
          totalInpatientBeds: 50,
          icuBeds: 5,
          hasEmergencyUnit: false,
          hasIcuOrHighDependencyUnit: true,
        );

        final entitySection = AssessmentSectionEntity(
          id: 'entity_section',
          sectionNumber: '3.1',
          title: 'Entity Section',
          description: 'Entity description',
          items: [],
        );

        final entity = AssessmentFormEntity(
          id: 'entity_form',
          assessorInfo: entityAssessorInfo,
          geoLocation: entityGeoLocation,
          facilityIdentification: entityFacilityId,
          facilityServices: entityFacilityServices,
          sections: [entitySection],
          notes: 'Entity notes',
          isSubmitted: true,
          submissionDate: DateTime(2023, 7, 15),
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final result = AssessmentFormModel.fromEntity(entity);

        // Assert
        // Verify all nested objects are converted to models
        expect(result.assessorInfo, isA<AssessorInfoModel>());
        expect(result.geoLocation, isA<GeoLocationModel>());
        expect(
          result.facilityIdentification,
          isA<FacilityIdentificationModel>(),
        );
        expect(result.facilityServices, isA<FacilityServicesModel>());
        expect(result.sections[0], isA<AssessmentSectionModel>());

        // Verify data integrity
        expect(result.assessorInfo.name, 'Entity Assessor');
        expect(result.geoLocation.country, 'Entity Country');
        expect(result.facilityIdentification.facilityName, 'Entity Hospital');
        expect(result.facilityServices.totalInpatientBeds, 50);
        expect(result.sections[0].title, 'Entity Section');
      });
    });

    test('fromEntity conversion with mixed types', () {
      // Arrange
      final entity = AssessmentFormEntity(
        id: 'x',
        assessorInfo: tAssessorInfoModel, // Already a model
        geoLocation: tGeoLocationModel, // Already a model
        facilityIdentification: tFacilityIdModel, // Already a model
        facilityServices: tFacilityServicesModel, // Already a model
        sections: [tSectionModel], // Already a model
        notes: 'n',
        isSubmitted: false,
        submissionDate: null,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
      // Act
      final result = AssessmentFormModel.fromEntity(entity);
      // Assert
      expect(result.id, 'x');
      expect(result, isA<AssessmentFormModel>());
      // These should remain the same model instances
      expect(result.assessorInfo, same(tAssessorInfoModel));
      expect(result.geoLocation, same(tGeoLocationModel));
    });

    group('copyWith', () {
      test('updates fields and updatedAt', () async {
        // Arrange
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = tAssessmentFormModel.copyWith(notes: 'updated');
        // Assert
        expect(result.notes, 'updated');
        expect(result.createdAt, tAssessmentFormModel.createdAt);
        expect(result.updatedAt.isAfter(before), true);
      });

      test('entity-to-model conversion', () {
        // Arrange
        final domainInfo = AssessorInfoEntity(
          name: 'Domain Assessor',
          email: 'domain@test.com',
          phoneNumber: '+9876543210',
          assessmentDate: DateTime(2023, 6, 1),
        );
        // Act
        final result = tAssessmentFormModel.copyWith(assessorInfo: domainInfo);
        // Assert
        expect(result.assessorInfo, isA<AssessorInfoModel>());
        expect(result.assessorInfo.name, 'Domain Assessor');
      });

      test('copyWith with all entity types converts to models', () {
        // Arrange
        final entityGeoLocation = GeoLocationEntity(
          country: 'Copy Country',
          regionProvince: 'Copy Region',
          district: 'Copy District',
          cityVillage: 'Copy City',
          addressOrCoordinates: 'Copy Address',
          locationType: FacilityLocationType.periUrban,
        );

        final entityFacilityId = FacilityIdentificationEntity(
          facilityCode: 'COPY001',
          facilityName: 'Copy Hospital',
          managingAuthority: ManagingAuthorityType.university,
          directorName: 'Dr. Copy',
          directorPhone: '+111111111',
          directorEmail: 'copy.director@test.com',
          respondentName: 'Copy Respondent',
          respondentPosition: 'Copy Manager',
          structureType: FacilityStructureType.temporaryShortTerm,
          facilityType: FacilityType.standaloneTreatmentCenter,
          existingFacilityType: ExistingFacilityType.infectiousDiseasesUnit,
        );

        final entityFacilityServices = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false,
          totalInpatientBeds: 75,
          icuBeds: 10,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: false,
        );

        final entitySection = AssessmentSectionEntity(
          id: 'copy_section',
          sectionNumber: '5.1',
          title: 'Copy Section',
          description: 'Copy description',
          items: [],
        );

        // Act
        final result = tAssessmentFormModel.copyWith(
          geoLocation: entityGeoLocation,
          facilityIdentification: entityFacilityId,
          facilityServices: entityFacilityServices,
          sections: [entitySection],
        );

        // Assert
        // Verify conversion to models
        expect(result.geoLocation, isA<GeoLocationModel>());
        expect(
          result.facilityIdentification,
          isA<FacilityIdentificationModel>(),
        );
        expect(result.facilityServices, isA<FacilityServicesModel>());
        expect(result.sections[0], isA<AssessmentSectionModel>());

        // Verify data integrity
        expect(result.geoLocation.country, 'Copy Country');
        expect(result.facilityIdentification.facilityName, 'Copy Hospital');
        expect(result.facilityServices.totalInpatientBeds, 75);
        expect(result.sections[0].title, 'Copy Section');
      });

      test(
        'copyWith with explicit isSubmitted and submissionDate parameters',
        () {
          // Arrange
          final customSubmissionDate = DateTime(2023, 8, 20, 15, 30);

          // Act
          final result = tAssessmentFormModel.copyWith(
            isSubmitted: true,
            submissionDate: customSubmissionDate,
          );
          // Assert
          expect(result.isSubmitted, true);
          expect(result.submissionDate, customSubmissionDate);
          expect(
            result.createdAt,
            tAssessmentFormModel.createdAt,
          ); // Should be preserved
        },
      );

      test('copyWith with null isSubmitted and submissionDate uses defaults', () {
        // Arrange and Act
        final result = tAssessmentFormModel.copyWith(
          notes: 'test',
          // Not providing isSubmitted or submissionDate - should use existing values
        );

        // Assert
        expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
        expect(result.submissionDate, tAssessmentFormModel.submissionDate);
      });
    });

    group('copyWithModels method', () {
      test('copies provided model fields directly', () {
        // Arrange
        final newAssessor = AssessorInfoModel(
          name: 'Model Assessor',
          email: 'model@test.com',
          phoneNumber: '+1234567890',
          assessmentDate: DateTime(2023, 8, 1),
        );
        // Act
        final result = tAssessmentFormModel.copyWithModels(
          assessorInfo: newAssessor,
          notes: 'Model test notes',
        );
        // Assert
        expect(result.assessorInfo.name, 'Model Assessor');
        expect(result.notes, 'Model test notes');
      });

      test('updates all fields when provided', () {
        // Arrange
        final newAssessor = AssessorInfoModel(
          name: 'All Fields Assessor',
          email: 'allfields@test.com',
          phoneNumber: '+9999999999',
          assessmentDate: DateTime(2023, 9, 1),
        );
        final newGeo = GeoLocationModel(
          country: 'All Fields Country',
          regionProvince: 'All Fields Region',
          district: 'All Fields District',
          cityVillage: 'All Fields City',
          addressOrCoordinates: 'All Fields Address',
          locationType: FacilityLocationType.rural,
        );
        final newId = FacilityIdentificationModel(
          facilityCode: 'ALL001',
          facilityName: 'All Fields Hospital',
          managingAuthority: ManagingAuthorityType.university,
          directorName: 'Dr. All Fields',
          directorPhone: '+8888888888',
          directorEmail: 'allfields.director@test.com',
          respondentName: 'All Fields Respondent',
          respondentPosition: 'All Fields Manager',
          structureType: FacilityStructureType.temporaryShortTerm,
          facilityType: FacilityType.standaloneTreatmentCenter,
          existingFacilityType:
              ExistingFacilityType.regionalProvincialReferralHospital,
        );
        final newServices = FacilityServicesModel(
          hasOutpatientServices: false,
          hasInpatientServices: false,
          totalInpatientBeds: 25,
          icuBeds: 2,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: false,
        );
        final newSection = AssessmentSectionModel(
          id: 'all_fields_section',
          sectionNumber: '4.1',
          title: 'All Fields Section',
          description: 'All fields description',
          items: [],
        );
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = tAssessmentFormModel.copyWithModels(
          id: 'all_fields_id',
          assessorInfo: newAssessor,
          geoLocation: newGeo,
          facilityIdentification: newId,
          facilityServices: newServices,
          sections: [newSection],
          notes: 'All fields notes',
          isSubmitted: true,
          submissionDate: DateTime(2023, 9, 17),
        );
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.id, 'all_fields_id');
        expect(result.assessorInfo.name, 'All Fields Assessor');
        expect(result.geoLocation.country, 'All Fields Country');
        expect(
          result.facilityIdentification.facilityName,
          'All Fields Hospital',
        );
        expect(result.facilityServices.totalInpatientBeds, 25);
        expect(result.sections[0].title, 'All Fields Section');
        expect(result.notes, 'All fields notes');
        expect(result.isSubmitted, true);
        expect(result.submissionDate, DateTime(2023, 9, 17));
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
      });

      test('preserves all when no args', () {
        // Arrange and Act
        final result = tAssessmentFormModel.copyWithModels();
        // Assert
        expect(result.id, tAssessmentFormModel.id);
        expect(
          result.assessorInfo.name,
          tAssessmentFormModel.assessorInfo.name,
        );
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt.isAfter(testUpdatedAt), true);
      });
    });

    group('_copyWithSystemTimestamps method', () {
      test('markAsSubmitted uses _copyWithSystemTimestamps correctly', () {
        // Arrange
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = tAssessmentFormModel.markAsSubmitted();
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.isSubmitted, true);
        expect(result.submissionDate, isNotNull);
        expect(result.submissionDate!.isAfter(before), true);
        expect(result.submissionDate!.isBefore(after), true);
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
      });

      test('markAsSubmitted preserves all other data', () {
        // Arrange and Act
        final result = tAssessmentFormModel.markAsSubmitted();
        // Assert
        expect(result.id, tAssessmentFormModel.id);
        expect(result.assessorInfo, tAssessmentFormModel.assessorInfo);
        expect(result.geoLocation, tAssessmentFormModel.geoLocation);
        expect(
          result.facilityIdentification,
          tAssessmentFormModel.facilityIdentification,
        );
        expect(result.facilityServices, tAssessmentFormModel.facilityServices);
        expect(result.sections, tAssessmentFormModel.sections);
        expect(result.notes, tAssessmentFormModel.notes);
      });
    });

    group('fromJson edge cases', () {
      test('null created_at', () {
        // Arrange
        final map = tAssessmentFormModel.toJson()..['created_at'] = null;
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.createdAt.isBefore(after), true);
      });
      test('null updated_at', () {
        // Arrange
        final map = tAssessmentFormModel.toJson()..['updated_at'] = null;
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.updatedAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
      });
      test('empty string timestamps', () {
        // Arrange and Act
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = ''
              ..['updated_at'] = '';
        // Assert
        expect(() => AssessmentFormModel.fromJson(map), returnsNormally);
      });
      test('invalid timestamp formats', () {
        // Arrange and Act
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = 'invalid'
              ..['updated_at'] = 'also-invalid';
        // Assert
        expect(() => AssessmentFormModel.fromJson(map), returnsNormally);
      });
    });

    group('entity type checking in copyWith', () {
      test('assessorInfo already model', () {
        // Arrange
        final modelInfo = AssessorInfoModel(
          name: 'Model',
          email: 'm@test',
          phoneNumber: '0',
          assessmentDate: DateTime.now(),
        );
        // Act
        final result = tAssessmentFormModel.copyWith(assessorInfo: modelInfo);
        // Assert
        expect(result.assessorInfo, isA<AssessorInfoModel>());
      });
      test('geoLocation already model', () {
        // Arrange
        final modelGeo = GeoLocationModel(
          country: 'C',
          regionProvince: 'R',
          district: 'D',
          cityVillage: 'V',
          addressOrCoordinates: 'A',
          locationType: FacilityLocationType.urban,
        );
        // Act
        final result = tAssessmentFormModel.copyWith(geoLocation: modelGeo);
        // Assert
        expect(result.geoLocation, isA<GeoLocationModel>());
      });
      test('all nested already models', () {
        // Arrange
        final modelSection = AssessmentSectionModel(
          id: 's',
          sectionNumber: '1',
          title: 'T',
          description: 'D',
          items: [],
        );
        // Act
        final result = tAssessmentFormModel.copyWith(
          assessorInfo: tAssessorInfoModel,
          sections: [modelSection],
        );
        // Assert
        expect(result.sections[0], isA<AssessmentSectionModel>());
      });
    });

    group('_parseDateTime helper method', () {
      test('null dateValue', () {
        // Arrange
        final map = tAssessmentFormModel.toJson()..['submission_date'] = null;
        // Act
        final result = AssessmentFormModel.fromJson(map);
        // Assert
        expect(result.submissionDate, isNull);
      });
      test('non-string dateValue', () {
        // Arrange
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = 123
              ..['updated_at'] = true
              ..['submission_date'] = {};
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
        expect(result.submissionDate, isNull);
      });
      test('empty string values', () {
        // Arrange
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = ''
              ..['updated_at'] = ''
              ..['submission_date'] = '';
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
        expect(result.submissionDate, isNull);
      });
      test('valid date string', () {
        // Arrange
        final iso = '2023-12-31T23:59:59.000Z';
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = iso
              ..['updated_at'] = iso
              ..['submission_date'] = iso;
        // Act
        final result = AssessmentFormModel.fromJson(map);
        // Assert
        expect(result.createdAt, DateTime.parse(iso));
        expect(result.updatedAt, DateTime.parse(iso));
        expect(result.submissionDate, DateTime.parse(iso));
      });
      test('invalid format fallback', () {
        // Arrange
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = 'not-date'
              ..['updated_at'] = '2023-13-01'
              ..['submission_date'] = 'abc';
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
        expect(result.submissionDate, isNull);
      });
    });

    group('_copyWithSystemTimestamps internal method', () {
      test(
        'markAsSubmitted uses same now for submissionDate and updatedAt',
        () {
          // Arrange
          final before = DateTime.now().subtract(Duration(milliseconds: 10));
          // Act
          final result = tAssessmentFormModel.markAsSubmitted();
          final after = DateTime.now().add(Duration(milliseconds: 10));
          // Assert
          expect(result.submissionDate!.isAfter(before), true);
          expect(result.updatedAt.isBefore(after), true);
          expect(result.submissionDate, result.updatedAt);
        },
      );
      test('repeated markAsSubmitted preserves data', () {
        // Arrange
        final first = tAssessmentFormModel.markAsSubmitted();
        // Act
        final second = first.markAsSubmitted();
        // Assert
        expect(second.isSubmitted, true);
        expect(second.createdAt, testCreatedAt);
      });
    });

    group('Additional edge cases for complete', () {
      test('mixed valid and invalid dates', () {
        // Arrange
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = '2023-01-01T10:00:00.000Z'
              ..['updated_at'] = 'bad'
              ..['submission_date'] = null;
        // Act
        final result = AssessmentFormModel.fromJson(map);
        // Assert
        expect(result.createdAt, DateTime.parse('2023-01-01T10:00:00.000Z'));
        expect(result.updatedAt, isA<DateTime>());
        expect(result.submissionDate, isNull);
      });
      test('all null dates', () {
        // Arrange
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = null
              ..['updated_at'] = null
              ..['submission_date'] = null;
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
        expect(result.submissionDate, isNull);
      });
      test('whitespace-only dates', () {
        // Arrange
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = '   '
              ..['updated_at'] = '\t\n'
              ..['submission_date'] = ' ';
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
        expect(result.submissionDate, isNull);
      });
      test('array or map as date value', () {
        // Arrange
        final before = DateTime.now().subtract(Duration(milliseconds: 10));
        final map =
            tAssessmentFormModel.toJson()
              ..['created_at'] = ['2023', '01', '01']
              ..['updated_at'] = {'year': 2023}
              ..['submission_date'] = [];
        // Act
        final result = AssessmentFormModel.fromJson(map);
        final after = DateTime.now().add(Duration(milliseconds: 10));
        // Assert
        expect(result.createdAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
        expect(result.submissionDate, isNull);
      });
    });
  });

  group('_copyWithSystemTimestamps null coalescing', () {
    test('exercises null coalescing for isSubmitted', () {
      // Arrange and Act
      final result = tAssessmentFormModel.copyWithSystemTimestampsForTesting(
        notes: 'test', // Change something else to verify it works
        isSubmitted: null, // This should fall back to this.isSubmitted
      );
      // Assert
      expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
      expect(result.notes, 'test');
    });

    test('exercises null coalescing for submissionDate', () {
      // Arrange
      final submittedModel = tAssessmentFormModel.markAsSubmitted();

      // Act
      final result = submittedModel.copyWithSystemTimestampsForTesting(
        notes: 'test', // Change something else to verify it works
        submissionDate: null, // This should fall back to this.submissionDate
      );
      // Assert
      expect(result.submissionDate, submittedModel.submissionDate);
      expect(result.notes, 'test');
    });

    test('exercises null coalescing for updatedAt', () {
      // Arrange and Act
      final result = tAssessmentFormModel.copyWithSystemTimestampsForTesting(
        notes: 'test', // Change something else to verify it works
        updatedAt: null, // This should fall back to this.updatedAt
      );
      // Assert
      expect(result.updatedAt, tAssessmentFormModel.updatedAt);
      expect(result.notes, 'test');
    });

    test('exercises all null coalescing operators together', () {
      // Arrange
      final submittedModel = tAssessmentFormModel.markAsSubmitted();
      // Act
      final result = submittedModel.copyWithSystemTimestampsForTesting(
        notes: 'all null test',
        isSubmitted: null,
        submissionDate: null,
        updatedAt: null,
      );
      // Assert
      expect(result.isSubmitted, submittedModel.isSubmitted);
      expect(result.submissionDate, submittedModel.submissionDate);
      expect(result.updatedAt, submittedModel.updatedAt);
      expect(result.notes, 'all null test');
    });
  });
}
