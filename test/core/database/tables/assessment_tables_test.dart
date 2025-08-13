import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:treatment_center/core/database/app_database.dart';

void main() {
  group('Table Definition Validation Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
    });

    tearDown(() => database.close());

    // These tests validate that your table definitions work correctly
    // This is the ONLY way to test table definitions meaningfully

    test('AssessmentForms table schema is correct', () async {
      // This validates your table definition actually works
      final tableInfo =
          await database
              .customSelect('PRAGMA table_info(assessment_forms)')
              .get();

      final columnNames =
          tableInfo.map((row) => row.data['name'] as String).toSet();

      // Validates all your column definitions
      expect(columnNames, contains('id'));
      expect(columnNames, contains('assessor_info_id'));
      expect(columnNames, contains('geo_location_id'));
      expect(columnNames, contains('facility_identification_id'));
      expect(columnNames, contains('facility_services_id'));
      expect(columnNames, contains('notes'));
      expect(columnNames, contains('is_submitted'));
      expect(columnNames, contains('submission_date'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('All table primary keys are correctly defined', () async {
      final tables = [
        'assessment_forms',
        'assessor_infos',
        'geo_locations',
        'facility_identifications',
        'facility_services',
        'assessment_sections',
        'assessment_items',
        'assessment_ratings',
      ];

      for (final tableName in tables) {
        final tableInfo =
            await database.customSelect('PRAGMA table_info($tableName)').get();

        final primaryKeyColumns =
            tableInfo
                .where((row) => row.data['pk'] == 1)
                .map((row) => row.data['name'] as String)
                .toList();

        // Validates your primaryKey override works
        expect(
          primaryKeyColumns,
          equals(['id']),
          reason: 'Table $tableName should have id as primary key',
        );
      }
    });

    test('Foreign key relationships are correctly defined', () async {
      final formsFKs =
          await database
              .customSelect('PRAGMA foreign_key_list(assessment_forms)')
              .get();

      final referencedTables =
          formsFKs.map((row) => row.data['table'] as String).toSet();

      // Validates your .references() calls work
      expect(referencedTables, contains('assessor_infos'));
      expect(referencedTables, contains('geo_locations'));
      expect(referencedTables, contains('facility_identifications'));
      expect(referencedTables, contains('facility_services'));
    });

    test('Nullable columns are correctly defined', () async {
      final tableInfo =
          await database
              .customSelect('PRAGMA table_info(assessment_forms)')
              .get();

      // Find the notes column
      final notesColumn = tableInfo.firstWhere(
        (row) => row.data['name'] == 'notes',
      );

      // Validates your .nullable() call works
      expect(
        notesColumn.data['notnull'],
        equals(0),
        reason: 'notes column should be nullable',
      );

      // Find submission_date column
      final submissionDateColumn = tableInfo.firstWhere(
        (row) => row.data['name'] == 'submission_date',
      );

      // Validates your .nullable() call works
      expect(
        submissionDateColumn.data['notnull'],
        equals(0),
        reason: 'submission_date column should be nullable',
      );
    });

    test('Default values are correctly applied', () async {
      final tableInfo =
          await database
              .customSelect('PRAGMA table_info(assessment_forms)')
              .get();

      // Find the is_submitted column
      final isSubmittedColumn = tableInfo.firstWhere(
        (row) => row.data['name'] == 'is_submitted',
      );

      // Validates your .withDefault() call works
      expect(
        isSubmittedColumn.data['dflt_value'],
        equals('0'),
        reason: 'is_submitted should default to false (0)',
      );
    });

    test('Data classes are generated correctly', () {
      // This validates your @DataClassName annotations work
      expect(AssessmentFormData, isNotNull);
      expect(AssessorInfoData, isNotNull);
      expect(GeoLocationData, isNotNull);
      expect(FacilityIdentificationData, isNotNull);
      expect(FacilityServicesData, isNotNull);
      expect(AssessmentSectionData, isNotNull);
      expect(AssessmentItemData, isNotNull);
      expect(AssessmentRatingData, isNotNull);
    });

    test('Companion classes are generated correctly', () {
      // This validates Drift generated companions from your table definitions
      expect(AssessmentFormsCompanion, isNotNull);
      expect(AssessorInfosCompanion, isNotNull);
      expect(GeoLocationsCompanion, isNotNull);
      expect(FacilityIdentificationsCompanion, isNotNull);
      expect(FacilityServicesCompanion, isNotNull);
      expect(AssessmentSectionsCompanion, isNotNull);
      expect(AssessmentItemsCompanion, isNotNull);
      expect(AssessmentRatingsCompanion, isNotNull);
    });

    test('Column types are correctly interpreted', () async {
      // Create and insert data to validate column types work

      await database
          .into(database.facilityServices)
          .insert(
            FacilityServicesCompanion.insert(
              id: 'test-services',
              hasOutpatientServices: true, // Boolean
              hasInpatientServices: false, // Boolean
              totalInpatientBeds: 150, // Integer
              icuBeds: 20, // Integer
              hasEmergencyUnit: true, // Boolean
              hasIcuOrHighDependencyUnit: false, // Boolean
            ),
          );

      final services =
          await (database.select(database.facilityServices)
            ..where((s) => s.id.equals('test-services'))).getSingle();

      // Validates your column type declarations work
      expect(services.id, isA<String>());
      expect(services.hasOutpatientServices, isA<bool>());
      expect(services.hasInpatientServices, isA<bool>());
      expect(services.totalInpatientBeds, isA<int>());
      expect(services.icuBeds, isA<int>());
    });
  });
}
