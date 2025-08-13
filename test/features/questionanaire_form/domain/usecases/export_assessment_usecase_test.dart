import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/export_assessment_usecase.dart';

@GenerateMocks([ExportServiceFactoryBase, ExportService, AssessmentValidator])
import 'export_assessment_usecase_test.mocks.dart';

void main() {
  late MockExportServiceFactoryBase mockFactory;
  late MockExportService mockService;
  late MockAssessmentValidator mockValidator;
  late ExportResult testExportResult;
  late DateTime testDateTime;

  // Clock function for testing
  DateTime testClock() => testDateTime;

  // Helper to create a valid assessment form
  AssessmentFormEntity createValidAssessment() => AssessmentFormEntity(
    id: 'test-id',
    assessorInfo: AssessorInfoEntity(
      name: 'Test Assessor',
      email: 'assessor@test.com',
      phoneNumber: '+1234567890',
      assessmentDate: DateTime(2025, 1, 1),
    ),
    geoLocation: GeoLocationEntity(
      country: 'Test Country',
      regionProvince: 'Test Region',
      cityVillage: 'Test City',
      latitude: 0.0,
      longitude: 0.0,
      district: 'Test District',
      addressOrCoordinates: 'Test Address',
      locationType: null,
    ),
    facilityIdentification: FacilityIdentificationEntity(
      facilityName: 'Test Facility',
      facilityCode: 'TF001',
      managingAuthority: null,
      directorName: 'Test Director',
      directorPhone: '+1234567890',
      directorEmail: 'director@test.com',
      respondentName: 'Test Respondent',
      respondentPosition: 'Manager',
      structureType: null,
      facilityType: null,
    ),
    facilityServices: FacilityServicesEntity(
      hasOutpatientServices: true,
      hasInpatientServices: false,
    ),
    sections: [
      AssessmentSectionEntity(
        id: 'section-1',
        title: 'Test Section',
        description: 'Test Description',
        items: [
          AssessmentItemEntity(
            id: 1,
            selectedRating: AssessmentRatingEntity(
              id: 'rating-1',
              value: 0,
              label: 'label',
              description: 'description',
            ),
            itemNumber: '1.1',
            sectionNumber: '1',
            area: 'Test Area',
            meetsTargetDescription: 'Meets target',
            partiallyMeetsDescription: 'Partially meets',
            doesNotMeetDescription: 'Does not meet',
          ),
        ],
        sectionNumber: '1',
      ),
    ],
    photos: const [],
    notes: 'Test notes',
    isSubmitted: false,
    submissionDate: null,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
  final dummyAssessment = createValidAssessment();
  final dummyOptions = ExportOptions(includeAnalysis: true);

  setUp(() {
    mockFactory = MockExportServiceFactoryBase();
    mockService = MockExportService();
    mockValidator = MockAssessmentValidator();
    testDateTime = DateTime(2025, 1, 15, 10, 30);

    testExportResult = ExportResult(
      filePath: '/test/path/export.pdf',
      fileName: 'export.pdf',
      format: 'PDF',
      fileSizeBytes: 1024,
      createdAt: testDateTime,
    );

    // Default successful behavior
    when(mockFactory.isFormatSupported(any)).thenReturn(true);
    when(mockFactory.createExportService(any)).thenReturn(mockService);
    when(mockFactory.getSupportedFormats()).thenReturn(['pdf', 'xlsx', 'docx']);
    when(
      mockFactory.getFormatInfo(any),
    ).thenReturn({'extension': '.pdf', 'mimeType': 'application/pdf'});

    when(
      mockService.exportAssessment(
        any,
        outputPath: anyNamed('outputPath'),
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => testExportResult);

    when(
      mockService.getExportStatistics(any),
    ).thenReturn({'totalPages': 10, 'totalSections': 1, 'totalItems': 1});

    // validateForExport is void, doesn't throw by default
    when(mockService.validateForExport(any)).thenReturn(null);

    // Validator methods don't throw by default
    when(mockValidator.validateCommon(any)).thenReturn(null);
    when(mockValidator.validateExcel(any)).thenReturn(null);
    when(mockValidator.validatePdf(any)).thenReturn(null);
    when(mockValidator.validateDoc(any)).thenReturn(null);
  });

  group('ExportAssessmentUsecase', () {
    test('should return ExportResult on successful export', () async {
      // Arrange
      final usecase = ExportAssessmentUsecase(
        factory: mockFactory,
        validator: mockValidator,
        clock: testClock,
      );
      final params = ExportAssessmentParams.pdf(
        assessment: createValidAssessment(),
        outputPath: '/test/output',
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left: $failure'), (
        exportResult,
      ) {
        expect(exportResult, equals(testExportResult));
      });

      verify(mockFactory.isFormatSupported('pdf')).called(1);
      verify(mockValidator.validateCommon(any)).called(1);
      verify(mockFactory.createExportService('pdf')).called(1);
      verify(
        mockService.exportAssessment(
          any,
          outputPath: '/test/output',
          options: anyNamed('options'),
        ),
      ).called(1);
    });

    test('should return ValidationFailure for unsupported format', () async {
      // Arrange
      when(mockFactory.isFormatSupported('txt')).thenReturn(false);

      final usecase = ExportAssessmentUsecase(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ExportAssessmentParams(
        assessment: createValidAssessment(),
        format: 'txt',
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('Unsupported export format: txt'));
        expect(failure.message, contains('pdf, xlsx, docx'));
      }, (_) => fail('Expected Left but got Right'));

      verifyNever(mockValidator.validateCommon(any));
      verifyNever(mockFactory.createExportService(any));
    });

    test(
      'should return ExportFailure when service throws ExportException',
      () async {
        // Arrange
        when(
          mockService.exportAssessment(
            any,
            outputPath: anyNamed('outputPath'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          const ExportException(message: 'Export failed', exportFormat: 'pdf'),
        );

        final usecase = ExportAssessmentUsecase(
          factory: mockFactory,
          validator: mockValidator,
        );
        final params = ExportAssessmentParams.pdf(
          assessment: createValidAssessment(),
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ExportFailure>());
          expect(failure.message, equals('Export failed'));
        }, (_) => fail('Expected Left but got Right'));
      },
    );

    test(
      'should return FileOperationFailure when service throws FileException',
      () async {
        // Arrange
        when(
          mockService.exportAssessment(
            any,
            outputPath: anyNamed('outputPath'),
            options: anyNamed('options'),
          ),
        ).thenThrow(const FileException(message: 'File write failed'));

        final usecase = ExportAssessmentUsecase(
          factory: mockFactory,
          validator: mockValidator,
        );
        final params = ExportAssessmentParams.pdf(
          assessment: createValidAssessment(),
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<FileOperationFailure>());
          expect(failure.message, equals('File write failed'));
        }, (_) => fail('Expected Left but got Right'));
      },
    );

    test('should return UnexpectedFailure for generic exceptions', () async {
      // Arrange
      when(
        mockService.exportAssessment(
          any,
          outputPath: anyNamed('outputPath'),
          options: anyNamed('options'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      final usecase = ExportAssessmentUsecase(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ExportAssessmentParams.pdf(
        assessment: createValidAssessment(),
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<UnexpectedFailure>());
        expect(failure.message, contains('An unexpected error occurred'));
      }, (_) => fail('Expected Left but got Right'));
    });

    test('should use provided export options', () async {
      // Arrange
      final customOptions = ExportOptions(
        includeAnalysis: false,
        includeSectionDetails: false,
        includeSignaturePage: false,
        customTemplate: 'custom.docx',
        additionalOptions: {'key': 'value'},
      );

      final usecase = ExportAssessmentUsecase(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ExportAssessmentParams(
        assessment: createValidAssessment(),
        format: 'pdf',
        outputPath: '/custom/path',
        options: customOptions,
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      verify(
        mockService.exportAssessment(
          any,
          outputPath: '/custom/path',
          options: customOptions,
        ),
      ).called(1);
    });
  });

  group('ExportAssessmentToExcel', () {
    test('should validate and export to Excel successfully', () async {
      // Arrange
      when(mockFactory.createExportService('excel')).thenReturn(mockService);

      final usecase = ExportAssessmentToExcel(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ExportAssessmentToExcelParams(
        assessment: createValidAssessment(),
        outputPath: '/test/excel.xlsx',
        includeAnalysis: true,
        includeSectionDetails: false,
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      verify(mockValidator.validateExcel(any)).called(1);
      verify(mockFactory.createExportService('excel')).called(1);
      verify(
        mockService.exportAssessment(
          any,
          outputPath: '/test/excel.xlsx',
          options: argThat(
            isA<ExportOptions>()
                .having((o) => o.includeAnalysis, 'includeAnalysis', true)
                .having(
                  (o) => o.includeSectionDetails,
                  'includeSectionDetails',
                  false,
                )
                .having(
                  (o) => o.includeSignaturePage,
                  'includeSignaturePage',
                  false,
                ),
            named: 'options',
          ),
        ),
      ).called(1);
    });
  });

  group('ExportAssessmentToPdf', () {
    test('should validate and export to PDF with all options', () async {
      // Arrange
      final usecase = ExportAssessmentToPdf(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ExportAssessmentToPdfParams(
        assessment: createValidAssessment(),
        outputPath: '/test/report.pdf',
        includeAnalysis: true,
        includeDetailedSections: true,
        includeSignaturePage: true,
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      verify(mockValidator.validatePdf(any)).called(1);
      verify(mockFactory.createExportService('pdf')).called(1);
      verify(
        mockService.exportAssessment(
          any,
          outputPath: '/test/report.pdf',
          options: argThat(
            isA<ExportOptions>()
                .having((o) => o.includeAnalysis, 'includeAnalysis', true)
                .having(
                  (o) => o.includeSectionDetails,
                  'includeSectionDetails',
                  true,
                )
                .having(
                  (o) => o.includeSignaturePage,
                  'includeSignaturePage',
                  true,
                ),
            named: 'options',
          ),
        ),
      ).called(1);
    });
  });

  group('ExportAssessmentToDoc', () {
    test('should validate and export to DOCX with custom template', () async {
      // Arrange
      when(mockFactory.createExportService('docx')).thenReturn(mockService);

      final usecase = ExportAssessmentToDoc(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ExportAssessmentToDocParams(
        assessment: createValidAssessment(),
        outputPath: '/test/report.docx',
        includeAnalysis: false,
        includeSectionDetails: true,
        includeSignaturePage: false,
        customTemplate: '/templates/custom.docx',
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      verify(mockValidator.validateDoc(any)).called(1);
      verify(mockFactory.createExportService('docx')).called(1);
      verify(
        mockService.exportAssessment(
          any,
          outputPath: '/test/report.docx',
          options: argThat(
            isA<ExportOptions>()
                .having((o) => o.includeAnalysis, 'includeAnalysis', false)
                .having(
                  (o) => o.includeSectionDetails,
                  'includeSectionDetails',
                  true,
                )
                .having(
                  (o) => o.includeSignaturePage,
                  'includeSignaturePage',
                  false,
                )
                .having(
                  (o) => o.customTemplate,
                  'customTemplate',
                  '/templates/custom.docx',
                ),
            named: 'options',
          ),
        ),
      ).called(1);
    });
  });

  group('GetExportStatistics', () {
    test('should return merged statistics and format info', () async {
      // Arrange
      final usecase = GetExportStatistics(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = GetExportStatisticsParams(
        assessment: createValidAssessment(),
        format: 'pdf',
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left: $failure'), (
        stats,
      ) {
        expect(stats['totalPages'], equals(10));
        expect(stats['totalSections'], equals(1));
        expect(stats['totalItems'], equals(1));
        expect(stats['extension'], equals('.pdf'));
        expect(stats['mimeType'], equals('application/pdf'));
      });

      verify(mockValidator.validateCommon(any)).called(1);
      verify(mockService.getExportStatistics(any)).called(1);
      verify(mockFactory.getFormatInfo('pdf')).called(1);
    });

    test('should return ValidationFailure for unsupported format', () async {
      // Arrange
      when(mockFactory.isFormatSupported('yaml')).thenReturn(false);

      final usecase = GetExportStatistics(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = GetExportStatisticsParams(
        assessment: createValidAssessment(),
        format: 'yaml',
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('Unsupported export format: yaml'));
      }, (_) => fail('Expected Left but got Right'));
    });
  });

  group('ValidateAssessmentForExport', () {
    test('should return true when validation passes', () async {
      // Arrange
      final usecase = ValidateAssessmentForExport(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ValidateAssessmentForExportParams(
        assessment: createValidAssessment(),
        format: 'pdf',
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (isValid) => expect(isValid, isTrue),
      );

      verify(mockValidator.validateCommon(any)).called(1);
      verify(mockService.validateForExport(any)).called(1);
    });

    test(
      'should return ValidationFailure when service validation fails',
      () async {
        // Arrange
        when(mockService.validateForExport(any)).thenThrow(
          const ValidationException(message: 'Invalid data for export'),
        );

        final usecase = ValidateAssessmentForExport(
          factory: mockFactory,
          validator: mockValidator,
        );
        final params = ValidateAssessmentForExportParams(
          assessment: createValidAssessment(),
          format: 'pdf',
        );

        // Act
        final result = await usecase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, equals('Invalid data for export'));
        }, (_) => fail('Expected Left but got Right'));
      },
    );
  });

  group('DefaultAssessmentValidator', () {
    late DefaultAssessmentValidator validator;

    setUp(() {
      validator = const DefaultAssessmentValidator();
    });

    test('validateCommon should throw when facility name is empty', () {
      // Arrange
      final assessment = AssessmentFormEntity(
        id: 'test-id',
        assessorInfo: AssessorInfoEntity(
          name: 'test name',
          email: 'assessor@test.com',
          phoneNumber: '+1234567890',
          assessmentDate: DateTime(2025, 1, 1),
        ),
        geoLocation: GeoLocationEntity(
          country: 'Test Country',
          regionProvince: 'Test Region',
          cityVillage: 'Test City',
          latitude: 0.0,
          longitude: 0.0,
          district: 'Test District',
          addressOrCoordinates: 'Test Address',
          locationType: null,
        ),
        facilityIdentification: FacilityIdentificationEntity(
          facilityName: '',
          facilityCode: 'code',
          managingAuthority: null,
          directorName: 'Test Director',
          directorPhone: '+1234567890',
          directorEmail: 'director@test.com',
          respondentName: 'Test Respondent',
          respondentPosition: 'Manager',
          structureType: null,
          facilityType: null,
        ),
        facilityServices: FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false,
        ),
        sections: [
          AssessmentSectionEntity(
            id: 'section-1',
            title: 'Test Section',
            description: 'Test Description',
            items: [
              AssessmentItemEntity(
                id: 1,
                selectedRating: AssessmentRatingEntity(
                  id: 'rating-1',
                  value: 0,
                  label: 'label',
                  description: 'description',
                ),
                itemNumber: '1.1',
                sectionNumber: '1',
                area: 'Test Area',
                meetsTargetDescription: 'Meets target',
                partiallyMeetsDescription: 'Partially meets',
                doesNotMeetDescription: 'Does not meet',
              ),
            ],
            sectionNumber: '1',
          ),
        ],
        photos: const [],
        notes: 'Test notes',
        isSubmitted: false,
        submissionDate: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Act & Assert
      expect(
        () => validator.validateCommon(assessment),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Assessment must have a facility name before export',
          ),
        ),
      );
    });

    test('validateCommon should throw when facility code is empty', () {
      // Arrange
      final assessment = AssessmentFormEntity(
        id: 'test-id',
        assessorInfo: AssessorInfoEntity(
          name: 'test name',
          email: 'assessor@test.com',
          phoneNumber: '+1234567890',
          assessmentDate: DateTime(2025, 1, 1),
        ),
        geoLocation: GeoLocationEntity(
          country: 'Test Country',
          regionProvince: 'Test Region',
          cityVillage: 'Test City',
          latitude: 0.0,
          longitude: 0.0,
          district: 'Test District',
          addressOrCoordinates: 'Test Address',
          locationType: null,
        ),
        facilityIdentification: FacilityIdentificationEntity(
          facilityName: 'Test Facility',
          facilityCode: '',
          managingAuthority: null,
          directorName: 'Test Director',
          directorPhone: '+1234567890',
          directorEmail: 'director@test.com',
          respondentName: 'Test Respondent',
          respondentPosition: 'Manager',
          structureType: null,
          facilityType: null,
        ),
        facilityServices: FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false,
        ),
        sections: [
          AssessmentSectionEntity(
            id: 'section-1',
            title: 'Test Section',
            description: 'Test Description',
            items: [
              AssessmentItemEntity(
                id: 1,
                selectedRating: AssessmentRatingEntity(
                  id: 'rating-1',
                  value: 0,
                  label: 'label',
                  description: 'description',
                ),
                itemNumber: '1.1',
                sectionNumber: '1',
                area: 'Test Area',
                meetsTargetDescription: 'Meets target',
                partiallyMeetsDescription: 'Partially meets',
                doesNotMeetDescription: 'Does not meet',
              ),
            ],
            sectionNumber: '1',
          ),
        ],
        photos: const [],
        notes: 'Test notes',
        isSubmitted: false,
        submissionDate: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Act & Assert
      expect(
        () => validator.validateCommon(assessment),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Assessment must have a facility code before export',
          ),
        ),
      );
    });

    test('validateCommon should throw when assessor name is empty', () {
      // Arrange
      final assessment = AssessmentFormEntity(
        id: 'test-id',
        assessorInfo: AssessorInfoEntity(
          name: '',
          email: 'assessor@test.com',
          phoneNumber: '+1234567890',
          assessmentDate: DateTime(2025, 1, 1),
        ),
        geoLocation: GeoLocationEntity(
          country: 'Test Country',
          regionProvince: 'Test Region',
          cityVillage: 'Test City',
          latitude: 0.0,
          longitude: 0.0,
          district: 'Test District',
          addressOrCoordinates: 'Test Address',
          locationType: null,
        ),
        facilityIdentification: FacilityIdentificationEntity(
          facilityName: 'Test Facility',
          facilityCode: 'TF001',
          managingAuthority: null,
          directorName: 'Test Director',
          directorPhone: '+1234567890',
          directorEmail: 'director@test.com',
          respondentName: 'Test Respondent',
          respondentPosition: 'Manager',
          structureType: null,
          facilityType: null,
        ),
        facilityServices: FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false,
        ),
        sections: [
          AssessmentSectionEntity(
            id: 'section-1',
            title: 'Test Section',
            description: 'Test Description',
            items: [
              AssessmentItemEntity(
                id: 1,
                selectedRating: AssessmentRatingEntity(
                  id: 'rating-1',
                  value: 0,
                  label: 'label',
                  description: 'description',
                ),
                itemNumber: '1.1',
                sectionNumber: '1',
                area: 'Test Area',
                meetsTargetDescription: 'Meets target',
                partiallyMeetsDescription: 'Partially meets',
                doesNotMeetDescription: 'Does not meet',
              ),
            ],
            sectionNumber: '1',
          ),
        ],
        photos: const [],
        notes: 'Test notes',
        isSubmitted: false,
        submissionDate: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Act & Assert
      expect(
        () => validator.validateCommon(assessment),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Assessment must have an assessor name before export',
          ),
        ),
      );
    });

    test('validateCommon should throw when sections are empty', () {
      // Arrange
      final assessment = createValidAssessment().copyWith(sections: []);

      // Act & Assert
      expect(
        () => validator.validateCommon(assessment),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Assessment must have at least one section before export',
          ),
        ),
      );
    });

    test('validateExcel should throw when no items exist', () {
      // Arrange
      final assessment = createValidAssessment().copyWith(
        sections: [
          AssessmentSectionEntity(
            id: 's1',
            title: 'Empty Section',
            description: '',
            items: [],
            sectionNumber: '1',
          ),
        ],
      );

      // Act & Assert
      expect(
        () => validator.validateExcel(assessment),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Cannot export to Excel: Assessment has no items',
          ),
        ),
      );
    });

    test('validatePdf should call validateCommon', () {
      // Should not throw for valid assessment
      expect(
        () => validator.validatePdf(createValidAssessment()),
        returnsNormally,
      );

      // Should throw for invalid assessment
      final validAssessment = createValidAssessment();
      final invalidAssessment = AssessmentFormEntity(
        id: validAssessment.id,
        assessorInfo: validAssessment.assessorInfo,
        geoLocation: validAssessment.geoLocation,
        facilityIdentification: FacilityIdentificationEntity(
          facilityName: '',
          facilityCode: validAssessment.facilityIdentification.facilityCode,
          managingAuthority:
              validAssessment.facilityIdentification.managingAuthority,
          directorName: validAssessment.facilityIdentification.directorName,
          directorPhone: validAssessment.facilityIdentification.directorPhone,
          directorEmail: validAssessment.facilityIdentification.directorEmail,
          respondentName: validAssessment.facilityIdentification.respondentName,
          respondentPosition:
              validAssessment.facilityIdentification.respondentPosition,
          structureType: validAssessment.facilityIdentification.structureType,
          facilityType: validAssessment.facilityIdentification.facilityType,
        ),
        facilityServices: validAssessment.facilityServices,
        sections: validAssessment.sections,
        photos: validAssessment.photos,
        notes: validAssessment.notes,
        isSubmitted: validAssessment.isSubmitted,
        submissionDate: validAssessment.submissionDate,
        createdAt: validAssessment.createdAt,
        updatedAt: validAssessment.updatedAt,
      );

      expect(
        () => validator.validatePdf(invalidAssessment),
        throwsA(isA<ValidationException>()),
      );
    });

    test('validateDoc should call validateCommon', () {
      // Should not throw for valid assessment
      expect(
        () => validator.validateDoc(createValidAssessment()),
        returnsNormally,
      );

      // Should throw for invalid assessment
      final invalidAssessment = createValidAssessment().copyWith(sections: []);

      expect(
        () => validator.validateDoc(invalidAssessment),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('ExportAssessmentParams factory methods', () {
    final assessment = createValidAssessment();

    test('pdf factory creates correct params', () {
      final params = ExportAssessmentParams.pdf(
        assessment: assessment,
        outputPath: '/test.pdf',
        includeAnalysis: false,
      );

      expect(params.format, equals('pdf'));
      expect(params.outputPath, equals('/test.pdf'));
      expect(params.options?.includeAnalysis, isFalse);
      expect(params.options?.includeSignaturePage, isTrue);
    });

    test('excel factory creates correct params', () {
      final params = ExportAssessmentParams.excel(
        assessment: assessment,
        outputPath: '/test.xlsx',
      );

      expect(params.format, equals('xlsx'));
      expect(params.outputPath, equals('/test.xlsx'));
      expect(params.options?.includeSignaturePage, isFalse);
    });

    test('doc factory creates correct params', () {
      final params = ExportAssessmentParams.doc(
        assessment: assessment,
        outputPath: '/test.docx',
      );

      expect(params.format, equals('docx'));
      expect(params.outputPath, equals('/test.docx'));
      expect(params.options?.includeSignaturePage, isTrue);
    });

    test('withDefaults factory includes additional options', () {
      final params = ExportAssessmentParams.withDefaults(
        assessment: assessment,
        format: 'custom',
        customTemplate: 'template.txt',
        additionalOptions: {'key': 'value'},
      );

      expect(params.format, equals('custom'));
      expect(params.options?.customTemplate, equals('template.txt'));
      expect(params.options?.additionalOptions, equals({'key': 'value'}));
    });
  });

  group('ExportServiceFactoryAdapter', () {
    test('should delegate all calls to ExportServiceFactory', () {
      // This test would require the actual ExportServiceFactory to be available
      // For now, we'll just test that the adapter exists and has the right interface
      const adapter = ExportServiceFactoryAdapter();

      expect(adapter, isA<ExportServiceFactoryBase>());
    });
  });
  group('ExportServiceFactoryAdapter', () {
    const adapter = ExportServiceFactoryAdapter();

    test('isFormatSupported delegates to ExportServiceFactory', () {
      // pick a format you know is supported (e.g. 'pdf')
      final expected = ExportServiceFactory.isFormatSupported('pdf');
      expect(adapter.isFormatSupported('pdf'), equals(expected));
    });

    test('getSupportedFormats delegates to ExportServiceFactory', () {
      final expected = ExportServiceFactory.getSupportedFormats();
      expect(adapter.getSupportedFormats(), equals(expected));
    });

    test('getFormatInfo delegates to ExportServiceFactory', () {
      final expected = ExportServiceFactory.getFormatInfo('pdf');
      expect(adapter.getFormatInfo('pdf'), equals(expected));
    });

    test('createExportService delegates to ExportServiceFactory', () {
      final fromAdapter = adapter.createExportService('pdf');
      final fromStatic = ExportServiceFactory.createExportService('pdf');
      // just verify you got the same type of service back
      expect(fromAdapter.runtimeType, equals(fromStatic.runtimeType));
    });
  });

  group('ValidateAssessmentForExport (unsupported format)', () {
    test('should return ValidationFailure when format unsupported', () async {
      // Arrange
      when(mockFactory.isFormatSupported('pdf')).thenReturn(false);
      final usecase = ValidateAssessmentForExport(
        factory: mockFactory,
        validator: mockValidator,
      );
      final params = ValidateAssessmentForExportParams(
        assessment: createValidAssessment(),
        format: 'pdf',
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, equals('Unsupported export format: pdf'));
      }, (_) => fail('Expected Left but got Right'));
      verifyNever(mockValidator.validateCommon(any));
      verifyNever(mockFactory.createExportService(any));
    });
  });

  group('Equatable props – ExportAssessmentParams', () {
    test('identical params are equal', () {
      final a = ExportAssessmentParams(
        assessment: dummyAssessment,
        format: 'pdf',
        outputPath: '/foo.pdf',
        options: dummyOptions,
      );
      final b = ExportAssessmentParams(
        assessment: dummyAssessment,
        format: 'pdf',
        outputPath: '/foo.pdf',
        options: dummyOptions,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different format is not equal', () {
      final a = ExportAssessmentParams(
        assessment: dummyAssessment,
        format: 'pdf',
        outputPath: '/foo.pdf',
        options: dummyOptions,
      );
      final c = ExportAssessmentParams(
        assessment: dummyAssessment,
        format: 'xlsx',
        outputPath: '/foo.pdf',
        options: dummyOptions,
      );
      expect(a == c, isFalse);
    });
  });

  group('Equatable props – ExportAssessmentToExcelParams', () {
    test('identical excel params are equal', () {
      final a = ExportAssessmentToExcelParams(
        assessment: dummyAssessment,
        outputPath: '/out.xlsx',
        includeAnalysis: true,
        includeSectionDetails: false,
      );
      final b = ExportAssessmentToExcelParams(
        assessment: dummyAssessment,
        outputPath: '/out.xlsx',
        includeAnalysis: true,
        includeSectionDetails: false,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toggle includeAnalysis makes them not equal', () {
      final a = ExportAssessmentToExcelParams(
        assessment: dummyAssessment,
        outputPath: '/out.xlsx',
        includeAnalysis: true,
        includeSectionDetails: false,
      );
      final c = ExportAssessmentToExcelParams(
        assessment: dummyAssessment,
        outputPath: '/out.xlsx',
        includeAnalysis: false,
        includeSectionDetails: false,
      );
      expect(a == c, isFalse);
    });
  });

  group('Equatable props – ExportAssessmentToPdfParams', () {
    test('identical pdf params are equal', () {
      final a = ExportAssessmentToPdfParams(
        assessment: dummyAssessment,
        outputPath: '/report.pdf',
        includeAnalysis: true,
        includeDetailedSections: true,
        includeSignaturePage: false,
      );
      final b = ExportAssessmentToPdfParams(
        assessment: dummyAssessment,
        outputPath: '/report.pdf',
        includeAnalysis: true,
        includeDetailedSections: true,
        includeSignaturePage: false,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different includeSignaturePage makes them not equal', () {
      final a = ExportAssessmentToPdfParams(
        assessment: dummyAssessment,
        outputPath: '/report.pdf',
        includeAnalysis: true,
        includeDetailedSections: true,
        includeSignaturePage: false,
      );
      final c = ExportAssessmentToPdfParams(
        assessment: dummyAssessment,
        outputPath: '/report.pdf',
        includeAnalysis: true,
        includeDetailedSections: true,
        includeSignaturePage: true,
      );
      expect(a == c, isFalse);
    });
  });

  group('Equatable props – ExportAssessmentToDocParams', () {
    test('identical doc params are equal', () {
      final a = ExportAssessmentToDocParams(
        assessment: dummyAssessment,
        outputPath: '/docx.docx',
        includeAnalysis: false,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: '/tmpl.docx',
      );
      final b = ExportAssessmentToDocParams(
        assessment: dummyAssessment,
        outputPath: '/docx.docx',
        includeAnalysis: false,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: '/tmpl.docx',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('changing customTemplate makes them not equal', () {
      final a = ExportAssessmentToDocParams(
        assessment: dummyAssessment,
        outputPath: '/docx.docx',
        includeAnalysis: false,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: '/tmpl.docx',
      );
      final c = ExportAssessmentToDocParams(
        assessment: dummyAssessment,
        outputPath: '/docx.docx',
        includeAnalysis: false,
        includeSectionDetails: true,
        includeSignaturePage: true,
        customTemplate: null,
      );
      expect(a == c, isFalse);
    });
  });

  group('Equatable props – GetExportStatisticsParams', () {
    test('identical stats params are equal', () {
      final a = GetExportStatisticsParams(
        assessment: dummyAssessment,
        format: 'pdf',
      );
      final b = GetExportStatisticsParams(
        assessment: dummyAssessment,
        format: 'pdf',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different format makes them not equal', () {
      final a = GetExportStatisticsParams(
        assessment: dummyAssessment,
        format: 'pdf',
      );
      final c = GetExportStatisticsParams(
        assessment: dummyAssessment,
        format: 'docx',
      );
      expect(a == c, isFalse);
    });
  });

  group('Equatable props – ValidateAssessmentForExportParams', () {
    test('identical validate params are equal', () {
      final a = ValidateAssessmentForExportParams(
        assessment: dummyAssessment,
        format: 'xlsx',
      );
      final b = ValidateAssessmentForExportParams(
        assessment: dummyAssessment,
        format: 'xlsx',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different assessment instance makes them not equal', () {
      final otherAssessment = createValidAssessment().copyWith(id: 'other');
      final a = ValidateAssessmentForExportParams(
        assessment: dummyAssessment,
        format: 'xlsx',
      );
      final c = ValidateAssessmentForExportParams(
        assessment: otherAssessment,
        format: 'xlsx',
      );
      expect(a == c, isFalse);
    });
  });
}
