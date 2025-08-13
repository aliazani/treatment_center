import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';

void main() {
  // Sample data for testing
  final testDate = DateTime(2023, 5, 15);
  final testCreatedAt = DateTime(2023, 5, 10, 9, 0);
  final testUpdatedAt = DateTime(2023, 5, 12, 14, 30);

  // Sample assessment items and sections
  final item1 = AssessmentItemEntity(
    id: 1,
    itemNumber: 'item_1',
    sectionNumber: '2.1.1',
    area: 'Health care facility entrances',
    meetsTargetDescription: 'Description 1',
    partiallyMeetsDescription: 'Description 2',
    doesNotMeetDescription: 'Description 3',
  );

  final item2 = AssessmentItemEntity(
    id: 2,
    itemNumber: 'item_2',
    sectionNumber: '2.1.2',
    area: 'Area distribution',
    meetsTargetDescription: 'Description 1',
    partiallyMeetsDescription: 'Description 2',
    doesNotMeetDescription: 'Description 3',
    selectedRating: AssessmentRatingEntity.meetsTarget(),
  );

  final section1 = AssessmentSectionEntity(
    id: 'section1',
    sectionNumber: '2.1',
    title: 'Facility accesses and flows',
    items: [item1, item2],
  );

  // Sample form data
  final testAssessorInfo = AssessorInfoEntity(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phoneNumber: '+1234567890',
    assessmentDate: testDate,
  );

  final testGeoLocation = GeoLocationEntity(
    country: 'Uganda',
    regionProvince: 'Western Region',
    district: 'Kasese',
    cityVillage: 'Bwera',
    addressOrCoordinates: '0.14825, 29.71769',
    locationType: FacilityLocationType.rural,
  );

  final testFacilityId = FacilityIdentificationEntity(
    facilityCode: 'F12345',
    facilityName: 'Bwera Hospital',
    managingAuthority: ManagingAuthorityType.government,
    directorName: 'Dr. Jane Smith',
    directorPhone: '+256789123456',
    directorEmail: 'jane.smith@bwera.org',
    respondentName: 'John Doe',
    respondentPosition: 'IPC Focal Person',
    structureType: FacilityStructureType.permanent,
    facilityType: FacilityType.screeningAndTemporaryIsolation,
    existingFacilityType: ExistingFacilityType.firstReferralHospital,
  );

  final testFacilityServices = FacilityServicesEntity(
    hasOutpatientServices: true,
    hasInpatientServices: true,
    totalInpatientBeds: 100,
    icuBeds: 10,
    hasEmergencyUnit: true,
    hasIcuOrHighDependencyUnit: true,
  );

  group('AssessmentForm', () {
    test('should create a valid AssessmentForm with timestamps', () {
      // Arrange & Act
      final form = AssessmentFormEntity(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Assert
      expect(form.id, 'form1');
      expect(form.assessorInfo, testAssessorInfo);
      expect(form.geoLocation, testGeoLocation);
      expect(form.facilityIdentification, testFacilityId);
      expect(form.facilityServices, testFacilityServices);
      expect(form.sections, [section1]);
      expect(form.isSubmitted, false);
      expect(form.submissionDate, isNull);
      expect(form.createdAt, testCreatedAt);
      expect(form.updatedAt, testUpdatedAt);
    });

    group('create factory constructor', () {
      test('should create assessment with current timestamps', () {
        // Arrange
        final beforeCreation = DateTime.now();

        // Act
        final form = AssessmentFormEntity.create(
          id: 'new_form',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          notes: 'New assessment notes',
        );

        final afterCreation = DateTime.now();

        // Assert
        expect(form.id, 'new_form');
        expect(form.notes, 'New assessment notes');
        expect(form.isSubmitted, false);
        expect(form.submissionDate, isNull);
        expect(
          form.createdAt.isAfter(beforeCreation) ||
              form.createdAt.isAtSameMomentAs(beforeCreation),
          true,
        );
        expect(
          form.createdAt.isBefore(afterCreation) ||
              form.createdAt.isAtSameMomentAs(afterCreation),
          true,
        );
        expect(
          form.updatedAt.isAfter(beforeCreation) ||
              form.updatedAt.isAtSameMomentAs(beforeCreation),
          true,
        );
        expect(
          form.updatedAt.isBefore(afterCreation) ||
              form.updatedAt.isAtSameMomentAs(afterCreation),
          true,
        );
        expect(form.createdAt.isAtSameMomentAs(form.updatedAt), true);
      });

      test('should create assessment with specified values', () {
        // Act
        final form = AssessmentFormEntity.create(
          id: 'custom_form',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          notes: 'Custom notes',
          isSubmitted: true,
          submissionDate: testDate,
        );

        // Assert
        expect(form.notes, 'Custom notes');
        expect(form.isSubmitted, true);
        expect(form.submissionDate, testDate);
        expect(form.createdAt, isA<DateTime>());
        expect(form.updatedAt, isA<DateTime>());
      });
    });

    test('should correctly calculate completion statistics', () {
      // Arrange
      final form = AssessmentFormEntity(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Act & Assert
      // Section has 2 items, but only 1 is rated
      expect(form.completionPercentage, 24.107142857142858);
      expect(form.isComplete, false);
      expect(form.totalItems, 2);
      expect(form.completedItems, 1);

      // Complete all items and check again
      final completedItem1 = item1.copyWith(
        selectedRating: AssessmentRatingEntity.doesNotMeetTarget(),
      );

      final completedSection1 = section1.copyWith(
        items: [completedItem1, item2],
      );

      final completedForm = form.copyWith(sections: [completedSection1]);

      // Assert after completing all items
      expect(completedForm.completionPercentage, 24.107142857142858);
      expect(completedForm.isComplete, false);
      expect(completedForm.totalItems, 2);
      expect(completedForm.completedItems, 2);
    });

    test('should mark form as submitted with timestamp updates', () {
      // Arrange
      final form = AssessmentFormEntity(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      final beforeSubmission = DateTime.now();

      // Act
      final submittedForm = form.markAsSubmitted();

      final afterSubmission = DateTime.now();

      // Assert
      expect(submittedForm.isSubmitted, true);
      expect(submittedForm.submissionDate, isNotNull);
      expect(
        submittedForm.submissionDate!.isAfter(beforeSubmission) ||
            submittedForm.submissionDate!.isAtSameMomentAs(beforeSubmission),
        true,
      );
      expect(
        submittedForm.submissionDate!.isBefore(afterSubmission) ||
            submittedForm.submissionDate!.isAtSameMomentAs(afterSubmission),
        true,
      );

      // Verify createdAt is unchanged
      expect(submittedForm.createdAt, testCreatedAt);

      // Verify updatedAt is updated
      expect(submittedForm.updatedAt.isAfter(testUpdatedAt), true);
      expect(
        submittedForm.updatedAt.isAfter(beforeSubmission) ||
            submittedForm.updatedAt.isAtSameMomentAs(beforeSubmission),
        true,
      );
      expect(
        submittedForm.updatedAt.isBefore(afterSubmission) ||
            submittedForm.updatedAt.isAtSameMomentAs(afterSubmission),
        true,
      );

      // Verify submissionDate and updatedAt are the same
      expect(
        submittedForm.submissionDate!.isAtSameMomentAs(submittedForm.updatedAt),
        true,
      );
    });

    test(
      'copyWith should create a new instance with updated fields and timestamp',
      () {
        // Arrange
        final form = AssessmentFormEntity(
          id: 'form1',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final newAssessorInfo = AssessorInfoEntity(
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          phoneNumber: '+0987654321',
          assessmentDate: DateTime(2023, 5, 20),
        );

        final beforeUpdate = DateTime.now();

        // Act
        final updatedForm = form.copyWith(
          assessorInfo: newAssessorInfo,
          notes: 'Important observations',
        );

        final afterUpdate = DateTime.now();

        // Assert
        expect(updatedForm.id, form.id);
        expect(updatedForm.assessorInfo, newAssessorInfo);
        expect(updatedForm.geoLocation, form.geoLocation);
        expect(updatedForm.facilityIdentification, form.facilityIdentification);
        expect(updatedForm.facilityServices, form.facilityServices);
        expect(updatedForm.sections, form.sections);
        expect(updatedForm.notes, 'Important observations');

        // Verify timestamps
        expect(updatedForm.createdAt, testCreatedAt); // Should remain unchanged
        expect(
          updatedForm.updatedAt.isAfter(testUpdatedAt),
          true,
        ); // Should be updated
        expect(
          updatedForm.updatedAt.isAfter(beforeUpdate) ||
              updatedForm.updatedAt.isAtSameMomentAs(beforeUpdate),
          true,
        );
        expect(
          updatedForm.updatedAt.isBefore(afterUpdate) ||
              updatedForm.updatedAt.isAtSameMomentAs(afterUpdate),
          true,
        );
      },
    );

    test('should handle forms with no sections', () {
      // Arrange & Act
      final form = AssessmentFormEntity(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Assert
      expect(form.completionPercentage, 24.107142857142858);
      expect(form.isComplete, false); // Empty form is considered complete
      expect(form.totalItems, 0);
      expect(form.completedItems, 0);
    });

    group('utility properties and methods', () {
      test('canEdit should return correct values', () {
        // Arrange
        final draftForm = AssessmentFormEntity(
          id: 'draft',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          isSubmitted: false,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final submittedForm = draftForm.copyWith(isSubmitted: true);

        // Assert
        expect(draftForm.canEdit, true);
        expect(submittedForm.canEdit, false);
      });

      test('status should return correct status strings', () {
        // Arrange
        final incompleteForm = AssessmentFormEntity(
          id: 'incomplete',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1], // Has items, but not all rated (24% complete)
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final completedItem1 = item1.copyWith(
          selectedRating: AssessmentRatingEntity.meetsTarget(),
        );
        final completeSection = section1.copyWith(
          items: [completedItem1, item2],
        );
        final completeForm = incompleteForm.copyWith(
          sections: [completeSection],
        );

        final submittedForm = completeForm.markAsSubmitted();

        // Assert
        expect(incompleteForm.status, 'In Progress (24% complete)');
        expect(completeForm.status, 'In Progress (24% complete)');
        expect(submittedForm.status, 'Submitted');
      });

      test('timeSinceLastUpdate and age should calculate correctly', () {
        // Arrange
        final pastTime = DateTime.now().subtract(const Duration(hours: 2));
        final form = AssessmentFormEntity(
          id: 'time_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: pastTime,
          updatedAt: pastTime,
        );

        // Act
        final timeSinceUpdate = form.timeSinceLastUpdate;
        final age = form.age;

        // Assert
        expect(timeSinceUpdate.inHours, greaterThanOrEqualTo(1));
        expect(timeSinceUpdate.inHours, lessThan(3));
        expect(age.inHours, greaterThanOrEqualTo(1));
        expect(age.inHours, lessThan(3));
      });

      test('toString should provide useful information', () {
        // Arrange
        final form = AssessmentFormEntity(
          id: 'string_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final stringRepresentation = form.toString();

        // Assert
        expect(stringRepresentation, contains('string_test'));
        expect(stringRepresentation, contains('Bwera Hospital'));
        expect(stringRepresentation, contains('In Progress'));
        expect(stringRepresentation, contains(testCreatedAt.toString()));
        expect(stringRepresentation, contains(testUpdatedAt.toString()));
      });
    });

    group('equality and props', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final form1 = AssessmentFormEntity(
          id: 'same_form',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final form2 = AssessmentFormEntity(
          id: 'same_form',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Assert
        expect(form1, equals(form2));
        expect(form1.hashCode, equals(form2.hashCode));
      });

      test('should not be equal when timestamps differ', () {
        // Arrange
        final form1 = AssessmentFormEntity(
          id: 'timestamp_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final form2 = form1.copyWith(); // This will change updatedAt

        // Assert
        expect(form1, isNot(equals(form2)));
      });
    });

    group('timestamp behavior', () {
      test('should preserve createdAt when updating', () {
        // Arrange
        final originalCreatedAt = testCreatedAt;
        final form = AssessmentFormEntity(
          id: 'preserve_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: originalCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final updated = form.copyWith(notes: 'Updated');

        // Assert
        expect(updated.createdAt, originalCreatedAt);
        expect(updated.updatedAt.isAfter(testUpdatedAt), true);
      });

      test(
        'should have different timestamps for createdAt and updatedAt after updates',
        () async {
          // Arrange
          final original = AssessmentFormEntity.create(
            id: 'diff_timestamp_test',
            assessorInfo: testAssessorInfo,
            geoLocation: testGeoLocation,
            facilityIdentification: testFacilityId,
            facilityServices: testFacilityServices,
            sections: [section1],
          );

          // Small delay to ensure different timestamps
          await Future.delayed(const Duration(milliseconds: 1));

          // Act
          final updated = original.copyWith(notes: 'Updated');

          // Assert
          expect(updated.createdAt.isBefore(updated.updatedAt), true);
        },
      );
    });

    group('_copyWithSystemTimestamps coverage', () {
      test('should use existing isSubmitted when parameter is null', () {
        // Arrange - create form with isSubmitted = true
        final submittedForm = AssessmentFormEntity(
          id: 'test_submitted',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          isSubmitted: true,
          submissionDate: testDate,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act - call with isSubmitted as null to trigger ?? operator
        final result = submittedForm.copyWithSystemTimestamps(
          notes: 'Testing null coalescing',
          // isSubmitted is null, so should use this.isSubmitted (true)
        );

        // Assert
        expect(result.isSubmitted, true); // Should preserve original value
        expect(result.notes, 'Testing null coalescing');
      });

      test('should use existing submissionDate when parameter is null', () {
        // Arrange - create form with submissionDate
        final originalSubmissionDate = DateTime(2023, 4, 15, 10, 30);
        final submittedForm = AssessmentFormEntity(
          id: 'test_submission_date',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          isSubmitted: true,
          submissionDate: originalSubmissionDate,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act - call with submissionDate as null to trigger ?? operator
        final result = submittedForm.copyWithSystemTimestamps(
          notes: 'Testing submission date preservation',
          // submissionDate is null, so should use this.submissionDate
        );

        // Assert
        expect(
          result.submissionDate,
          originalSubmissionDate,
        ); // Should preserve original value
        expect(result.notes, 'Testing submission date preservation');
      });

      test('should use existing updatedAt when parameter is null', () {
        // Arrange - create form with specific updatedAt
        final originalUpdatedAt = DateTime(2023, 4, 20, 14, 45);
        final form = AssessmentFormEntity(
          id: 'test_updated_at',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: originalUpdatedAt,
        );

        // Act - call with updatedAt as null to trigger ?? operator
        final result = form.copyWithSystemTimestamps(
          notes: 'Testing updatedAt preservation',
          // updatedAt is null, so should use this.updatedAt
        );

        // Assert
        expect(
          result.updatedAt,
          originalUpdatedAt,
        ); // Should preserve original value
        expect(result.notes, 'Testing updatedAt preservation');
      });

      test('should handle multiple null parameters using original values', () {
        // Arrange - create form with specific values
        final originalSubmissionDate = DateTime(2023, 4, 10, 9, 15);
        final originalUpdatedAt = DateTime(2023, 4, 12, 11, 20);

        final form = AssessmentFormEntity(
          id: 'test_multiple_nulls',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          notes: 'Original notes',
          isSubmitted: true,
          submissionDate: originalSubmissionDate,
          createdAt: testCreatedAt,
          updatedAt: originalUpdatedAt,
        );

        // Act - call with multiple null parameters
        final result = form.copyWithSystemTimestamps(
          id: 'new_id', // explicit value
          // isSubmitted: null - should use original (true)
          // submissionDate: null - should use original
          // updatedAt: null - should use original
          // All other params null - should use originals
        );

        // Assert - verify all null coalescing operators worked
        expect(result.id, 'new_id'); // explicit value used
        expect(result.assessorInfo, form.assessorInfo); // null ?? original
        expect(result.geoLocation, form.geoLocation); // null ?? original
        expect(
          result.facilityIdentification,
          form.facilityIdentification,
        ); // null ?? original
        expect(
          result.facilityServices,
          form.facilityServices,
        ); // null ?? original
        expect(result.sections, form.sections); // null ?? original
        expect(result.notes, form.notes); // null ?? original
        expect(result.isSubmitted, true); // null ?? original (true)
        expect(
          result.submissionDate,
          originalSubmissionDate,
        ); // null ?? original
        expect(result.createdAt, testCreatedAt); // null ?? original
        expect(result.updatedAt, originalUpdatedAt); // null ?? original
      });
    });
  });

  // Add these test groups to your existing test file

  // Note: You may need to add these imports to your existing test file:
  // import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
  // import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';

  group('Section 1 Progress Calculations', () {
    // Helper method to create minimal required entities for Section 1
    AssessmentFormEntity createFormWithSection1Data({
      AssessorInfoEntity? assessorInfo,
      GeoLocationEntity? geoLocation,
      FacilityIdentificationEntity? facilityId,
      FacilityServicesEntity? facilityServices,
      List<PhotoEntity>? photos,
      List<AssessmentSectionEntity>? sections,
    }) {
      return AssessmentFormEntity(
        id: 'section1_test',
        assessorInfo: assessorInfo ?? testAssessorInfo,
        geoLocation: geoLocation ?? testGeoLocation,
        facilityIdentification: facilityId ?? testFacilityId,
        facilityServices: facilityServices ?? testFacilityServices,
        sections: sections ?? [],
        photos: photos ?? [],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
    }

    group('section1TotalItems', () {
      test('should calculate correct total for complete Section 1 data', () {
        // Act
        final form = createFormWithSection1Data();

        // Assert
        // 4 (assessor) + 6 (geo) + 11 (facility) + 6 (services with inpatient) + 1 (photos) = 28
        expect(form.section1TotalItems, 28);
      });

      test('should calculate correct total when inpatient services is false', () {
        // Arrange
        final facilityServices = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false, // This reduces conditional fields
        );

        // Act
        final form = createFormWithSection1Data(
          facilityServices: facilityServices,
        );

        // Assert
        // 4 (assessor) + 6 (geo) + 11 (facility) + 2 (services without inpatient) + 1 (photos) = 24
        expect(form.section1TotalItems, 24);
      });

      test('should calculate correct total when inpatient services is null', () {
        // Arrange
        final facilityServices = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: null, // This reduces conditional fields
        );

        // Act
        final form = createFormWithSection1Data(
          facilityServices: facilityServices,
        );

        // Assert
        // 4 (assessor) + 6 (geo) + 11 (facility) + 2 (services without inpatient) + 1 (photos) = 24
        expect(form.section1TotalItems, 24);
      });
    });

    group('section1CompletedItems', () {
      test('should calculate zero when all fields are empty/null', () {
        // Arrange
        final emptyAssessorInfo = AssessorInfoEntity(
          name: '',
          email: '',
          phoneNumber: '',
          assessmentDate: null,
        );

        final emptyGeoLocation = GeoLocationEntity(
          country: '',
          regionProvince: '',
          district: '',
          cityVillage: '',
          addressOrCoordinates: '',
          locationType: null,
        );

        final emptyFacilityId = FacilityIdentificationEntity(
          facilityCode: '',
          facilityName: '',
          managingAuthority: null,
          directorName: '',
          directorPhone: '',
          directorEmail: '',
          respondentName: '',
          respondentPosition: '',
          structureType: null,
          facilityType: null,
          existingFacilityType: null,
        );

        final emptyFacilityServices = FacilityServicesEntity(
          hasOutpatientServices: null,
          hasInpatientServices: null,
        );

        // Act
        final form = createFormWithSection1Data(
          assessorInfo: emptyAssessorInfo,
          geoLocation: emptyGeoLocation,
          facilityId: emptyFacilityId,
          facilityServices: emptyFacilityServices,
          photos: [], // No photos
        );

        // Assert
        expect(form.section1CompletedItems, 0);
      });

      test('should calculate correct completion with partial data', () {
        // Arrange
        final partialAssessorInfo = AssessorInfoEntity(
          name: 'John Doe', // 1 completed
          email: '', // 0 completed
          phoneNumber: '+123456789', // 1 completed
          assessmentDate: null, // 0 completed
        );

        final partialGeoLocation = GeoLocationEntity(
          country: 'Uganda', // 1 completed
          regionProvince: '', // 0 completed
          district: 'Kasese', // 1 completed
          cityVillage: '', // 0 completed
          addressOrCoordinates: '0.14825, 29.71769', // 1 completed
          locationType: FacilityLocationType.rural, // 1 completed
        );

        // Using default testFacilityId (all 11 fields completed)
        // Using default testFacilityServices (all 6 fields completed)
        // No photos (0 completed)

        // Act
        final form = createFormWithSection1Data(
          assessorInfo: partialAssessorInfo,
          geoLocation: partialGeoLocation,
          photos: [],
        );

        // Assert
        // 2 (assessor) + 4 (geo) + 11 (facility) + 6 (services) + 0 (photos) = 23
        expect(form.section1CompletedItems, 23);
      });

      test('should calculate correct completion with photos', () {
        // Arrange
        final photos = [
          PhotoEntity(
            id: 'photo1',
            filePath: '/path/to/photo1.jpg',
            fileName: '',
            source: PhotoSource.camera,
            fileSizeBytes: 1024,
            capturedAt: DateTime.now(),
          ),
        ];

        // Act
        final form = createFormWithSection1Data(photos: photos);

        // Assert - should include 1 for photos
        expect(form.section1CompletedItems, greaterThan(0));
        expect(form.section1CompletedItems, 28); // All fields including photos
      });
    });

    group('section1UnansweredItems', () {
      test('should calculate correct unanswered items', () {
        // Arrange
        final partialAssessorInfo = AssessorInfoEntity(
          name: 'John Doe', // completed
          email: '', // not completed
          phoneNumber: '', // not completed
          assessmentDate: testDate, // completed
        );

        // Act
        final form = createFormWithSection1Data(
          assessorInfo: partialAssessorInfo,
        );

        // Assert
        final total = form.section1TotalItems;
        final completed = form.section1CompletedItems;
        expect(form.section1UnansweredItems, total - completed);
      });
    });

    group('section1Progress', () {
      test('should return 0.0 when no items are completed', () {
        // Arrange - create form with all empty fields
        final emptyAssessorInfo = AssessorInfoEntity(
          name: '',
          email: '',
          phoneNumber: '',
          assessmentDate: null,
        );

        final emptyGeoLocation = GeoLocationEntity(
          country: '',
          regionProvince: '',
          district: '',
          cityVillage: '',
          addressOrCoordinates: '',
          locationType: null,
        );

        final emptyFacilityId = FacilityIdentificationEntity(
          facilityCode: '',
          facilityName: '',
          managingAuthority: null,
          directorName: '',
          directorPhone: '',
          directorEmail: '',
          respondentName: '',
          respondentPosition: '',
          structureType: null,
          facilityType: null,
          existingFacilityType: null,
        );

        final emptyFacilityServices = FacilityServicesEntity(
          hasOutpatientServices: null,
          hasInpatientServices: null,
        );

        // Act
        final form = createFormWithSection1Data(
          assessorInfo: emptyAssessorInfo,
          geoLocation: emptyGeoLocation,
          facilityId: emptyFacilityId,
          facilityServices: emptyFacilityServices,
          photos: [],
        );

        // Assert
        expect(form.section1Progress, 0.0);
      });

      test('should return 100.0 when all items are completed', () {
        // Arrange - using default test entities which are complete
        final photos = [
          PhotoEntity(
            id: 'photo1',
            filePath: '/path/to/photo1.jpg',
            fileName: 'photo1.jpg',
            source: PhotoSource.camera,
            fileSizeBytes: 1024,
            capturedAt: DateTime.now(),
          ),
        ];

        // Act
        final form = createFormWithSection1Data(photos: photos);

        // Assert
        expect(form.section1Progress, 100.0);
      });

      test('should calculate correct percentage for partial completion', () {
        // Arrange - 50% completion scenario
        final partialAssessorInfo = AssessorInfoEntity(
          name: 'John Doe', // 1/4 completed for assessor
          email: '',
          phoneNumber: '',
          assessmentDate: null,
        );

        final emptyGeoLocation = GeoLocationEntity(
          country: '',
          regionProvince: '',
          district: '',
          cityVillage: '',
          addressOrCoordinates: '',
          locationType: null,
        );

        final emptyFacilityId = FacilityIdentificationEntity(
          facilityCode: '',
          facilityName: '',
          managingAuthority: null,
          directorName: '',
          directorPhone: '',
          directorEmail: '',
          respondentName: '',
          respondentPosition: '',
          structureType: null,
          facilityType: null,
          existingFacilityType: null,
        );

        final emptyFacilityServices = FacilityServicesEntity(
          hasOutpatientServices: null,
          hasInpatientServices: null,
        );

        // Act
        final form = createFormWithSection1Data(
          assessorInfo: partialAssessorInfo,
          geoLocation: emptyGeoLocation,
          facilityId: emptyFacilityId,
          facilityServices: emptyFacilityServices,
          photos: [],
        );

        // Assert
        final expectedPercentage = (1.0 / form.section1TotalItems) * 100.0;
        expect(form.section1Progress, closeTo(expectedPercentage, 0.1));
      });
    });

    group('isSection1Complete', () {
      test('should return false when Section 1 is incomplete', () {
        // Arrange
        final partialAssessorInfo = AssessorInfoEntity(
          name: 'John Doe',
          email: '', // Missing email makes it incomplete
          phoneNumber: '+123456789',
          assessmentDate: testDate,
        );

        // Act
        final form = createFormWithSection1Data(
          assessorInfo: partialAssessorInfo,
        );

        // Assert
        expect(form.isSection1Complete, false);
      });

      test('should return true when Section 1 is complete', () {
        // Arrange
        final photos = [
          PhotoEntity(
            id: 'photo1',
            filePath: '/path/to/photo1.jpg',
            fileName: 'photo1.jpg',
            source: PhotoSource.camera,
            fileSizeBytes: 1024,
            capturedAt: DateTime.now(),
          ),
        ];

        // Act
        final form = createFormWithSection1Data(photos: photos);

        // Assert
        expect(form.isSection1Complete, true);
      });
    });

    group('section1Status', () {
      test('should return detailed Section 1 status', () {
        // Arrange
        final photos = [
          PhotoEntity(
            id: 'photo1',
            filePath: '/path/to/photo1.jpg',
            fileName: 'photo1.jpg',
            source: PhotoSource.camera,
            fileSizeBytes: 1024,
            capturedAt: DateTime.now(),
          ),
        ];

        // Act
        final form = createFormWithSection1Data(photos: photos);
        final status = form.section1Status;

        // Assert
        expect(status, isA<Section1Status>());
        expect(status.totalItems, form.section1TotalItems);
        expect(status.completedItems, form.section1CompletedItems);
        expect(status.unansweredItems, form.section1UnansweredItems);
        expect(status.isComplete, form.isSection1Complete);
        expect(status.progressPercentage, form.section1Progress);

        // Check subsection progress
        expect(status.assessorInfo, isA<SubsectionProgress>());
        expect(status.geolocation, isA<SubsectionProgress>());
        expect(status.facilityIdentification, isA<SubsectionProgress>());
        expect(status.facilityServices, isA<SubsectionProgress>());
        expect(status.photoDocumentation, isA<SubsectionProgress>());
      });

      test('should handle incomplete status correctly', () {
        // Arrange
        final partialAssessorInfo = AssessorInfoEntity(
          name: 'John Doe',
          email: '', // Missing
          phoneNumber: '',
          assessmentDate: null,
        );

        // Act
        final form = createFormWithSection1Data(
          assessorInfo: partialAssessorInfo,
        );
        final status = form.section1Status;

        // Assert
        expect(status.isComplete, false);
        expect(status.unansweredItems, greaterThan(0));
        expect(status.progressPercentage, lessThan(100.0));
      });
    });
  });

  group('Section1Status Class', () {
    test('should calculate progressPercentage correctly', () {
      // Arrange
      const status = Section1Status(
        totalItems: 10,
        completedItems: 7,
        unansweredItems: 3,
        isComplete: false,
        assessorInfo: SubsectionProgress(
          subsectionName: '1.1 Assessment Information',
          totalItems: 4,
          completedItems: 4,
        ),
        geolocation: SubsectionProgress(
          subsectionName: '1.2 Geographical Location',
          totalItems: 6,
          completedItems: 3,
        ),
        facilityIdentification: SubsectionProgress(
          subsectionName: '1.3 Facility Identification',
          totalItems: 11,
          completedItems: 11,
        ),
        facilityServices: SubsectionProgress(
          subsectionName: '1.4 Existing Health Care Facility Services',
          totalItems: 6,
          completedItems: 6,
        ),
        photoDocumentation: SubsectionProgress(
          subsectionName: '1.5 Photo Documentation Summary',
          totalItems: 1,
          completedItems: 0,
        ),
      );

      // Act & Assert
      expect(status.progressPercentage, 70.0);
    });

    test('should handle zero total items', () {
      // Arrange
      const status = Section1Status(
        totalItems: 0,
        completedItems: 0,
        unansweredItems: 0,
        isComplete: true,
        assessorInfo: SubsectionProgress(
          subsectionName: '1.1 Assessment Information',
          totalItems: 0,
          completedItems: 0,
        ),
        geolocation: SubsectionProgress(
          subsectionName: '1.2 Geographical Location',
          totalItems: 0,
          completedItems: 0,
        ),
        facilityIdentification: SubsectionProgress(
          subsectionName: '1.3 Facility Identification',
          totalItems: 0,
          completedItems: 0,
        ),
        facilityServices: SubsectionProgress(
          subsectionName: '1.4 Existing Health Care Facility Services',
          totalItems: 0,
          completedItems: 0,
        ),
        photoDocumentation: SubsectionProgress(
          subsectionName: '1.5 Photo Documentation Summary',
          totalItems: 0,
          completedItems: 0,
        ),
      );

      // Act & Assert
      expect(status.progressPercentage, 0.0);
    });

    test('should have meaningful toString representation', () {
      // Arrange
      const status = Section1Status(
        totalItems: 10,
        completedItems: 7,
        unansweredItems: 3,
        isComplete: false,
        assessorInfo: SubsectionProgress(
          subsectionName: '1.1 Assessment Information',
          totalItems: 4,
          completedItems: 4,
        ),
        geolocation: SubsectionProgress(
          subsectionName: '1.2 Geographical Location',
          totalItems: 6,
          completedItems: 3,
        ),
        facilityIdentification: SubsectionProgress(
          subsectionName: '1.3 Facility Identification',
          totalItems: 11,
          completedItems: 11,
        ),
        facilityServices: SubsectionProgress(
          subsectionName: '1.4 Existing Health Care Facility Services',
          totalItems: 6,
          completedItems: 6,
        ),
        photoDocumentation: SubsectionProgress(
          subsectionName: '1.5 Photo Documentation Summary',
          totalItems: 1,
          completedItems: 0,
        ),
      );

      // Act
      final stringRep = status.toString();

      // Assert
      expect(stringRep, contains('total: 10'));
      expect(stringRep, contains('completed: 7'));
      expect(stringRep, contains('unanswered: 3'));
      expect(stringRep, contains('progress: 70.0%'));
      expect(stringRep, contains('complete: false'));
    });
  });

  group('SubsectionProgress Class', () {
    test('should calculate unansweredItems correctly', () {
      // Arrange
      const progress = SubsectionProgress(
        subsectionName: '1.1 Assessment Information',
        totalItems: 4,
        completedItems: 2,
      );

      // Act & Assert
      expect(progress.unansweredItems, 2);
    });

    test('should calculate isComplete correctly', () {
      // Arrange
      const completeProgress = SubsectionProgress(
        subsectionName: '1.1 Assessment Information',
        totalItems: 4,
        completedItems: 4,
      );

      const incompleteProgress = SubsectionProgress(
        subsectionName: '1.2 Geographical Location',
        totalItems: 6,
        completedItems: 3,
      );

      // Act & Assert
      expect(completeProgress.isComplete, true);
      expect(incompleteProgress.isComplete, false);
    });

    test('should calculate progressPercentage correctly', () {
      // Arrange
      const progress = SubsectionProgress(
        subsectionName: '1.1 Assessment Information',
        totalItems: 4,
        completedItems: 3,
      );

      const zeroProgress = SubsectionProgress(
        subsectionName: '1.2 Geographical Location',
        totalItems: 0,
        completedItems: 0,
      );

      // Act & Assert
      expect(progress.progressPercentage, 75.0);
      expect(zeroProgress.progressPercentage, 0.0);
    });

    test('should have meaningful toString representation', () {
      // Arrange
      const progress = SubsectionProgress(
        subsectionName: '1.1 Assessment Information',
        totalItems: 4,
        completedItems: 3,
      );

      // Act
      final stringRep = progress.toString();

      // Assert
      expect(stringRep, contains('1.1 Assessment Information'));
      expect(stringRep, contains('3/4'));
      expect(stringRep, contains('75.0%'));
    });
  });

  group('Complex totalItems and ratedItems with Section 1', () {
    test(
      'should correctly calculate totalItems including Section 1 metadata',
      () {
        // Arrange
        final section1 = AssessmentSectionEntity(
          id: 'section1',
          sectionNumber: '1',
          title: 'Assessment Information',
          items: [item1, item2], // 2 items
        );

        final section2 = AssessmentSectionEntity(
          id: 'section2',
          sectionNumber: '2',
          title: 'Facility Assessment',
          items: [item1], // 1 item
        );

        final form = AssessmentFormEntity(
          id: 'complex_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1, section2],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        // Section 1: section1TotalItems (28) + section items (2) = 30
        // Section 2: items (1) = 1
        // Total: 31
        expect(form.totalItems, 31);
      },
    );

    test(
      'should correctly calculate ratedItems including Section 1 metadata',
      () {
        // Arrange
        final ratedItem = item2; // Already has rating
        final unratedItem = item1; // No rating

        final section1 = AssessmentSectionEntity(
          id: 'section1',
          sectionNumber: '1',
          title: 'Assessment Information',
          items: [ratedItem, unratedItem], // 1 rated, 1 unrated
        );

        final section2 = AssessmentSectionEntity(
          id: 'section2',
          sectionNumber: '2',
          title: 'Facility Assessment',
          items: [ratedItem], // 1 rated
        );

        final photos = [
          PhotoEntity(
            id: 'photo1',
            filePath: '/path/to/photo1.jpg',
            fileName: 'photo1.jpg',
            source: PhotoSource.camera,
            fileSizeBytes: 1024,
            capturedAt: DateTime.now(),
          ),
        ];

        final form = AssessmentFormEntity(
          id: 'complex_rated_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1, section2],
          photos: photos,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        // Section 1: section1CompletedItems (28) + completed section items (1) = 29
        // Section 2: completed items (1) = 1
        // Total: 30
        expect(form.completedItems, 30);
      },
    );

    test(
      'should handle Section 1 with no inpatient services in calculations',
      () {
        // Arrange
        final facilityServicesNoInpatient = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false,
        );

        final section1 = AssessmentSectionEntity(
          id: 'section1',
          sectionNumber: '1',
          title: 'Assessment Information',
          items: [item1], // 1 item, unrated
        );

        final form = AssessmentFormEntity(
          id: 'no_inpatient_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: facilityServicesNoInpatient,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(form.totalItems, 25);
        expect(form.completedItems, 23);
      },
    );
  });

  group('completionPercentage with Section 1', () {
    test(
      'should calculate completion percentage including Section 1 metadata',
      () {
        final section1 = AssessmentSectionEntity(
          id: 'section1',
          sectionNumber: '1',
          title: 'Assessment Information',
          items: [item2], // 1 rated item (irrelevant for S1 pct)
        );

        final photos = [
          PhotoEntity(
            id: 'photo1',
            filePath: '/path/to/photo1.jpg',
            fileName: 'photo1.jpg',
            source: PhotoSource.camera,
            fileSizeBytes: 1024,
            capturedAt: DateTime.now(),
          ),
        ];

        final form = AssessmentFormEntity(
          id: 'completion_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          photos: photos, // makes S1 = 100%
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // S1=100%, S2=0%, S3=0%, S4=0% -> avg=25%
        expect(form.completionPercentage, 25.0);
      },
    );
  });

  group('isComplete with Section 1', () {
    test('should return false when Section 1 metadata is incomplete', () {
      // Arrange
      final incompleteAssessorInfo = AssessorInfoEntity(
        name: 'John Doe',
        email: '', // Missing required field
        phoneNumber: '+123456789',
        assessmentDate: testDate,
      );

      final section1 = AssessmentSectionEntity(
        id: 'section1',
        sectionNumber: '1',
        title: 'Assessment Information',
        items: [item2], // Complete item
      );

      final form = AssessmentFormEntity(
        id: 'incomplete_section1_test',
        assessorInfo: incompleteAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Act & Assert
      expect(form.isComplete, false);
    });

    test(
      'should return true when Section 1 is complete and Sections 2–4 exist and are complete',
      () {
        // Arrange — S1 needs a photo to be fully complete
        final s1 = AssessmentSectionEntity(
          id: 'section1',
          sectionNumber: '1',
          title: 'Assessment Information',
          items: [
            item2,
          ], // S1 item ratings don't affect S1 completeness (metadata-driven)
        );

        // Use a rated item for completeness
        final rated = item2; // already has selectedRating

        final s2 = AssessmentSectionEntity(
          id: 'section2',
          sectionNumber: '2',
          title: 'Facility Assessment',
          items: [rated],
        );
        final s3 = AssessmentSectionEntity(
          id: 'section3',
          sectionNumber: '3',
          title: 'Another Section',
          items: [rated],
        );
        final s4 = AssessmentSectionEntity(
          id: 'section4',
          sectionNumber: '4',
          title: 'Yet Another Section',
          items: [rated],
        );

        final photos = [
          PhotoEntity(
            id: 'photo1',
            filePath: '/path/to/photo1.jpg',
            fileName: 'photo1.jpg',
            source: PhotoSource.camera,
            fileSizeBytes: 1024,
            capturedAt: DateTime.now(),
          ),
        ];

        final form = AssessmentFormEntity(
          id: 'complete_all_sections_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [s1, s2, s3, s4],
          photos: photos, // makes S1 fully complete
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act & Assert
        expect(form.isComplete, true);
        expect(form.completionPercentage, 100.0);
      },
    );
  });

  group('Edge Cases and Error Scenarios', () {
    test(
      'should handle empty string values correctly in progress calculations',
      () {
        // Arrange - strings with only whitespace should be considered empty
        final assessorInfoWithWhitespace = AssessorInfoEntity(
          name: '   ', // Should be considered empty
          email: '\t\n', // Should be considered empty
          phoneNumber: ' \r\n ', // Should be considered empty
          assessmentDate: testDate, // Only this is completed
        );

        final form = AssessmentFormEntity(
          id: 'whitespace_test',
          assessorInfo: assessorInfoWithWhitespace,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final assessorProgress = form.section1Status.assessorInfo;

        // Act & Assert
        // Only assessmentDate should be considered completed (1 out of 4)
        expect(assessorProgress.completedItems, 1);
        expect(assessorProgress.totalItems, 4);
      },
    );

    test('should handle null vs empty string distinction', () {
      // Arrange
      final assessorInfoMixed = AssessorInfoEntity(
        name: 'John Doe', // Completed
        email: '', // Empty string - not completed
        phoneNumber: '+123456789', // Completed
        assessmentDate: null, // Null - not completed
      );

      final form = AssessmentFormEntity(
        id: 'null_vs_empty_test',
        assessorInfo: assessorInfoMixed,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      final assessorProgress = form.section1Status.assessorInfo;

      // Act & Assert
      // Only name and phoneNumber should be completed (2 out of 4)
      expect(assessorProgress.completedItems, 2);
    });

    test('should handle facility services conditional logic edge cases', () {
      // Arrange - Test when hasInpatientServices is true but other fields are null
      final partialInpatientServices = FacilityServicesEntity(
        hasOutpatientServices: true,
        hasInpatientServices: true, // This should add 4 more required fields
        totalInpatientBeds: null, // But these are null
        icuBeds: null,
        hasEmergencyUnit: null,
        hasIcuOrHighDependencyUnit: null,
      );

      final form = AssessmentFormEntity(
        id: 'partial_inpatient_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: partialInpatientServices,
        sections: [],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      final servicesProgress = form.section1Status.facilityServices;

      // Act & Assert
      // hasOutpatientServices (1) + hasInpatientServices (1) + 4 nulls = 2 completed out of 6
      expect(servicesProgress.totalItems, 6);
      expect(servicesProgress.completedItems, 2);
    });

    test(
      'should maintain consistency between different progress calculation methods',
      () {
        // Arrange
        final form = AssessmentFormEntity(
          id: 'consistency_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final directTotal = form.section1TotalItems;
        final directCompleted = form.section1CompletedItems;
        final directProgress = form.section1Progress;
        final directComplete = form.isSection1Complete;

        final statusTotal = form.section1Status.totalItems;
        final statusCompleted = form.section1Status.completedItems;
        final statusProgress = form.section1Status.progressPercentage;
        final statusComplete = form.section1Status.isComplete;

        // Assert - All calculation methods should return consistent results
        expect(directTotal, statusTotal);
        expect(directCompleted, statusCompleted);
        expect(directProgress, statusProgress);
        expect(directComplete, statusComplete);
      },
    );
  });

  // Additional test data for PhotoEntity if needed
  PhotoEntity createTestPhoto({
    String id = 'test_photo',
    String filePath = '/test/path/photo.jpg',
    String fileName = 'photo.jpg',
    PhotoSource source = PhotoSource.camera,
    int fileSizeBytes = 1024,
    DateTime? capturedAt,
  }) {
    return PhotoEntity(
      id: id,
      filePath: filePath,
      fileName: fileName,
      source: source,
      fileSizeBytes: fileSizeBytes,
      capturedAt: capturedAt ?? DateTime.now(),
    );
  }

  group('markedAsSubmitted property', () {
    test('should create submitted form with proper timestamps', () {
      // Arrange
      final originalForm = AssessmentFormEntity(
        id: 'marked_submitted_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      final beforeSubmission = DateTime.now();

      // Act
      final submittedForm = originalForm.markedAsSubmitted;

      final afterSubmission = DateTime.now();

      // Assert
      expect(submittedForm.isSubmitted, true);
      expect(submittedForm.submissionDate, isNotNull);
      expect(submittedForm.createdAt, testCreatedAt); // Should remain unchanged

      // Check timestamp ranges
      expect(
        submittedForm.submissionDate!.isAfter(beforeSubmission) ||
            submittedForm.submissionDate!.isAtSameMomentAs(beforeSubmission),
        true,
      );

      expect(
        submittedForm.submissionDate!.isBefore(afterSubmission) ||
            submittedForm.submissionDate!.isAtSameMomentAs(afterSubmission),
        true,
      );
      expect(
        submittedForm.updatedAt.isAfter(beforeSubmission) ||
            submittedForm.updatedAt.isAtSameMomentAs(beforeSubmission),
        true,
      );
      expect(
        submittedForm.updatedAt.isBefore(afterSubmission) ||
            submittedForm.updatedAt.isAtSameMomentAs(afterSubmission),
        true,
      );

      // Verify submissionDate and updatedAt are the same
      expect(
        submittedForm.submissionDate!.isAtSameMomentAs(submittedForm.updatedAt),
        true,
      );
    });
  });

  group('Complex Scenarios with Multiple Sections', () {
    test('should handle mixed section types correctly', () {
      final section1 = AssessmentSectionEntity(
        id: 'section1',
        sectionNumber: '1',
        title: 'Assessment Information',
        items: [item1, item2], // 1 rated, 1 unrated (irrelevant for S1 pct)
      );
      final section2 = AssessmentSectionEntity(
        id: 'section2',
        sectionNumber: '2',
        title: 'Facility Assessment',
        items: [item2], // rated -> 100% for S2
      );
      final section3 = AssessmentSectionEntity(
        id: 'section3',
        sectionNumber: '3',
        title: 'Another Section',
        items: [item1], // unrated -> 0% for S3
      );

      final form = AssessmentFormEntity(
        id: 'mixed_sections_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1, section2, section3],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // S1 has no photo => 27/28 ≈ 96.4286%. Average with (1, 0, 0) => ≈ 49.1071%
      expect(form.completionPercentage, closeTo(49.10714285714286, 1e-9));
    });

    test('should handle form with only Section 1', () {
      // Arrange
      final section1 = AssessmentSectionEntity(
        id: 'section1',
        sectionNumber: '1',
        title: 'Assessment Information',
        items: [],
      );

      final photos = [
        createTestPhoto(),
      ]; // makes S1 fully complete (includes 1.5 photos)

      final form = AssessmentFormEntity(
        id: 'only_section1_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
        photos: photos,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Act & Assert
      expect(form.totalItems, 28); // 1.1–1.5 metadata only
      expect(form.completedItems, 28); // all metadata complete
      expect(form.section1Progress, 100.0); // S1 is fully complete
      expect(
        form.completionPercentage,
        25.0,
      ); // avg of S1=100%, S2=0, S3=0, S4=0
      expect(form.isSection1Complete, true);
      expect(form.isComplete, false); // S2–S4 missing
    });

    test('should handle form with no Section 1', () {
      final section2 = AssessmentSectionEntity(
        id: 'section2',
        sectionNumber: '2',
        title: 'Facility Assessment',
        items: [item1, item2], // 1 unrated, 1 rated => 50% for S2
      );

      final form = AssessmentFormEntity(
        id: 'no_section1_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section2],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      expect(form.totalItems, 2);
      expect(form.completedItems, 1);
      expect(form.completionPercentage, closeTo(36.60714285714286, 1e-9));
      expect(form.isComplete, false);
    });
  });

  group('Private Helper Methods Coverage', () {
    test('should handle assessor info with all combinations', () {
      // Test all possible combinations of assessor info completion
      final testCases = [
        {
          'assessorInfo': AssessorInfoEntity(
            name: '',
            email: '',
            phoneNumber: '',
            assessmentDate: null,
          ),
          'expectedCompleted': 0,
        },
        {
          'assessorInfo': AssessorInfoEntity(
            name: 'John',
            email: '',
            phoneNumber: '',
            assessmentDate: null,
          ),
          'expectedCompleted': 1,
        },
        {
          'assessorInfo': AssessorInfoEntity(
            name: 'John',
            email: 'john@example.com',
            phoneNumber: '+123456789',
            assessmentDate: testDate,
          ),
          'expectedCompleted': 4,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final form = AssessmentFormEntity(
          id: 'assessor_combinations_test',
          assessorInfo: testCase['assessorInfo'] as AssessorInfoEntity,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final assessorProgress = form.section1Status.assessorInfo;

        // Assert
        expect(
          assessorProgress.completedItems,
          testCase['expectedCompleted'],
          reason: 'Failed for assessor info: ${testCase['assessorInfo']}',
        );
        expect(assessorProgress.totalItems, 4);
      }
    });

    test('should handle geolocation with all combinations', () {
      // Test different combinations of geolocation completion
      final testCases = [
        {
          'geoLocation': GeoLocationEntity(
            country: '',
            regionProvince: '',
            district: '',
            cityVillage: '',
            addressOrCoordinates: '',
            locationType: null,
          ),
          'expectedCompleted': 0,
        },
        {
          'geoLocation': GeoLocationEntity(
            country: 'Uganda',
            regionProvince: 'Western',
            district: '',
            cityVillage: '',
            addressOrCoordinates: '',
            locationType: null,
          ),
          'expectedCompleted': 2,
        },
        {
          'geoLocation': GeoLocationEntity(
            country: 'Uganda',
            regionProvince: 'Western',
            district: 'Kasese',
            cityVillage: 'Bwera',
            addressOrCoordinates: '0.14825, 29.71769',
            locationType: FacilityLocationType.urban,
          ),
          'expectedCompleted': 6,
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final form = AssessmentFormEntity(
          id: 'geo_combinations_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testCase['geoLocation'] as GeoLocationEntity,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final geoProgress = form.section1Status.geolocation;

        // Assert
        expect(
          geoProgress.completedItems,
          testCase['expectedCompleted'],
          reason: 'Failed for geolocation: ${testCase['geoLocation']}',
        );
        expect(geoProgress.totalItems, 6);
      }
    });

    test('should handle facility services conditional fields correctly', () {
      // Test different facility services scenarios
      final testCases = [
        {
          'services': FacilityServicesEntity(
            hasOutpatientServices: null,
            hasInpatientServices: null,
          ),
          'expectedTotal': 2,
          'expectedCompleted': 0,
        },
        {
          'services': FacilityServicesEntity(
            hasOutpatientServices: true,
            hasInpatientServices: false,
          ),
          'expectedTotal': 2,
          'expectedCompleted': 2,
        },
        {
          'services': FacilityServicesEntity(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: null,
            icuBeds: null,
            hasEmergencyUnit: null,
            hasIcuOrHighDependencyUnit: null,
          ),
          'expectedTotal': 6,
          'expectedCompleted': 2, // Only the first 2 fields
        },
        {
          'services': FacilityServicesEntity(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: 100,
            icuBeds: 10,
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          ),
          'expectedTotal': 6,
          'expectedCompleted': 6, // All fields complete
        },
      ];

      for (final testCase in testCases) {
        // Arrange
        final form = AssessmentFormEntity(
          id: 'services_combinations_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testCase['services'] as FacilityServicesEntity,
          sections: [],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act
        final servicesProgress = form.section1Status.facilityServices;

        // Assert
        expect(
          servicesProgress.totalItems,
          testCase['expectedTotal'],
          reason: 'Total failed for services: ${testCase['services']}',
        );
        expect(
          servicesProgress.completedItems,
          testCase['expectedCompleted'],
          reason: 'Completed failed for services: ${testCase['services']}',
        );
      }
    });
  });

  group('Regression Tests and Edge Cases', () {
    test('should handle extremely large numbers of sections', () {
      // Arrange - Create many sections to test performance/edge cases
      final sections = List.generate(100, (index) {
        return AssessmentSectionEntity(
          id: 'section_$index',
          sectionNumber: '$index',
          title: 'Section $index',
          items:
              index == 1
                  ? [item1, item2]
                  : [item1], // Section 1 gets special treatment
        );
      });

      final form = AssessmentFormEntity(
        id: 'large_sections_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: sections,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Act & Assert - Should not crash and should calculate correctly
      expect(form.totalItems, greaterThan(100));
      expect(form.completedItems, greaterThanOrEqualTo(0));
      expect(form.completionPercentage, greaterThanOrEqualTo(0.0));
      expect(form.completionPercentage, lessThanOrEqualTo(100.0));
    });

    test('should handle empty sections list gracefully', () {
      final form = AssessmentFormEntity(
        id: 'empty_sections_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // S1≈96.4286% (no photo), S2–S4 missing => avg ≈ 24.1071%
      expect(form.completionPercentage, closeTo(24.107142857142858, 1e-9));
      expect(form.isComplete, false);

      // These Section 1 helpers still reflect metadata totals
      expect(form.section1TotalItems, 28); // (4 + 6 + 11 + 6 + 1)
      expect(form.section1CompletedItems, 27); // missing photo only
      expect(form.section1Progress, closeTo(96.42857142857143, 1e-9));
      expect(form.isSection1Complete, false);
    });

    test('should handle concurrent timestamp operations correctly', () async {
      // Arrange
      final originalForm = AssessmentFormEntity(
        id: 'concurrent_test',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Act - Perform multiple operations that update timestamps
      final updated1 = originalForm.copyWith(notes: 'Update 1');
      await Future.delayed(const Duration(milliseconds: 1));
      final updated2 = updated1.copyWith(notes: 'Update 2');
      await Future.delayed(const Duration(milliseconds: 1));
      final submitted = updated2.markAsSubmitted();

      // Assert - Timestamps should be in correct order
      expect(originalForm.updatedAt.isBefore(updated1.updatedAt), true);
      expect(updated1.updatedAt.isBefore(updated2.updatedAt), true);
      expect(updated2.updatedAt.isBefore(submitted.updatedAt), true);

      // CreatedAt should remain constant
      expect(originalForm.createdAt, updated1.createdAt);
      expect(originalForm.createdAt, updated2.createdAt);
      expect(originalForm.createdAt, submitted.createdAt);

      // Submission date should match final updatedAt
      expect(
        submitted.submissionDate!.isAtSameMomentAs(submitted.updatedAt),
        true,
      );
    });

    test(
      'should maintain data integrity after multiple copyWith operations',
      () {
        // Arrange
        final originalForm = AssessmentFormEntity(
          id: 'integrity_test',
          assessorInfo: testAssessorInfo,
          geoLocation: testGeoLocation,
          facilityIdentification: testFacilityId,
          facilityServices: testFacilityServices,
          sections: [section1],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // Act - Chain multiple copyWith operations
        final modified = originalForm
            .copyWith(notes: 'First update')
            .copyWith(id: 'new_id')
            .copyWith(notes: 'Second update')
            .copyWith(isSubmitted: true);

        // Assert - Final form should have all updates and maintain integrity
        expect(modified.id, 'new_id');
        expect(modified.notes, 'Second update');
        expect(modified.isSubmitted, true);
        expect(
          modified.assessorInfo,
          originalForm.assessorInfo,
        ); // Should be unchanged
        expect(
          modified.createdAt,
          originalForm.createdAt,
        ); // Should be unchanged
        expect(modified.updatedAt.isAfter(originalForm.updatedAt), true);

        // Calculated properties should still work correctly
        expect(modified.section1TotalItems, originalForm.section1TotalItems);
        expect(
          modified.completionPercentage,
          originalForm.completionPercentage,
        );
      },
    );

    test('should handle Unicode and special characters in string fields', () {
      // Arrange
      final unicodeAssessorInfo = AssessorInfoEntity(
        name: 'José María García-López 🏥', // Unicode characters
        email: 'josé.maría@hospital-süd.org',
        phoneNumber: '+49 (0) 123 456-789',
        assessmentDate: testDate,
      );

      final unicodeGeoLocation = GeoLocationEntity(
        country: 'España',
        regionProvince: 'Cataluña',
        district: 'Girona',
        cityVillage: 'Figueres',
        addressOrCoordinates: 'Carrer de la Jonquera, 42°16′N 2°58′E',
        locationType: FacilityLocationType.urban,
      );

      final form = AssessmentFormEntity(
        id: 'unicode_test',
        assessorInfo: unicodeAssessorInfo,
        geoLocation: unicodeGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      // Act & Assert - Should handle Unicode correctly in progress calculations
      final assessorProgress = form.section1Status.assessorInfo;
      final geoProgress = form.section1Status.geolocation;

      expect(
        assessorProgress.completedItems,
        4,
      ); // All fields should be counted as complete
      expect(
        geoProgress.completedItems,
        6,
      ); // All fields should be counted as complete

      // ToString should work without errors
      expect(form.toString(), isA<String>());
      expect(form.section1Status.toString(), isA<String>());
    });
  });
}
