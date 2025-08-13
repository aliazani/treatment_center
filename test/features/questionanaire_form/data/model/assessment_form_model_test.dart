import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/photo_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';

// Import the test fixtures
import '../../../../fixtures/test_assessment_fixtures.dart';

void main() {
  // Test data constants
  final testSubmitDate = DateTime(2023, 5, 15);
  final testCreatedAt = DateTime(2023, 5, 8, 10, 30);
  final testUpdatedAt = DateTime(2023, 5, 9, 14, 45);

  // Test model instances
  late AssessorInfoModel tAssessorInfoModel;
  late GeoLocationModel tGeoLocationModel;
  late FacilityIdentificationModel tFacilityIdModel;
  late FacilityServicesModel tFacilityServicesModel;
  late AssessmentSectionModel tSectionModel;
  late AssessmentFormModel tAssessmentFormModel;

  setUp(() {
    // Use test fixtures for consistent test data
    tAssessorInfoModel = TestAssessmentFixtures.createTestAssessorInfoModel();
    tGeoLocationModel = TestAssessmentFixtures.createTestGeoLocationModel();
    tFacilityIdModel =
        TestAssessmentFixtures.createTestFacilityIdentificationModel();
    tFacilityServicesModel =
        TestAssessmentFixtures.createTestFacilityServicesModel();

    // Create a section with predefined items using fixtures
    tSectionModel = TestAssessmentFixtures.createTestAssessmentSectionModel(
      id: 'section_1',
      sectionNumber: '2.1',
      itemCount: 2,
      withRatings: true,
    );

    // Create assessment form using fixtures with custom timestamps
    tAssessmentFormModel = AssessmentFormModel(
      id: 'assessment_1',
      assessorInfo: tAssessorInfoModel,
      geoLocation: tGeoLocationModel,
      facilityIdentification: tFacilityIdModel,
      facilityServices: tFacilityServicesModel,
      sections: [tSectionModel],
      photos: [TestAssessmentFixtures.createTestPhotoModel()],
      notes: 'These are assessment notes',
      isSubmitted: false,
      submissionDate: null,
      createdAt: testCreatedAt,
      updatedAt: testUpdatedAt,
    );
  });

  group('AssessmentFormModel', () {
    test('should be a subclass of AssessmentFormEntity', () {
      expect(tAssessmentFormModel, isA<AssessmentFormEntity>());
    });

    group('create factory constructor', () {
      test('should create with current timestamps', () {
        final before = DateTime.now().subtract(
          const Duration(milliseconds: 100),
        );

        final result = AssessmentFormModel.create(
          id: 'new_assessment',
          assessorInfo: tAssessorInfoModel,
          geoLocation: tGeoLocationModel,
          facilityIdentification: tFacilityIdModel,
          facilityServices: tFacilityServicesModel,
          sections: [tSectionModel],
        );

        final after = DateTime.now().add(const Duration(milliseconds: 100));

        expect(result.id, 'new_assessment');
        expect(result.createdAt.isAfter(before), true);
        expect(result.createdAt.isBefore(after), true);
        expect(result.updatedAt, equals(result.createdAt));
        expect(result.isSubmitted, false);
        expect(result.submissionDate, isNull);
        expect(result.photos, isEmpty);
        expect(result.notes, isNull);
      });

      test('should create with optional parameters', () {
        final photos = TestAssessmentFixtures.createTestPhotos(count: 2);

        final result = AssessmentFormModel.create(
          id: 'custom_assessment',
          assessorInfo: tAssessorInfoModel,
          geoLocation: tGeoLocationModel,
          facilityIdentification: tFacilityIdModel,
          facilityServices: tFacilityServicesModel,
          sections: [tSectionModel],
          photos: photos,
          notes: 'Custom notes',
          isSubmitted: true,
          submissionDate: testSubmitDate,
        );

        expect(result.photos, equals(photos));
        expect(result.notes, 'Custom notes');
        expect(result.isSubmitted, true);
        expect(result.submissionDate, testSubmitDate);
      });
    });

    group('fromJson factory constructor', () {
      late Map<String, dynamic> jsonMap;

      setUp(() {
        jsonMap = tAssessmentFormModel.toJson();
      });

      test('should correctly deserialize from JSON', () {
        final result = AssessmentFormModel.fromJson(jsonMap);

        expect(result.id, tAssessmentFormModel.id);
        expect(
          result.assessorInfo.name,
          tAssessmentFormModel.assessorInfo.name,
        );
        expect(
          result.geoLocation.country,
          tAssessmentFormModel.geoLocation.country,
        );
        expect(
          result.facilityIdentification.facilityName,
          tAssessmentFormModel.facilityIdentification.facilityName,
        );
        expect(
          result.facilityServices.totalInpatientBeds,
          tAssessmentFormModel.facilityServices.totalInpatientBeds,
        );
        expect(result.sections.length, tAssessmentFormModel.sections.length);
        expect(result.photos.length, tAssessmentFormModel.photos.length);
        expect(result.notes, tAssessmentFormModel.notes);
        expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
        expect(result.createdAt, tAssessmentFormModel.createdAt);
        expect(result.updatedAt, tAssessmentFormModel.updatedAt);
      });

      test('should handle null photos array', () {
        jsonMap['photos'] = null;

        final result = AssessmentFormModel.fromJson(jsonMap);

        expect(result.photos, isEmpty);
      });

      test('should handle missing isSubmitted field', () {
        jsonMap.remove('is_submitted');

        final result = AssessmentFormModel.fromJson(jsonMap);

        expect(result.isSubmitted, false);
      });

      test('should handle null submission date', () {
        jsonMap['submission_date'] = null;

        final result = AssessmentFormModel.fromJson(jsonMap);

        expect(result.submissionDate, isNull);
      });

      group('_parseDateTime edge cases', () {
        test('should handle null datetime values', () {
          final before = DateTime.now().subtract(
            const Duration(milliseconds: 100),
          );
          jsonMap['created_at'] = null;
          jsonMap['updated_at'] = null;

          final result = AssessmentFormModel.fromJson(jsonMap);
          final after = DateTime.now().add(const Duration(milliseconds: 100));

          expect(result.createdAt.isAfter(before), true);
          expect(result.createdAt.isBefore(after), true);
          expect(result.updatedAt.isAfter(before), true);
          expect(result.updatedAt.isBefore(after), true);
        });

        test('should handle invalid datetime strings', () {
          final before = DateTime.now().subtract(
            const Duration(milliseconds: 100),
          );
          jsonMap['created_at'] = 'invalid-date';
          jsonMap['updated_at'] = 'also-invalid';
          jsonMap['submission_date'] = 'bad-date';

          final result = AssessmentFormModel.fromJson(jsonMap);
          final after = DateTime.now().add(const Duration(milliseconds: 100));

          expect(result.createdAt.isAfter(before), true);
          expect(result.createdAt.isBefore(after), true);
          expect(result.updatedAt.isAfter(before), true);
          expect(result.updatedAt.isBefore(after), true);
          expect(result.submissionDate, isNull);
        });

        test('should handle empty string datetime values', () {
          jsonMap['created_at'] = '';
          jsonMap['updated_at'] = '';
          jsonMap['submission_date'] = '';

          final result = AssessmentFormModel.fromJson(jsonMap);

          expect(result.submissionDate, isNull);
        });

        test('should handle non-string datetime values', () {
          jsonMap['created_at'] = 123;
          jsonMap['updated_at'] = true;
          jsonMap['submission_date'] = {};

          final result = AssessmentFormModel.fromJson(jsonMap);

          expect(result.submissionDate, isNull);
        });

        test('should handle whitespace-only datetime values', () {
          jsonMap['created_at'] = '   ';
          jsonMap['updated_at'] = '\t\n';
          jsonMap['submission_date'] = ' ';

          final result = AssessmentFormModel.fromJson(jsonMap);

          expect(result.submissionDate, isNull);
        });

        test('should parse valid ISO datetime strings', () {
          const isoString = '2023-12-25T15:30:45.123Z';
          jsonMap['created_at'] = isoString;
          jsonMap['updated_at'] = isoString;
          jsonMap['submission_date'] = isoString;

          final result = AssessmentFormModel.fromJson(jsonMap);
          final expectedDate = DateTime.parse(isoString);

          expect(result.createdAt, expectedDate);
          expect(result.updatedAt, expectedDate);
          expect(result.submissionDate, expectedDate);
        });
      });
    });

    group('fromEntity factory constructor', () {
      test('should convert entity with all model types', () {
        final entity = AssessmentFormEntity(
          id: 'entity_form',
          assessorInfo: tAssessorInfoModel,
          geoLocation: tGeoLocationModel,
          facilityIdentification: tFacilityIdModel,
          facilityServices: tFacilityServicesModel,
          sections: [tSectionModel],
          photos: [TestAssessmentFixtures.createTestPhotoModel()],
          notes: 'Entity notes',
          isSubmitted: true,
          submissionDate: testSubmitDate,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final result = AssessmentFormModel.fromEntity(entity);

        expect(result, isA<AssessmentFormModel>());
        expect(result.assessorInfo, same(tAssessorInfoModel));
        expect(result.geoLocation, same(tGeoLocationModel));
        expect(result.facilityIdentification, same(tFacilityIdModel));
        expect(result.facilityServices, same(tFacilityServicesModel));
        expect(result.sections[0], same(tSectionModel));
      });

      test('should convert entity with pure entity types to models', () {
        final entityAssessorInfo =
            TestAssessmentFixtures.createTestAssessorInfo();
        final entityGeoLocation =
            TestAssessmentFixtures.createTestGeoLocation();
        final entityFacilityId =
            TestAssessmentFixtures.createTestFacilityIdentification();
        final entityFacilityServices =
            TestAssessmentFixtures.createTestFacilityServices();
        final entitySection =
            TestAssessmentFixtures.createTestAssessmentSection(
              id: 'entity_section',
              sectionNumber: '3.1',
            );

        final entity = AssessmentFormEntity(
          id: 'entity_form',
          assessorInfo: entityAssessorInfo,
          geoLocation: entityGeoLocation,
          facilityIdentification: entityFacilityId,
          facilityServices: entityFacilityServices,
          sections: [entitySection],
          photos: [],
          notes: 'Entity notes',
          isSubmitted: true,
          submissionDate: testSubmitDate,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final result = AssessmentFormModel.fromEntity(entity);

        expect(result.assessorInfo, isA<AssessorInfoModel>());
        expect(result.geoLocation, isA<GeoLocationModel>());
        expect(
          result.facilityIdentification,
          isA<FacilityIdentificationModel>(),
        );
        expect(result.facilityServices, isA<FacilityServicesModel>());
        expect(result.sections[0], isA<AssessmentSectionModel>());

        expect(result.assessorInfo.name, entityAssessorInfo.name);
        expect(result.geoLocation.country, entityGeoLocation.country);
        expect(
          result.facilityIdentification.facilityName,
          entityFacilityId.facilityName,
        );
        expect(
          result.facilityServices.totalInpatientBeds,
          entityFacilityServices.totalInpatientBeds,
        );
        expect(result.sections[0].title, entitySection.title);
      });

      test('fromEntity conversion with mixed types', () {
        final entity = AssessmentFormEntity(
          id: 'mixed_entity',
          assessorInfo: tAssessorInfoModel, // Already a model
          geoLocation: tGeoLocationModel, // Already a model
          facilityIdentification: tFacilityIdModel, // Already a model
          facilityServices: tFacilityServicesModel, // Already a model
          sections: [tSectionModel], // Already a model
          photos: [],
          notes: 'Mixed entity notes',
          isSubmitted: false,
          submissionDate: null,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final result = AssessmentFormModel.fromEntity(entity);

        expect(result.id, 'mixed_entity');
        expect(result, isA<AssessmentFormModel>());
        // These should remain the same model instances
        expect(result.assessorInfo, same(tAssessorInfoModel));
        expect(result.geoLocation, same(tGeoLocationModel));
        expect(result.facilityIdentification, same(tFacilityIdModel));
        expect(result.facilityServices, same(tFacilityServicesModel));
        expect(result.sections[0], same(tSectionModel));
      });
    });

    group('toJson', () {
      test('should serialize correctly to JSON', () {
        final result = tAssessmentFormModel.toJson();

        expect(result['id'], tAssessmentFormModel.id);
        expect(result['assessor_info'], isA<Map<String, dynamic>>());
        expect(result['geo_location'], isA<Map<String, dynamic>>());
        expect(result['facility_identification'], isA<Map<String, dynamic>>());
        expect(result['facility_services'], isA<Map<String, dynamic>>());
        expect(result['sections'], isA<List>());
        expect(result['photos'], isA<List>());
        expect(result['notes'], tAssessmentFormModel.notes);
        expect(result['is_submitted'], tAssessmentFormModel.isSubmitted);
        expect(result['submission_date'], isNull);
        expect(
          result['created_at'],
          tAssessmentFormModel.createdAt.toIso8601String(),
        );
        expect(
          result['updated_at'],
          tAssessmentFormModel.updatedAt.toIso8601String(),
        );
      });

      test('should serialize submission date when present', () {
        final submittedForm = tAssessmentFormModel.markAsSubmitted();
        final result = submittedForm.toJson();

        expect(result['is_submitted'], true);
        expect(result['submission_date'], isNotNull);
        expect(
          result['submission_date'],
          submittedForm.submissionDate!.toIso8601String(),
        );
      });
    });

    group('toEntity', () {
      test('should convert model to entity correctly', () {
        final result = tAssessmentFormModel.toEntity();

        expect(result, isA<AssessmentFormEntity>());
        expect(result.id, tAssessmentFormModel.id);
        expect(
          result.assessorInfo.name,
          tAssessmentFormModel.assessorInfo.name,
        );
        expect(
          result.geoLocation.country,
          tAssessmentFormModel.geoLocation.country,
        );
        expect(result.notes, tAssessmentFormModel.notes);
        expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
        expect(result.createdAt, tAssessmentFormModel.createdAt);
        expect(result.updatedAt, tAssessmentFormModel.updatedAt);
      });
    });

    group('photoModels getter', () {
      test('should return list of PhotoModel instances', () {
        final result = tAssessmentFormModel.photoModels;

        expect(result, isA<List<PhotoModel>>());
        expect(result.length, 1);
        expect(result[0], isA<PhotoModel>());
      });

      test('should convert PhotoEntity to PhotoModel', () {
        // Create a photo entity using fixtures
        final photoEntity = PhotoEntity(
          id: 'photo_1',
          filePath: '/path/to/photo.jpg',
          fileName: 'photo.jpg',
          source: PhotoSource.camera,
          fileSizeBytes: 1024,
          capturedAt: DateTime.now(),
        );

        final formWithEntityPhoto = tAssessmentFormModel.copyWith(
          photos: [photoEntity],
        );

        final result = formWithEntityPhoto.photoModels;

        expect(result, isA<List<PhotoModel>>());
        expect(result[0], isA<PhotoModel>());
      });
    });

    group('copyWith', () {
      test('should update fields and refresh updatedAt timestamp', () {
        final before = DateTime.now().subtract(
          const Duration(milliseconds: 100),
        );

        final result = tAssessmentFormModel.copyWith(
          notes: 'Updated notes',
          isSubmitted: true,
        );

        final after = DateTime.now().add(const Duration(milliseconds: 100));

        expect(result.notes, 'Updated notes');
        expect(result.isSubmitted, true);
        expect(
          result.createdAt,
          tAssessmentFormModel.createdAt,
        ); // Should not change
        expect(result.updatedAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
      });

      test('should convert entity types to models', () {
        final entityAssessorInfo =
            TestAssessmentFixtures.createTestAssessorInfo();

        final result = tAssessmentFormModel.copyWith(
          assessorInfo: entityAssessorInfo,
        );

        expect(result.assessorInfo, isA<AssessorInfoModel>());
        expect(result.assessorInfo.name, entityAssessorInfo.name);
      });

      test('should copyWith with all entity types converts to models', () {
        final entityGeoLocation =
            TestAssessmentFixtures.createTestGeoLocation();
        final entityFacilityId =
            TestAssessmentFixtures.createTestFacilityIdentification();
        final entityFacilityServices =
            TestAssessmentFixtures.createTestFacilityServices();
        final entitySection =
            TestAssessmentFixtures.createTestAssessmentSection(
              id: 'copy_section',
              sectionNumber: '5.1',
            );

        final result = tAssessmentFormModel.copyWith(
          geoLocation: entityGeoLocation,
          facilityIdentification: entityFacilityId,
          facilityServices: entityFacilityServices,
          sections: [entitySection],
        );

        // Verify conversion to models
        expect(result.geoLocation, isA<GeoLocationModel>());
        expect(
          result.facilityIdentification,
          isA<FacilityIdentificationModel>(),
        );
        expect(result.facilityServices, isA<FacilityServicesModel>());
        expect(result.sections[0], isA<AssessmentSectionModel>());

        // Verify data integrity
        expect(result.geoLocation.country, entityGeoLocation.country);
        expect(
          result.facilityIdentification.facilityName,
          entityFacilityId.facilityName,
        );
        expect(
          result.facilityServices.totalInpatientBeds,
          entityFacilityServices.totalInpatientBeds,
        );
        expect(result.sections[0].title, entitySection.title);
      });

      test('should convert photos from entities to models', () {
        final photoEntity = PhotoEntity(
          id: 'photo_1',
          filePath: '/path/to/photo.jpg',
          fileName: 'photo.jpg',
          source: PhotoSource.gallery,
          fileSizeBytes: 2048,
          capturedAt: DateTime.now(),
        );

        final result = tAssessmentFormModel.copyWith(photos: [photoEntity]);

        expect(result.photos[0], isA<PhotoModel>());
        expect(result.photos[0].fileName, photoEntity.fileName);
      });

      test('should handle model types directly', () {
        final modelAssessorInfo =
            TestAssessmentFixtures.createTestAssessorInfoModel();

        final result = tAssessmentFormModel.copyWith(
          assessorInfo: modelAssessorInfo,
        );

        expect(result.assessorInfo, same(modelAssessorInfo));
      });

      test(
        'should copyWith with explicit isSubmitted and submissionDate parameters',
        () {
          final customSubmissionDate = DateTime(2023, 8, 20, 15, 30);

          final result = tAssessmentFormModel.copyWith(
            isSubmitted: true,
            submissionDate: customSubmissionDate,
          );

          expect(result.isSubmitted, true);
          expect(result.submissionDate, customSubmissionDate);
          expect(
            result.createdAt,
            tAssessmentFormModel.createdAt,
          ); // Should be preserved
        },
      );

      test('copyWith with null isSubmitted and submissionDate uses defaults', () {
        final result = tAssessmentFormModel.copyWith(
          notes: 'test',
          // Not providing isSubmitted or submissionDate - should use existing values
        );

        expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
        expect(result.submissionDate, tAssessmentFormModel.submissionDate);
      });

      test('should preserve existing values when not provided', () {
        final result = tAssessmentFormModel.copyWith(
          notes: 'Only notes changed',
        );

        expect(result.id, tAssessmentFormModel.id);
        expect(result.assessorInfo, tAssessmentFormModel.assessorInfo);
        expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
        expect(result.submissionDate, tAssessmentFormModel.submissionDate);
      });
    });

    group('copyWithModels', () {
      test('should copy with model types directly', () {
        final newAssessor =
            TestAssessmentFixtures.createTestAssessorInfoModel();

        final result = tAssessmentFormModel.copyWithModels(
          assessorInfo: newAssessor,
          notes: 'Models test notes',
        );

        expect(result.assessorInfo, same(newAssessor));
        expect(result.notes, 'Models test notes');
        expect(result.createdAt, tAssessmentFormModel.createdAt);
      });

      test('should update all fields when provided', () {
        final before = DateTime.now().subtract(
          const Duration(milliseconds: 100),
        );

        final result = tAssessmentFormModel.copyWithModels(
          id: 'updated_id',
          notes: 'All fields updated',
          isSubmitted: true,
          submissionDate: testSubmitDate,
        );

        final after = DateTime.now().add(const Duration(milliseconds: 100));

        expect(result.id, 'updated_id');
        expect(result.notes, 'All fields updated');
        expect(result.isSubmitted, true);
        expect(result.submissionDate, testSubmitDate);
        expect(result.updatedAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
      });

      test('should preserve all values when no parameters provided', () {
        final before = DateTime.now().subtract(
          const Duration(milliseconds: 100),
        );

        final result = tAssessmentFormModel.copyWithModels();

        final after = DateTime.now().add(const Duration(milliseconds: 100));

        expect(result.id, tAssessmentFormModel.id);
        expect(result.assessorInfo, tAssessmentFormModel.assessorInfo);
        expect(result.notes, tAssessmentFormModel.notes);
        expect(result.createdAt, tAssessmentFormModel.createdAt);
        expect(result.updatedAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
      });
    });

    group('markAsSubmitted', () {
      test('should mark as submitted with current timestamp', () {
        final before = DateTime.now().subtract(
          const Duration(milliseconds: 100),
        );

        final result = tAssessmentFormModel.markAsSubmitted();

        final after = DateTime.now().add(const Duration(milliseconds: 100));

        expect(result.isSubmitted, true);
        expect(result.submissionDate, isNotNull);
        expect(result.submissionDate!.isAfter(before), true);
        expect(result.submissionDate!.isBefore(after), true);
        expect(result.updatedAt.isAfter(before), true);
        expect(result.updatedAt.isBefore(after), true);
        expect(result.submissionDate, equals(result.updatedAt));
      });

      test('should preserve all other data', () {
        final result = tAssessmentFormModel.markAsSubmitted();

        expect(result.id, tAssessmentFormModel.id);
        expect(result.assessorInfo, tAssessmentFormModel.assessorInfo);
        expect(result.geoLocation, tAssessmentFormModel.geoLocation);
        expect(
          result.facilityIdentification,
          tAssessmentFormModel.facilityIdentification,
        );
        expect(result.facilityServices, tAssessmentFormModel.facilityServices);
        expect(result.sections, tAssessmentFormModel.sections);
        expect(result.photos, tAssessmentFormModel.photos);
        expect(result.notes, tAssessmentFormModel.notes);
        expect(result.createdAt, tAssessmentFormModel.createdAt);
      });

      test('should handle repeated submission', () {
        final firstSubmission = tAssessmentFormModel.markAsSubmitted();
        final secondSubmission = firstSubmission.markAsSubmitted();

        expect(secondSubmission.isSubmitted, true);
        expect(secondSubmission.submissionDate, isNotNull);
        expect(secondSubmission.createdAt, tAssessmentFormModel.createdAt);
      });
    });

    group('copyWithSystemTimestampsForTesting', () {
      test('should exercise null coalescing for isSubmitted', () {
        final result = tAssessmentFormModel.copyWithSystemTimestampsForTesting(
          notes: 'test null coalescing',
          isSubmitted: null,
        );

        expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
        expect(result.notes, 'test null coalescing');
      });

      test('should exercise null coalescing for submissionDate', () {
        final submittedModel = tAssessmentFormModel.markAsSubmitted();

        final result = submittedModel.copyWithSystemTimestampsForTesting(
          notes: 'test submission date null coalescing',
          submissionDate: null,
        );

        expect(result.submissionDate, submittedModel.submissionDate);
        expect(result.notes, 'test submission date null coalescing');
      });

      test('should exercise null coalescing for updatedAt', () {
        final result = tAssessmentFormModel.copyWithSystemTimestampsForTesting(
          notes: 'test updated at null coalescing',
          updatedAt: null,
        );

        expect(result.updatedAt, tAssessmentFormModel.updatedAt);
        expect(result.notes, 'test updated at null coalescing');
      });

      test('should exercise all null coalescing operators together', () {
        final submittedModel = tAssessmentFormModel.markAsSubmitted();

        final result = submittedModel.copyWithSystemTimestampsForTesting(
          notes: 'all null coalescing test',
          isSubmitted: null,
          submissionDate: null,
          updatedAt: null,
        );

        expect(result.isSubmitted, submittedModel.isSubmitted);
        expect(result.submissionDate, submittedModel.submissionDate);
        expect(result.updatedAt, submittedModel.updatedAt);
        expect(result.notes, 'all null coalescing test');
      });

      test('should allow explicit timestamp overrides', () {
        final customCreatedAt = DateTime(2023, 1, 1);
        final customUpdatedAt = DateTime(2023, 2, 1);
        final customSubmissionDate = DateTime(2023, 3, 1);

        final result = tAssessmentFormModel.copyWithSystemTimestampsForTesting(
          createdAt: customCreatedAt,
          updatedAt: customUpdatedAt,
          submissionDate: customSubmissionDate,
          isSubmitted: true,
        );

        expect(result.createdAt, customCreatedAt);
        expect(result.updatedAt, customUpdatedAt);
        expect(result.submissionDate, customSubmissionDate);
        expect(result.isSubmitted, true);
      });
    });

    group('JSON round-trip tests', () {
      test(
        'should maintain data integrity through JSON serialization cycle',
        () {
          final json = tAssessmentFormModel.toJson();
          final restored = AssessmentFormModel.fromJson(json);
          final jsonAgain = restored.toJson();

          expect(jsonAgain, equals(json));
        },
      );

      test('should handle complex data in round-trip', () {
        final complexForm = tAssessmentFormModel.copyWith(
          photos: TestAssessmentFixtures.createTestPhotos(count: 2),
          notes: 'Complex notes with special characters: àáâãäå',
          isSubmitted: true,
          submissionDate: testSubmitDate,
        );

        final json = complexForm.toJson();
        final restored = AssessmentFormModel.fromJson(json);

        expect(restored.photos.length, 2);
        expect(restored.notes, complexForm.notes);
        expect(restored.isSubmitted, true);
        expect(restored.submissionDate, testSubmitDate);
      });
    });

    group('Entity type checking in copyWith', () {
      test('assessorInfo already model', () {
        final modelInfo = TestAssessmentFixtures.createTestAssessorInfoModel();

        final result = tAssessmentFormModel.copyWith(assessorInfo: modelInfo);

        expect(result.assessorInfo, isA<AssessorInfoModel>());
        expect(result.assessorInfo, same(modelInfo));
      });

      test('geoLocation already model', () {
        final modelGeo = TestAssessmentFixtures.createTestGeoLocationModel();

        final result = tAssessmentFormModel.copyWith(geoLocation: modelGeo);

        expect(result.geoLocation, isA<GeoLocationModel>());
        expect(result.geoLocation, same(modelGeo));
      });

      test('facilityIdentification already model', () {
        final modelFacilityId =
            TestAssessmentFixtures.createTestFacilityIdentificationModel();

        final result = tAssessmentFormModel.copyWith(
          facilityIdentification: modelFacilityId,
        );

        expect(
          result.facilityIdentification,
          isA<FacilityIdentificationModel>(),
        );
        expect(result.facilityIdentification, same(modelFacilityId));
      });

      test('facilityServices already model', () {
        final modelFacilityServices =
            TestAssessmentFixtures.createTestFacilityServicesModel();

        final result = tAssessmentFormModel.copyWith(
          facilityServices: modelFacilityServices,
        );

        expect(result.facilityServices, isA<FacilityServicesModel>());
        expect(result.facilityServices, same(modelFacilityServices));
      });

      test('sections already models', () {
        final modelSection =
            TestAssessmentFixtures.createTestAssessmentSectionModel(
              id: 'model_section',
              sectionNumber: '1',
            );

        final result = tAssessmentFormModel.copyWith(sections: [modelSection]);

        expect(result.sections[0], isA<AssessmentSectionModel>());
        expect(result.sections[0], same(modelSection));
      });

      test('photos already models', () {
        final modelPhoto = TestAssessmentFixtures.createTestPhotoModel();

        final result = tAssessmentFormModel.copyWith(photos: [modelPhoto]);

        expect(result.photos[0], isA<PhotoModel>());
        expect(result.photos[0], same(modelPhoto));
      });

      test('all nested already models', () {
        final modelAssessorInfo =
            TestAssessmentFixtures.createTestAssessorInfoModel();
        final modelSection =
            TestAssessmentFixtures.createTestAssessmentSectionModel(
              id: 'all_model_section',
              sectionNumber: '1',
            );

        final result = tAssessmentFormModel.copyWith(
          assessorInfo: modelAssessorInfo,
          sections: [modelSection],
        );

        expect(result.assessorInfo, same(modelAssessorInfo));
        expect(result.sections[0], same(modelSection));
      });
    });

    group('Additional edge case conversions', () {
      test('should handle mixed entity and model conversion in sections', () {
        final entitySection =
            TestAssessmentFixtures.createTestAssessmentSection(
              id: 'entity_sec',
              sectionNumber: '1',
            );
        final modelSection =
            TestAssessmentFixtures.createTestAssessmentSectionModel(
              id: 'model_sec',
              sectionNumber: '2',
            );

        final result = tAssessmentFormModel.copyWith(
          sections: [entitySection, modelSection],
        );

        expect(result.sections[0], isA<AssessmentSectionModel>());
        expect(result.sections[1], isA<AssessmentSectionModel>());
        expect(
          result.sections[1],
          same(modelSection),
        ); // Should be same instance for model
      });

      test('should handle entity to model conversion in all nested fields', () {
        final entityAssessorInfo =
            TestAssessmentFixtures.createTestAssessorInfo();
        final entityGeoLocation =
            TestAssessmentFixtures.createTestGeoLocation();
        final entityFacilityId =
            TestAssessmentFixtures.createTestFacilityIdentification();
        final entityFacilityServices =
            TestAssessmentFixtures.createTestFacilityServices();
        final entitySection =
            TestAssessmentFixtures.createTestAssessmentSection(
              id: 'nested_entity_section',
              sectionNumber: '1',
            );

        final result = tAssessmentFormModel.copyWith(
          assessorInfo: entityAssessorInfo,
          geoLocation: entityGeoLocation,
          facilityIdentification: entityFacilityId,
          facilityServices: entityFacilityServices,
          sections: [entitySection],
        );

        // Verify all conversions happened
        expect(result.assessorInfo, isA<AssessorInfoModel>());
        expect(result.geoLocation, isA<GeoLocationModel>());
        expect(
          result.facilityIdentification,
          isA<FacilityIdentificationModel>(),
        );
        expect(result.facilityServices, isA<FacilityServicesModel>());
        expect(result.sections[0], isA<AssessmentSectionModel>());

        // Verify data integrity after conversion
        expect(result.assessorInfo.name, entityAssessorInfo.name);
        expect(result.geoLocation.country, entityGeoLocation.country);
        expect(
          result.facilityIdentification.facilityName,
          entityFacilityId.facilityName,
        );
        expect(
          result.facilityServices.totalInpatientBeds,
          entityFacilityServices.totalInpatientBeds,
        );
        expect(result.sections[0].title, entitySection.title);
      });

      test('should convert photo entities to models in copyWith', () {
        final photoEntity1 = PhotoEntity(
          id: 'entity_photo_1',
          filePath: '/path/entity1.jpg',
          fileName: 'entity1.jpg',
          source: PhotoSource.gallery,
          fileSizeBytes: 2048,
          capturedAt: DateTime.now(),
        );
        final photoModel = TestAssessmentFixtures.createTestPhotoModel(
          fileName: 'model_photo.jpg',
        );

        final result = tAssessmentFormModel.copyWith(
          photos: [photoEntity1, photoModel],
        );

        expect(result.photos[0], isA<PhotoModel>());
        expect(result.photos[1], isA<PhotoModel>());
        expect(result.photos[0].fileName, 'entity1.jpg');
        expect(
          result.photos[1],
          same(photoModel),
        ); // Should be same instance for model
      });
    });

    group('Edge cases and error handling', () {
      test('should handle empty sections list', () {
        final formWithNoSections = AssessmentFormModel.create(
          id: 'no_sections',
          assessorInfo: tAssessorInfoModel,
          geoLocation: tGeoLocationModel,
          facilityIdentification: tFacilityIdModel,
          facilityServices: tFacilityServicesModel,
          sections: [],
        );

        expect(formWithNoSections.sections, isEmpty);

        final json = formWithNoSections.toJson();
        final restored = AssessmentFormModel.fromJson(json);

        expect(restored.sections, isEmpty);
      });

      test('should handle very long text fields', () {
        final longText = 'A' * 10000; // 10k characters

        final result = tAssessmentFormModel.copyWith(notes: longText);

        expect(result.notes, longText);

        final json = result.toJson();
        final restored = AssessmentFormModel.fromJson(json);

        expect(restored.notes, longText);
      });

      test('should handle extreme dates', () {
        final extremePast = DateTime(1900, 1, 1);
        final extremeFuture = DateTime(2200, 12, 31);

        final result = tAssessmentFormModel.copyWithModels(
          submissionDate: extremeFuture,
        );

        // Use the testing method to set extreme past for created date
        final resultWithExtremePast = result.copyWithSystemTimestampsForTesting(
          createdAt: extremePast,
        );

        expect(resultWithExtremePast.submissionDate, extremeFuture);
        expect(resultWithExtremePast.createdAt, extremePast);
      });
    });

    group('Test fixture integration tests', () {
      test('should work with mixed ratings assessment fixture', () {
        final mixedAssessment =
            TestAssessmentFixtures.createMixedRatingsAssessmentModel(
              id: 'fixture-mixed',
            );

        expect(mixedAssessment, isA<AssessmentFormModel>());
        expect(mixedAssessment.sections.length, 2);
        expect(mixedAssessment.sections[0].items.length, 3);
        expect(mixedAssessment.sections[1].items.length, 3);

        final json = mixedAssessment.toJson();
        final restored = AssessmentFormModel.fromJson(json);

        expect(restored.id, mixedAssessment.id);
        expect(restored.sections.length, mixedAssessment.sections.length);
      });

      test('should work with submitted assessment fixture', () {
        final submittedAssessment =
            TestAssessmentFixtures.createSubmittedAssessmentModel(
              id: 'fixture-submitted',
            );

        expect(submittedAssessment.isSubmitted, true);
        expect(submittedAssessment.submissionDate, isNotNull);

        final json = submittedAssessment.toJson();
        final restored = AssessmentFormModel.fromJson(json);

        expect(restored.isSubmitted, true);
        expect(restored.submissionDate, isNotNull);
      });

      test('should work with assessment with photos fixture', () {
        final assessmentWithPhotos =
            TestAssessmentFixtures.createTestAssessmentModelWithPhotos(
              id: 'fixture-photos',
              photoCount: 3,
            );

        expect(assessmentWithPhotos.photos.length, 3);
        expect(assessmentWithPhotos.photoModels.length, 3);

        final json = assessmentWithPhotos.toJson();
        final restored = AssessmentFormModel.fromJson(json);

        expect(restored.photos.length, 3);
      });

      test('should work with minimal assessment fixture', () {
        final minimalAssessment =
            TestAssessmentFixtures.createMinimalAssessment(
              id: 'fixture-minimal',
            );

        expect(minimalAssessment.notes, '');
        expect(minimalAssessment.isSubmitted, false);
        expect(minimalAssessment.submissionDate, isNull);
        expect(minimalAssessment.photos, isEmpty);

        final json = minimalAssessment.toJson();
        final restored = AssessmentFormModel.fromJson(json);

        expect(restored.notes, minimalAssessment.notes);
        expect(restored.photos, isEmpty);
      });

      test('should work with maximal assessment fixture', () {
        final maximalAssessment =
            TestAssessmentFixtures.createMaximalAssessment(
              id: 'fixture-maximal',
            );

        expect(maximalAssessment.sections.length, 5);
        expect(maximalAssessment.isSubmitted, true);
        expect(maximalAssessment.submissionDate, isNotNull);
        expect(maximalAssessment.photos.isNotEmpty, true);
        expect(maximalAssessment.notes, isNotNull);
        expect(maximalAssessment.notes!.isNotEmpty, true);
      });
    });

    group('Fixture consistency tests', () {
      test('should maintain consistency between entity and model fixtures', () {
        final entityAssessment =
            TestAssessmentFixtures.createTestAssessmentForm(
              id: 'consistency-entity',
            );

        final modelAssessment =
            TestAssessmentFixtures.createTestAssessmentFormModel(
              id: 'consistency-model',
            );

        // Both should have same basic structure
        expect(
          entityAssessment.assessorInfo.name,
          modelAssessment.assessorInfo.name,
        );
        expect(
          entityAssessment.geoLocation.country,
          modelAssessment.geoLocation.country,
        );
        expect(
          entityAssessment.facilityIdentification.facilityName,
          modelAssessment.facilityIdentification.facilityName,
        );
        expect(
          entityAssessment.sections.length,
          modelAssessment.sections.length,
        );
      });

      test('should convert between entity and model using fixtures', () {
        final entityAssessment =
            TestAssessmentFixtures.createTestAssessmentForm(id: 'convert-test');

        final convertedModel = AssessmentFormModel.fromEntity(entityAssessment);
        final convertedEntity = convertedModel.toEntity();

        expect(convertedEntity.id, entityAssessment.id);
        expect(
          convertedEntity.assessorInfo.name,
          entityAssessment.assessorInfo.name,
        );
        expect(convertedEntity.notes, entityAssessment.notes);
        expect(convertedEntity.isSubmitted, entityAssessment.isSubmitted);
      });
    });
  });
}
