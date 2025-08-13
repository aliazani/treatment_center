import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';
import 'package:treatment_center/core/services/doc_export_service.dart';
import 'package:treatment_center/core/services/excel_export_service.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/core/services/pdf_export_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';

import 'export_service_test.mocks.dart';

@GenerateMocks([
  FileProvider,
  FileWrapper,
  AssessmentFormModel,
  FacilityIdentificationEntity,
  AssessmentSectionEntity,
  AssessmentItemEntity,
])
void main() {
  group('ExportResult', () {
    test('should create ExportResult with all required parameters', () {
      final createdAt = DateTime.now();
      final metadata = {'key': 'value'};

      final result = ExportResult(
        filePath: '/path/to/file.pdf',
        fileName: 'test_file.pdf',
        format: 'PDF',
        fileSizeBytes: 1024,
        createdAt: createdAt,
        metadata: metadata,
      );

      expect(result.filePath, '/path/to/file.pdf');
      expect(result.fileName, 'test_file.pdf');
      expect(result.format, 'PDF');
      expect(result.fileSizeBytes, 1024);
      expect(result.createdAt, createdAt);
      expect(result.metadata, metadata);
    });

    test('fileSizeFormatted should format different file sizes correctly', () {
      expect(
        ExportResult(
          filePath: '/path',
          fileName: 'test',
          format: 'PDF',
          fileSizeBytes: 512,
          createdAt: DateTime.now(),
        ).fileSizeFormatted,
        '512 B',
      );

      expect(
        ExportResult(
          filePath: '/path',
          fileName: 'test',
          format: 'PDF',
          fileSizeBytes: 1536,
          createdAt: DateTime.now(),
        ).fileSizeFormatted,
        '1.5 KB',
      );

      expect(
        ExportResult(
          filePath: '/path',
          fileName: 'test',
          format: 'PDF',
          fileSizeBytes: 2097152,
          createdAt: DateTime.now(),
        ).fileSizeFormatted,
        '2.0 MB',
      );
    });

    test('toString should return formatted string', () {
      final result = ExportResult(
        filePath: '/path/to/file.pdf',
        fileName: 'test_file.pdf',
        format: 'PDF',
        fileSizeBytes: 1024,
        createdAt: DateTime.now(),
      );

      expect(
        result.toString(),
        'ExportResult(fileName: test_file.pdf, format: PDF, size: 1.0 KB)',
      );
    });
  });

  group('ExportOptions', () {
    test('should create with default values', () {
      const options = ExportOptions();
      expect(options.includeAnalysis, true);
      expect(options.includeSectionDetails, true);
      expect(options.includeSignaturePage, true);
      expect(options.customTemplate, null);
      expect(options.additionalOptions, null);
    });

    test('toMap should convert to Map correctly', () {
      final options = ExportOptions(
        includeAnalysis: false,
        includeSectionDetails: true,
        includeSignaturePage: false,
        customTemplate: 'template.docx',
        additionalOptions: {'key': 'value'},
      );

      final map = options.toMap();
      expect(map['includeAnalysis'], false);
      expect(map['includeSectionDetails'], true);
      expect(map['includeSignaturePage'], false);
      expect(map['customTemplate'], 'template.docx');
      expect(map['additionalOptions'], {'key': 'value'});
    });

    test('fromMap should create from Map correctly', () {
      final map = {
        'includeAnalysis': false,
        'includeSectionDetails': true,
        'includeSignaturePage': false,
        'customTemplate': 'template.docx',
        'additionalOptions': {'key': 'value'},
      };

      final options = ExportOptions.fromMap(map);
      expect(options.includeAnalysis, false);
      expect(options.includeSectionDetails, true);
      expect(options.includeSignaturePage, false);
      expect(options.customTemplate, 'template.docx');
      expect(options.additionalOptions, {'key': 'value'});
    });

    test('copyWith should update only specified fields', () {
      const original = ExportOptions(
        includeAnalysis: true,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: 'original.docx',
      );

      final updated = original.copyWith(
        includeAnalysis: false,
        customTemplate: 'updated.docx',
      );

      expect(updated.includeAnalysis, false);
      expect(updated.includeSectionDetails, true); // unchanged
      expect(updated.includeSignaturePage, true); // unchanged
      expect(updated.customTemplate, 'updated.docx');
    });
  });

  group('ExportOptions – copyWith edge cases', () {
    test('retains includeAnalysis when not passed', () {
      const original = ExportOptions(
        includeAnalysis: false,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: 'orig.docx',
      );

      // omit includeAnalysis entirely
      final updated = original.copyWith(
        includeSectionDetails: false, // something else, just to call copyWith
      );

      expect(updated.includeAnalysis, false); // unchanged
      expect(updated.includeSectionDetails, false); // updated
      expect(updated.customTemplate, 'orig.docx'); // unchanged
    });

    test('overrides customTemplate when non‑null', () {
      const original = ExportOptions(
        includeAnalysis: true,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: 'orig.docx',
      );

      final updated = original.copyWith(customTemplate: 'new_template.docx');

      expect(updated.customTemplate, 'new_template.docx'); // overridden
      expect(updated.includeAnalysis, true); // unchanged
    });

    test('retains customTemplate when explicitly passing null', () {
      const original = ExportOptions(
        includeAnalysis: true,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: 'orig.docx',
      );

      // passing null should be interpreted as “leave unchanged”
      final updated = original.copyWith(customTemplate: null);

      expect(updated.customTemplate, 'orig.docx'); // unchanged
      expect(updated.includeAnalysis, true); // unchanged
    });
  });

  group('ExportService Abstract Class - Direct Method Tests', () {
    late ConcreteExportService exportService;
    late MockAssessmentFormModel mockAssessment;
    late MockFacilityIdentificationEntity mockFacilityId;
    late MockAssessmentSectionEntity mockSection;
    late MockAssessmentItemEntity mockItem1;
    late MockAssessmentItemEntity mockItem2;

    setUp(() {
      exportService = ConcreteExportService();
      mockAssessment = MockAssessmentFormModel();
      mockFacilityId = MockFacilityIdentificationEntity();
      mockSection = MockAssessmentSectionEntity();
      mockItem1 = MockAssessmentItemEntity();
      mockItem2 = MockAssessmentItemEntity();

      // Setup facility identification
      when(mockAssessment.facilityIdentification).thenReturn(mockFacilityId);
      when(mockFacilityId.facilityCode).thenReturn('FAC123');
      when(mockFacilityId.facilityName).thenReturn('Test Facility');

      when(mockAssessment.totalItems).thenReturn(2); // 2 items overall
      when(mockAssessment.completedItems).thenReturn(1); // 1 completed
    });

    group('getDefaultFileName - Abstract Class Implementation', () {
      test('should generate filename with facility code and timestamp', () {
        // Act
        final fileName = exportService.getDefaultFileName(mockAssessment);

        // Assert
        expect(fileName, contains('FVD_Assessment_FAC123_'));
        expect(fileName, endsWith('.test'));
        expect(fileName, matches(RegExp(r'FVD_Assessment_FAC123_\d+\.test')));
      });

      test('should handle different facility codes', () {
        // Arrange
        when(mockFacilityId.facilityCode).thenReturn('XYZ999');

        // Act
        final fileName = exportService.getDefaultFileName(mockAssessment);

        // Assert
        expect(fileName, contains('FVD_Assessment_XYZ999_'));
        expect(fileName, endsWith('.test'));
      });
    });

    group('getExportStatistics - Abstract Class Implementation', () {
      test('should calculate statistics with sections and items', () {
        // Arrange
        when(mockSection.items).thenReturn([mockItem1, mockItem2]);
        when(mockSection.completedItemsCount).thenReturn(1);
        when(mockAssessment.sections).thenReturn([mockSection]);
        when(mockAssessment.completionPercentage).thenReturn(50.0);
        when(mockAssessment.isSubmitted).thenReturn(true);

        // Act
        final stats = exportService.getExportStatistics(mockAssessment);

        // Assert
        expect(stats['totalSections'], 1);
        expect(stats['totalItems'], 2);
        expect(stats['completedItems'], 1);
        expect(stats['completionRate'], 50.0);
        expect(stats['isSubmitted'], true);
        expect(stats['canExport'], true);
        expect(stats['formatName'], 'Test Format');
        expect(stats['fileExtension'], 'test');
      });

      test('should handle multiple sections', () {
        // Arrange
        final mockItem3 = MockAssessmentItemEntity();

        // Create another section with different values to test multiple sections
        when(mockAssessment.totalItems).thenReturn(3); // 3 items overall
        when(mockAssessment.completedItems).thenReturn(2); // 2 completed

        final mockSection2 = MockAssessmentSectionEntity();
        when(mockSection2.items).thenReturn([mockItem3]);
        when(mockSection2.completedItemsCount).thenReturn(0);

        when(mockSection.items).thenReturn([mockItem1, mockItem2]);
        when(mockSection.completedItemsCount).thenReturn(2);
        when(mockAssessment.sections).thenReturn([mockSection, mockSection2]);
        when(mockAssessment.completionPercentage).thenReturn(66.7);
        when(mockAssessment.isSubmitted).thenReturn(false);

        // Act
        final stats = exportService.getExportStatistics(mockAssessment);

        // Assert
        expect(stats['totalSections'], 2);
        expect(stats['totalItems'], 3);
        expect(stats['completedItems'], 2);
        expect(stats['completionRate'], 66.7);
        expect(stats['canExport'], true);
      });
    });
  });

  group('BaseExportService - Real validateExportedFile Implementation', () {
    late RealBaseExportService baseService;
    late MockFileProvider mockProvider;

    setUp(() {
      mockProvider = MockFileProvider();

      when(mockProvider.getFile(any)).thenAnswer((invocation) async {
        final path = invocation.positionalArguments.first as String;

        // create a single wrapper per call and wire it up to the real File API
        final wrapper = MockFileWrapper();
        when(wrapper.path).thenReturn(path);
        when(wrapper.exists()).thenAnswer((_) async => File(path).existsSync());
        when(wrapper.length()).thenAnswer(
          (_) async => File(path).existsSync() ? File(path).lengthSync() : 0,
        );
        return wrapper;
      });

      baseService = RealBaseExportService(fileProvider: mockProvider);
    });

    group('validateExportedFile - Real File() Implementation', () {
      test('should throw FileException when file does not exist', () async {
        // Arrange
        const nonExistentPath = '/non/existent/file.pdf';

        // Act & Assert
        expect(
          () async => await baseService.validateExportedFile(nonExistentPath),
          throwsA(
            isA<FileException>().having(
              (e) => e.message,
              'message',
              contains('File was not created'),
            ),
          ),
        );
      });

      test(
        'should throw FileException when file exists but is empty',
        () async {
          // Arrange - Create an empty temporary file
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/empty_test_file.tmp');

          try {
            await tempFile.create();

            // Act & Assert
            expect(
              () async => await baseService.validateExportedFile(tempFile.path),
              throwsA(
                isA<FileException>().having(
                  (e) => e.message,
                  'message',
                  contains('File is empty'),
                ),
              ),
            );
          } finally {
            // Cleanup
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          }
        },
      );

      test('should pass validation when file exists and has content', () async {
        // Arrange - Create a temporary file with content
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/valid_test_file.tmp');

        try {
          await tempFile.writeAsString('Test content');

          // Act & Assert - Should not throw
          await baseService.validateExportedFile(tempFile.path);

          // If we reach here, the test passed
          expect(true, true);
        } finally {
          // Cleanup
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      });
    });
  });

  group('BaseExportService – getRatingText()', () {
    final helper = TestHelperService(fileProvider: MockFileProvider());

    test('returns correct string for every rating value', () {
      expect(helper.getRatingText(MockRatingValue(3)), '+++ (3) Meets target');
      expect(
        helper.getRatingText(MockRatingValue(2)),
        '++ (2) Partially meets target',
      );
      expect(
        helper.getRatingText(MockRatingValue(1)),
        '+ (1) Does not meet target',
      );
      expect(helper.getRatingText(MockRatingValue(0)), "DK - Don't Know");
      expect(
        helper.getRatingText(MockRatingValue(-1)),
        'NA - Not Applicable',
      ); // <–– line ❸
      expect(helper.getRatingText(MockRatingValue(99)), 'Unknown');
      expect(helper.getRatingText(null), 'Not Rated'); // null safety
    });
  });

  group('ExportServiceFactory – concrete implementations', () {
    test('returns PdfExportService for "pdf"', () {
      final service = ExportServiceFactory.createExportService('pdf');
      expect(service, isA<PdfExportService>());
    });

    test('returns ExcelExportService for "xlsx"', () {
      final service = ExportServiceFactory.createExportService('xlsx');
      expect(service, isA<ExcelExportService>());
    });

    test('returns DocExportService for "doc"', () {
      final service = ExportServiceFactory.createExportService('doc');
      expect(service, isA<DocExportService>());
    });
    test('returns DocExportService for "docx"', () {
      final service = ExportServiceFactory.createExportService('docx');
      expect(service, isA<DocExportService>());
    });
  });

  group('ExportServiceFactory – getFormatInfo()', () {
    test('maps out extension / name / mimeType for a known format', () {
      final info = ExportServiceFactory.getFormatInfo('pdf');
      expect(info, containsPair('extension', 'pdf'));
      expect(info['name'], isNotEmpty);
      expect(info['mimeType'], startsWith('application/'));
    });
  });

  group('ExportServiceFactory - Essential Coverage', () {
    test('getSupportedFormats should return all supported formats', () {
      final formats = ExportServiceFactory.getSupportedFormats();
      expect(formats, contains('pdf'));
      expect(formats, contains('xlsx'));
      expect(formats, contains('excel'));
      expect(formats, contains('docx'));
      expect(formats, contains('doc'));
      expect(formats.length, 5);
    });

    test('isFormatSupported should return correct values', () {
      expect(ExportServiceFactory.isFormatSupported('pdf'), true);
      expect(ExportServiceFactory.isFormatSupported('txt'), false);
    });

    test('should throw ValidationException for unsupported format', () {
      expect(
        () => ExportServiceFactory.createExportService('unsupported'),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}

/// Concrete implementation to test abstract class methods directly
class ConcreteExportService extends ExportService {
  @override
  String get fileExtension => 'test';

  @override
  String get formatName => 'Test Format';

  @override
  String get mimeType => 'application/test';

  @override
  Future<ExportResult> exportAssessment(
    AssessmentFormModel assessment, {
    String? outputPath,
    ExportOptions? options,
  }) async {
    throw UnimplementedError('Not needed for abstract method testing');
  }

  @override
  void validateForExport(AssessmentFormModel assessment) {
    // Not needed for abstract method testing
  }

  // These methods are automatically inherited from ExportService abstract class
  // No need to implement them since they have concrete implementations in the abstract class
}

/// Real BaseExportService implementation to test actual validateExportedFile
class RealBaseExportService extends BaseExportService {
  RealBaseExportService({required super.fileProvider});

  @override
  String get fileExtension => 'test';

  @override
  String get formatName => 'Test Format';

  @override
  String get mimeType => 'application/test';

  @override
  Future<ExportResult> exportAssessment(
    AssessmentFormModel assessment, {
    String? outputPath,
    ExportOptions? options,
  }) async {
    throw UnimplementedError('Not needed for validateExportedFile testing');
  }

  // validateExportedFile() is inherited from BaseExportService and uses File() directly
}

/// Test service to expose helper methods from BaseExportService
class TestHelperService extends BaseExportService {
  TestHelperService({required super.fileProvider});

  @override
  String get fileExtension => 'test';

  @override
  String get formatName => 'Test Format';

  @override
  String get mimeType => 'application/test';

  @override
  Future<ExportResult> exportAssessment(
    AssessmentFormModel assessment, {
    String? outputPath,
    ExportOptions? options,
  }) async {
    throw UnimplementedError('Not needed for helper method testing');
  }
}

/// Mock classes for testing rating values
class MockRatingValue {
  final int value;
  MockRatingValue(this.value);
}
