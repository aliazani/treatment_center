import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';

void main() {
  // Sample data for testing
  final testDate = DateTime(2023, 5, 15);
  final testCreatedAt = DateTime(2023, 5, 10, 9, 0);
  final testUpdatedAt = DateTime(2023, 5, 12, 14, 30);

  // Sample assessment items and sections
  final item1 = AssessmentItemEntity(
    id: 'item1',
    sectionNumber: '2.1.1',
    area: 'Health care facility entrances',
    meetsTargetDescription: 'Description 1',
    partiallyMeetsDescription: 'Description 2',
    doesNotMeetDescription: 'Description 3',
  );

  final item2 = AssessmentItemEntity(
    id: 'item2',
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
      expect(form.completionPercentage, 50.0);
      expect(form.isComplete, false);
      expect(form.totalItems, 2);
      expect(form.ratedItems, 1);

      // Complete all items and check again
      final completedItem1 = item1.copyWith(
        selectedRating: AssessmentRatingEntity.doesNotMeetTarget(),
      );

      final completedSection1 = section1.copyWith(
        items: [completedItem1, item2],
      );

      final completedForm = form.copyWith(sections: [completedSection1]);

      // Assert after completing all items
      expect(completedForm.completionPercentage, 100.0);
      expect(completedForm.isComplete, true);
      expect(completedForm.totalItems, 2);
      expect(completedForm.ratedItems, 2);
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
      expect(form.completionPercentage, 0.0);
      expect(form.isComplete, true); // Empty form is considered complete
      expect(form.totalItems, 0);
      expect(form.ratedItems, 0);
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
          sections: [section1], // Has items, but not all rated (50% complete)
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
        expect(incompleteForm.status, 'In Progress (50% complete)');
        expect(completeForm.status, 'Complete (Draft)');
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
}
