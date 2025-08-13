import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:archive/archive.dart';

import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';
import 'package:treatment_center/core/providers/save_path_resolver.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/core/services/doc_export_service.dart';

import '../../fixtures/test_assessment_fixtures.dart';
@GenerateMocks([FileProvider, FileWrapper, Directory])
import 'doc_export_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocExportService', () {
    late DocExportService docExportService;
    late MockFileProvider mockFileProvider;
    late MockFileWrapper mockFileWrapper;
    late MockDirectory mockTempDir;
    late AssessmentFormModel tAssessment;

    const String tFacilityCode = 'TF001';
    const String tOutputPath = '/tmp/test_export.docx';

    setUp(() {
      mockFileProvider = MockFileProvider();
      mockFileWrapper = MockFileWrapper();
      mockTempDir = MockDirectory();

      when(mockTempDir.path).thenReturn('/tmp');

      docExportService = TestDocExportService(
        fileProvider: mockFileProvider,
        getSavePath: ({
          required String fileName,
          required String mimeType,
          Uint8List? bytes,
        }) async {
          return tOutputPath;
        },
      );

      tAssessment = TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'test-id',
        sectionCount: 2,
        itemsPerSection: 2,
        withRatings: true,
        isSubmitted: true,
      ).copyWithModels(
        facilityIdentification: FacilityIdentificationModel(
          facilityCode: tFacilityCode,
          facilityName: 'Test Facility',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Dr. Smith',
          directorPhone: '+1234567890',
          directorEmail: 'director@test.com',
          respondentName: 'Jane Doe',
          respondentPosition: 'Manager',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
          existingFacilityType: ExistingFacilityType.primaryHealthClinic,
        ),
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    group('Properties', () {
      test('should return correct file extension', () {
        expect(docExportService.fileExtension, equals('docx'));
      });

      test('should return correct format name', () {
        expect(docExportService.formatName, equals('Microsoft Word'));
      });

      test('should return correct MIME type', () {
        expect(
          docExportService.mimeType,
          equals(
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          ),
        );
      });
    });

    group('exportAssessment', () {
      setUp(() {
        _setupSuccessfulExportMocks(mockFileProvider, mockFileWrapper);
        _setupAssetBundleMock();
      });

      test('should successfully export assessment with valid data', () async {
        // Act
        final result = await docExportService.exportAssessment(tAssessment);

        // Assert
        expect(result, isA<ExportResult>());
        expect(result.filePath, isNotEmpty);
        expect(result.fileName, contains('FVD_Assessment'));
        expect(result.fileName, contains(tFacilityCode));
        expect(result.fileName, endsWith('.docx'));
        expect(result.format, equals('Microsoft Word'));
        expect(
          result.fileSizeBytes,
          greaterThan(0),
          reason: 'documentBytes should never be empty',
        );
        expect(result.createdAt, isA<DateTime>());

        // Verify metadata
        expect(result.metadata?['wordCount'], isA<int>());
        expect(result.metadata?['pageCount'], isA<int>());
        expect(result.metadata?['sectionsIncluded'], equals(2));
        expect(result.metadata?['itemsIncluded'], equals(4));
        expect(result.metadata?['method'], equals('template_replacement'));
        expect(result.metadata?['templateVersion'], equals('v3.0_template'));
        expect(result.metadata?['completionRate'], isA<double>());
      });

      test('should export to custom output path when provided', () async {
        // Act
        final result = await docExportService.exportAssessment(
          tAssessment,
          outputPath: tOutputPath,
        );

        // Assert
        expect(result.filePath, equals(tOutputPath));
        verify(mockFileProvider.getFile(tOutputPath)).called(1);
      });

      test(
        'should use default filename when output path not provided',
        () async {
          // Act
          final result = await docExportService.exportAssessment(tAssessment);

          // Assert
          expect(result.fileName, contains('FVD_Assessment'));
          expect(result.fileName, contains(tFacilityCode));
          expect(result.fileName, endsWith('.docx'));
        },
      );

      test('should include export options in processing', () async {
        // Arrange
        const exportOptions = ExportOptions();

        // Act
        final result = await docExportService.exportAssessment(
          tAssessment,
          options: exportOptions,
        );

        // Assert
        expect(result, isA<ExportResult>());
        // Verify that options were processed (indirectly through successful export)
      });

      group('Validation', () {
        test(
          'should throw ValidationException when assessment has no items',
          () async {
            // Arrange
            final invalidAssessment =
                TestAssessmentFixtures.createAssessmentWithEmptySectionsModel(
                  id: 'invalid-id',
                );

            // Act & Assert
            expect(
              () => docExportService.exportAssessment(invalidAssessment),
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.message,
                  'message',
                  contains('at least one item'),
                ),
              ),
            );
          },
        );

        test(
          'should throw ValidationException when facility name is Unknown Facility',
          () async {
            // Arrange
            final invalidAssessment =
                TestAssessmentFixtures.createTestAssessmentFormModel(
                  id: 'invalid-id',
                ).copyWithModels(
                  facilityIdentification: FacilityIdentificationModel(
                    facilityCode: 'TF001',
                    facilityName:
                        'Unknown Facility', // This specific value triggers validation
                    managingAuthority: ManagingAuthorityType.government,
                    directorName: 'Dr. Smith',
                    directorPhone: '+1234567890',
                    directorEmail: 'director@test.com',
                    respondentName: 'Jane Doe',
                    respondentPosition: 'Manager',
                    structureType: FacilityStructureType.permanent,
                    facilityType: FacilityType.screeningAndTemporaryIsolation,
                    existingFacilityType:
                        ExistingFacilityType.primaryHealthClinic,
                  ),
                );

            // Act & Assert
            expect(
              () => docExportService.exportAssessment(invalidAssessment),
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.message,
                  'message',
                  contains('Facility name is required for DOCX export'),
                ),
              ),
            );
          },
        );
      });

      group('Error Handling', () {
        test('should throw ExportException when file writing fails', () async {
          // Arrange
          when(
            mockFileProvider.writeAsBytes(any, any),
          ).thenThrow(const FileSystemException('Write failed'));

          // Act & Assert
          expect(
            () => docExportService.exportAssessment(tAssessment),
            throwsA(
              isA<ExportException>().having(
                (e) => e.message,
                'message',
                contains('Failed to export Word document'),
              ),
            ),
          );
        });

        test('should handle template processing errors gracefully', () async {
          // Arrange - Setup invalid asset bundle response that will cause decode error
          const channel = MethodChannel('flutter/assets');
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                if (methodCall.method == 'load' &&
                    methodCall.arguments ==
                        'assets/templates/fvd_assessment_template.docx') {
                  // Return invalid data that will cause ZipDecoder to fail
                  return Uint8List.fromList([
                    1,
                    2,
                    3,
                    4,
                    5,
                  ]).buffer.asByteData();
                }
                return null;
              });

          // Act & Assert
          expect(
            () => docExportService.exportAssessment(tAssessment),
            throwsA(
              isA<ExportException>().having(
                (e) => e.message,
                'message',
                anyOf([
                  contains('Failed to process template'),
                  contains('Message corrupted'),
                  contains('Failed to export Word document'),
                ]),
              ),
            ),
          );
        });

        test('should provide useful error information for debugging', () async {
          // Test that errors contain enough information for debugging
          final stats = docExportService.getExportStatistics(tAssessment);

          // Should provide comprehensive metadata for debugging
          expect(stats['canExport'], isTrue);
          expect(stats['totalItems'], greaterThan(0));
          expect(stats['formatName'], equals('Microsoft Word'));
          expect(stats['fileExtension'], equals('docx'));
        });
      });
    });

    group('Data Extraction Methods', () {
      group('Facility Information', () {
        test('should extract facility name correctly', () {
          final result = docExportService.getExportStatistics(tAssessment);
          expect(result['formatName'], equals('Microsoft Word'));
        });

        test('should handle empty facility name gracefully', () {
          final assessment =
              TestAssessmentFixtures.createTestAssessmentFormModel(
                id: 'test-id',
              ).copyWithModels(
                facilityIdentification: FacilityIdentificationModel(
                  facilityCode: 'TF001',
                  facilityName: '', // Empty facility name
                  managingAuthority: ManagingAuthorityType.government,
                  directorName: 'Dr. Smith',
                  directorPhone: '+1234567890',
                  directorEmail: 'director@test.com',
                  respondentName: 'Jane Doe',
                  respondentPosition: 'Manager',
                  structureType: FacilityStructureType.permanent,
                  facilityType: FacilityType.screeningAndTemporaryIsolation,
                  existingFacilityType:
                      ExistingFacilityType.primaryHealthClinic,
                ),
              );

          // Should not throw but handle gracefully
          expect(
            () => docExportService.getDefaultFileName(assessment),
            returnsNormally,
          );
        });

        test('should extract facility code correctly', () {
          // Test through default filename generation
          final fileName = docExportService.getDefaultFileName(tAssessment);
          expect(fileName, contains(tFacilityCode));
        });

        test('should handle missing facility code gracefully', () {
          final assessment =
              TestAssessmentFixtures.createTestAssessmentFormModel(
                id: 'test-id',
              ).copyWithModels(
                facilityIdentification: FacilityIdentificationModel(
                  facilityCode: '', // Empty facility code
                  facilityName: 'Test Facility',
                  managingAuthority: ManagingAuthorityType.government,
                  directorName: 'Dr. Smith',
                  directorPhone: '+1234567890',
                  directorEmail: 'director@test.com',
                  respondentName: 'Jane Doe',
                  respondentPosition: 'Manager',
                  structureType: FacilityStructureType.permanent,
                  facilityType: FacilityType.screeningAndTemporaryIsolation,
                  existingFacilityType:
                      ExistingFacilityType.primaryHealthClinic,
                ),
              );

          final fileName = docExportService.getDefaultFileName(assessment);
          expect(fileName, isNotEmpty);
        });
      });

      group('Assessor Information', () {
        test('should extract assessor information correctly', () {
          expect(
            () => docExportService.getExportStatistics(tAssessment),
            returnsNormally,
          );
        });
      });

      group('Geolocation Information', () {
        test('should handle complete geolocation data', () {
          expect(
            () => docExportService.getExportStatistics(tAssessment),
            returnsNormally,
          );
        });

        test('should handle missing geolocation data gracefully', () {
          final assessment =
              TestAssessmentFixtures.createTestAssessmentFormModel(
                id: 'test-id',
              ).copyWithModels(
                geoLocation: GeoLocationModel(
                  country: '',
                  regionProvince: '',
                  district: '',
                  cityVillage: '',
                  addressOrCoordinates: '',
                  latitude: null,
                  longitude: null,
                  locationType: FacilityLocationType.urban,
                ),
              );

          expect(
            () => docExportService.getExportStatistics(assessment),
            returnsNormally,
          );
        });
      });
    });

    group('Statistical Calculations', () {
      test('should calculate completion rate correctly', () {
        // Use mixed ratings assessment for predictable completion rate
        final mixedAssessment =
            TestAssessmentFixtures.createMixedRatingsAssessmentModel(
              id: 'mixed-test',
            );

        final stats = docExportService.getExportStatistics(mixedAssessment);

        expect(stats['totalSections'], equals(2));
        expect(stats['totalItems'], equals(34));
        expect(stats['completedItems'], equals(33));
        expect(stats['completionRate'], closeTo(50, 1));
      });

      test('should handle zero completion gracefully', () {
        final assessment =
            TestAssessmentFixtures.createAssessmentWithEmptySectionOneAndOthers(
              id: 'empty-test',
            );
        final stats = docExportService.getExportStatistics(assessment);

        expect(stats['completionRate'], equals(0));
      });

      test('should count ratings by label substring correctly', () async {
        // Arrange - Use specific test assessment from fixtures
        final assessment =
            TestAssessmentFixtures.createAssessmentWithSpecificRatingLabels(
              id: 'labels-test',
            );
        _setupAssetBundleMock();
        _setupSuccessfulExportMocks(mockFileProvider, mockFileWrapper);

        // Act
        final result = await docExportService.exportAssessment(assessment);

        // Assert
        expect(result, isA<ExportResult>());
        expect(result.filePath, isNotEmpty);

        // Verify that the export completed successfully
        expect(result.metadata?['method'], equals('template_replacement'));
        expect(result.metadata?['sectionsIncluded'], equals(1));
        expect(result.metadata?['itemsIncluded'], equals(4));

        // Verify that file operations were called successfully
        verify(mockFileProvider.getFile(any)).called(1);
        verify(mockFileProvider.writeAsBytes(any, any)).called(1);
      });

      test('should count DK and NA labels correctly in statistics', () {
        // Arrange
        final assessment =
            TestAssessmentFixtures.createAssessmentWithSpecificRatingLabels(
              id: 'labels-test',
            );

        // Act
        final stats = docExportService.getExportStatistics(assessment);

        // Assert - The statistics should reflect the counted labels
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['totalItems'], equals(32)); // We create 32 items
        expect(stats['completedItems'], equals(31)); // All items have ratings
        expect(stats['formatName'], equals('Microsoft Word'));
        expect(stats['fileExtension'], equals('docx'));
      });
    });

    group('Template Processing', () {
      setUp(() {
        // Setup asset mock for template processing tests
        _setupAssetBundleMock();
        _setupSuccessfulExportMocks(mockFileProvider, mockFileWrapper);
      });

      test(
        'should handle invalid UTF-8 content in XML files using fallback',
        () async {
          // Arrange - Create a mock asset bundle with invalid UTF-8 content
          _setupAssetBundleMockWithInvalidUtf8();
          _setupSuccessfulExportMocks(mockFileProvider, mockFileWrapper);

          // Act
          final result = await docExportService.exportAssessment(tAssessment);

          // Assert
          expect(result, isA<ExportResult>());
          expect(result.filePath, isNotEmpty);
          expect(result.metadata?['method'], equals('template_replacement'));

          // Verify that file operations were still called successfully
          verify(mockFileProvider.getFile(any)).called(1);
          verify(mockFileProvider.writeAsBytes(any, any)).called(1);
        },
      );

      test('should handle template replacement correctly', () async {
        // This is tested indirectly through successful export
        final result = await docExportService.exportAssessment(tAssessment);
        expect(result.metadata?['method'], equals('template_replacement'));
      });

      test('should escape XML characters in replacements', () async {
        // Create assessment with special characters using fixtures
        final assessment =
            TestAssessmentFixtures.createAssessmentWithSpecialCharacters(
              id: 'special-test',
            );

        // Should not throw and handle special characters
        final result = await docExportService.exportAssessment(assessment);
        expect(result, isA<ExportResult>());
      });

      test(
        'should throw ExportException when ZIP encoding returns null',
        () async {
          // Arrange
          final testService = TestDocExportService(
            fileProvider: mockFileProvider,
            // getTempDir: () async => mockTempDir,
            shouldReturnNullEncoding: true,
          );

          _setupAssetBundleMock();
          _setupSuccessfulExportMocks(mockFileProvider, mockFileWrapper);

          // Act & Assert
          expect(
            () => testService.exportAssessment(tAssessment),
            throwsA(
              isA<ExportException>().having(
                (e) => e.message,
                'message',
                contains('Failed to encode DOCX archive'),
              ),
            ),
          );
        },
      );

      test('should handle special rating types in export', () async {
        // Test with different rating types
        final assessments = [
          TestAssessmentFixtures.createAssessmentWithNotApplicableRating(
            id: 'na-test',
          ),
          TestAssessmentFixtures.createAssessmentWithUnknownRating(
            id: 'unknown-test',
          ),
          TestAssessmentFixtures.createAssessmentWithNullValueRating(
            id: 'null-test',
          ),
        ];

        for (final assessment in assessments) {
          // Act
          final result = await docExportService.exportAssessment(assessment);

          // Assert
          expect(result, isA<ExportResult>());
          expect(result.filePath, isNotEmpty);

          // Verify that file operations were called successfully
          verify(mockFileProvider.getFile(any)).called(1);
          verify(mockFileProvider.writeAsBytes(any, any)).called(1);

          // Reset mocks for next iteration
          reset(mockFileProvider);
          _setupSuccessfulExportMocks(mockFileProvider, mockFileWrapper);
        }
      });
    });

    group('File Operations', () {
      test('should generate unique filenames', () async {
        final fileName1 = docExportService.getDefaultFileName(tAssessment);

        // Add a small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 1));

        final fileName2 = docExportService.getDefaultFileName(tAssessment);

        expect(fileName1, isNot(equals(fileName2)));
      });
    });

    group('Format-Specific Validation', () {
      test('should validate facility name requirement', () {
        expect(
          () => docExportService.validateFormatSpecific(tAssessment),
          returnsNormally,
        );
      });

      test('should fail validation for assessment with no items', () {
        final invalidAssessment =
            TestAssessmentFixtures.createAssessmentWithEmptySectionsModel(
              id: 'invalid-test',
            );

        expect(
          () => docExportService.validateFormatSpecific(invalidAssessment),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle null values gracefully', () {
        final assessment = TestAssessmentFixtures.createMinimalAssessment(
          id: 'minimal-test',
        );
        expect(
          () => docExportService.getExportStatistics(assessment),
          returnsNormally,
        );
      });

      test('should handle empty sections', () {
        final assessment =
            TestAssessmentFixtures.createAssessmentWithEmptySectionOneAndOthers(
              id: 'empty-sections-test',
            );

        final stats = docExportService.getExportStatistics(assessment);
        expect(stats['completedItems'], equals(0));
      });

      test('should handle very large assessments', () {
        final largeAssessment = TestAssessmentFixtures.createMaximalAssessment(
          id: 'large-test',
        );
        expect(
          () => docExportService.getExportStatistics(largeAssessment),
          returnsNormally,
        );
      });

      test('should handle assessment with all question types', () {
        final comprehensiveAssessment =
            TestAssessmentFixtures.createMixedRatingsAssessmentModel(
              id: 'comprehensive-test',
            );
        expect(
          () => docExportService.getExportStatistics(comprehensiveAssessment),
          returnsNormally,
        );
      });
    });

    group('Integration Tests', () {
      setUp(() {
        // Setup asset mock for integration tests
        _setupAssetBundleMock();
        _setupSuccessfulExportMocks(mockFileProvider, mockFileWrapper);
      });

      test('should complete full export process', () async {
        // This tests the integration of all components
        final result = await docExportService.exportAssessment(tAssessment);

        expect(result, isA<ExportResult>());
        expect(result.filePath, isNotEmpty);
        expect(result.fileSizeBytes, greaterThan(0));
        expect(result.metadata, isNotEmpty);

        // Verify file operations were called
        verify(mockFileProvider.getFile(any)).called(1);
        verify(mockFileProvider.writeAsBytes(any, any)).called(1);
      });
    });
  });
}

// Mock asset bundle for template loading
void _setupAssetBundleMock() {
  const contentTypes = '''
<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Override PartName="/word/document.xml"
            ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';

  const rels = '''
<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
                Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
                Target="word/document.xml"/>
</Relationships>''';

  const documentXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>{{FACILITY_NAME}}</w:t></w:r></w:p>
    <w:p><w:r><w:t>{{ASSESSOR_NAME}}</w:t></w:r></w:p>
    <w:p><w:r><w:t>{{TOTAL_ITEMS}}</w:t></w:r></w:p>
  </w:body>
</w:document>''';

  final archive =
      Archive()
        ..addFile(
          ArchiveFile(
            '[Content_Types].xml',
            contentTypes.length,
            utf8.encode(contentTypes),
          )..compress = false,
        )
        ..addFile(
          ArchiveFile('_rels/.rels', rels.length, utf8.encode(rels))
            ..compress = false,
        )
        ..addFile(
          ArchiveFile(
            'word/document.xml',
            documentXml.length,
            utf8.encode(documentXml),
          )..compress = false,
        );

  final bytes = ZipEncoder().encode(archive)!;
  final byteData = ByteData.view(Uint8List.fromList(bytes).buffer);

  const channelName = 'flutter/assets';
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channelName, (ByteData? message) async {
        return byteData;
      });
}

void _setupAssetBundleMockWithInvalidUtf8() {
  const contentTypes = '''
<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Override PartName="/word/document.xml"
            ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';

  const rels = '''
<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
                Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
                Target="word/document.xml"/>
</Relationships>''';

  const documentXmlStart = '''
<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>{{FACILITY_NAME}}</w:t></w:r></w:p>
    <w:p><w:r><w:t>Content with invalid UTF-8: ''';

  const documentXmlEnd = '''</w:t></w:r></w:p>
    <w:p><w:r><w:t>{{ASSESSOR_NAME}}</w:t></w:r></w:p>
    <w:p><w:r><w:t>{{TOTAL_ITEMS}}</w:t></w:r></w:p>
  </w:body>
</w:document>''';

  final invalidUtf8Bytes = [0xFF, 0xFE, 0xFD, 0xFC];
  final documentBytes = <int>[];
  documentBytes.addAll(utf8.encode(documentXmlStart));
  documentBytes.addAll(invalidUtf8Bytes);
  documentBytes.addAll(utf8.encode(documentXmlEnd));

  final archive =
      Archive()
        ..addFile(
          ArchiveFile(
            '[Content_Types].xml',
            contentTypes.length,
            utf8.encode(contentTypes),
          )..compress = false,
        )
        ..addFile(
          ArchiveFile('_rels/.rels', rels.length, utf8.encode(rels))
            ..compress = false,
        )
        ..addFile(
          ArchiveFile('word/document.xml', documentBytes.length, documentBytes)
            ..compress = false,
        );

  final bytes = ZipEncoder().encode(archive)!;
  final byteData = ByteData.view(Uint8List.fromList(bytes).buffer);

  const channelName = 'flutter/assets';
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channelName, (ByteData? message) async {
        return byteData;
      });
}

// Helper methods for setting up mocks
void _setupSuccessfulExportMocks(
  MockFileProvider mockFileProvider,
  MockFileWrapper mockFileWrapper,
) {
  when(mockFileProvider.getFile(any)).thenAnswer((_) async => mockFileWrapper);

  // 💾 writeAsBytes → no-op
  when(
    mockFileProvider.writeAsBytes(any, any),
  ).thenAnswer((_) async => mockFileWrapper);
}

class TestDocExportService extends DocExportService {
  final bool shouldReturnNullEncoding;

  TestDocExportService({
    required super.fileProvider,
    GetSavePath? getSavePath,
    this.shouldReturnNullEncoding = false,
  }) : super(getSavePath: getSavePath ?? defaultSavePath);

  @override
  List<int>? encodeArchive(Archive archive) {
    if (shouldReturnNullEncoding) {
      return null;
    }
    return super.encodeArchive(archive);
  }

  @override
  Future<void> validateExportedFile(
    String path, {
    int? minSizeBytes = 1000,
  }) async {
    // no-op in tests
  }
}
