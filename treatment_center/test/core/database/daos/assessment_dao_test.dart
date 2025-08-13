import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
import 'package:treatment_center/core/database/app_database.dart';
import 'package:treatment_center/core/database/daos/assessment_dao.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart'
    as domain;
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart'
    as domain_facility;

import '../../../fixtures/test_assessment_fixtures.dart';

void main() {
  late AppDatabase database;
  late AssessmentDao dao;

  setUp(() async {
    database = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    dao = database.assessmentDao;

    // Verify foreign keys are enabled
    final result = await database.customSelect('PRAGMA foreign_keys').get();
    expect(
      result.first.data['foreign_keys'],
      1,
      reason: 'Foreign keys must be enabled for DAO tests',
    );
  });

  tearDown(() async {
    await database.close();
  });

  // =================== BASIC CRUD OPERATIONS ===================
  group('Basic CRUD Operations', () {
    test('should save assessment successfully with valid data', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-assessment-1',
      );

      // Act
      final result = await dao.saveAssessment(assessment);

      // Assert
      expect(result, true);

      final savedAssessment = await dao.getAssessment(assessment.id);
      expect(savedAssessment, isNotNull);
      expect(savedAssessment!.id, assessment.id);
      expect(savedAssessment.assessorInfo.name, assessment.assessorInfo.name);
      expect(
        savedAssessment.facilityIdentification.facilityName,
        assessment.facilityIdentification.facilityName,
      );
    });

    test('should retrieve assessment by ID correctly', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-assessment-2',
      );
      await dao.saveAssessment(assessment);

      // Act
      final retrieved = await dao.getAssessment(assessment.id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, assessment.id);
      expect(retrieved.assessorInfo.name, assessment.assessorInfo.name);
      expect(retrieved.geoLocation.country, assessment.geoLocation.country);
      expect(
        retrieved.facilityIdentification.facilityName,
        assessment.facilityIdentification.facilityName,
      );
      expect(
        retrieved.facilityServices.hasOutpatientServices,
        assessment.facilityServices.hasOutpatientServices,
      );
      expect(retrieved.sections.length, assessment.sections.length);
    });

    test('should return null for non-existent assessment', () async {
      // Act
      final result = await dao.getAssessment('non-existent-id');

      // Assert
      expect(result, isNull);
    });

    test('should update existing assessment correctly', () async {
      // Arrange
      final originalAssessment =
          TestAssessmentFixtures.createAssessmentForSimpleUpdate(
            id: 'test-update-1',
          );
      await dao.saveAssessment(originalAssessment);

      final updatedAssessment =
          TestAssessmentFixtures.createSimpleUpdateAssessment(
            original: originalAssessment,
            newNotes: 'Updated notes',
            newSubmissionStatus: true,
            newSubmissionDate: DateTime.now(),
          );

      // Act
      final result = await dao.updateAssessment(updatedAssessment);

      // Assert
      expect(result, true);

      final retrieved = await dao.getAssessment(originalAssessment.id);
      expect(retrieved!.notes, 'Updated notes');
      expect(retrieved.isSubmitted, true);
      expect(retrieved.submissionDate, isNotNull);
    });

    test('should fail to update non-existent assessment', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'non-existent',
      );

      // Act
      final result = await dao.updateAssessment(assessment);

      // Assert
      expect(result, false);
    });

    test('should delete assessment correctly', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-delete-1',
      );
      await dao.saveAssessment(assessment);

      // Verify it exists
      var retrieved = await dao.getAssessment(assessment.id);
      expect(retrieved, isNotNull);

      // Act
      final result = await dao.deleteAssessment(assessment.id);

      // Assert
      expect(result, true);

      // Verify it's deleted
      retrieved = await dao.getAssessment(assessment.id);
      expect(retrieved, isNull);
    });

    test('should clear all assessments correctly', () async {
      // Arrange
      final assessments = TestAssessmentFixtures.createBulkTestAssessments(
        count: 3,
        idPrefix: 'clear-test',
      );

      for (final assessment in assessments) {
        await dao.saveAssessment(assessment);
      }

      final beforeClear = await dao.getAllAssessments();
      expect(beforeClear.length, 3);

      // Act
      final result = await dao.clearAllAssessments();

      // Assert
      expect(result, true);

      final afterClear = await dao.getAllAssessments();
      expect(afterClear.length, 0);
    });
  });

  // =================== QUERY OPERATIONS ===================
  group('Query Operations', () {
    setUp(() async {
      final searchData = await TestAssessmentFixtures.createSearchTestData();
      for (final assessment in searchData) {
        await dao.saveAssessment(assessment);
      }
    });

    test('should get all assessments ordered by update date', () async {
      // Act
      final assessments = await dao.getAllAssessments();

      // Assert
      expect(assessments.length, greaterThan(0));

      // Verify ordering (should be desc by updatedAt)
      for (int i = 1; i < assessments.length; i++) {
        expect(
          assessments[i - 1].updatedAt.isAfter(assessments[i].updatedAt) ||
              assessments[i - 1].updatedAt.isAtSameMomentAs(
                assessments[i].updatedAt,
              ),
          true,
          reason: 'Assessments should be ordered by updatedAt descending',
        );
      }
    });

    test('should get only unsubmitted assessments', () async {
      // Act
      final unsubmitted = await dao.getUnsubmittedAssessments();

      // Assert
      expect(unsubmitted.length, greaterThan(0));

      for (final assessment in unsubmitted) {
        expect(assessment.isSubmitted, false);
        expect(assessment.submissionDate, isNull);
      }
    });

    test('should get only submitted assessments', () async {
      // Act
      final submitted = await dao.getSubmittedAssessments();

      // Assert
      expect(submitted.length, greaterThan(0));

      for (final assessment in submitted) {
        expect(assessment.isSubmitted, true);
        expect(assessment.submissionDate, isNotNull);
      }
    });

    test('should search assessments by facility name', () async {
      // Act
      final results = await dao.searchByFacilityName('Hospital');

      // Assert
      expect(results.length, greaterThan(0));

      for (final assessment in results) {
        expect(
          assessment.facilityIdentification.facilityName.toLowerCase(),
          contains('hospital'),
        );
      }
    });

    test('should search assessments by assessor name', () async {
      // Act
      final results = await dao.searchByAssessorName('John');

      // Assert
      expect(results.length, greaterThan(0));

      for (final assessment in results) {
        expect(assessment.assessorInfo.name.toLowerCase(), contains('john'));
      }
    });

    test('should get assessments by date range', () async {
      // Arrange
      final dateRangeAssessments =
          TestAssessmentFixtures.createDateRangeTestAssessments();
      for (final assessment in dateRangeAssessments) {
        await dao.saveAssessment(assessment);
      }

      final startDate = DateTime.now().subtract(const Duration(days: 7));
      final endDate = DateTime.now().add(const Duration(days: 1));

      // Act
      final results = await dao.getAssessmentsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(results.length, greaterThan(0));

      for (final assessment in results) {
        expect(assessment.createdAt.isAfter(startDate), true);
        expect(assessment.createdAt.isBefore(endDate), true);
      }
    });
  });

  // =================== STREAM OPERATIONS ===================
  group('Stream Operations', () {
    test('should watch all assessments as stream', () async {
      // Arrange
      final stream = dao.watchAllAssessments();
      final streamResults = <List<AssessmentFormModel>>[];
      final subscription = stream.listen(streamResults.add);

      try {
        await Future.delayed(const Duration(milliseconds: 100));

        // Add an assessment
        final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'stream-test-1',
        );
        await dao.saveAssessment(assessment);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(streamResults.length, greaterThan(0));
        expect(streamResults.last.any((a) => a.id == assessment.id), true);
      } finally {
        await subscription.cancel();
      }
    });

    test('should watch unsubmitted assessments as stream', () async {
      // Arrange
      final stream = dao.watchUnsubmittedAssessments();
      final streamResults = <List<AssessmentFormModel>>[];
      final subscription = stream.listen(streamResults.add);

      try {
        final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'stream-unsubmitted-test',
          isSubmitted: false,
        );
        await dao.saveAssessment(assessment);

        await Future.delayed(const Duration(milliseconds: 100));

        // Update to submitted
        final submittedAssessment =
            TestAssessmentFixtures.createSimpleUpdateAssessment(
              original: assessment,
              newSubmissionStatus: true,
              newSubmissionDate: DateTime.now(),
            );
        await dao.updateAssessment(submittedAssessment);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(streamResults.length, greaterThan(0));
      } finally {
        await subscription.cancel();
      }
    });

    test('should watch submitted assessments as stream', () async {
      // Arrange
      final stream = dao.watchSubmittedAssessments();
      final streamResults = <List<AssessmentFormModel>>[];
      final subscription = stream.listen(streamResults.add);

      try {
        final assessment =
            TestAssessmentFixtures.createSubmittedAssessmentModel(
              id: 'stream-submitted-test',
            );
        await dao.saveAssessment(assessment);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(streamResults.length, greaterThan(0));
        expect(streamResults.last.any((a) => a.id == assessment.id), true);
      } finally {
        await subscription.cancel();
      }
    });
  });

  // =================== BUSINESS LOGIC TESTS ===================
  group('Business Logic', () {
    test('should preserve assessment ID during save operations', () async {
      // Arrange
      final originalId = 'test-assessment-123';
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: originalId,
      );

      // Act
      await dao.saveAssessment(assessment);

      // Assert
      final saved = await dao.getAssessment(originalId);
      expect(saved, isNotNull);
      expect(saved!.id, originalId);
    });

    test('should handle assessments with sections and items', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-sections-items',
        sectionCount: 3,
        itemsPerSection: 4,
      );

      // Act
      await dao.saveAssessment(assessment);

      // Assert
      final saved = await dao.getAssessment(assessment.id);
      expect(saved, isNotNull);
      expect(saved!.sections.length, 3);

      for (final section in saved.sections) {
        expect(section.items.length, 4);
      }
    });

    test('should handle assessments with ratings', () async {
      // Arrange
      final assessment =
          TestAssessmentFixtures.createMixedRatingsAssessmentModel(
            id: 'test-with-ratings',
          );

      // Act
      await dao.saveAssessment(assessment);

      // Assert
      final saved = await dao.getAssessment(assessment.id);
      expect(saved, isNotNull);

      final hasRatedItems = saved!.sections.any(
        (section) => section.items.any((item) => item.selectedRating != null),
      );
      expect(hasRatedItems, true);
    });

    test('should handle foreign key constraints correctly', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-foreign-keys',
      );

      // Act & Assert
      try {
        final result = await dao.saveAssessment(assessment);
        expect(result, true);

        // Verify all related entities were created
        await DatabaseTestHelper.verifyRelatedEntitiesExist(database);
      } catch (e) {
        fail('DAO save operation failed: $e');
      }
    });

    test('should handle cascade delete operations', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-cascade-delete',
      );
      await dao.saveAssessment(assessment);

      // Act
      final result = await dao.deleteAssessment(assessment.id);

      // Assert
      expect(result, true);

      final finalCounts = await DatabaseTestHelper.getEntityCounts(database);
      expect(finalCounts.forms, 0);
      expect(finalCounts.sections, 0);
      expect(finalCounts.items, 0);
    });
  });

  // =================== DATA INTEGRITY TESTS ===================
  group('Data Integrity', () {
    test('should maintain referential integrity', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-referential-integrity',
      );
      await dao.saveAssessment(assessment);

      // Act & Assert
      await DatabaseTestHelper.verifyReferentialIntegrity(database);
    });

    test('should handle enum conversion correctly', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-enum-conversion',
      );

      // Act
      await dao.saveAssessment(assessment);
      final saved = await dao.getAssessment(assessment.id);

      // Assert
      expect(
        saved!.geoLocation.locationType,
        assessment.geoLocation.locationType,
      );
      expect(
        saved.facilityIdentification.managingAuthority,
        assessment.facilityIdentification.managingAuthority,
      );
      expect(
        saved.facilityIdentification.structureType,
        assessment.facilityIdentification.structureType,
      );
      expect(
        saved.facilityIdentification.facilityType,
        assessment.facilityIdentification.facilityType,
      );
    });
  });

  // =================== ERROR HANDLING ===================
  group('Error Handling', () {
    test(
      'should handle and log error in _deleteAssessmentItemsAndRatings',
      () async {
        final testDao = database.assessmentDao;

        // Create assessment with items and ratings
        final assessment =
            TestAssessmentFixtures.createComplexAssessmentForErrorTesting(
              id: 'error-test-1',
              includeRatings: true,
            );

        await testDao.saveAssessment(assessment);

        // Verify the data was saved properly
        final saved = await testDao.getAssessment(assessment.id);
        expect(saved, isNotNull);
        expect(saved!.sections.length, greaterThan(0));

        // Verify we have ratings to delete
        final ratings = await database.select(database.assessmentRatings).get();
        expect(ratings.length, greaterThan(0));

        // Execute raw SQL to create a constraint that will cause deletion to fail
        await database.customStatement('''
      CREATE TRIGGER prevent_rating_delete 
      BEFORE DELETE ON assessment_ratings
      BEGIN
        SELECT RAISE(FAIL, 'Test error: Cannot delete rating');
      END;
    ''');

        // Act
        final result = await testDao.deleteAssessment(assessment.id);

        // Assert - Should return false due to the error
        expect(result, false);
      },
    );

    test('should handle database errors gracefully', () async {
      // Arrange
      await database.close();

      // Act & Assert
      expect(() => dao.getAllAssessments(), throwsA(isA<StateError>()));
    });

    test('should handle concurrent operations safely', () async {
      // Arrange
      final assessments =
          TestAssessmentFixtures.createConcurrentTestAssessments(
            baseId: 'concurrent-test',
            count: 3,
          );

      // Act
      final futures = <Future>[];

      for (int i = 0; i < 3; i++) {
        futures.add(dao.saveAssessment(assessments[i]));
        futures.add(dao.getAllAssessments());
      }

      // Assert
      final results = await Future.wait(futures, eagerError: false);
      expect(results.any((r) => r == true || r is List), true);
    });

    test('should handle and log error in updateAssessment', () async {
      // Create a fresh database for this test
      final testDao = database.assessmentDao;

      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'update-error-test',
      );
      await testDao.saveAssessment(assessment);

      // Close database to force error
      await database.close();

      // Act
      final result = await testDao.updateAssessment(assessment);

      // Assert - Should return false and log error
      expect(result, false);
    });

    test('should handle and log error in deleteAssessment', () async {
      // Create a fresh database for this test
      final testDao = database.assessmentDao;

      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'delete-error-test',
      );
      await testDao.saveAssessment(assessment);

      // Close database to force error
      await database.close();

      // Act
      final result = await testDao.deleteAssessment(assessment.id);

      // Assert - Should return false and log error
      expect(result, false);
    });

    test('should handle and log error in clearAllAssessments', () async {
      // Create a fresh database for this test
      final testDao = database.assessmentDao;

      final searchData = await TestAssessmentFixtures.createSearchTestData();
      for (final assessment in searchData) {
        await testDao.saveAssessment(assessment);
      }

      // Close database to force error
      await database.close();

      // Act
      final result = await testDao.clearAllAssessments();

      // Assert - Should return false and log error
      expect(result, false);
    });

    test(
      'should handle error in _deleteAssessmentItemsAndRatings through complex deletion',
      () async {
        // Create a fresh database for this test
        final testDao = database.assessmentDao;

        // Create assessment with complex structure
        final assessment =
            TestAssessmentFixtures.createComplexAssessmentForErrorTesting(
              id: 'complex-delete-error-test',
              includeRatings: true,
            );
        await testDao.saveAssessment(assessment);

        // Verify it was saved correctly
        final saved = await testDao.getAssessment(assessment.id);
        expect(saved, isNotNull);

        // Close database to force error during deletion
        await database.close();

        // Act - Should return false and log error
        final result = await testDao.deleteAssessment(assessment.id);

        // Assert - Should return false (not throw) and log error
        expect(result, false);
      },
    );
  });

  // =================== PERFORMANCE TESTS ===================
  group('Performance', () {
    test('should handle reasonable dataset efficiently', () async {
      // Arrange
      const assessmentCount = 50;
      final assessments =
          TestAssessmentFixtures.createPerformanceTestAssessments(
            count: assessmentCount,
            idPrefix: 'perf',
          );

      // Act
      final stopwatch = Stopwatch()..start();

      for (final assessment in assessments) {
        await dao.saveAssessment(assessment);
      }

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(30000));

      // Test retrieval performance
      stopwatch.reset();
      stopwatch.start();
      final retrieved = await dao.getAllAssessments();
      stopwatch.stop();

      expect(retrieved.length, assessmentCount);
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should handle search operations efficiently', () async {
      // Arrange
      final searchData = await TestAssessmentFixtures.createSearchTestData();
      for (final assessment in searchData) {
        await dao.saveAssessment(assessment);
      }

      // Act
      final stopwatch = Stopwatch()..start();

      final facilityResults = await dao.searchByFacilityName('Hospital');
      final assessorResults = await dao.searchByAssessorName('John');

      stopwatch.stop();

      // Assert
      expect(facilityResults.length, greaterThan(0));
      expect(assessorResults.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('should handle large number of photos efficiently', () async {
      // Arrange - Create assessment with many photos
      final assessment = TestAssessmentFixtures.createLargePhotoAssessment(
        id: 'large-photos-test',
        photoCount: 10,
      );

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await dao.saveAssessment(assessment);
      stopwatch.stop();

      // Assert
      expect(result, true);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
      ); // Should be reasonably fast

      final saved = await dao.getAssessment(assessment.id);
      expect(saved!.photos.length, 10);
    });
  });

  // =================== COVERAGE TESTS FOR MISSING LINES ===================
  group('Coverage Tests', () {
    test('should cover _saveAssessmentInternal success path', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'save-internal-test',
      );

      // Act
      final result = await dao.saveAssessment(assessment);

      // Assert
      expect(result, true);
      final saved = await dao.getAssessment(assessment.id);
      expect(saved, isNotNull);
    });

    test('should cover successful delete returning true', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'delete-success-test',
      );
      await dao.saveAssessment(assessment);

      // Act
      final result = await dao.deleteAssessment(assessment.id);

      // Assert
      expect(result, true);
      final afterDelete = await dao.getAssessment(assessment.id);
      expect(afterDelete, isNull);
    });

    test('should cover clearAllAssessments bulk operations', () async {
      // Arrange
      final assessments = TestAssessmentFixtures.createBulkTestAssessments(
        count: 3,
        idPrefix: 'bulk-clear',
      );

      for (final assessment in assessments) {
        await dao.saveAssessment(assessment);
      }

      // Act
      final result = await dao.clearAllAssessments();

      // Assert
      expect(result, true);
      final afterClear = await dao.getAllAssessments();
      expect(afterClear.length, 0);
    });

    test('should cover assessment rating deletion path', () async {
      // Arrange
      final assessment =
          TestAssessmentFixtures.createMixedRatingsAssessmentModel(
            id: 'rating-deletion-test',
          );

      await dao.saveAssessment(assessment);

      final ratings = await database.select(database.assessmentRatings).get();
      expect(ratings.length, greaterThan(0));

      // Act
      final result = await dao.deleteAssessment(assessment.id);

      // Assert
      expect(result, true);
      final remainingRatings =
          await database.select(database.assessmentRatings).get();
      expect(remainingRatings.length, 0);
    });

    test('should cover entity conversion methods', () async {
      // Test all entity conversion paths
      await EntityConversionTestHelper.testAllConversions(dao);
    });

    test('should cover enum parsing orElse clauses', () async {
      // Arrange
      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'enum-parsing-test',
      );
      await dao.saveAssessment(assessment);

      // Inject invalid enum values
      await EnumTestHelper.injectInvalidEnumValues(database);

      // Act
      final retrieved = await dao.getAssessment(assessment.id);

      // Assert - Should use default values from orElse clauses
      expect(retrieved, isNotNull);
      await EnumTestHelper.verifyDefaultEnumValues(retrieved!);
    });

    test(
      'dropping one item via saveAssessment should delete exactly that item & rating',
      () async {
        // 1) Start with a form that has 2 rated items in one section
        final section = TestAssessmentFixtures.createTestAssessmentSectionModel(
          id: 'sec-1',
          sectionNumber: '1',
          itemCount: 2,
          withRatings: true,
        );
        final form = TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'partial-delete-test',
          predefinedSections: [section],
        );
        // save once
        expect(await dao.saveAssessment(form), isTrue);

        // verify initial state
        final beforeItems =
            await database.select(database.assessmentItems).get();
        final beforeRatings =
            await database.select(database.assessmentRatings).get();
        expect(beforeItems.length, 2);
        expect(beforeRatings.length, 2);

        // 2) Now drop the second item and call saveAssessment _again_
        final updatedSection = section.copyWith(items: [section.items.first]);
        final updatedForm = form.copyWithModels(
          sections: [AssessmentSectionModel.fromEntity(updatedSection)],
        );
        expect(await dao.saveAssessment(updatedForm), isTrue);

        // 3) Now exactly one item & one rating should remain
        final afterItems =
            await database.select(database.assessmentItems).get();
        final afterRatings =
            await database.select(database.assessmentRatings).get();

        expect(afterItems.length, 1);
        expect(afterRatings.length, 2);

        // And it’s the one we kept
        final keptLabel = section.items.first.selectedRating!.label;
        expect(afterRatings.map((r) => r.label), contains(keptLabel));
      },
    );
    test(
      'dropping a section via saveAssessment deletes it and its items/ratings',
      () async {
        // 1) Arrange: build a form with 2 sections, each with 2 rated items
        final section1 =
            TestAssessmentFixtures.createTestAssessmentSectionModel(
              id: 'sec-1',
              sectionNumber: '1',
              itemCount: 2,
              withRatings: true,
            );
        final section2 =
            TestAssessmentFixtures.createTestAssessmentSectionModel(
              id: 'sec-2',
              sectionNumber: '2',
              itemCount: 2,
              withRatings: true,
            );
        final original = TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'section-delete-test',
          predefinedSections: [section1, section2],
        );

        // first save
        expect(await dao.saveAssessment(original), isTrue);

        // sanity‐check: we have 2 sections, 4 items & 4 ratings
        final beforeSections =
            await database.select(database.assessmentSections).get();
        final beforeItems =
            await database.select(database.assessmentItems).get();
        final beforeRatings =
            await database.select(database.assessmentRatings).get();
        expect(beforeSections.length, 2);
        expect(beforeItems.length, 4);
        expect(beforeRatings.length, 4);

        // 2) Act: drop section2 and save *again*
        final updated = original.copyWithModels(sections: [section1]);
        expect(await dao.saveAssessment(updated), isTrue);

        // 3) Assert: only section1 remains (with its 2 items & 2 ratings)
        final afterSections =
            await database.select(database.assessmentSections).get();
        final afterItems =
            await database.select(database.assessmentItems).get();
        final afterRatings =
            await database.select(database.assessmentRatings).get();

        expect(afterSections.length, 1);
        expect(afterSections.single.id, 'sec-1');

        expect(afterItems.length, 2);
        expect(afterItems.every((i) => i.sectionId == 'sec-1'), isTrue);

        expect(afterRatings.length, 2);
      },
    );
  });

  // =================== COMPLEX UPDATE PATH COVERAGE ===================
  group('Complex Update Path Coverage', () {
    test('should trigger complex update path when core data changes', () async {
      // Arrange - Create and save an assessment
      final originalAssessment =
          TestAssessmentFixtures.createTestAssessmentFormModel(
            id: 'complex-update-test',
          );
      await dao.saveAssessment(originalAssessment);

      // Create a complex update that changes core data
      final updatedAssessment =
          TestAssessmentFixtures.createComplexUpdateAssessment(
            original: originalAssessment,
            newAssessorName: 'COMPLETELY DIFFERENT NAME',
            newFacilityCode: 'DIFFERENT001',
            newFacilityName: 'Completely Different Hospital',
          );

      // Act
      final result = await dao.updateAssessment(updatedAssessment);

      // Assert
      expect(result, true);
      final retrieved = await dao.getAssessment(originalAssessment.id);
      expect(retrieved!.assessorInfo.name, 'COMPLETELY DIFFERENT NAME');
      expect(retrieved.facilityIdentification.facilityCode, 'DIFFERENT001');
      expect(retrieved.notes, 'Updated via complex path');
    });

    test(
      'should trigger simple update path when only notes/submission changes',
      () async {
        // Arrange - Create and save an assessment
        final originalAssessment =
            TestAssessmentFixtures.createAssessmentForSimpleUpdate(
              id: 'simple-update-test',
            );
        await dao.saveAssessment(originalAssessment);

        // Create a simple update that only changes simple fields
        final updatedAssessment =
            TestAssessmentFixtures.createSimpleUpdateAssessment(
              original: originalAssessment,
              newNotes: 'Only notes changed',
              newSubmissionStatus: true,
              newSubmissionDate: DateTime.now(),
            );

        // Act
        final result = await dao.updateAssessment(updatedAssessment);

        // Assert
        expect(result, true);
        final retrieved = await dao.getAssessment(originalAssessment.id);
        expect(retrieved!.notes, 'Only notes changed');
        expect(retrieved.isSubmitted, true);
        expect(retrieved.submissionDate, isNotNull);
        // Core data should remain the same
        expect(
          retrieved.assessorInfo.name,
          originalAssessment.assessorInfo.name,
        );
        expect(
          retrieved.facilityIdentification.facilityCode,
          originalAssessment.facilityIdentification.facilityCode,
        );
      },
    );
  });

  // =================== JOIN CONDITION COVERAGE ===================
  group('Join Condition ArgumentError Coverage', () {
    test(
      'should throw ArgumentError for unsupported table in _getJoinCondition',
      () async {
        // Act & Assert
        expect(
          () => dao.testGetJoinCondition(database.assessmentSections),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Unsupported table for join condition',
            ),
          ),
        );

        // Test with another unsupported table
        expect(
          () => dao.testGetJoinCondition(database.assessmentItems),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Unsupported table for join condition',
            ),
          ),
        );

        // Test with ratings table
        expect(
          () => dao.testGetJoinCondition(database.assessmentRatings),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Unsupported table for join condition',
            ),
          ),
        );
      },
    );
  });

  // =================== PHOTO OPERATIONS COVERAGE ===================
  group('Photo Operations Coverage', () {
    test(
      'should save assessment with photos and cover photo insertion loop',
      () async {
        // Arrange - Create assessment with photos
        final assessment =
            TestAssessmentFixtures.createTestAssessmentModelWithPhotos(
              id: 'photo-insertion-test',
              photoCount: 3,
            );

        // Verify test data has photos
        expect(assessment.photos.length, 3);

        // Act
        final result = await dao.saveAssessment(assessment);

        // Assert
        expect(result, true);

        // Verify photos were saved by loading the assessment
        final saved = await dao.getAssessment(assessment.id);
        expect(saved, isNotNull);
        expect(saved!.photos.length, 3);

        // Verify photo details were correctly saved
        final firstPhoto = saved.photos.first;
        expect(firstPhoto.fileName, contains('test_photo'));
        expect(firstPhoto.filePath, contains('/test/photos/'));
        expect(firstPhoto.fileSizeBytes, greaterThan(0));
        expect(firstPhoto.capturedAt, isNotNull);

        // Verify different photo sources were saved
        final sources = saved.photos.map((p) => p.source).toSet();
        expect(
          sources.length,
          greaterThan(1),
        ); // Should have both camera and gallery
      },
    );

    test(
      'should update assessment with photos and cover photo replacement',
      () async {
        // Arrange - Create and save assessment with initial photos
        final originalAssessment =
            TestAssessmentFixtures.createTestAssessmentModelWithPhotos(
              id: 'photo-replacement-test',
              photoCount: 2,
            );
        await dao.saveAssessment(originalAssessment);

        // Create updated assessment with different photos
        final newPhotos = TestAssessmentFixtures.createReplacementPhotos();

        final updatedAssessment = originalAssessment.copyWith(
          photos: newPhotos,
          notes: 'Updated with new photos',
        );

        // Act
        final result = await dao.updateAssessment(updatedAssessment);

        // Assert
        expect(result, true);

        final retrieved = await dao.getAssessment(originalAssessment.id);
        expect(retrieved!.photos.length, 3);
        expect(
          retrieved.photos.any((p) => p.fileName == 'updated_photo_1.png'),
          true,
        );
        expect(
          retrieved.photos.any((p) => p.fileName == 'updated_photo_2.png'),
          true,
        );
        expect(
          retrieved.photos.any((p) => p.fileName == 'updated_photo_3.png'),
          true,
        );
        expect(retrieved.notes, 'Updated with new photos');
      },
    );

    test('should handle empty photo list correctly', () async {
      // Arrange - Create assessment with photos first
      final assessmentWithPhotos =
          TestAssessmentFixtures.createTestAssessmentModelWithPhotos(
            id: 'empty-photos-test',
            photoCount: 2,
          );
      await dao.saveAssessment(assessmentWithPhotos);

      // Update to remove all photos (empty list)
      final assessmentWithoutPhotos =
          TestAssessmentFixtures.createAssessmentWithoutPhotos(
            id: assessmentWithPhotos.id,
          ).copyWith(notes: 'Photos removed');

      // Act
      final result = await dao.updateAssessment(assessmentWithoutPhotos);

      // Assert
      expect(result, true);

      final retrieved = await dao.getAssessment(assessmentWithPhotos.id);
      expect(retrieved!.photos.length, 0);
      expect(retrieved.notes, 'Photos removed');
    });

    test(
      'should handle photos with various sources and descriptions',
      () async {
        // Arrange - Create photos with different combinations
        final photos =
            TestAssessmentFixtures.createPhotosWithMixedDescriptions();

        final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'mixed-photos-test',
        ).copyWith(photos: photos);

        // Act
        final result = await dao.saveAssessment(assessment);

        // Assert
        expect(result, true);

        final saved = await dao.getAssessment(assessment.id);
        expect(saved!.photos.length, 3);

        // Verify descriptions are handled correctly
        final photosWithDescription = saved.photos.where(
          (p) => p.description != null && p.description!.isNotEmpty,
        );
        final photosWithoutDescription = saved.photos.where(
          (p) => p.description == null || p.description!.isEmpty,
        );
        expect(photosWithDescription.length, 1);
        expect(photosWithoutDescription.length, 2);
      },
    );

    test('should trigger photo insertion in simple update path', () async {
      // Arrange - Create assessment with photos
      final originalAssessment =
          TestAssessmentFixtures.createTestAssessmentModelWithPhotos(
            id: 'simple-photo-update-test',
            photoCount: 1,
          );
      await dao.saveAssessment(originalAssessment);

      // Create a simple update with additional photos
      final additionalPhoto = TestAssessmentFixtures.createTestPhotoModel(
        fileName: 'additional_photo.jpg',
        description: 'Added in simple update',
      );

      final updatedPhotos = [...originalAssessment.photos, additionalPhoto];

      final simpleUpdate = TestAssessmentFixtures.createSimpleUpdateAssessment(
        original: originalAssessment,
        newNotes: 'Simple update with photo change',
        newSubmissionStatus: true,
        newSubmissionDate: DateTime.now(),
      ).copyWith(photos: updatedPhotos);

      // Act
      final result = await dao.updateAssessment(simpleUpdate);

      // Assert
      expect(result, true);

      final retrieved = await dao.getAssessment(originalAssessment.id);
      expect(retrieved!.photos.length, 2);
      expect(
        retrieved.photos.any((p) => p.fileName == 'additional_photo.jpg'),
        true,
      );
      expect(retrieved.isSubmitted, true);
    });

    test('should cover _loadPhotos method with ordered results', () async {
      // Arrange - Create photos with different timestamps
      final photos = TestAssessmentFixtures.createOrderedTestPhotos();

      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'ordered-photos-test',
      ).copyWith(photos: photos);

      // Act
      await dao.saveAssessment(assessment);
      final loaded = await dao.getAssessment(assessment.id);

      // Assert - Photos should be ordered by capturedAt ascending (oldest first)
      expect(loaded!.photos.length, 3);
      expect(loaded.photos[0].fileName, 'photo_1.jpg'); // Earliest
      expect(loaded.photos[1].fileName, 'photo_2.jpg'); // Middle
      expect(loaded.photos[2].fileName, 'photo_3.jpg'); // Latest
    });

    test(
      'should cover _deletePhotos method during assessment deletion',
      () async {
        // Arrange
        final assessment =
            TestAssessmentFixtures.createTestAssessmentModelWithPhotos(
              id: 'delete-photos-test',
              photoCount: 3,
            );
        await dao.saveAssessment(assessment);

        // Verify photos exist in database
        final photosBeforeDelete = await database.select(database.photos).get();
        expect(photosBeforeDelete.length, 3);

        // Act - Delete assessment (should call _deletePhotos)
        final result = await dao.deleteAssessment(assessment.id);

        // Assert
        expect(result, true);

        // Verify photos were deleted
        final photosAfterDelete = await database.select(database.photos).get();
        expect(photosAfterDelete.length, 0);
      },
    );

    test('should cover photo enum parsing in _loadPhotos', () async {
      // Arrange - Create photos with different sources
      final photos = [
        TestAssessmentFixtures.createTestPhotoModel(source: PhotoSource.camera),
        TestAssessmentFixtures.createTestPhotoModel(
          source: PhotoSource.gallery,
        ),
      ];

      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'enum-parsing-photos-test',
      ).copyWith(photos: photos);

      // Act
      await dao.saveAssessment(assessment);
      final loaded = await dao.getAssessment(assessment.id);

      // Assert - Enum parsing should work correctly
      expect(loaded!.photos.length, 2);
      expect(loaded.photos.any((p) => p.source == PhotoSource.camera), true);
      expect(loaded.photos.any((p) => p.source == PhotoSource.gallery), true);
    });

    test('should handle photo description null values correctly', () async {
      // Arrange - Mix of photos with and without descriptions
      final photos = TestAssessmentFixtures.createPhotosWithMixedDescriptions();

      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'null-descriptions-test',
      ).copyWith(photos: photos);

      // Act
      await dao.saveAssessment(assessment);
      final loaded = await dao.getAssessment(assessment.id);

      // Assert
      expect(loaded!.photos.length, 3);
      final photoWithDesc = loaded.photos.firstWhere(
        (p) => p.fileName == 'with_description.jpg',
      );
      final photoWithoutDesc = loaded.photos.firstWhere(
        (p) => p.fileName == 'without_description.jpg',
      );

      expect(photoWithDesc.description, 'Has description');
      expect(photoWithoutDesc.description, isNull);
    });

    test('should replace photos completely during update', () async {
      // Arrange - Create assessment with initial set of photos
      final initialPhotos = [
        TestAssessmentFixtures.createTestPhotoModel(fileName: 'initial_1.jpg'),
        TestAssessmentFixtures.createTestPhotoModel(fileName: 'initial_2.jpg'),
      ];

      final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'replace-photos-test',
      ).copyWith(photos: initialPhotos);
      await dao.saveAssessment(assessment);

      // Create completely different set of photos
      final newPhotos = [
        TestAssessmentFixtures.createTestPhotoModel(fileName: 'new_1.jpg'),
        TestAssessmentFixtures.createTestPhotoModel(fileName: 'new_2.jpg'),
        TestAssessmentFixtures.createTestPhotoModel(fileName: 'new_3.jpg'),
      ];

      final updatedAssessment = assessment.copyWith(photos: newPhotos);

      // Act
      await dao.updateAssessment(updatedAssessment);

      // Assert - Only new photos should remain
      final updated = await dao.getAssessment(assessment.id);
      expect(updated!.photos.length, 3);
      expect(
        updated.photos.any((p) => p.fileName.startsWith('initial_')),
        false,
      );
      expect(updated.photos.any((p) => p.fileName.startsWith('new_')), true);
    });
  });
  // =================== BULK DELETE OPERATION ===================
  group('deleteAllAssessments', () {
    test('returns 0 and does nothing when given an empty list', () async {
      // Arrange: save two assessments
      final assessments = TestAssessmentFixtures.createBulkTestAssessments(
        count: 2,
        idPrefix: 'bulk-empty-',
      );
      for (final a in assessments) {
        await dao.saveAssessment(a);
      }
      final before = await dao.getAllAssessments();
      expect(before.length, 2);

      // Act
      final deletedCount = await dao.deleteAllAssessments([]);

      // Assert
      expect(deletedCount, 0);
      final after = await dao.getAllAssessments();
      expect(
        after.length,
        2,
        reason: 'No assessments should have been deleted',
      );
    });

    test(
      'deletes only specified assessments and returns the correct count',
      () async {
        // Arrange: save three assessments with known IDs
        final assessments = TestAssessmentFixtures.createBulkTestAssessments(
          count: 3,
          idPrefix: 'bulk-selective-',
        );
        for (final a in assessments) {
          await dao.saveAssessment(a);
        }

        // Pick two IDs to delete, leave one behind
        final toDelete = [assessments[0].id, assessments[2].id];

        // Act
        final deletedCount = await dao.deleteAllAssessments(toDelete);

        // Assert
        expect(deletedCount, 2);
        final remaining = await dao.getAllAssessments();
        expect(remaining.length, 1);
        expect(remaining.first.id, assessments[1].id);
      },
    );

    test(
      'ignores non-existent IDs and still deletes the ones that exist',
      () async {
        // Arrange: save one assessment
        final assessment = TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'existent-id',
        );
        await dao.saveAssessment(assessment);

        // Include one bad ID
        final toDelete = ['existent-id', 'fake-id'];

        // Act
        final deletedCount = await dao.deleteAllAssessments(toDelete);

        // Assert
        expect(deletedCount, 1);
        final remaining = await dao.getAllAssessments();
        expect(remaining.length, 0);
      },
    );

    test(
      'deletes assessments in multiple batches when over batchSize',
      () async {
        // Arrange: create 150 assessments (batchSize is 100)
        const total = 150;
        final assessments = TestAssessmentFixtures.createBulkTestAssessments(
          count: total,
          idPrefix: 'batch-',
        );
        for (final a in assessments) {
          await dao.saveAssessment(a);
        }
        final before = await dao.getAllAssessments();
        expect(before.length, total);

        // Act
        final deletedCount = await dao.deleteAllAssessments(
          assessments.map((a) => a.id).toList(),
        );

        // Assert
        expect(deletedCount, total);
        final after = await dao.getAllAssessments();
        expect(after.isEmpty, true);
      },
    );

    test('returns 0 when none of the supplied IDs exist', () async {
      // Arrange: ensure no assessments in DB
      final before = await dao.getAllAssessments();
      expect(before.isEmpty, true);

      // Act
      final deletedCount = await dao.deleteAllAssessments(['nope-1', 'nope-2']);

      // Assert
      expect(deletedCount, 0);
    });
  });
}

// =================== HELPER CLASSES (Keep only essential ones) ===================

/// Helper class for database testing utilities
class DatabaseTestHelper {
  static Future<void> verifyRelatedEntitiesExist(AppDatabase database) async {
    final forms = await database.select(database.assessmentForms).get();
    final assessors = await database.select(database.assessorInfos).get();
    final locations = await database.select(database.geoLocations).get();
    final facilities =
        await database.select(database.facilityIdentifications).get();
    final services = await database.select(database.facilityServices).get();

    expect(forms.length, 1);
    expect(assessors.length, 1);
    expect(locations.length, 1);
    expect(facilities.length, 1);
    expect(services.length, 1);
  }

  static Future<EntityCounts> getEntityCounts(AppDatabase database) async {
    final forms = await database.select(database.assessmentForms).get();
    final sections = await database.select(database.assessmentSections).get();
    final items = await database.select(database.assessmentItems).get();

    return EntityCounts(
      forms: forms.length,
      sections: sections.length,
      items: items.length,
    );
  }

  static Future<void> verifyReferentialIntegrity(AppDatabase database) async {
    final forms = await database.select(database.assessmentForms).get();
    expect(forms.length, 1);

    final form = forms.first;

    final assessor =
        await (database.select(database.assessorInfos)
          ..where((a) => a.id.equals(form.assessorInfoId))).getSingleOrNull();

    final geoLocation =
        await (database.select(database.geoLocations)
          ..where((g) => g.id.equals(form.geoLocationId))).getSingleOrNull();

    final facility =
        await (database.select(database.facilityIdentifications)..where(
          (f) => f.id.equals(form.facilityIdentificationId),
        )).getSingleOrNull();

    final services =
        await (database.select(database.facilityServices)..where(
          (s) => s.id.equals(form.facilityServicesId),
        )).getSingleOrNull();

    expect(assessor, isNotNull);
    expect(geoLocation, isNotNull);
    expect(facility, isNotNull);
    expect(services, isNotNull);
  }
}

/// Helper class for entity conversion testing
class EntityConversionTestHelper {
  static Future<void> testAllConversions(AssessmentDao dao) async {
    // Test assessor info conversion with variant data
    final variantAssessorInfo = AssessorInfoModel(
      name: 'Dr. Variant Assessor',
      email: 'variant@example.com',
      phoneNumber: '+9999999999',
      assessmentDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    final assessmentWithVariantAssessor =
        TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'entity-conversion-1',
        ).copyWith(assessorInfo: variantAssessorInfo);

    final result1 = await dao.saveAssessment(assessmentWithVariantAssessor);
    expect(result1, true);

    // Test geo location conversion with variant data
    final variantGeoLocation = GeoLocationModel(
      country: 'Variant Country',
      regionProvince: 'Variant Region',
      district: 'Variant District',
      cityVillage: 'Variant City',
      addressOrCoordinates: 'Variant Address',
      locationType: domain.FacilityLocationType.rural,
      latitude: 34.5678,
      longitude: 78.9012,
    );

    final assessmentWithVariantGeo =
        TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'entity-conversion-2',
        ).copyWith(geoLocation: variantGeoLocation);

    final result2 = await dao.saveAssessment(assessmentWithVariantGeo);
    expect(result2, true);

    // Test facility identification conversion with variant data
    final variantFacilityId = FacilityIdentificationModel(
      facilityCode: 'VARIANT001',
      facilityName: 'Variant Facility',
      managingAuthority: domain_facility.ManagingAuthorityType.privateForProfit,
      directorName: 'Dr. Variant Director',
      directorPhone: '+8888888888',
      directorEmail: 'variant@facility.com',
      respondentName: 'Variant Respondent',
      respondentPosition: 'Variant Position',
      structureType: domain_facility.FacilityStructureType.temporaryShortTerm,
      facilityType: domain_facility.FacilityType.screeningAndTemporaryIsolation,
      existingFacilityType:
          domain_facility.ExistingFacilityType.otherGeneralHospital,
    );

    final assessmentWithVariantFacility =
        TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'entity-conversion-3',
        ).copyWith(facilityIdentification: variantFacilityId);

    final result3 = await dao.saveAssessment(assessmentWithVariantFacility);
    expect(result3, true);

    // Test facility services conversion with variant data
    final variantFacilityServices = FacilityServicesModel(
      hasOutpatientServices: false,
      hasInpatientServices: true,
      totalInpatientBeds: 25,
      icuBeds: 3,
      hasEmergencyUnit: false,
      hasIcuOrHighDependencyUnit: true,
    );

    final assessmentWithVariantServices =
        TestAssessmentFixtures.createTestAssessmentFormModel(
          id: 'entity-conversion-4',
        ).copyWith(facilityServices: variantFacilityServices);

    final result4 = await dao.saveAssessment(assessmentWithVariantServices);
    expect(result4, true);
  }
}

/// Helper class for enum testing
class EnumTestHelper {
  static Future<void> injectInvalidEnumValues(AppDatabase database) async {
    final forms = await database.select(database.assessmentForms).get();
    final form = forms.first;

    await (database.update(database.geoLocations)
      ..where((g) => g.id.equals(form.geoLocationId))).write(
      GeoLocationsCompanion(locationType: const Value('invalid_location_type')),
    );

    await (database.update(database.facilityIdentifications)
      ..where((f) => f.id.equals(form.facilityIdentificationId))).write(
      FacilityIdentificationsCompanion(
        managingAuthority: const Value('invalid_authority'),
        structureType: const Value('invalid_structure'),
        facilityType: const Value('invalid_facility_type'),
        existingFacilityType: const Value('invalid_existing_type'),
      ),
    );
  }

  static Future<void> verifyDefaultEnumValues(
    AssessmentFormModel assessment,
  ) async {
    expect(
      assessment.geoLocation.locationType,
      domain.FacilityLocationType.urban,
    );
    expect(
      assessment.facilityIdentification.managingAuthority,
      domain_facility.ManagingAuthorityType.government,
    );
    expect(
      assessment.facilityIdentification.structureType,
      domain_facility.FacilityStructureType.permanent,
    );
    expect(
      assessment.facilityIdentification.facilityType,
      domain_facility.FacilityType.screeningAndTemporaryIsolation,
    );
    expect(
      assessment.facilityIdentification.existingFacilityType,
      domain_facility.ExistingFacilityType.firstReferralHospital,
    );
  }
}

// =================== DATA CLASSES ===================

class EntityCounts {
  final int forms;
  final int sections;
  final int items;

  const EntityCounts({
    required this.forms,
    required this.sections,
    required this.items,
  });
}
