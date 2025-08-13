import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';
import 'package:treatment_center/core/services/excel_import_service.dart';
import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';

import 'import_service_test.mocks.dart';

@GenerateMocks([
  FileProvider,
  FileWrapper,
  AssessmentFormModel,
  FacilityIdentificationEntity,
  AssessorInfoEntity,
  AssessmentSectionEntity,
])
void main() {
  final sl = GetIt.instance;
  provideDummy<FileSystemEntityType>(FileSystemEntityType.file);

  group('ImportedAssessmentForm', () {
    test('should create with all fields', () {
      final now = DateTime.now();
      final dto = ImportedAssessmentForm(
        assessment: MockAssessmentFormModel(),
        filePath: '/tmp/test.xlsx',
        format: 'XLSX',
        importedAt: now,
        metadata: {'foo': 'bar'},
      );
      expect(dto.assessment, isA<AssessmentFormModel>());
      expect(dto.filePath, '/tmp/test.xlsx');
      expect(dto.format, 'XLSX');
      expect(dto.importedAt, now);
      expect(dto.metadata, {'foo': 'bar'});
    });

    test('props should include all fields', () {
      final now = DateTime.now();
      final dto = ImportedAssessmentForm(
        assessment: MockAssessmentFormModel(),
        filePath: 'a',
        format: 'b',
        importedAt: now,
      );
      expect(dto.props, [dto.assessment, 'a', 'b', now, null]);
    });
  });

  group('ImportOptions', () {
    test('defaults are correct', () {
      const opts = ImportOptions();
      expect(opts.importSectionDetails, true);
      expect(opts.validateAfterImport, true);
      expect(opts.preserveExistingData, false);
      expect(opts.customMappings, null);
    });

    test('props should include all values', () {
      const custom = {'x': 1};
      const opts = ImportOptions(
        importSectionDetails: false,
        validateAfterImport: false,
        preserveExistingData: true,
        customMappings: custom,
      );
      expect(opts.props, [false, false, true, custom]);
    });
  });

  group('ImportValidator', () {
    const validExts = ['xlsx'];

    test('isValidFileFormat returns true for supported extension', () {
      expect(ImportValidator.isValidFileFormat('foo.xlsx', validExts), true);
      expect(ImportValidator.isValidFileFormat('foo.XLSX', validExts), true);
      expect(ImportValidator.isValidFileFormat('foo.doc', validExts), false);
    });

    test('getFileExtension returns lowercase extension', () {
      expect(ImportValidator.getFileExtension('a.BcD'), 'bcd');
      expect(ImportValidator.getFileExtension('noext'), 'noext');
    });

    test('isValidMimeType matches ignoring case', () {
      const mimes = ['a/B', 'C/D'];
      expect(ImportValidator.isValidMimeType('a/b', mimes), true);
      expect(ImportValidator.isValidMimeType('c/d', mimes), true);
      expect(ImportValidator.isValidMimeType('x/y', mimes), false);
    });

    test('isValidFileSize false if file missing, size ok if exists', () async {
      final provider = MockFileProvider();
      final wrapper = MockFileWrapper();

      // wire up your provider
      when(provider.getFile(any)).thenAnswer((_) async => wrapper);

      // 1) file missing
      when(wrapper.exists()).thenAnswer((_) async => false);
      expect(
        await ImportValidator.isValidFileSize(
          'some/path.xlsx',
          fileProvider: provider,
        ),
        isFalse,
      );

      // 2) file exists & non-zero length => true
      when(wrapper.exists()).thenAnswer((_) async => true);
      when(wrapper.length()).thenAnswer((_) async => 123);
      expect(
        await ImportValidator.isValidFileSize(
          'some/path.xlsx',
          fileProvider: provider,
        ),
        isTrue,
      );
    });
  });

  group('BaseImportService.validateFileForImport', () {
    late BaseImportService service;
    late MockFileProvider mockProvider;
    late MockFileWrapper mockFileWrapper;

    setUp(() {
      mockProvider = MockFileProvider();
      mockFileWrapper = MockFileWrapper();
      service = ExcelImportService(fileProvider: mockProvider);

      // ensure any factory lookup also sees our mockProvider
      sl.registerSingleton<FileProvider>(mockProvider);

      // stub getFile to return our mockFile for any path
      when(mockProvider.getFile(any)).thenAnswer((_) async => mockFileWrapper);
    });

    tearDown(() {
      sl.reset();
    });

    test('throws if file does not exist', () async {
      when(mockFileWrapper.exists()).thenAnswer((_) async => false);
      await expectLater(
        service.validateFileForImport('path.xlsx'),
        throwsA(isA<FileException>()),
      );
    });

    test('throws if file too large', () async {
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      when(mockFileWrapper.length()).thenAnswer((_) async => 60 * 1024 * 1024);
      expect(
        () async => await service.validateFileForImport('f.xlsx'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws if file empty', () async {
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      when(mockFileWrapper.length()).thenAnswer((_) async => 0);

      expect(
        () async => await service.validateFileForImport('f.xlsx'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws if extension unsupported', () async {
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      when(mockFileWrapper.length()).thenAnswer((_) async => 10 * 1024);
      when(mockFileWrapper.path).thenReturn('f.csv');

      expect(
        () async => await service.validateFileForImport('f.csv'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('passes for valid xlsx file', () async {
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      when(mockFileWrapper.length()).thenAnswer((_) async => 10 * 1024);
      when(mockFileWrapper.path).thenReturn('f.xlsx');

      await service.validateFileForImport('data.xlsx');
    });
  });

  group('ImportServiceFactory', () {
    final mockProvider = MockFileProvider();

    setUp(() {
      // register for factory
      sl.registerSingleton<FileProvider>(mockProvider);
    });

    tearDown(() {
      sl.reset();
    });

    test('create excel service for xlsx', () {
      final svc = ImportServiceFactory.createImportService('xlsx');
      expect(svc, isA<ExcelImportService>());
    });

    test('throws for unsupported format', () {
      expect(
        () => ImportServiceFactory.createImportService('csv'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('getSupportedFormats returns unmodifiable list', () {
      final fmts = ImportServiceFactory.getSupportedFormats();
      expect(fmts, ['xlsx']);
      expect(() => fmts.add('csv'), throwsUnsupportedError);
    });

    test('isFormatSupported matches correctly', () {
      expect(ImportServiceFactory.isFormatSupported('xlsx'), true);
      expect(ImportServiceFactory.isFormatSupported('csv'), false);
    });

    test('getMimeTypesForFormat returns expected types', () {
      final types = ImportServiceFactory.getMimeTypesForFormat('xlsx');
      expect(
        types,
        contains(
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );
      expect(types, contains('application/vnd.ms-excel'));
      expect(ImportServiceFactory.getMimeTypesForFormat('csv'), isEmpty);
    });
  });

  group('BaseImportService.getImportStatistics', () {
    late BaseImportService service;
    late MockAssessmentFormModel mockAssess;

    setUp(() {
      final mockProvider = MockFileProvider();
      service = ExcelImportService(fileProvider: mockProvider);

      mockAssess = MockAssessmentFormModel();
      when(mockAssess.totalItems).thenReturn(4);
      when(mockAssess.completedItems).thenReturn(2);

      final mockFacilityId = MockFacilityIdentificationEntity();
      when(mockAssess.facilityIdentification).thenReturn(mockFacilityId);
      when(mockFacilityId.facilityName).thenReturn('F');
      when(mockFacilityId.facilityCode).thenReturn('C');

      final mockAssessor = MockAssessorInfoEntity();
      when(mockAssess.assessorInfo).thenReturn(mockAssessor);
      when(mockAssessor.name).thenReturn('A');

      final mockSection = MockAssessmentSectionEntity();
      when(
        mockAssess.sections,
      ).thenReturn([mockSection, mockSection, mockSection]);
    });

    test('calculates stats correctly', () {
      final imported = ImportedAssessmentForm(
        assessment: mockAssess,
        filePath: '/f.xlsx',
        format: 'XLSX',
        importedAt: DateTime.parse('2025-07-30T12:00:00Z'),
        metadata: {'m': 1},
      );

      final stats = service.getImportStatistics(imported);
      expect(stats['formatName'], service.formatName);
      expect(stats['filePath'], '/f.xlsx');
      expect(stats['totalSections'], 3);
      expect(stats['totalItems'], 4);
      expect(stats['completedItems'], 2);
      expect(stats['completionRate'], 50.0);
      expect(stats['isValid'], true);
      expect(stats['metadata'], {'m': 1});
    });
  });
  group('BaseImportService.validateFormatSpecific', () {
    test('default implementation does nothing', () {
      final provider = MockFileProvider();
      final svc = DummyImportService(provider);
      expect(() => svc.validateFormatSpecific('any.file'), returnsNormally);
    });
  });
}

/// Dummy service to test default format-specific validation
class DummyImportService extends BaseImportService {
  DummyImportService(FileProvider fileProvider)
    : super(fileProvider: fileProvider);

  @override
  String get supportedExtension => 'tmp';

  @override
  String get formatName => 'Dummy';

  @override
  List<String> get supportedMimeTypes => [];

  @override
  Future<ImportedAssessmentForm> importAssessment(
    String filePath, {
    ImportOptions? options,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ImportedAssessmentForm> importFromBytes(
    Uint8List bytes, {
    String? originalName,
    ImportOptions? options,
  }) {
    throw UnimplementedError();
  }
}
