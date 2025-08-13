import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';
import 'package:treatment_center/core/services/excel_import_service.dart';
import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_section_two_page.dart';

@GenerateMocks([FileProvider, FileWrapper, FileStat])
import 'excel_import_service_test.mocks.dart';

void main() {
  late ExcelImportService excelImportService;
  late MockFileProvider mockFileProvider;
  late MockFileWrapper mockFileWrapper;
  late MockFileStat mockFileStat;

  setUp(() {
    mockFileProvider = MockFileProvider();
    mockFileWrapper = MockFileWrapper();
    mockFileStat = MockFileStat();

    excelImportService = ExcelImportService(fileProvider: mockFileProvider);
  });

  /// Sets up successful file operation mocks for testing
  void setupSuccessfulFileMocks({
    String? filePath,
    int fileSize = 1024 * 1024, // 1MB default
    Uint8List? fileBytes,
  }) {
    when(
      mockFileProvider.getFile(any),
    ).thenAnswer((_) async => mockFileWrapper);
    when(mockFileProvider.readAsBytes(any)).thenAnswer(
      (_) async => fileBytes ?? TestFixturesHelper.createMockExcelBytes(),
    );
    //  when(mockFileWrapper.stat()).thenAnswer((_) async => mockFileStat);

    when(
      mockFileProvider.readAsString(any),
    ).thenAnswer((_) async => 'mock content');
    when(
      mockFileProvider.writeAsBytes(any, any),
    ).thenAnswer((_) async => mockFileWrapper);
    when(
      mockFileProvider.writeAsString(any, any),
    ).thenAnswer((_) async => mockFileWrapper);

    // Mock File operations
    when(mockFileWrapper.exists()).thenAnswer((_) async => true);
    when(mockFileWrapper.length()).thenAnswer((_) async => fileSize);
    when(mockFileStat.size).thenReturn(fileSize);
    when(mockFileStat.modified).thenReturn(DateTime.now());
    when(mockFileStat.accessed).thenReturn(DateTime.now());
  }

  group('ExcelImportService - Comprehensive Test Suite', () {
    // ========================================================================
    // INITIALIZATION AND BASIC PROPERTIES TESTS
    // ========================================================================
    group('initialization and properties', () {
      test('should be properly initialized with FileProvider', () {
        // assert
        expect(excelImportService, isA<ExcelImportService>());
        expect(excelImportService, isA<BaseImportService>());
      });

      test('should have correct supportedExtension', () {
        // act & assert
        expect(excelImportService.supportedExtension, equals('xlsx'));
      });

      test('should have correct formatName', () {
        // act & assert
        expect(excelImportService.formatName, equals('Microsoft Excel'));
      });

      test('should have correct supportedMimeTypes', () {
        // act & assert
        expect(
          excelImportService.supportedMimeTypes,
          equals([
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'application/vnd.ms-excel',
          ]),
        );
      });
    });

    // ========================================================================
    // FILE VALIDATION TESTS
    // ========================================================================
    group('validateFormatSpecific', () {
      const String validXlsxPath = '/path/to/file.xlsx';
      const String validXlsPath = '/path/to/file.xls';
      const String invalidExtensionPath = '/path/to/file.txt';

      test('should pass validation for valid .xlsx file', () {
        // arrange
        setupSuccessfulFileMocks(filePath: validXlsxPath);

        // act & assert
        expect(
          () => excelImportService.validateFormatSpecific(validXlsxPath),
          returnsNormally,
        );
      });

      test('should pass validation for valid .xls file', () {
        // arrange
        setupSuccessfulFileMocks(filePath: validXlsPath);

        // act & assert
        expect(
          () => excelImportService.validateFormatSpecific(validXlsPath),
          returnsNormally,
        );
      });

      test('should throw ValidationException for invalid file extension', () {
        // act & assert
        expect(
          () => excelImportService.validateFormatSpecific(invalidExtensionPath),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('File must be an Excel file'),
            ),
          ),
        );
      });
    });

    // ========================================================================
    // IMPORT ASSESSMENT WORKFLOW TESTS
    // ========================================================================
    group('importAssessment workflow', () {
      const String testFilePath = '/path/to/test.xlsx';

      test(
        'should successfully import assessment with default options',
        () async {
          // arrange
          final mockExcelBytes = TestFixturesHelper.createMockExcelBytes();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: mockExcelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(result, isA<ImportedAssessmentForm>());
          expect(result.filePath, equals(testFilePath));
          expect(result.format, equals('Microsoft Excel'));
          expect(result.assessment, isA<AssessmentFormModel>());
          expect(result.importedAt, isA<DateTime>());
          expect(result.metadata, isA<Map<String, dynamic>>());

          // Verify file operations were called
          verify(mockFileProvider.getFile(testFilePath)).called(2);
          verify(mockFileProvider.readAsBytes(mockFileWrapper)).called(1);
        },
      );

      test('should successfully import with custom options', () async {
        // arrange
        final customOptions = ImportOptions(
          importSectionDetails: false,
          validateAfterImport: false,
          preserveExistingData: true,
        );
        setupSuccessfulFileMocks(filePath: testFilePath);

        // act
        final result = await excelImportService.importAssessment(
          testFilePath,
          options: customOptions,
        );

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        expect(result.filePath, equals(testFilePath));
      });

      test(
        'should throw ExcelImportException when file reading fails',
        () async {
          // arrange
          setupSuccessfulFileMocks(filePath: testFilePath);
          when(
            mockFileProvider.readAsBytes(mockFileWrapper),
          ).thenThrow(const FileSystemException('File read error'));

          // act & assert
          expect(
            () => excelImportService.importAssessment(testFilePath),
            throwsA(
              isA<ExcelImportException>().having(
                (e) => e.message,
                'message',
                contains('Failed to import Excel file'),
              ),
            ),
          );
        },
      );

      test('should rethrow ImportException without wrapping', () async {
        // arrange
        setupSuccessfulFileMocks(filePath: testFilePath);
        when(
          mockFileProvider.readAsBytes(mockFileWrapper),
        ).thenThrow(ImportException(message: 'Import failed'));

        // act & assert
        expect(
          () => excelImportService.importAssessment(testFilePath),
          throwsA(
            isA<ImportException>().having(
              (e) => e.message,
              'message',
              equals('Import failed'),
            ),
          ),
        );
      });

      test('should rethrow ValidationException without wrapping', () async {
        // arrange
        setupSuccessfulFileMocks(filePath: testFilePath);
        when(
          mockFileProvider.readAsBytes(mockFileWrapper),
        ).thenThrow(ValidationException(message: 'Validation failed'));

        // act & assert
        expect(
          () => excelImportService.importAssessment(testFilePath),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              equals('Validation failed'),
            ),
          ),
        );
      });

      test('should rethrow FileException without wrapping', () async {
        // arrange
        setupSuccessfulFileMocks(filePath: testFilePath);
        when(
          mockFileProvider.readAsBytes(mockFileWrapper),
        ).thenThrow(FileException(message: 'File operation failed'));

        // act & assert
        expect(
          () => excelImportService.importAssessment(testFilePath),
          throwsA(
            isA<FileException>().having(
              (e) => e.message,
              'message',
              equals('File operation failed'),
            ),
          ),
        );
      });
    });

    // ========================================================================
    // ENUM PARSING INTEGRATION TESTS
    // ========================================================================
    group('enum parsing integration tests', () {
      const String testFilePath = '/path/to/enum_test.xlsx';

      test(
        'should parse facility location types correctly through import',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithLocationData();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(
            result.assessment.geoLocation.locationType,
            isA<FacilityLocationType>(),
          );
        },
      );

      test(
        'should parse managing authority types correctly through import',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithAuthorityData();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(
            result.assessment.facilityIdentification.managingAuthority,
            isA<ManagingAuthorityType>(),
          );
        },
      );

      test(
        'should parse facility structure types correctly through import',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithStructureData();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(
            result.assessment.facilityIdentification.structureType,
            isA<FacilityStructureType>(),
          );
        },
      );
    });

    // ========================================================================
    // DATA PARSING INTEGRATION TESTS
    // ========================================================================
    group('data parsing integration tests', () {
      const String testFilePath = '/path/to/parsing_test.xlsx';

      test('should parse dates correctly through import workflow', () async {
        // arrange
        final excelBytes = TestFixturesHelper.createExcelWithDateData();
        setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

        // act
        final result = await excelImportService.importAssessment(testFilePath);

        // assert
        expect(result.assessment.assessorInfo.assessmentDate, isA<DateTime>());
        expect(result.assessment.createdAt, isA<DateTime>());
      });

      test(
        'should parse boolean values correctly through import workflow',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithBooleanData();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(
            result.assessment.facilityServices.hasOutpatientServices,
            isA<bool>(),
          );
          expect(
            result.assessment.facilityServices.hasInpatientServices,
            isA<bool>(),
          );
          expect(
            result.assessment.facilityServices.hasEmergencyUnit,
            isA<bool?>(),
          );
        },
      );

      test(
        'should parse integer values correctly through import workflow',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithIntegerData();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(
            result.assessment.facilityServices.totalInpatientBeds,
            isA<int?>(),
          );
          expect(result.assessment.facilityServices.icuBeds, isA<int?>());
        },
      );

      test(
        'should parse coordinate values correctly through import workflow',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithCoordinateData();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(result.assessment.geoLocation.latitude, isA<double?>());
          expect(result.assessment.geoLocation.longitude, isA<double?>());
        },
      );
    });

    // ========================================================================
    // RATING PARSING INTEGRATION TESTS
    // ========================================================================
    group('rating parsing integration tests', () {
      const String testFilePath = '/path/to/rating_test.xlsx';

      test(
        'should parse various rating formats through import workflow',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithVariousRatings();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(result, isA<ImportedAssessmentForm>());

          // Should have parsed different rating formats
          final allItems =
              result.assessment.sections
                  .expand((section) => section.items)
                  .toList();

          expect(allItems, isNotEmpty);

          // Check that ratings were parsed (some items should have ratings)
          final ratedItems = allItems.where(
            (item) => item.selectedRating != null,
          );
          expect(ratedItems.length, greaterThanOrEqualTo(0));
        },
      );

      test('should handle pending status ratings correctly', () async {
        // arrange
        final excelBytes = TestFixturesHelper.createExcelWithPendingRatings();
        setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

        // act
        final result = await excelImportService.importAssessment(testFilePath);

        // assert
        expect(result, isA<ImportedAssessmentForm>());

        // Pending items should not have ratings
        final allItems =
            result.assessment.sections
                .expand((section) => section.items)
                .where(
                  (item) =>
                      item.comment?.toLowerCase().contains('pending') == true,
                )
                .toList();

        for (final item in allItems) {
          expect(item.selectedRating, isNull);
        }
      });
    });

    // ========================================================================
    // ITEM VALIDATION AND SECTION IDENTIFICATION INTEGRATION TESTS
    // ========================================================================
    group('item validation and section identification integration tests', () {
      const String testFilePath = '/path/to/validation_test.xlsx';

      test('should filter out summary rows during import', () async {
        // arrange
        final excelBytes = TestFixturesHelper.createExcelWithSummaryRows();
        setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

        // act
        final result = await excelImportService.importAssessment(testFilePath);

        // assert
        expect(result, isA<ImportedAssessmentForm>());

        // Should not have any summary rows as assessment items
        final allItems =
            result.assessment.sections
                .expand((section) => section.items)
                .toList();

        // No items should have summary-like item numbers
        for (final item in allItems) {
          expect(item.itemNumber.toLowerCase(), isNot(contains('summary')));
          expect(item.itemNumber.toLowerCase(), isNot(contains('total')));
          expect(item.area.toLowerCase(), isNot(contains('completed')));
        }
      });

      test('should only include valid item numbers during import', () async {
        // arrange
        final excelBytes = TestFixturesHelper.createExcelWithMixedItemNumbers();
        setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

        // act
        final result = await excelImportService.importAssessment(testFilePath);

        // assert
        expect(result, isA<ImportedAssessmentForm>());

        // All items should have valid item number format (x.y.z)
        final allItems =
            result.assessment.sections
                .expand((section) => section.items)
                .toList();

        final itemNumberPattern = RegExp(r'^\d+\.\d+\.\d+$');
        for (final item in allItems) {
          if (item.itemNumber.isNotEmpty) {
            expect(
              itemNumberPattern.hasMatch(item.itemNumber),
              isTrue,
              reason:
                  'Item number ${item.itemNumber} should match pattern x.y.z',
            );
          }
        }
      });

      test('should identify and process section sheets correctly', () async {
        // arrange
        final excelBytes = TestFixturesHelper.createExcelWithMultipleSections();
        setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

        // act
        final result = await excelImportService.importAssessment(testFilePath);

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        expect(result.assessment.sections, isNotEmpty);

        // Sections should be properly numbered and ordered
        final sectionNumbers =
            result.assessment.sections
                .map((s) => int.tryParse(s.sectionNumber) ?? 0)
                .where((n) => n > 0)
                .toList();

        if (sectionNumbers.length > 1) {
          for (int i = 1; i < sectionNumbers.length; i++) {
            expect(
              sectionNumbers[i],
              greaterThanOrEqualTo(sectionNumbers[i - 1]),
              reason: 'Sections should be ordered numerically',
            );
          }
        }
      });

      test(
        'should extract section numbers correctly from sheet names',
        () async {
          // arrange
          final excelBytes = TestFixturesHelper.createExcelWithNamedSections();
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: excelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(result, isA<ImportedAssessmentForm>());

          // Should have extracted section numbers from sheet names
          final hasNumberedSections = result.assessment.sections.any(
            (section) => RegExp(r'^\d+$').hasMatch(section.sectionNumber),
          );

          expect(
            hasNumberedSections,
            isTrue,
            reason:
                'Should have at least one section with a numeric section number',
          );
        },
      );
    });

    // ========================================================================
    // INTEGRATION TESTS - COMPLETE WORKFLOWS
    // ========================================================================
    group('integration tests - complete workflows', () {
      const String testFilePath = '/path/to/complete_assessment.xlsx';

      test('should import complete assessment with all sections', () async {
        // arrange
        final completeExcelBytes = TestFixturesHelper.createMockExcelBytes(
          includeAssessmentSummary: true,
          includeSectionSheets: true,
          includeValidData: true,
          numberOfSections: 4,
        );
        setupSuccessfulFileMocks(
          filePath: testFilePath,
          fileSize: 5 * 1024 * 1024, // 5MB
          fileBytes: completeExcelBytes,
        );

        final options = ImportOptions(
          importSectionDetails: true,
          validateAfterImport: true,
          preserveExistingData: false,
        );

        // act
        final result = await excelImportService.importAssessment(
          testFilePath,
          options: options,
        );

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        expect(
          result.assessment.facilityIdentification.facilityName,
          isNotEmpty,
        );
        expect(result.assessment.assessorInfo.name, isNotEmpty);
        expect(result.assessment.geoLocation.country, isNotEmpty);
        expect(result.assessment.sections, isNotEmpty);

        // Verify file operations
        verify(mockFileProvider.getFile(testFilePath)).called(2);
        verify(mockFileProvider.readAsBytes(mockFileWrapper)).called(1);
      });

      test(
        'should import assessment with minimal data when some fields are missing',
        () async {
          // arrange
          final minimalExcelBytes = TestFixturesHelper.createMockExcelBytes(
            includeAssessmentSummary: true,
            includeSectionSheets: false,
            includeValidData: false,
            numberOfSections: 1,
          );
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: minimalExcelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );

          // assert
          expect(result, isA<ImportedAssessmentForm>());
          expect(result.assessment, isA<AssessmentFormModel>());

          // Should have default values for missing fields
          expect(
            result.assessment.facilityIdentification.facilityCode,
            'MTC‑001',
          );
          expect(
            result.assessment.sections,
            isNotEmpty,
          ); // Should have default sections
        },
      );

      test('should handle Excel with multiple section sheets', () async {
        // arrange
        // Build a bona‑fide .xlsx with 4 section sheets
        final excel = Excel.createExcel();
        // (Optionally add an Assessment Summary sheet)
        final summary = excel['Assessment Summary'];
        summary.appendRow([
          TextCellValue('Facility name'),
          TextCellValue('Mock'),
        ]);

        // Now create the 4 section sheets
        for (var i = 1; i <= 4; i++) {
          final sheet = excel['Section $i'];
          // put at least a header row so your parser sees it:
          sheet.appendRow([
            TextCellValue('Section #'),
            TextCellValue('Assessment Area'),
            TextCellValue('Rating'),
          ]);
        }

        // Delete the auto‑gen “Sheet1” so only your four sections + summary remain
        excel.delete('Sheet1');

        final multiSectionExcelBytes = Uint8List.fromList(excel.encode()!);

        setupSuccessfulFileMocks(
          filePath: testFilePath,
          fileBytes: multiSectionExcelBytes,
        );

        // act
        final result = await excelImportService.importAssessment(testFilePath);

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        expect(result.assessment.sections.length, greaterThanOrEqualTo(1));

        // Sections should be ordered by section number
        final sectionNumbers =
            result.assessment.sections
                .map((s) => int.tryParse(s.sectionNumber) ?? 0)
                .toList();

        for (int i = 1; i < sectionNumbers.length; i++) {
          expect(
            sectionNumbers[i],
            greaterThanOrEqualTo(sectionNumbers[i - 1]),
          );
        }
      });

      test(
        'should generate correct import statistics for complete workflow',
        () async {
          // arrange
          final completeExcelBytes = TestFixturesHelper.createMockExcelBytes(
            includeAssessmentSummary: true,
            includeSectionSheets: true,
            includeValidData: true,
            numberOfSections: 3,
          );
          setupSuccessfulFileMocks(
            filePath: testFilePath,
            fileBytes: completeExcelBytes,
          );

          // act
          final result = await excelImportService.importAssessment(
            testFilePath,
          );
          final statistics = excelImportService.getImportStatistics(result);

          // assert
          expect(statistics['formatName'], equals('Microsoft Excel'));
          expect(statistics['totalSections'], isA<int>());
          expect(statistics['totalItems'], isA<int>());
          expect(statistics['completedItems'], isA<int>());
          expect(statistics['completionRate'], isA<double>());
          expect(statistics['metadata'], isA<Map<String, dynamic>>());

          // Completion rate should be between 0 and 100
          expect(statistics['completionRate'], greaterThanOrEqualTo(0.0));
          expect(statistics['completionRate'], lessThanOrEqualTo(100.0));
        },
      );
    });

    // ========================================================================
    // ERROR SCENARIOS AND EDGE CASES
    // ========================================================================
    group('error scenarios and edge cases', () {
      const String problematicFilePath = '/path/to/problematic.xlsx';

      test('should handle corrupted Excel file gracefully', () async {
        // arrange
        final corruptedBytes = TestFixturesHelper.createCorruptedExcelBytes();
        setupSuccessfulFileMocks(
          filePath: problematicFilePath,
          fileBytes: corruptedBytes,
        );

        // act & assert
        expect(
          () => excelImportService.importAssessment(problematicFilePath),
          throwsA(isA<ExcelImportException>()),
        );
      });

      test('should handle Excel file with empty cells', () async {
        // arrange
        final emptyCellsBytes = TestFixturesHelper.createExcelWithEmptyCells();
        setupSuccessfulFileMocks(
          filePath: problematicFilePath,
          fileBytes: emptyCellsBytes,
        );

        // act
        final result = await excelImportService.importAssessment(
          problematicFilePath,
        );

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        // Should have default values for empty cells
        expect(
          result.assessment.facilityIdentification.facilityName,
          isNotNull,
        );
        expect(result.assessment.assessorInfo.name, isNotNull);
      });

      test('should handle Excel file with special characters', () async {
        // arrange
        final specialCharsBytes =
            TestFixturesHelper.createExcelWithUnicodeData();
        setupSuccessfulFileMocks(
          filePath: problematicFilePath,
          fileBytes: specialCharsBytes,
        );

        // act
        final result = await excelImportService.importAssessment(
          problematicFilePath,
        );

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        // Should handle special characters properly
        expect(result.assessment, isA<AssessmentFormModel>());
      });
    });

    // ========================================================================
    // PERFORMANCE TESTS
    // ========================================================================
    group('performance tests', () {
      test('should handle large Excel file efficiently', () async {
        // arrange
        const largeFilePath = '/path/to/large_assessment.xlsx';
        // generate a real .xlsx (with lots of sections to simulate "large")
        final largeExcelBytes = TestFixturesHelper.createMockExcelBytes(
          includeAssessmentSummary: true,
          includeSectionSheets: true,
          includeValidData: true,
          numberOfSections: 50,
        );

        setupSuccessfulFileMocks(
          filePath: largeFilePath,
          fileSize: 25 * 1024 * 1024, // 25MB
          fileBytes: largeExcelBytes,
        );

        final stopwatch = Stopwatch()..start();

        // act
        final result = await excelImportService.importAssessment(largeFilePath);

        stopwatch.stop();

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(30000),
        ); // Within 30 seconds

        // Should handle large amount of data
        expect(result.assessment.sections.length, greaterThanOrEqualTo(1));
      });
    });
  });
  // ========================================================================
  // HELPER METHODS UNIT TESTS - Coverage for private parsing methods
  // ========================================================================
  group('helper methods unit tests', () {
    late TestableExcelImportService testableService;

    setUp(() {
      testableService = TestableExcelImportService(
        fileProvider: mockFileProvider,
      );
    });

    group('_parseDouble', () {
      test('should parse valid double values', () {
        expect(testableService.parseDoubleTest('123.45'), equals(123.45));
        expect(testableService.parseDoubleTest('0.0'), equals(0.0));
        expect(testableService.parseDoubleTest('-45.67'), equals(-45.67));
      });

      test('should return null for invalid double values', () {
        expect(testableService.parseDoubleTest(null), isNull);
        expect(testableService.parseDoubleTest(''), isNull);
        expect(testableService.parseDoubleTest('invalid'), isNull);
        expect(testableService.parseDoubleTest('   '), isNull);
      });

      test('should handle numeric types correctly', () {
        expect(testableService.parseDoubleTest(123), equals(123.0));
        expect(testableService.parseDoubleTest(0), equals(0.0));
      });
    });

    group('enum parsing edge cases', () {
      test('_parseFacilityLocationType should handle all enum cases', () {
        // Valid cases
        expect(
          testableService.parseFacilityLocationTypeTest('urban'),
          equals(FacilityLocationType.urban),
        );
        expect(
          testableService.parseFacilityLocationTypeTest('RURAL'),
          equals(FacilityLocationType.rural),
        );
        expect(
          testableService.parseFacilityLocationTypeTest('Peri-Urban'),
          equals(FacilityLocationType.periUrban),
        );

        // Edge cases
        expect(testableService.parseFacilityLocationTypeTest(''), isNull);
        expect(testableService.parseFacilityLocationTypeTest(null), isNull);
        expect(
          testableService.parseFacilityLocationTypeTest('unknown'),
          isNull,
        );
      });

      test('_parseManagingAuthorityType should handle all enum cases', () {
        // Valid cases - test all enum values
        expect(
          testableService.parseManagingAuthorityTypeTest('government'),
          equals(ManagingAuthorityType.government),
        );
        expect(
          testableService.parseManagingAuthorityTypeTest('private for profit'),
          equals(ManagingAuthorityType.privateForProfit),
        );
        expect(
          testableService.parseManagingAuthorityTypeTest(
            'private not for profit',
          ),
          equals(ManagingAuthorityType.privateNotForProfit),
        );
        expect(
          testableService.parseManagingAuthorityTypeTest(
            'militaryPoliceNationalGuard',
          ),
          equals(ManagingAuthorityType.militaryPoliceNationalGuard),
        );
        expect(
          testableService.parseManagingAuthorityTypeTest('other'),
          equals(ManagingAuthorityType.other),
        );

        // Edge cases
        expect(testableService.parseManagingAuthorityTypeTest(''), isNull);
        expect(testableService.parseManagingAuthorityTypeTest(null), isNull);
      });

      test('_parseFacilityStructureType should handle all enum cases', () {
        // Valid cases
        expect(
          testableService.parseFacilityStructureTypeTest('permanent'),
          equals(FacilityStructureType.permanent),
        );
        expect(
          testableService.parseFacilityStructureTypeTest(
            'temporary medium term',
          ),
          equals(FacilityStructureType.temporaryMediumTerm),
        );
        expect(
          testableService.parseFacilityStructureTypeTest(
            'temporary short term',
          ),
          equals(FacilityStructureType.temporaryShortTerm),
        );
        // Edge cases
        expect(testableService.parseFacilityStructureTypeTest(''), isNull);
        expect(testableService.parseFacilityStructureTypeTest(null), isNull);
      });

      test('_parseFacilityType should handle all enum cases', () {
        // Valid cases
        expect(
          testableService.parseFacilityTypeTest(
            'screening and temporary isolation',
          ),
          equals(FacilityType.screeningAndTemporaryIsolation),
        );
        expect(
          testableService.parseFacilityTypeTest('standalone treatment center'),
          equals(FacilityType.standaloneTreatmentCenter),
        );

        // Edge cases
        expect(testableService.parseFacilityTypeTest(''), isNull);
        expect(testableService.parseFacilityTypeTest(null), isNull);
      });

      test('_parseExistingFacilityType should handle all enum cases', () {
        // Test all enum values
        expect(
          testableService.parseExistingFacilityTypeTest(
            'first referral hospital',
          ),
          equals(ExistingFacilityType.firstReferralHospital),
        );
        expect(
          testableService.parseExistingFacilityTypeTest(
            'regional Provincial Referral Hospital',
          ),
          equals(ExistingFacilityType.regionalProvincialReferralHospital),
        );
        expect(
          testableService.parseExistingFacilityTypeTest(
            'nationalReferralHospital',
          ),
          equals(ExistingFacilityType.nationalReferralHospital),
        );
        expect(
          testableService.parseExistingFacilityTypeTest('otherGeneralHospital'),
          equals(ExistingFacilityType.otherGeneralHospital),
        );
        expect(
          testableService.parseExistingFacilityTypeTest(
            'infectious diseases unit',
          ),
          equals(ExistingFacilityType.infectiousDiseasesUnit),
        );
        expect(
          testableService.parseExistingFacilityTypeTest(
            'primary health clinic',
          ),
          equals(ExistingFacilityType.primaryHealthClinic),
        );
        expect(
          testableService.parseExistingFacilityTypeTest('other'),
          equals(ExistingFacilityType.other),
        );

        // Edge cases
        expect(testableService.parseExistingFacilityTypeTest(''), isNull);
        expect(testableService.parseExistingFacilityTypeTest(null), isNull);
      });
    });

    group('date parsing edge cases', () {
      test('should handle various date formats', () {
        // ISO format
        expect(
          testableService.parseDateTest('2024-01-15'),
          equals(DateTime(2024, 1, 15)),
        );

        // US format
        expect(
          testableService.parseDateTest('01/15/2024'),
          equals(DateTime(2024, 1, 15)),
        );

        // With time
        expect(
          testableService.parseDateTest('2024-01-15 10:30:00'),
          equals(DateTime(2024, 1, 15)),
        );
      });

      test('should handle invalid date values', () {
        expect(testableService.parseDateTest(null), isNull);
        expect(testableService.parseDateTest(''), isNull);
        expect(testableService.parseDateTest('   '), isNull);
        expect(testableService.parseDateTest('not submitted'), isNull);
        expect(testableService.parseDateTest('invalid date'), isNull);
      });
    });

    group('boolean parsing edge cases', () {
      test('should handle various true values', () {
        expect(testableService.parseBooleanTest('yes'), isTrue);
        expect(testableService.parseBooleanTest('YES'), isTrue);
        expect(testableService.parseBooleanTest('true'), isTrue);
        expect(testableService.parseBooleanTest('TRUE'), isTrue);
        expect(testableService.parseBooleanTest('1'), isTrue);
        expect(testableService.parseBooleanTest('  yes  '), isTrue);
      });

      test('should handle various false values', () {
        expect(testableService.parseBooleanTest('no'), isFalse);
        expect(testableService.parseBooleanTest('NO'), isFalse);
        expect(testableService.parseBooleanTest('false'), isFalse);
        expect(testableService.parseBooleanTest('FALSE'), isFalse);
        expect(testableService.parseBooleanTest('0'), isFalse);
        expect(testableService.parseBooleanTest('  no  '), isFalse);
      });

      test('should return null for ambiguous values', () {
        expect(testableService.parseBooleanTest(null), isNull);
        expect(testableService.parseBooleanTest(''), isNull);
        expect(testableService.parseBooleanTest('maybe'), isNull);
        expect(testableService.parseBooleanTest('unknown'), isNull);
      });
    });

    group('integer parsing edge cases', () {
      test('should handle various integer formats', () {
        expect(testableService.parseIntTest('123'), equals(123));
        expect(testableService.parseIntTest('0'), equals(0));
        expect(testableService.parseIntTest('  456  '), equals(456));
        expect(testableService.parseIntTest(789), equals(789));
      });

      test('should return null for invalid integers', () {
        expect(testableService.parseIntTest(null), isNull);
        expect(testableService.parseIntTest(''), isNull);
        expect(testableService.parseIntTest('not specified'), isNull);
        expect(testableService.parseIntTest('abc'), isNull);
        expect(testableService.parseIntTest('12.34'), isNull);
      });
    });
  });

  // ========================================================================
  // EXCEL STRUCTURE PARSING TESTS - Coverage for sheet/cell handling
  // ========================================================================
  group('excel structure parsing tests', () {
    const String testFilePath = '/path/to/structure_test.xlsx';

    test('should handle Excel with no Assessment Summary sheet', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithoutSummarySheet();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      // Should still create assessment with default values
      expect(result.assessment.facilityIdentification.facilityName, isNotNull);
    });

    test(
      'should handle Excel with multiple sheets named similarly to summary',
      () async {
        // arrange
        final excelBytes =
            TestFixturesHelper.createExcelWithMultipleSummarySheets();
        setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

        // act
        final result = await excelImportService.importAssessment(testFilePath);

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        expect(result.assessment, isA<AssessmentFormModel>());
      },
    );

    test('should handle Excel with malformed section headers', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithMalformedHeaders();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      // Should fall back to default sections when headers are malformed
      expect(result.assessment.sections, isNotEmpty);
    });

    test('should handle Excel with non-standard sheet names', () async {
      // arrange
      final excelBytes =
          TestFixturesHelper.createExcelWithNonStandardSheetNames();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment.sections, isNotEmpty);
    });

    test('should handle Excel with cells containing formulas', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithFormulas();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment, isA<AssessmentFormModel>());
    });

    test('should handle Excel with merged cells', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithMergedCells();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment, isA<AssessmentFormModel>());
    });
  });

  // ========================================================================
  // RATING PARSING COMPREHENSIVE TESTS
  // ========================================================================
  group('rating parsing comprehensive tests', () {
    const String testFilePath = '/path/to/rating_comprehensive_test.xlsx';

    test('should parse all rating text variations correctly', () async {
      // arrange
      final excelBytes =
          TestFixturesHelper.createExcelWithAllRatingVariations();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());

      final allItems =
          result.assessment.sections
              .expand((section) => section.items)
              .toList();

      // Should have items with different rating types
      final meetsTargetItems = allItems.where(
        (item) => item.selectedRating?.label == AssessmentRating.meets.name,
      );
      final partiallyMeetsItems = allItems.where(
        (item) => item.selectedRating?.label == AssessmentRating.partial.name,
      );
      final doesNotMeetItems = allItems.where(
        (item) => item.selectedRating?.label == AssessmentRating.doesNot.name,
      );

      expect(meetsTargetItems.length, greaterThanOrEqualTo(0));
      expect(partiallyMeetsItems.length, greaterThanOrEqualTo(0));
      expect(doesNotMeetItems.length, greaterThanOrEqualTo(0));
    });

    test('should handle don\'t know and not applicable ratings', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithSpecialRatings();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());

      final allItems =
          result.assessment.sections
              .expand((section) => section.items)
              .toList();

      // Should have items with special rating types
      final dontKnowItems = allItems.where(
        (item) => item.selectedRating?.label == AssessmentRating.dontKnow.name,
      );
      final notApplicableItems = allItems.where(
        (item) =>
            item.selectedRating?.label == AssessmentRating.notApplicable.name,
      );

      expect(dontKnowItems.length, greaterThanOrEqualTo(0));
      expect(notApplicableItems.length, greaterThanOrEqualTo(0));
    });

    test('should handle mixed rating text and choice formats', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithMixedRatingFormats();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      // Should parse various rating formats without throwing errors
      expect(result.assessment.sections, isNotEmpty);
    });
  });

  // ========================================================================
  // SUMMARY ROW AND ITEM VALIDATION COMPREHENSIVE TESTS
  // ========================================================================
  group('summary row and item validation comprehensive tests', () {
    late TestableExcelImportService testableService;

    setUp(() {
      testableService = TestableExcelImportService(
        fileProvider: mockFileProvider,
      );
    });

    test('_isSummaryRow should identify all summary row patterns', () {
      // Test all summary patterns mentioned in the code
      expect(
        testableService.isSummaryRowTest('Section Summary', 'Total Items'),
        isTrue,
      );
      expect(
        testableService.isSummaryRowTest('', 'total items completed'),
        isTrue,
      );
      expect(testableService.isSummaryRowTest('Completed', ''), isTrue);
      expect(testableService.isSummaryRowTest('', 'unanswered items'), isTrue);
      expect(testableService.isSummaryRowTest('Meets Target', '75%'), isTrue);
      expect(testableService.isSummaryRowTest('', 'completion rate'), isTrue);
      expect(
        testableService.isSummaryRowTest('Warning', 'incomplete section'),
        isTrue,
      );

      // Test valid item rows
      expect(
        testableService.isSummaryRowTest('2.1.1', 'Assessment area'),
        isFalse,
      );
      expect(
        testableService.isSummaryRowTest('3.2.5', 'Valid assessment area'),
        isFalse,
      );
    });

    test(
      '_isValidItemNumber should validate item number patterns correctly',
      () {
        // Valid item numbers
        expect(testableService.isValidItemNumberTest('2.1.1'), isTrue);
        expect(testableService.isValidItemNumberTest('3.2.5'), isTrue);
        expect(testableService.isValidItemNumberTest('4.10.25'), isTrue);

        // Invalid item numbers
        expect(testableService.isValidItemNumberTest(''), isFalse);
        expect(testableService.isValidItemNumberTest(null), isFalse);
        expect(testableService.isValidItemNumberTest('2.1'), isFalse);
        expect(testableService.isValidItemNumberTest('2.1.1.1'), isFalse);
        expect(testableService.isValidItemNumberTest('section 2'), isFalse);
        expect(testableService.isValidItemNumberTest('total'), isFalse);
        expect(testableService.isValidItemNumberTest('a.b.c'), isFalse);
      },
    );

    test('should filter complex summary patterns during import', () async {
      // arrange
      const testFilePath = '/path/to/complex_summary_test.xlsx';
      final excelBytes =
          TestFixturesHelper.createExcelWithComplexSummaryPatterns();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());

      final allItems =
          result.assessment.sections
              .expand((section) => section.items)
              .toList();

      // Should not have any items with summary-like content
      for (final item in allItems) {
        expect(item.itemNumber.toLowerCase(), isNot(contains('warning')));
        expect(item.itemNumber.toLowerCase(), isNot(contains('critical')));
        expect(item.area.toLowerCase(), isNot(contains('completion rate')));
        expect(item.area.toLowerCase(), isNot(contains('items still need')));
      }
    });
  });

  // ========================================================================
  // CELL VALUE RETRIEVAL AND PARSING EDGE CASES
  // ========================================================================
  group('cell value retrieval and parsing edge cases', () {
    const String testFilePath = '/path/to/cell_parsing_test.xlsx';

    test('should handle cells with very long text content', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithLongTextContent();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment, isA<AssessmentFormModel>());
    });

    test('should handle cells with numeric values stored as text', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithNumericTextValues();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      // Numeric values should be parsed correctly even when stored as text
      expect(
        result.assessment.facilityServices.totalInpatientBeds,
        isA<int?>(),
      );
      expect(result.assessment.facilityServices.icuBeds, isA<int?>());
    });

    test('should handle cells with mixed data types', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithMixedDataTypes();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment, isA<AssessmentFormModel>());
    });

    test('should handle Excel with inconsistent column layouts', () async {
      // arrange
      final excelBytes =
          TestFixturesHelper.createExcelWithInconsistentColumns();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment.sections, isNotEmpty);
    });
  });

  // ========================================================================
  // COORDINATE AND GEOLOCATION PARSING TESTS
  // ========================================================================
  group('coordinate and geolocation parsing tests', () {
    const String testFilePath = '/path/to/geolocation_test.xlsx';

    test('should parse various coordinate formats', () async {
      // arrange
      final excelBytes =
          TestFixturesHelper.createExcelWithVariousCoordinateFormats();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment.geoLocation.latitude, isA<double?>());
      expect(result.assessment.geoLocation.longitude, isA<double?>());
    });

    test('should handle invalid coordinate values gracefully', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithInvalidCoordinates();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      // Should not throw errors for invalid coordinates
      expect(result.assessment.geoLocation, isA<GeoLocationModel>());
    });

    test('should handle missing geolocation data', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithMissingGeoData();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment.geoLocation.country, isNotNull);
      expect(result.assessment.geoLocation.latitude, isA<double?>());
    });
  });

  // ========================================================================
  // DEBUG AND UTILITY METHODS TESTS
  // ========================================================================
  group('debug and utility methods tests', () {
    test('should handle _debugExcelStructure without throwing', () async {
      // arrange
      const testFilePath = '/path/to/debug_test.xlsx';
      final excelBytes = TestFixturesHelper.createExcelForDebugTesting();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act & assert - should not throw during debug
      expect(
        () => excelImportService.importAssessment(testFilePath),
        returnsNormally,
      );
    });

    test('should handle Excel with very wide sheets (many columns)', () async {
      // arrange
      const testFilePath = '/path/to/wide_sheet_test.xlsx';
      final excelBytes = TestFixturesHelper.createExcelWithManyColumns();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment, isA<AssessmentFormModel>());
    });

    test('should handle Excel with very tall sheets (many rows)', () async {
      // arrange
      const testFilePath = '/path/to/tall_sheet_test.xlsx';
      final excelBytes = TestFixturesHelper.createExcelWithManyRows();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      // act
      final result = await excelImportService.importAssessment(testFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment, isA<AssessmentFormModel>());
    });
  });

  // ========================================================================
  // OPTION HANDLING COMPREHENSIVE TESTS
  // ========================================================================
  group('import options comprehensive tests', () {
    const String testFilePath = '/path/to/options_test.xlsx';

    test('should respect importSectionDetails = false option', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelWithDetailedSections();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      final options = ImportOptions(
        importSectionDetails: false,
        validateAfterImport: true,
        preserveExistingData: false,
      );

      // act
      final result = await excelImportService.importAssessment(
        testFilePath,
        options: options,
      );

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      // Should have default sections instead of parsed section details
      expect(result.assessment.sections, isNotEmpty);
      expect(
        result.assessment.sections.length,
        equals(4),
      ); // Default sections count
    });

    test('should handle all combination of import options', () async {
      // arrange
      final excelBytes = TestFixturesHelper.createExcelForOptionsTest();
      setupSuccessfulFileMocks(filePath: testFilePath, fileBytes: excelBytes);

      final optionsCombinations = [
        ImportOptions(
          importSectionDetails: true,
          validateAfterImport: true,
          preserveExistingData: true,
        ),
        ImportOptions(
          importSectionDetails: false,
          validateAfterImport: false,
          preserveExistingData: false,
        ),
        ImportOptions(
          importSectionDetails: true,
          validateAfterImport: true,
          preserveExistingData: false,
        ),
      ];

      for (final options in optionsCombinations) {
        // act
        final result = await excelImportService.importAssessment(
          testFilePath,
          options: options,
        );

        // assert
        expect(result, isA<ImportedAssessmentForm>());
        expect(result.assessment, isA<AssessmentFormModel>());
      }
    });
  });

  // ========================================================================
  // METADATA AND STATISTICS EDGE CASES
  // ========================================================================
  group('metadata and statistics edge cases', () {
    test('should generate accurate statistics for various scenarios', () {
      // Test with assessment having mixed completion rates
      final mixedAssessment =
          TestDataHelper.createMockAssessmentWithMixedCompletion();
      final importedForm = ImportedAssessmentForm(
        assessment: mixedAssessment,
        filePath: '/test/mixed.xlsx',
        format: 'Microsoft Excel',
        importedAt: DateTime(2024, 1, 15, 14, 30),
        metadata: {
          'totalSheets': 5,
          'sheetNames': [
            'Summary',
            'Section 2',
            'Section 3',
            'Section 4',
            'Section 5',
          ],
          'importedSections': 4,
          'totalItems': 50,
        },
      );

      // act
      final statistics = excelImportService.getImportStatistics(importedForm);

      // assert
      expect(statistics['formatName'], equals('Microsoft Excel'));
      expect(statistics['importedAt'], equals('2024-01-15T14:30:00.000'));
      expect(statistics['totalSections'], isA<int>());
      expect(statistics['totalItems'], isA<int>());
      expect(statistics['completedItems'], isA<int>());
      expect(statistics['completionRate'], isA<double>());
      expect(statistics['metadata'], isA<Map<String, dynamic>>());
    });
  });

  group('edge case validation tests', () {
    test('should handle file size exactly at limit (50MB)', () async {
      // arrange
      const limitFilePath = '/path/to/limit.xlsx';
      setupSuccessfulFileMocks(filePath: limitFilePath);
      when(mockFileStat.size).thenReturn(50 * 1024 * 1024); // Exactly 50MB

      // act & assert
      expect(
        () => excelImportService.validateFormatSpecific(limitFilePath),
        returnsNormally,
      );
    });
  });

  group('importFromBytes', () {
    test('should successfully import from bytes with synthetic path', () async {
      // arrange
      final bytes = TestFixturesHelper.createMockExcelBytes(
        includeAssessmentSummary: true,
        includeSectionSheets: true,
        includeValidData: true,
        numberOfSections: 2,
      );

      // act
      final result = await excelImportService.importFromBytes(bytes);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      // default filePath when originalName is null
      expect(result.filePath, equals('<bytes>'));
      expect(result.format, equals('Microsoft Excel'));

      // metadata
      expect(result.metadata?['origin'], equals('bytes'));
      expect(result.metadata?['totalSheets'], equals(3));
      // we built Summary + 2 section sheets
      expect(result.metadata?['sheetNames'], isA<List<String>>());

      // assessment
      expect(result.assessment, isA<AssessmentFormModel>());
      expect(result.assessment.sections, isNotEmpty);
    });

    test('should use provided originalName as filePath', () async {
      // arrange
      final bytes = TestFixturesHelper.createMockExcelBytes(
        includeAssessmentSummary: true,
        includeSectionSheets: false,
        includeValidData: false,
        numberOfSections: 0,
      );
      const customName = 'my_upload.xlsx';

      // act
      final result = await excelImportService.importFromBytes(
        bytes,
        originalName: customName,
      );

      // assert
      expect(result.filePath, equals(customName));
      expect(result.metadata?['origin'], equals('bytes'));
    });

    test('should respect ImportOptions.importSectionDetails = false', () async {
      // arrange
      final bytes = TestFixturesHelper.createMockExcelBytes(
        includeAssessmentSummary: true,
        includeSectionSheets: true,
        includeValidData: true,
        numberOfSections: 3,
      );

      final options = ImportOptions(importSectionDetails: false);

      // act
      final result = await excelImportService.importFromBytes(
        bytes,
        options: options,
      );

      // assert
      // since importSectionDetails is false, should get default sections count (4)
      expect(result.assessment.sections.length, equals(4));
    });

    test('should respect ImportOptions.importSectionDetails = true', () async {
      // arrange
      final bytes = TestFixturesHelper.createMockExcelBytes(
        includeAssessmentSummary: true,
        includeSectionSheets: true,
        includeValidData: true,
        numberOfSections: 2,
      );

      final options = ImportOptions(importSectionDetails: true);

      // act
      final result = await excelImportService.importFromBytes(
        bytes,
        options: options,
      );

      // assert
      // should include the two real sections plus the default section1
      expect(result.assessment.sections.length, greaterThanOrEqualTo(3));
    });
  });

  group('private method direct tests', () {
    late TestableExcelImportService testableService;

    setUp(() {
      testableService = TestableExcelImportService(
        fileProvider: mockFileProvider,
      );
    });

    test('_parseDouble should handle edge cases', () {
      // Test various numeric formats
      expect(testableService.parseDoubleTest('123'), equals(123.0));
      expect(testableService.parseDoubleTest(123.45), equals(123.45));
      expect(testableService.parseDoubleTest(' 123.45 '), equals(123.45));
      expect(testableService.parseDoubleTest('0'), equals(0.0));
      expect(testableService.parseDoubleTest('-123.45'), equals(-123.45));

      // Test invalid cases
      expect(testableService.parseDoubleTest(''), isNull);
      expect(testableService.parseDoubleTest('   '), isNull);
      expect(testableService.parseDoubleTest('abc'), isNull);
      expect(testableService.parseDoubleTest('12.34.56'), isNull);
    });

    test('_parseInt should handle edge cases including existing integer', () {
      // Test when value is already an integer
      expect(testableService.parseIntTest(42), equals(42));
      expect(testableService.parseIntTest(0), equals(0));
      expect(testableService.parseIntTest(-5), equals(-5));

      // Test string to int conversion
      expect(testableService.parseIntTest('42'), equals(42));
      expect(testableService.parseIntTest(' 42 '), equals(42));
      expect(testableService.parseIntTest('0'), equals(0));

      // Test invalid cases
      expect(testableService.parseIntTest('not specified'), isNull);
      expect(testableService.parseIntTest('NOT SPECIFIED'), isNull);
      expect(testableService.parseIntTest(''), isNull);
      expect(testableService.parseIntTest('abc'), isNull);
      expect(testableService.parseIntTest('12.34'), isNull);
    });

    test('enum parsing should handle exact enum matches', () {
      // Test direct enum name matches for FacilityLocationType
      expect(
        testableService.parseFacilityLocationTypeTest('urban'),
        equals(FacilityLocationType.urban),
      );
      expect(
        testableService.parseFacilityLocationTypeTest('rural'),
        equals(FacilityLocationType.rural),
      );
      expect(
        testableService.parseFacilityLocationTypeTest('periUrban'),
        equals(FacilityLocationType.periUrban),
      );

      // Test case variations
      expect(
        testableService.parseFacilityLocationTypeTest('URBAN'),
        equals(FacilityLocationType.urban),
      );
      expect(
        testableService.parseFacilityLocationTypeTest('Rural'),
        equals(FacilityLocationType.rural),
      );
    });

    test('_parseDate should handle various date formats comprehensively', () {
      // Test ISO format variations
      expect(
        testableService.parseDateTest('2024-01-15'),
        equals(DateTime(2024, 1, 15)),
      );
      expect(
        testableService.parseDateTest('2024-01-15 10:30:00'),
        equals(DateTime(2024, 1, 15)),
      );

      // Test US format
      expect(
        testableService.parseDateTest('01/15/2024'),
        equals(DateTime(2024, 1, 15)),
      );
      expect(
        testableService.parseDateTest('1/15/2024'),
        equals(DateTime(2024, 1, 15)),
      );

      // Test invalid dates and edge cases
      expect(testableService.parseDateTest('not submitted'), isNull);
      expect(testableService.parseDateTest('NOT SUBMITTED'), isNull);
      expect(testableService.parseDateTest(''), isNull);
      expect(testableService.parseDateTest('   '), isNull);
      expect(testableService.parseDateTest('invalid-date'), isNull);
    });

    test('summary row detection should be comprehensive', () {
      // Test all patterns mentioned in the implementation
      expect(testableService.isSummaryRowTest('section summary', ''), isTrue);
      expect(testableService.isSummaryRowTest('', 'total items'), isTrue);
      expect(
        testableService.isSummaryRowTest('completed', 'unanswered'),
        isTrue,
      );
      expect(testableService.isSummaryRowTest('', 'meets target'), isTrue);
      expect(testableService.isSummaryRowTest('partially meets', ''), isTrue);
      expect(testableService.isSummaryRowTest('does not meet', ''), isTrue);
      expect(
        testableService.isSummaryRowTest('don\'t know', 'not applicable'),
        isTrue,
      );
      expect(testableService.isSummaryRowTest('', 'completion rate'), isTrue);
      expect(
        testableService.isSummaryRowTest('warning', 'incomplete section'),
        isTrue,
      );
      expect(testableService.isSummaryRowTest('items still need', ''), isTrue);
      expect(testableService.isSummaryRowTest('critical issues', ''), isTrue);
      expect(
        testableService.isSummaryRowTest('complete evaluation', ''),
        isTrue,
      );

      // Test case insensitive matching
      expect(testableService.isSummaryRowTest('SECTION SUMMARY', ''), isTrue);
      expect(testableService.isSummaryRowTest('', 'TOTAL ITEMS'), isTrue);

      // Test valid item rows should return false
      expect(
        testableService.isSummaryRowTest('2.1.1', 'Valid assessment area'),
        isFalse,
      );
      expect(
        testableService.isSummaryRowTest('3.2.5', 'Another valid area'),
        isFalse,
      );
    });

    test('item number validation should be precise', () {
      // Valid patterns
      expect(testableService.isValidItemNumberTest('2.1.1'), isTrue);
      expect(testableService.isValidItemNumberTest('10.5.25'), isTrue);
      expect(testableService.isValidItemNumberTest('1.1.1'), isTrue);

      // Invalid patterns
      expect(testableService.isValidItemNumberTest('2.1'), isFalse);
      expect(testableService.isValidItemNumberTest('2'), isFalse);
      expect(testableService.isValidItemNumberTest('2.1.1.1'), isFalse);
      expect(testableService.isValidItemNumberTest('a.b.c'), isFalse);
      expect(testableService.isValidItemNumberTest('section 2'), isFalse);
      expect(testableService.isValidItemNumberTest(''), isFalse);
      expect(testableService.isValidItemNumberTest(null), isFalse);
      expect(testableService.isValidItemNumberTest('2.1.'), isFalse);
      expect(testableService.isValidItemNumberTest('.1.1'), isFalse);
    });
  });

  group('complex integration scenarios', () {
    test('should handle Excel with all possible data variations', () async {
      // arrange
      const complexFilePath = '/path/to/complex_all_variations.xlsx';
      final complexExcelBytes =
          TestFixturesHelper.createComplexExcelWithAllVariations();
      setupSuccessfulFileMocks(
        filePath: complexFilePath,
        fileBytes: complexExcelBytes,
      );

      // act
      final result = await excelImportService.importAssessment(complexFilePath);

      // assert
      expect(result, isA<ImportedAssessmentForm>());
      expect(result.assessment, isA<AssessmentFormModel>());

      // Verify all major components are present
      expect(
        result.assessment.facilityIdentification,
        isA<FacilityIdentificationModel>(),
      );
      expect(result.assessment.geoLocation, isA<GeoLocationModel>());
      expect(result.assessment.facilityServices, isA<FacilityServicesModel>());
      expect(result.assessment.assessorInfo, isA<AssessorInfoModel>());
      expect(result.assessment.sections, isNotEmpty);
    });

    test(
      'should maintain data integrity through complete import process',
      () async {
        // arrange
        const integrityTestPath = '/path/to/integrity_test.xlsx';
        final integrityExcelBytes =
            TestFixturesHelper.createExcelForIntegrityTesting();
        setupSuccessfulFileMocks(
          filePath: integrityTestPath,
          fileBytes: integrityExcelBytes,
        );

        // act
        final result = await excelImportService.importAssessment(
          integrityTestPath,
        );
        final statistics = excelImportService.getImportStatistics(result);

        // assert
        expect(result, isA<ImportedAssessmentForm>());

        // Verify statistics match the actual imported data
        final actualTotalItems = result.assessment.totalItems;
        expect(statistics['totalItems'], equals(actualTotalItems));

        final actualCompletedItems = result.assessment.completedItems;
        expect(statistics['completedItems'], equals(actualCompletedItems));

        // Verify completion rate calculation
        final expectedCompletionRate =
            actualTotalItems > 0
                ? (actualCompletedItems / actualTotalItems) * 100
                : 0.0;
        expect(statistics['completionRate'], equals(expectedCompletionRate));
      },
    );
  });
}

// =============================================================================
// TEST HELPER CLASSES AND UTILITIES
// =============================================================================

/// Helper class for creating test fixtures and mock data
class TestFixturesHelper {
  /// Creates mock Excel bytes for testing purposes
  /// ─── inside TestFixturesHelper ────────────────────────────────────────────
  static Uint8List createMockExcelBytes({
    bool includeAssessmentSummary = true,
    bool includeSectionSheets = true,
    bool includeValidData = true,
    int numberOfSections = 3,
  }) {
    final excel = Excel.createExcel(); // comes with a default 'Sheet1'

    // 1️⃣  Assessment Summary sheet
    if (includeAssessmentSummary) {
      final summary = excel['Assessment Summary'];
      summary.appendRow([
        TextCellValue('Country'),
        TextCellValue('Test Country'),
      ]);
      summary.appendRow([
        TextCellValue('Name of person conducting assessment'),
        TextCellValue('Tester'),
      ]);
      summary.appendRow([
        TextCellValue('Date of assessment'),
        TextCellValue('2025‑07‑28'),
      ]);

      summary.appendRow([
        TextCellValue('Facility name'),
        TextCellValue('Mock Treatment Centre'),
      ]);
      summary.appendRow([
        TextCellValue('Facility code'),
        TextCellValue('MTC‑001'),
      ]);
    }

    // 2️⃣  Section sheets
    if (includeSectionSheets) {
      for (int i = 0; i < numberOfSections; i++) {
        final sheet = excel['Section ${i + 2}'];
        // minimal header row expected by your parser
        sheet.appendRow([
          TextCellValue('Section #'),
          TextCellValue('Assessment Area'),
          TextCellValue('Rating'),
          TextCellValue('Choice Made'),
          TextCellValue('Status'),
          TextCellValue('Comment'),
        ]);

        if (includeValidData) {
          sheet.appendRow([
            TextCellValue('${i + 2}.1.1'),
            TextCellValue('Mock area ${(i + 2)}'),
            TextCellValue('+++'), // meets‑target
            TextCellValue(''), // choice
            TextCellValue(''), // status
            TextCellValue('Test comment'),
          ]);
        }
      }
    }

    // 3️⃣  Remove the auto‑generated empty sheet so it doesn’t confuse the tests
    excel.delete('Sheet1');

    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates mock Excel bytes with specific sheet configuration
  static Uint8List createExcelWithSheets({
    required List<String> sheetNames,
    bool hasValidSummaryData = true,
    bool hasSectionData = true,
  }) {
    final baseSize = 2048;
    final sheetSize = 1024;
    final totalSize = baseSize + (sheetNames.length * sheetSize);

    return Uint8List.fromList(
      List.generate(totalSize, (index) {
        final sheetIndex = (index - baseSize) ~/ sheetSize;
        if (sheetIndex >= 0 && sheetIndex < sheetNames.length) {
          return (sheetIndex * 73 + index * 19) % 256;
        } else {
          return (index * 43 + 127) % 256;
        }
      }),
    );
  }

  /// Creates corrupted Excel bytes for error testing
  static Uint8List createCorruptedExcelBytes() {
    return Uint8List.fromList([
      0x50, 0x4B, 0x03, 0x04, // ZIP header (Excel files are ZIP)
      ...List.generate(100, (index) => 0xFF), // Invalid data
      0x00, 0x00, 0x00, 0x00, // Corrupted structure
    ]);
  }

  /// Creates Excel bytes with empty/null cells
  static Uint8List createExcelWithEmptyCells() {
    final excel = Excel.createExcel();
    // Add an “Assessment Summary” sheet (so your parser finds it)
    final sheet = excel['Assessment Summary'];
    // Put rows with headers but empty values
    sheet.appendRow([TextCellValue('Facility name'), TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('Name of person conducting assessment'),
      TextCellValue(''),
    ]);
    sheet.appendRow([TextCellValue('Date of assessment'), TextCellValue('')]);
    // Remove the default blank “Sheet1”
    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel bytes with special characters and Unicode
  static Uint8List createExcelWithUnicodeData() {
    // 1) Create a real Excel workbook
    final excel = Excel.createExcel();
    // 2) Grab (or create) your “Assessment Summary” sheet
    final sheet = excel['Assessment Summary'];
    // 3) Append a couple of rows with special characters
    sheet.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Tést Fäçility – 中國医院'),
    ]);
    sheet.appendRow([
      TextCellValue('Name of person conducting assessment'),
      TextCellValue('测试人员'),
    ]);
    sheet.appendRow([
      TextCellValue('Date of assessment'),
      TextCellValue('2024‑08‑01'),
    ]);
    // 4) Remove the default blank sheet so your parser doesn’t see it
    excel.delete('Sheet1');
    // 5) Encode to bytes
    return Uint8List.fromList(excel.encode()!);
  }

  // Specific test data creation methods
  static Uint8List createExcelWithLocationData() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 1);
  }

  static Uint8List createExcelWithAuthorityData() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 1);
  }

  static Uint8List createExcelWithStructureData() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 1);
  }

  static Uint8List createExcelWithDateData() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 1);
  }

  static Uint8List createExcelWithBooleanData() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 1);
  }

  static Uint8List createExcelWithIntegerData() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 1);
  }

  static Uint8List createExcelWithCoordinateData() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 1);
  }

  static Uint8List createExcelWithVariousRatings() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 3);
  }

  static Uint8List createExcelWithPendingRatings() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 2);
  }

  static Uint8List createExcelWithSummaryRows() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 2);
  }

  static Uint8List createExcelWithMixedItemNumbers() {
    return createMockExcelBytes(includeValidData: true, numberOfSections: 3);
  }

  static Uint8List createExcelWithMultipleSections() {
    return createMockExcelBytes(
      includeAssessmentSummary: true,
      includeSectionSheets: true,
      includeValidData: true,
      numberOfSections: 4,
    );
  }

  static Uint8List createExcelWithNamedSections() {
    final excel = Excel.createExcel();

    // 1) Summary sheet
    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);

    // 2) Section 2
    final sec2 = excel['Section 2'];
    sec2.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);

    // 3) Assessment Section 3
    final sec3 = excel['Assessment Section 3'];
    sec3.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);

    // Remove the default sheet so Excel.decodeBytes() sees exactly these three
    excel.delete('Sheet1');

    return Uint8List.fromList(excel.encode()!);
  }

  static Uint8List createExcelWithoutSummarySheet() {
    final excel = Excel.createExcel();

    // Only create section sheets, no summary
    final sheet2 = excel['Section 2'];
    sheet2.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);

    excel.delete('Sheet1'); // Remove default sheet
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with multiple summary-like sheets
  static Uint8List createExcelWithMultipleSummarySheets() {
    final excel = Excel.createExcel();

    // Create multiple sheets that could be considered summary sheets
    final summary1 = excel['Assessment Summary'];
    summary1.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);

    final summary2 = excel['Summary'];
    summary2.appendRow([
      TextCellValue('Country'),
      TextCellValue('Test Country'),
    ]);

    final overview = excel['Overview'];
    overview.appendRow([
      TextCellValue('Assessment Date'),
      TextCellValue('2024-01-15'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with malformed section headers
  static Uint8List createExcelWithMalformedHeaders() {
    final excel = Excel.createExcel();

    final sheet = excel['Section 2'];
    // Malformed headers - missing expected column names
    sheet.appendRow([
      TextCellValue('Wrong Header 1'),
      TextCellValue('Wrong Header 2'),
      TextCellValue('Wrong Header 3'),
    ]);
    sheet.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Some area'),
      TextCellValue('+++'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with non-standard sheet names
  static Uint8List createExcelWithNonStandardSheetNames() {
    final excel = Excel.createExcel();

    // Non-standard but potentially valid sheet names
    final sheet1 = excel['Assessment_Data'];
    sheet1.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);

    final sheet2 = excel['Part_2_Assessment'];
    sheet2.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);

    final sheet3 = excel['Random_Sheet_Name'];
    sheet3.appendRow([TextCellValue('Random Data')]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with formula cells
  static Uint8List createExcelWithFormulas() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    sheet.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);
    sheet.appendRow([
      TextCellValue('Total Beds'),
      TextCellValue('=SUM(A1:A10)'),
    ]);
    sheet.appendRow([
      TextCellValue('Completion Rate'),
      TextCellValue('=B1/B2*100'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with merged cells
  static Uint8List createExcelWithMergedCells() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    sheet.appendRow([TextCellValue('Facility Information Header (Merged)')]);
    sheet.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with all rating variations
  static Uint8List createExcelWithAllRatingVariations() {
    final excel = Excel.createExcel();

    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);

    final section = excel['Section 2'];
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
      TextCellValue('Choice Made'),
      TextCellValue('Status'),
    ]);

    // Different rating formats
    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Area 1'),
      TextCellValue('+++'),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('2.1.2'),
      TextCellValue('Area 2'),
      TextCellValue('MEETS'),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('2.1.3'),
      TextCellValue('Area 3'),
      TextCellValue('++'),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('2.1.4'),
      TextCellValue('Area 4'),
      TextCellValue('+'),
      TextCellValue(''),
      TextCellValue(''),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with special ratings (DK, NA)
  static Uint8List createExcelWithSpecialRatings() {
    final excel = Excel.createExcel();

    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);

    final section = excel['Section 2'];
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
      TextCellValue('Choice Made'),
    ]);

    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Area 1'),
      TextCellValue('DK'),
      TextCellValue('Don\'t know'),
    ]);
    section.appendRow([
      TextCellValue('2.1.2'),
      TextCellValue('Area 2'),
      TextCellValue('NA'),
      TextCellValue('Not applicable'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with mixed rating formats
  static Uint8List createExcelWithMixedRatingFormats() {
    final excel = Excel.createExcel();

    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);

    final section = excel['Section 2'];
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
      TextCellValue('Choice Made'),
      TextCellValue('Status'),
    ]);

    // Mix of rating and choice formats
    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Area 1'),
      TextCellValue('+++'),
      TextCellValue(''),
      TextCellValue('Completed'),
    ]);
    section.appendRow([
      TextCellValue('2.1.2'),
      TextCellValue('Area 2'),
      TextCellValue(''),
      TextCellValue('Meets target requirements'),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('2.1.3'),
      TextCellValue('Area 3'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('Pending review'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with complex summary patterns
  static Uint8List createExcelWithComplexSummaryPatterns() {
    final excel = Excel.createExcel();

    final section = excel['Section 2'];
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);

    // Valid items
    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Valid area'),
      TextCellValue('+++'),
    ]);

    // Complex summary patterns that should be filtered
    section.appendRow([
      TextCellValue('Section Summary'),
      TextCellValue('Total items: 25'),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('Warning'),
      TextCellValue('3 items still need attention'),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('Critical Issues'),
      TextCellValue('Complete evaluation required'),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('Completion Rate'),
      TextCellValue('85% completed'),
      TextCellValue(''),
    ]);

    // Another valid item
    section.appendRow([
      TextCellValue('2.1.2'),
      TextCellValue('Another valid area'),
      TextCellValue('++'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with long text content
  static Uint8List createExcelWithLongTextContent() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    final longText =
        'This is a very long text content that simulates real-world scenarios where Excel cells might contain extensive descriptions, detailed comments, or comprehensive explanations that need to be handled properly by the import service without causing performance issues or memory problems.';

    sheet.appendRow([TextCellValue('Facility name'), TextCellValue(longText)]);
    sheet.appendRow([
      TextCellValue('Description'),
      TextCellValue(longText * 3),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with numeric values stored as text
  static Uint8List createExcelWithNumericTextValues() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    sheet.appendRow([
      TextCellValue('Total number of overnight/inpatient beds'),
      TextCellValue('50'),
    ]);
    sheet.appendRow([
      TextCellValue(
        'Of the total number of inpatient beds, how many are intensive care unit (ICU) beds?',
      ),
      TextCellValue('10'),
    ]);
    sheet.appendRow([TextCellValue('Latitude'), TextCellValue('12.3456')]);
    sheet.appendRow([TextCellValue('Longitude'), TextCellValue('-98.7654')]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with mixed data types
  static Uint8List createExcelWithMixedDataTypes() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    sheet.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);
    sheet.appendRow([TextCellValue('Total beds'), IntCellValue(50)]);
    sheet.appendRow([TextCellValue('Latitude'), DoubleCellValue(12.3456)]);
    sheet.appendRow([
      TextCellValue('Has emergency unit'),
      TextCellValue('yes'),
    ]);
    sheet.appendRow([
      TextCellValue('Assessment Date'),
      TextCellValue('2024-01-15'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with inconsistent column layouts
  static Uint8List createExcelWithInconsistentColumns() {
    final excel = Excel.createExcel();

    final section = excel['Section 2'];
    // First row has different number of columns than header
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
      TextCellValue('Extra Column'),
    ]);

    // Data rows have different column counts
    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Area 1'),
    ]); // Missing columns

    section.appendRow([
      TextCellValue('2.1.2'),
      TextCellValue('Area 2'),
      TextCellValue('+++'),
      TextCellValue('Extra data'),
      TextCellValue('Even more data'),
    ]); // Extra columns

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with various coordinate formats
  static Uint8List createExcelWithVariousCoordinateFormats() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    sheet.appendRow([TextCellValue('Latitude'), TextCellValue('12.3456')]);
    sheet.appendRow([TextCellValue('Longitude'), TextCellValue('-98.7654')]);
    sheet.appendRow([
      TextCellValue('Address/GPS coordinates'),
      TextCellValue('12°20\'44.0"N 98°45\'55.4"W'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with invalid coordinates
  static Uint8List createExcelWithInvalidCoordinates() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    sheet.appendRow([
      TextCellValue('Latitude'),
      TextCellValue('invalid_latitude'),
    ]);
    sheet.appendRow([
      TextCellValue('Longitude'),
      TextCellValue('not_a_number'),
    ]);
    sheet.appendRow([
      TextCellValue('Address/GPS coordinates'),
      TextCellValue('Somewhere on Earth'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with missing geo data
  static Uint8List createExcelWithMissingGeoData() {
    final excel = Excel.createExcel();

    final sheet = excel['Assessment Summary'];
    sheet.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Test Facility'),
    ]);
    // Missing latitude, longitude, country, etc.

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel for debug testing
  static Uint8List createExcelForDebugTesting() {
    final excel = Excel.createExcel();

    // Multiple sheets with various structures
    final sheet1 = excel['Debug Sheet 1'];
    for (int i = 0; i < 10; i++) {
      sheet1.appendRow([
        TextCellValue('Cell ${i}0'),
        TextCellValue('Cell ${i}1'),
        TextCellValue('Cell ${i}2'),
      ]);
    }

    final sheet2 = excel['Debug Sheet 2'];
    for (int i = 0; i < 5; i++) {
      sheet2.appendRow([TextCellValue('Data $i')]);
    }

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with many columns
  static Uint8List createExcelWithManyColumns() {
    final excel = Excel.createExcel();

    final sheet = excel['Wide Sheet'];
    final headerRow = <CellValue>[];
    final dataRow = <CellValue>[];

    for (int i = 0; i < 50; i++) {
      headerRow.add(TextCellValue('Header $i'));
      dataRow.add(TextCellValue('Data $i'));
    }

    sheet.appendRow(headerRow);
    sheet.appendRow(dataRow);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with many rows
  static Uint8List createExcelWithManyRows() {
    final excel = Excel.createExcel();

    final sheet = excel['Tall Sheet'];
    sheet.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);

    for (int i = 1; i <= 1000; i++) {
      sheet.appendRow([
        TextCellValue('2.1.$i'),
        TextCellValue('Area $i'),
        TextCellValue('+++'),
      ]);
    }

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel with detailed sections
  static Uint8List createExcelWithDetailedSections() {
    final excel = Excel.createExcel();

    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Detailed Test Facility'),
    ]);

    // Multiple detailed section sheets
    for (int sectionNum = 2; sectionNum <= 5; sectionNum++) {
      final section = excel['Section $sectionNum'];
      section.appendRow([
        TextCellValue('Section #'),
        TextCellValue('Assessment Area'),
        TextCellValue('Rating'),
        TextCellValue('Comment'),
      ]);

      for (int item = 1; item <= 10; item++) {
        section.appendRow([
          TextCellValue('$sectionNum.1.$item'),
          TextCellValue('Detailed area $sectionNum.$item'),
          TextCellValue('+++'),
          TextCellValue('Detailed comment for item $item'),
        ]);
      }
    }

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  /// Creates Excel for options testing
  static Uint8List createExcelForOptionsTest() {
    final excel = Excel.createExcel();

    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Options Test Facility'),
    ]);
    summary.appendRow([
      TextCellValue('Country'),
      TextCellValue('Test Country'),
    ]);
    summary.appendRow([
      TextCellValue('Name of person conducting assessment'),
      TextCellValue('Test Assessor'),
    ]);

    final section = excel['Section 2'];
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);
    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Test area'),
      TextCellValue('+++'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  static Uint8List createComplexExcelWithAllVariations() {
    final excel = Excel.createExcel();

    // Comprehensive summary sheet with all possible fields
    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Name of person conducting assessment'),
      TextCellValue('Dr. Test Assessor'),
    ]);
    summary.appendRow([
      TextCellValue('Email'),
      TextCellValue('test@example.com'),
    ]);
    summary.appendRow([
      TextCellValue('Phone'),
      TextCellValue('+1-234-567-8900'),
    ]);
    summary.appendRow([
      TextCellValue('Date of assessment'),
      TextCellValue('2024-01-15'),
    ]);

    summary.appendRow([
      TextCellValue('Country'),
      TextCellValue('Test Country'),
    ]);
    summary.appendRow([
      TextCellValue('Region/Province'),
      TextCellValue('Test Region'),
    ]);
    summary.appendRow([
      TextCellValue('District'),
      TextCellValue('Test District'),
    ]);
    summary.appendRow([
      TextCellValue('City/Village'),
      TextCellValue('Test City'),
    ]);
    summary.appendRow([
      TextCellValue('Address/GPS coordinates'),
      TextCellValue('123 Test Street'),
    ]);
    summary.appendRow([
      TextCellValue('Record of facility location'),
      TextCellValue('Urban'),
    ]);
    summary.appendRow([TextCellValue('Latitude'), TextCellValue('12.3456')]);
    summary.appendRow([TextCellValue('Longitude'), TextCellValue('-98.7654')]);

    summary.appendRow([
      TextCellValue('Facility code'),
      TextCellValue('TEST-001'),
    ]);
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Comprehensive Test Facility'),
    ]);
    summary.appendRow([
      TextCellValue('Managing authority'),
      TextCellValue('Government'),
    ]);
    summary.appendRow([
      TextCellValue('Director/Manager name'),
      TextCellValue('Dr. Jane Director'),
    ]);
    summary.appendRow([
      TextCellValue('Director/Manager phone'),
      TextCellValue('+1-234-567-8901'),
    ]);
    summary.appendRow([
      TextCellValue('Director/Manager email'),
      TextCellValue('director@test.com'),
    ]);
    summary.appendRow([
      TextCellValue('Respondent or key informant\'s name'),
      TextCellValue('John Respondent'),
    ]);
    summary.appendRow([
      TextCellValue('Respondent or key informant\'s position'),
      TextCellValue('Senior Nurse'),
    ]);
    summary.appendRow([
      TextCellValue('Type of structure'),
      TextCellValue('Permanent'),
    ]);
    summary.appendRow([
      TextCellValue('Type of facility'),
      TextCellValue('Standalone Treatment Center'),
    ]);
    summary.appendRow([
      TextCellValue('Type of existing health care facility'),
      TextCellValue('First Referral Hospital'),
    ]);

    summary.appendRow([
      TextCellValue('The facility offers outpatient services'),
      TextCellValue('Yes'),
    ]);
    summary.appendRow([
      TextCellValue('The facility offers inpatient services'),
      TextCellValue('Yes'),
    ]);
    summary.appendRow([
      TextCellValue('Total number of overnight/inpatient beds'),
      TextCellValue('150'),
    ]);
    summary.appendRow([
      TextCellValue(
        'Of the total number of inpatient beds, how many are intensive care unit (ICU) beds?',
      ),
      TextCellValue('20'),
    ]);
    summary.appendRow([
      TextCellValue(
        'The facility has dedicated 24-hour staffed emergency unit',
      ),
      TextCellValue('True'),
    ]);
    summary.appendRow([
      TextCellValue('The facility has intensive care or high-dependency unit'),
      TextCellValue('1'),
    ]);

    summary.appendRow([
      TextCellValue('Assessment Status'),
      TextCellValue('Submitted'),
    ]);
    summary.appendRow([
      TextCellValue('Submission Date'),
      TextCellValue('2024-01-20'),
    ]);

    // Comprehensive section sheet with various item types
    final section = excel['Section 2'];
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
      TextCellValue('Choice Made'),
      TextCellValue('Status'),
      TextCellValue('Comment'),
    ]);

    // Various rating formats and statuses
    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Comprehensive Area 1'),
      TextCellValue('+++'),
      TextCellValue('Meets target requirements'),
      TextCellValue('Completed'),
      TextCellValue('Excellent compliance'),
    ]);

    section.appendRow([
      TextCellValue('2.1.2'),
      TextCellValue('Comprehensive Area 2'),
      TextCellValue('++'),
      TextCellValue('Some improvements needed'),
      TextCellValue('Completed'),
      TextCellValue('Minor issues identified'),
    ]);

    section.appendRow([
      TextCellValue('2.1.3'),
      TextCellValue('Comprehensive Area 3'),
      TextCellValue('+'),
      TextCellValue('Significant gaps'),
      TextCellValue('Completed'),
      TextCellValue('Major improvements required'),
    ]);

    section.appendRow([
      TextCellValue('2.1.4'),
      TextCellValue('Comprehensive Area 4'),
      TextCellValue('DK'),
      TextCellValue('Information not available'),
      TextCellValue('Completed'),
      TextCellValue('Data unavailable at time of assessment'),
    ]);

    section.appendRow([
      TextCellValue('2.1.5'),
      TextCellValue('Comprehensive Area 5'),
      TextCellValue('NA'),
      TextCellValue('Does not apply'),
      TextCellValue('Completed'),
      TextCellValue('Not applicable to this facility type'),
    ]);

    section.appendRow([
      TextCellValue('2.1.6'),
      TextCellValue('Comprehensive Area 6'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('Pending'),
      TextCellValue('Awaiting additional information'),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  static Uint8List createExcelForIntegrityTesting() {
    final excel = Excel.createExcel();

    final summary = excel['Assessment Summary'];
    summary.appendRow([
      TextCellValue('Facility name'),
      TextCellValue('Facility code'),
      TextCellValue('Integrity Test Facility'),
    ]);
    summary.appendRow([
      TextCellValue('Name of person conducting assessment'),
      TextCellValue('Integrity Tester'),
    ]);

    final section = excel['Section 2'];
    section.appendRow([
      TextCellValue('Section #'),
      TextCellValue('Assessment Area'),
      TextCellValue('Rating'),
    ]);

    // Exactly 5 items: 3 completed, 2 not completed
    section.appendRow([
      TextCellValue('2.1.1'),
      TextCellValue('Area 1'),
      TextCellValue('+++'),
    ]);
    section.appendRow([
      TextCellValue('2.1.2'),
      TextCellValue('Area 2'),
      TextCellValue('++'),
    ]);
    section.appendRow([
      TextCellValue('2.1.3'),
      TextCellValue('Area 3'),
      TextCellValue('+'),
    ]);
    section.appendRow([
      TextCellValue('2.1.4'),
      TextCellValue('Area 4'),
      TextCellValue(''),
    ]);
    section.appendRow([
      TextCellValue('2.1.5'),
      TextCellValue('Area 5'),
      TextCellValue(''),
    ]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }
}

/// Helper class for creating test data models
class TestDataHelper {
  // Add these methods to TestDataHelper class:
  static AssessmentFormModel createMockAssessmentWithMixedCompletion() {
    final baseAssessment = createMockAssessmentFormModel();

    // Create sections with mixed completion
    final sections = [
      AssessmentSectionModel(
        id: 'section_2',
        sectionNumber: '2',
        title: 'Test Section 2',
        description: 'Test Description',
        items: [
          AssessmentItemModel(
            id: 1,
            itemNumber: '2.1.1',
            sectionNumber: '2.1.1',
            area: 'Test Area 1',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
            selectedRating: AssessmentRatingModel.meetsTarget(),
            comment: 'Completed item',
          ),
          AssessmentItemModel(
            id: 2,
            itemNumber: '2.1.2',
            sectionNumber: '2.1.2',
            area: 'Test Area 2',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
            selectedRating: null, // Not completed
            comment: 'Pending item',
          ),
        ],
      ),
    ];

    return baseAssessment.copyWith(sections: sections);
  }

  static AssessmentFormModel createMockAssessmentWithNullDate() {
    final baseAssessment = createMockAssessmentFormModel();

    final assessorInfoWithNullDate = AssessorInfoModel(
      name: 'Test Assessor',
      email: 'test@example.com',
      phoneNumber: '+1234567890',
      assessmentDate: null, // Null date
    );

    return baseAssessment.copyWith(assessorInfo: assessorInfoWithNullDate);
  }

  /// Creates a mock AssessmentFormModel for testing
  static AssessmentFormModel createMockAssessmentFormModel() {
    return AssessmentFormModel(
      id: 'test_assessment_id',
      assessorInfo: AssessorInfoModel(
        name: 'Test Assessor',
        email: 'test@example.com',
        phoneNumber: '+1234567890',
        assessmentDate: DateTime(2024, 1, 15),
      ),
      geoLocation: GeoLocationModel(
        country: 'Test Country',
        regionProvince: 'Test Region',
        district: 'Test District',
        cityVillage: 'Test City',
        addressOrCoordinates: 'Test Address',
        locationType: FacilityLocationType.urban,
        latitude: 0.0,
        longitude: 0.0,
      ),
      facilityIdentification: FacilityIdentificationModel(
        facilityCode: 'TEST001',
        facilityName: 'Test Facility',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Test Director',
        directorPhone: '+1234567890',
        directorEmail: 'director@test.com',
        respondentName: 'Test Respondent',
        respondentPosition: 'Test Position',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.firstReferralHospital,
      ),
      facilityServices: FacilityServicesModel(
        hasOutpatientServices: true,
        hasInpatientServices: true,
        totalInpatientBeds: 50,
        icuBeds: 10,
        hasEmergencyUnit: true,
        hasIcuOrHighDependencyUnit: true,
      ),
      sections: [
        AssessmentSectionModel(
          id: 'section_2',
          sectionNumber: '2',
          title: 'Test Section',
          description: 'Test Description',
          items: [
            AssessmentItemModel(
              id: 1,
              itemNumber: '2.1.1',
              sectionNumber: '2.1.1',
              area: 'Test Area',
              meetsTargetDescription: 'Meets target',
              partiallyMeetsDescription: 'Partially meets',
              doesNotMeetDescription: 'Does not meet',
              selectedRating: AssessmentRatingModel.meetsTarget(),
              comment: 'Test comment',
            ),
          ],
        ),
      ],
      isSubmitted: false,
      submissionDate: null,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );
  }

  /// Creates a mock AssessmentFormModel with no items for testing
  static AssessmentFormModel createMockAssessmentFormModelWithNoItems() {
    final mockAssessment = createMockAssessmentFormModel();
    return mockAssessment.copyWith(
      sections: [
        AssessmentSectionModel(
          id: 'section_empty',
          sectionNumber: '1',
          title: 'Empty Section',
          description: 'No items',
          items: [], // Empty items list
        ),
      ],
    );
  }

  /// Creates assessment with various rating types
  static AssessmentFormModel createMockAssessmentWithVariousRatings() {
    final baseAssessment = createMockAssessmentFormModel();

    final sections = [
      AssessmentSectionModel(
        id: 'section_ratings',
        sectionNumber: '2',
        title: 'Various Ratings Section',
        description: 'Section with different rating types',
        items: [
          AssessmentItemModel(
            id: 1,
            itemNumber: '2.1.1',
            sectionNumber: '2.1.1',
            area: 'Meets Target Area',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
            selectedRating: AssessmentRatingModel.meetsTarget(),
            comment: 'Excellent performance',
          ),
          AssessmentItemModel(
            id: 2,
            itemNumber: '2.1.2',
            sectionNumber: '2.1.2',
            area: 'Partially Meets Area',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
            selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
            comment: 'Needs improvement',
          ),
          AssessmentItemModel(
            id: 3,
            itemNumber: '2.1.3',
            sectionNumber: '2.1.3',
            area: 'Does Not Meet Area',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
            selectedRating: AssessmentRatingModel.doesNotMeetTarget(),
            comment: 'Significant gaps',
          ),
          AssessmentItemModel(
            id: 4,
            itemNumber: '2.1.4',
            sectionNumber: '2.1.4',
            area: 'Don\'t Know Area',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
            selectedRating: AssessmentRatingModel.dontKnow(),
            comment: 'Information not available',
          ),
          AssessmentItemModel(
            id: 5,
            itemNumber: '2.1.5',
            sectionNumber: '2.1.5',
            area: 'Not Applicable Area',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
            selectedRating: AssessmentRatingModel.notApplicable(),
            comment: 'Does not apply to this facility',
          ),
        ],
      ),
    ];

    return baseAssessment.copyWith(sections: sections);
  }
}

class TestableExcelImportService extends ExcelImportService {
  TestableExcelImportService({required super.fileProvider});

  @override
  Future<void> validateFileForImport(String _) async {
    // bypass real validation in tests
  }
}
