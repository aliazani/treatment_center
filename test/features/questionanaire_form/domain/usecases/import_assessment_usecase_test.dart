import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fpdart/fpdart.dart' as fpdart;

import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';
import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/import_assessment_usecase.dart';
import 'package:mockito/mockito.dart' as mockito;

@GenerateMocks([ImportService, AssessmentRepository, FileWrapper, FileProvider])
import 'import_assessment_usecase_test.mocks.dart';

void main() {
  // Provide dummy value for Either<Failure, bool> to fix MissingDummyValueError
  mockito.provideDummy<Either<Failure, bool>>(const Right(true));

  // --------------------------------------------------------------------------
  // Helpers & test fixtures
  // --------------------------------------------------------------------------

  const path = '/tmp/file.xlsx';
  const fmt = 'xlsx';
  final existingItem = AssessmentItemEntity(
    id: 1,
    sectionNumber: '1',
    itemNumber: '1.1',
    area: 'Area1',
    meetsTargetDescription: 'A',
    partiallyMeetsDescription: 'B',
    doesNotMeetDescription: 'C',
  );
  final existingSection = AssessmentSectionEntity(
    id: 's',
    sectionNumber: '1',
    title: 'Sec',
    description: null,
    items: [existingItem],
  );
  final baseEntity = AssessmentFormEntity(
    id: 'base',
    sections: [existingSection],
    photos: const [],
    isSubmitted: false,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    assessorInfo: AssessorInfoEntity(
      name: 'Assessor Name',
      email: 'assessor@example.com',
      phoneNumber: '1234567890',
      assessmentDate: DateTime(2025, 1, 1),
    ),
    geoLocation: GeoLocationEntity(
      latitude: 0.0,
      longitude: 0.0,
      country: 'Country',
      regionProvince: 'Region',
      district: 'District',
      cityVillage: 'City',
      addressOrCoordinates: 'Address',
      locationType: FacilityLocationType.urban,
    ),
    facilityIdentification: FacilityIdentificationEntity(
      facilityName: 'Facility Name',
      facilityCode: 'FAC001',
      managingAuthority: ManagingAuthorityType.government,
      directorName: 'Director Name',
      directorPhone: '1234567890',
      directorEmail: 'director@example.com',
      respondentName: 'Respondent Name',
      respondentPosition: 'Respondent Position',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.screeningAndTemporaryIsolation,
    ),
    facilityServices: FacilityServicesEntity(
      hasOutpatientServices: true,
      hasInpatientServices: false,
    ),
  );

  const item = AssessmentItemEntity(
    id: 1,
    sectionNumber: '1',
    itemNumber: '1.1',
    area: 'A',
    meetsTargetDescription: '',
    partiallyMeetsDescription: '',
    doesNotMeetDescription: '',
  );

  const section = AssessmentSectionModel(
    id: 's',
    sectionNumber: '1',
    title: 'S1',
    description: '',
    items: [item],
  );

  // Create test instances for non-nullable fields
  final assessorInfo = AssessorInfoModel(
    name: 'Test Assessor',
    email: 'test@example.com',
    phoneNumber: '1234567890',
    assessmentDate: DateTime(2025, 1, 1),
  );

  final geoLocation = GeoLocationModel(
    latitude: 0.0,
    longitude: 0.0,
    country: 'Test Country',
    regionProvince: 'Test Region',
    district: 'Test District',
    cityVillage: 'Test City',
    addressOrCoordinates: 'Test Address',
    locationType: FacilityLocationType.urban,
  );

  final facilityIdentification = FacilityIdentificationModel(
    facilityName: 'Test Facility',
    facilityCode: 'TEST001',
    managingAuthority: ManagingAuthorityType.government,
    directorName: 'Test Director',
    directorPhone: '1234567890',
    directorEmail: 'director@example.com',
    respondentName: 'Test Respondent',
    respondentPosition: 'Test Position',
    structureType: FacilityStructureType.permanent,
    facilityType: FacilityType.screeningAndTemporaryIsolation,
  );

  final facilityServices = FacilityServicesModel(
    hasOutpatientServices: true,
    hasInpatientServices: false,
  );

  final entity = AssessmentFormModel(
    id: 'e',
    sections: const [section],
    photos: const [],
    isSubmitted: false,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    assessorInfo: assessorInfo,
    geoLocation: geoLocation,
    facilityIdentification: facilityIdentification,
    facilityServices: facilityServices,
  );

  ImportedAssessmentForm imported(String p) => ImportedAssessmentForm(
    assessment: entity,
    format: 'xlsx',
    filePath: p,
    importedAt: DateTime(2025),
    metadata: const {},
  );

  imported(path);
  late GetIt getIt;
  late ImportServiceFactoryAdapter adapter;
  mockito.provideDummy<Either<Failure, AssessmentFormEntity>>(
    Right<Failure, AssessmentFormEntity>(entity),
  );

  setUpAll(() {
    // Initialize and reset the service locator
    getIt = GetIt.instance;
    getIt.reset();
    // Provide a fake FileProvider so ExcelImportService can be constructed
    getIt.registerSingleton<FileProvider>(MockFileProvider());
  });

  setUp(() {
    adapter = ImportServiceFactoryAdapter();
  });

  // --------------------------------------------------------------------------
  group('GetImportStatistics', () {
    late MockImportService service;
    late GetImportStatistics usecase;
    late MockFileProvider mockFileProvider;
    late MockFileWrapper mockFileWrapper;

    setUp(() {
      service = MockImportService();
      mockFileWrapper = MockFileWrapper();
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      when(mockFileWrapper.length()).thenAnswer((_) async => 42);

      mockFileProvider = MockFileProvider();
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);
      TestableImportServiceFactory.mockService = service;
      TestableImportServiceFactory.shouldThrowOnCreate = false;

      usecase = GetImportStatistics(
        fileProvider: mockFileProvider,
        factory:
            TestableImportServiceFactoryAdapter(), // if you also need to inject your test factory
      );
    });

    test('returns stats from an existing import result', () async {
      when(
        service.getImportStatistics(any),
      ).thenReturn(<String, dynamic>{'ok': true});

      final res = await usecase(
        GetImportStatisticsParams.fromResult(imported(path)),
      );

      expect(res.isRight(), isTrue);

      // 2) inspect the inner Map
      res.fold(
        (l) => fail('Expected Right but got $l'),
        (map) => expect(map, <String, dynamic>{'ok': true}),
      );
      verify(service.getImportStatistics(any)).called(1);
    });

    test('analyzes file when filePath provided', () async {
      // Since GetImportStatistics uses File directly, we need to test with a real file
      // or skip this test in unit tests and cover it in integration tests
      final res = await usecase(
        GetImportStatisticsParams.fromFile(format: fmt, filePath: path),
      );

      res.fold((_) => fail('Expected Right'), (stats) {
        expect(stats['formatName'], fmt);
        expect(stats['filePath'], path);
        expect(stats['fileExists'], isA<bool>());
        expect(stats['fileSizeBytes'], isA<int>());
      });
    });

    test(
      'falls back to generic stats when neither file nor result given',
      () async {
        final res = await usecase(const GetImportStatisticsParams(format: fmt));
        expect(res.isRight(), true);

        final stats = res.getRight().getOrElse(() => {});
        expect(stats['formatName'], fmt);
        expect(stats['isSupported'], true);
        expect(stats['supportedFormats'], contains('xlsx'));
        expect(stats['features'], isA<Map>());
      },
    );

    test('maps ImportException → ImportFailure', () async {
      TestableImportServiceFactory.shouldThrowOnCreate = true;
      TestableImportServiceFactory.throwMessage = 'err';

      final res = await usecase(
        GetImportStatisticsParams.fromResult(imported(path)),
      );

      expect(res.isLeft(), true);
      expect(
        res.getLeft().getOrElse(() => throw 'Should not reach'),
        isA<ImportFailure>(),
      );
    });

    test('maps ValidationException → ValidationFailure', () async {
      // Simulate validation failure inside getImportStatistics()
      when(
        service.getImportStatistics(any),
      ).thenThrow(const ValidationException(message: 'valerr'));

      final res = await usecase(
        GetImportStatisticsParams.fromResult(imported(path)),
      );

      expect(res.isLeft(), true);
      expect(
        res.getLeft().getOrElse(() => throw 'Should not reach'),
        isA<ValidationFailure>(),
      );
    });

    test('maps unexpected exception → UnexpectedFailure', () async {
      // Simulate an unforeseen error
      when(service.getImportStatistics(any)).thenThrow(StateError('boom'));

      final res = await usecase(
        GetImportStatisticsParams.fromResult(imported(path)),
      );

      expect(res.isLeft(), true);
      expect(
        res.getLeft().getOrElse(() => throw 'Should not reach'),
        isA<UnexpectedFailure>(),
      );
    });

    test('default features empty for unsupported format', () async {
      // When neither filePath nor importResult is provided,
      // and format is unknown, features → {}
      final res = await usecase(const GetImportStatisticsParams(format: 'foo'));
      expect(res.isRight(), true);
      final stats = res.getRight().getOrElse(() => {});
      expect(stats['features'], {});
    });

    test('default constructor uses default dependencies', () async {
      // no factory or fileProvider injected → uses ImportServiceFactoryAdapter & FileProviderImpl
      final defaultUsecase = GetImportStatistics();
      final res = await defaultUsecase(
        const GetImportStatisticsParams(format: 'xlsx'),
      );
      expect(res.isRight(), isTrue);
      final stats = res.getRight().getOrElse(() => {});
      // default factory reports supported formats and isSupported correctly
      expect(stats['isSupported'], isTrue);
      expect(stats['supportedFormats'], contains('xlsx'));
    });
  });

  // --------------------------------------------------------------------------

  group('ImportAssessmentUsecase', () {
    late MockAssessmentRepository repo;
    late MockImportService service;
    late ImportAssessmentUsecase usecase;

    setUp(() {
      // fresh mocks for every test
      repo = MockAssessmentRepository();
      service = MockImportService();

      // ✦ default stub → Right(true) so Mockito always has a value
      when(repo.saveAssessment(any)).thenAnswer((_) async => const Right(true));

      // wire the factory to return our mock service
      TestableImportServiceFactory.mockService = service;
      TestableImportServiceFactory.shouldThrowOnCreate = false;

      usecase = ImportAssessmentUsecase(
        repo,
        factory: TestableImportServiceFactoryAdapter(),
      );
    });

    //---------------------------------------------------------------------------
    test('validation: empty path produces ValidationFailure', () async {
      final res = await usecase(
        const ImportAssessmentParams(filePath: '', format: fmt),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('validation: empty format produces ValidationFailure', () async {
      final res = await usecase(
        const ImportAssessmentParams(filePath: path, format: ''),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('validation: unsupported format produces ValidationFailure', () async {
      final res = await usecase(
        const ImportAssessmentParams(filePath: path, format: 'unsupported'),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    //---------------------------------------------------------------------------
    test('imports without saving', () async {
      when(
        service.importAssessment(path, options: null),
      ).thenAnswer((invocation) async => imported(path));

      final res = await usecase(
        const ImportAssessmentParams(filePath: path, format: fmt),
      );

      expect(res.isRight(), isTrue);
      expect(res.getRight().getOrElse(() => throw 'unreachable'), entity);
      verifyNever(repo.saveAssessment(any));
    });

    test('imports AND saves when requested', () async {
      when(
        service.importAssessment(path, options: null),
      ).thenAnswer((_) async => imported(path));
      // repo.saveAssessment already stubbed in setUp()

      final res = await usecase(
        const ImportAssessmentParams(
          filePath: path,
          format: fmt,
          saveAfterImport: true,
        ),
      );

      expect(res.isRight(), isTrue);
      verify(repo.saveAssessment(any)).called(1);
    });

    //---------------------------------------------------------------------------
    test('bubbles repository failure', () async {
      when(
        service.importAssessment(path, options: null),
      ).thenAnswer((_) async => imported(path));
      when(
        repo.saveAssessment(any),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'no')));

      final res = await usecase(
        const ImportAssessmentParams(
          filePath: path,
          format: fmt,
          saveAfterImport: true,
        ),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<CacheFailure>()),
        (_) => fail('expected Left'),
      );
    });

    //---------------------------------------------------------------------------
    test('maps ImportException → ImportFailure', () async {
      when(
        service.importAssessment(path, options: null),
      ).thenThrow(const ImportException(message: 'bad'));

      final res = await usecase(
        const ImportAssessmentParams(filePath: path, format: fmt),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<ImportFailure>()),
        (_) => fail('expected Left'),
      );
    });
    test(
      'default constructor uses real adapter for unsupported format',
      () async {
        // No factory injected → falls back to ImportServiceFactoryAdapter
        final repoDefault = MockAssessmentRepository();
        final ucDefault = ImportAssessmentUsecase(repoDefault);

        // 'pdf' is not supported by the real adapter
        final res = await ucDefault(
          const ImportAssessmentParams(filePath: 'any', format: 'pdf'),
        );

        expect(res.isLeft(), isTrue);
        res.fold(
          (f) => expect(f, isA<ValidationFailure>()),
          (_) => fail('expected Left'),
        );
      },
    );
    test('save returns false → UnexpectedFailure', () async {
      // given an import that succeeds...
      when(
        service.importAssessment(path, options: null),
      ).thenAnswer((_) async => imported(path));
      // but saving fails (ok == false)
      when(
        repo.saveAssessment(entity),
      ).thenAnswer((_) async => const Right(false));

      final res = await usecase(
        const ImportAssessmentParams(
          filePath: path,
          format: fmt,
          saveAfterImport: true,
        ),
      );

      expect(res.isLeft(), isTrue);
      res.fold((f) {
        expect(f, isA<UnexpectedFailure>());
        expect(f.message, 'Failed to save assessment');
      }, (_) => fail('expected Left'));
    });
    test('unexpected exception → UnexpectedFailure', () async {
      // Have the import service throw something we don't specially catch
      when(
        service.importAssessment(path, options: null),
      ).thenThrow(StateError('whoops'));

      final res = await usecase(
        const ImportAssessmentParams(filePath: path, format: fmt),
      );

      expect(res.isLeft(), isTrue);
      res.fold((f) {
        expect(f, isA<UnexpectedFailure>());
        // The message should be the toString() of the original error
        expect(f.message, contains('Bad state: whoops'));
      }, (_) => fail('expected Left'));
    });
  });

  // --------------------------------------------------------------------------
  group('ImportAssessmentFromExcel', () {
    late MockAssessmentRepository repo;
    late MockImportService svc;
    late ImportAssessmentFromExcel uc;
    late MockFileProvider fileProvider;

    setUp(() {
      repo = MockAssessmentRepository();
      svc = MockImportService();
      fileProvider = MockFileProvider();
      when(
        fileProvider.getFile(any),
      ).thenAnswer((_) async => MockFileWrapper());
      TestableImportServiceFactory.mockService = svc;
      TestableImportServiceFactory.shouldThrowOnCreate = false;

      // make file look valid to skip size/exists checks
      final mockFile = MockFileWrapper();
      when(mockFile.exists()).thenAnswer((_) async => true);
      when(mockFile.length()).thenAnswer((_) async => 1024);
      when(fileProvider.getFile(path)).thenAnswer((_) async => mockFile);

      // wire our test factory to return svc
      TestableImportServiceFactory.mockService = svc;
      TestableImportServiceFactory.shouldThrowOnCreate = false;

      // inject both factory and fileProvider
      uc = ImportAssessmentFromExcel(
        repo,
        factory: TestableImportServiceFactoryAdapter(),
        fileProvider: fileProvider,
      );
    });

    test('rejects wrong extension', () async {
      final res = await uc(
        const ImportAssessmentFromExcelParams(filePath: '/tmp/bad.txt'),
      );
      expect(res.isLeft(), true);
      expect(
        res.getLeft().getOrElse(() => throw 'Should not reach'),
        isA<ValidationFailure>(),
      );
    });

    test('accepts .xlsx extension', () async {
      when(
        svc.importAssessment(any, options: anyNamed('options')),
      ).thenAnswer((_) async => imported(path));

      final res = await uc(
        const ImportAssessmentFromExcelParams(filePath: path),
      );
      expect(res.isRight(), true);
    });

    test('imports, merges & saves', () async {
      when(
        svc.importAssessment(any, options: anyNamed('options')),
      ).thenAnswer((_) async => imported(path));

      when(
        repo.getAssessment('old'),
      ).thenAnswer((_) async => Right(entity.copyWith(id: 'old')));
      when(repo.saveAssessment(any)).thenAnswer((_) async => const Right(true));

      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
          saveAfterImport: true,
        ),
      );

      expect(res.isRight(), true);
      verify(repo.getAssessment('old')).called(1);
      verify(repo.saveAssessment(any)).called(1);
    });

    test('handles merge when existing assessment not found', () async {
      when(
        svc.importAssessment(any, options: anyNamed('options')),
      ).thenAnswer((_) async => imported(path));
      when(
        repo.getAssessment('old'),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'not found')));
      when(repo.saveAssessment(any)).thenAnswer((_) async => const Right(true));

      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
          saveAfterImport: true,
        ),
      );

      expect(res.isRight(), true);
      verify(repo.getAssessment('old')).called(1);
      // Should save the imported assessment without merge
      verify(repo.saveAssessment(entity)).called(1);
    });

    test('maps ExcelImportException → ImportFailure', () async {
      when(
        svc.importAssessment(any, options: anyNamed('options')),
      ).thenThrow(const ExcelImportException(message: 'excel error'));

      final res = await uc(
        const ImportAssessmentFromExcelParams(filePath: path),
      );
      expect(res.isLeft(), true);
      expect(
        res.getLeft().getOrElse(() => throw 'Should not reach'),
        isA<ImportFailure>(),
      );
    });

    test('maps ImportException → ImportFailure', () async {
      when(
        svc.importAssessment(any, options: anyNamed('options')),
      ).thenThrow(const ImportException(message: 'bad'));

      final res = await uc(
        const ImportAssessmentFromExcelParams(filePath: path),
      );
      expect(res.isLeft(), true);
      expect(
        res.getLeft().getOrElse(() => throw 'Should not reach'),
        isA<ImportFailure>(),
      );
    });

    test('file size validation (integration test placeholder)', () async {
      // This test would require actual file system access
      // In a unit test, we can't easily test the file size validation
      // because File operations are not mockable in the current implementation
      // Consider adding FileProvider dependency injection to make this testable

      // For now, we'll just verify the service is called correctly
      when(
        svc.importAssessment(any, options: anyNamed('options')),
      ).thenAnswer((_) async => imported(path));

      final res = await uc(
        const ImportAssessmentFromExcelParams(filePath: path),
      );

      expect(res.isRight(), true);
    });

    test('repository failure is propagated', () async {
      // stub import to succeed
      when(
        svc.importAssessment(path, options: anyNamed('options')),
      ).thenAnswer((_) async => imported(path));
      // stub merge path if needed
      when(repo.getAssessment('old')).thenAnswer((_) async {
        // Take the exact model your import‐stub returns, and only change its id
        final model = imported(path).assessment;
        final existing = model.copyWith(id: 'old');
        return Right(existing);
      });
      // stub save to return a specific failure
      final fail = CacheFailure(message: 'disk full');
      when(repo.saveAssessment(any)).thenAnswer((_) async => Left(fail));

      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
          saveAfterImport: true,
        ),
      );

      expect(res.isLeft(), isTrue);
      res.fold((f) {
        // should be the exact same failure instance
        expect(f, equals(fail));
      }, (_) => fail);
    });

    test('file-provider exception → FileOperationFailure', () async {
      when(
        fileProvider.getFile(path),
      ).thenThrow(const FileException(message: 'can’t read'));

      final res = await uc(
        const ImportAssessmentFromExcelParams(filePath: path),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<FileOperationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('oversize Excel → ValidationFailure', () async {
      final big = MockFileWrapper();
      when(big.exists()).thenAnswer((_) async => true);
      when(big.length()).thenAnswer((_) async => 51 * 1024 * 1024);
      when(fileProvider.getFile(path)).thenAnswer((_) async => big);

      final res = await uc(
        const ImportAssessmentFromExcelParams(filePath: path),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('unexpected error → UnexpectedFailure', () async {
      when(
        svc.importAssessment(path, options: anyNamed('options')),
      ).thenAnswer((_) async => imported(path));
      // simulate a bug in _merge
      when(repo.getAssessment(any)).thenThrow(StateError('broken'));

      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
        ),
      );

      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('save returns false → UnexpectedFailure', () async {
      // 1) stub import to succeed
      when(
        svc.importAssessment(path, options: anyNamed('options')),
      ).thenAnswer((_) async => imported(path));

      // 2) stub merge (so entity gets an id if needed)
      when(repo.getAssessment('old')).thenAnswer(
        (_) async => Right(imported(path).assessment.copyWith(id: 'old')),
      );

      // 3) stub saveAssessment to return Right(false)
      when(
        repo.saveAssessment(any),
      ).thenAnswer((_) async => const Right(false));

      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
          saveAfterImport: true,
        ),
      );

      expect(res.isLeft(), isTrue);
      res.fold((f) {
        expect(f, isA<UnexpectedFailure>());
        expect(f.message, 'Failed to save assessment');
      }, (_) => fail('expected Left'));
    });
    test('mergeSections adds entirely new sections', () async {
      // existing has one section "1"
      final existingSections = [
        AssessmentSectionModel(
          id: 's',
          sectionNumber: '1',
          title: 'Original',
          description: 'Desc',
          items: const [],
        ),
      ];
      // imported has a completely new section "2"
      final newSection = AssessmentSectionModel(
        id: 's2',
        sectionNumber: '2',
        title: 'New Sec',
        description: 'New Desc',
        items: const [],
      );
      // stub import to return both sections
      when(svc.importAssessment(path, options: anyNamed('options'))).thenAnswer(
        (_) async => ImportedAssessmentForm(
          assessment: entity.copyWith(
            sections: [...existingSections, newSection],
          ),
          filePath: path,
          format: 'xlsx',
          importedAt: DateTime.now(),
        ),
      );
      // no mergeWithExisting path needed; we force it
      when(repo.getAssessment(any)).thenAnswer(
        (_) async => Right(entity.copyWith(sections: existingSections)),
      );

      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
          saveAfterImport: false,
        ),
      );

      expect(res.isRight(), isTrue);
      final merged = res.getRight().getOrElse(() => throw '');
      // should contain both original "1" and new "2"
      final numbers = merged.sections.map((s) => s.sectionNumber).toList();
      expect(numbers, containsAll(['1', '2']));
    });

    test('mergeSections adds entirely new sections', () async {
      // 1) Define an existing (domain) section:
      final existingSection = AssessmentSectionEntity(
        id: 's1',
        sectionNumber: '1',
        title: 'Original',
        description: 'Desc1',
        items: const [],
      );

      // 2) Define a completely new (domain) section:
      final newSection = AssessmentSectionEntity(
        id: 's2',
        sectionNumber: '2',
        title: 'New Section',
        description: 'Desc2',
        items: const [],
      );

      // Stub the import service to return an ImportedAssessmentForm
      // whose .assessment is **already** a domain-entity copy of baseEntity:
      when(svc.importAssessment(path, options: anyNamed('options'))).thenAnswer(
        (_) async => ImportedAssessmentForm(
          assessment: AssessmentFormModel.fromEntity(
            baseEntity.copyWith(sections: [existingSection, newSection]),
          ),
          filePath: path,
          format: fmt,
          importedAt: DateTime.now(),
          metadata: {},
        ),
      );

      // Stub repo.getAssessment to return only the existingSection:
      when(repo.getAssessment('old')).thenAnswer(
        (_) async => Right(baseEntity.copyWith(sections: [existingSection])),
      );

      // Run the use-case
      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
          saveAfterImport: false,
        ),
      );
      expect(res.isRight(), isTrue);

      // Verify that we now have *both* sections 1 and 2:
      final merged = res.getRight().getOrElse(() => throw 'nope');
      final numbers = merged.sections.map((s) => s.sectionNumber).toList();
      expect(numbers, containsAll(['1', '2']));
    });

    test('mergeItems adds new items and overrides non-empty fields', () async {
      // 1) Existing section with one item (domain entity):
      final existingItem = AssessmentItemEntity(
        id: 1,
        sectionNumber: '1',
        itemNumber: '1.1',
        area: 'Area1',
        meetsTargetDescription: 'A',
        partiallyMeetsDescription: 'B',
        doesNotMeetDescription: 'C',
      );
      final existingSection = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '1',
        title: 'Section',
        description: null,
        items: [existingItem],
      );

      // 2) Imported section has:
      //    – the same itemNumber "1.1" but with a new meetsTargetDescription
      //    – a brand-new itemNumber "1.2"
      final importedItems = [
        AssessmentItemEntity(
          id: 99,
          sectionNumber: '1',
          itemNumber: '1.1',
          area: '',
          meetsTargetDescription: 'New A',
          partiallyMeetsDescription: '',
          doesNotMeetDescription: '',
        ),
        AssessmentItemEntity(
          id: 100,
          sectionNumber: '1',
          itemNumber: '1.2',
          area: 'Area2',
          meetsTargetDescription: '',
          partiallyMeetsDescription: '',
          doesNotMeetDescription: '',
        ),
      ];

      // Stub the import to return an entity copy:
      when(svc.importAssessment(path, options: anyNamed('options'))).thenAnswer(
        (_) async => ImportedAssessmentForm(
          assessment: AssessmentFormModel.fromEntity(
            baseEntity.copyWith(
              sections: [existingSection.copyWith(items: importedItems)],
            ),
          ),
          filePath: path,
          format: fmt,
          importedAt: DateTime.now(),
          metadata: {},
        ),
      );

      // Stub getAssessment to return exactly that existingSection
      when(repo.getAssessment('old')).thenAnswer(
        (_) async => Right(baseEntity.copyWith(sections: [existingSection])),
      );

      // Run the use-case
      final res = await uc(
        const ImportAssessmentFromExcelParams(
          filePath: path,
          existingAssessmentId: 'old',
          mergeWithExisting: true,
          saveAfterImport: false,
        ),
      );
      expect(res.isRight(), isTrue);

      // Verify items:
      final merged = res.getRight().getOrElse(() => throw 'nope');
      final items = merged.sections.single.items;
      expect(items.map((i) => i.itemNumber), containsAll(['1.1', '1.2']));

      // And ensure only meetsTargetDescription was overridden:
      final updated = items.firstWhere((i) => i.itemNumber == '1.1');
      expect(updated.meetsTargetDescription, 'New A');
      expect(updated.partiallyMeetsDescription, 'B');
      expect(updated.doesNotMeetDescription, 'C');
    });
    test(
      'mergeItems overrides partiallyMeetsDescription when imported non-empty',
      () async {
        // 1) Existing section with one item:
        final existingItem = AssessmentItemEntity(
          id: 1,
          sectionNumber: '1',
          itemNumber: '1.1',
          area: 'Area1',
          meetsTargetDescription: 'A',
          partiallyMeetsDescription: 'B',
          doesNotMeetDescription: 'C',
        );
        final existingSection = AssessmentSectionEntity(
          id: 's',
          sectionNumber: '1',
          title: 'Section',
          description: null,
          items: [existingItem],
        );

        // 2) Imported section has same itemNumber but new partiallyMeetsDescription:
        final importedItems = [
          AssessmentItemEntity(
            id: 99,
            sectionNumber: '1',
            itemNumber: '1.1',
            area: '',
            meetsTargetDescription: '',
            partiallyMeetsDescription: 'New B',
            doesNotMeetDescription: '',
          ),
        ];

        when(
          svc.importAssessment(path, options: anyNamed('options')),
        ).thenAnswer(
          (_) async => ImportedAssessmentForm(
            assessment: AssessmentFormModel.fromEntity(
              baseEntity.copyWith(
                sections: [existingSection.copyWith(items: importedItems)],
              ),
            ),
            filePath: path,
            format: fmt,
            importedAt: DateTime.now(),
            metadata: {},
          ),
        );

        when(repo.getAssessment('old')).thenAnswer(
          (_) async => Right(baseEntity.copyWith(sections: [existingSection])),
        );

        final res = await uc(
          const ImportAssessmentFromExcelParams(
            filePath: path,
            existingAssessmentId: 'old',
            mergeWithExisting: true,
            saveAfterImport: false,
          ),
        );

        expect(res.isRight(), isTrue);
        final merged = res.getRight().getOrElse(() => throw 'nope');
        final updated = merged.sections.single.items.single;

        // partiallyMeetsDescription should be overridden:
        expect(updated.partiallyMeetsDescription, 'New B');
        // other fields remain from existing:
        expect(updated.meetsTargetDescription, 'A');
        expect(updated.doesNotMeetDescription, 'C');
      },
    );

    test(
      'mergeItems overrides doesNotMeetDescription when imported non-empty',
      () async {
        // 1) Existing section with one item:
        final existingItem = AssessmentItemEntity(
          id: 1,
          sectionNumber: '1',
          itemNumber: '1.1',
          area: 'Area1',
          meetsTargetDescription: 'A',
          partiallyMeetsDescription: 'B',
          doesNotMeetDescription: 'C',
        );
        final existingSection = AssessmentSectionEntity(
          id: 's',
          sectionNumber: '1',
          title: 'Section',
          description: null,
          items: [existingItem],
        );

        // 2) Imported section has same itemNumber but new doesNotMeetDescription:
        final importedItems = [
          AssessmentItemEntity(
            id: 99,
            sectionNumber: '1',
            itemNumber: '1.1',
            area: '',
            meetsTargetDescription: '',
            partiallyMeetsDescription: '',
            doesNotMeetDescription: 'New C',
          ),
        ];

        when(
          svc.importAssessment(path, options: anyNamed('options')),
        ).thenAnswer(
          (_) async => ImportedAssessmentForm(
            assessment: AssessmentFormModel.fromEntity(
              baseEntity.copyWith(
                sections: [existingSection.copyWith(items: importedItems)],
              ),
            ),
            filePath: path,
            format: fmt,
            importedAt: DateTime.now(),
            metadata: {},
          ),
        );

        when(repo.getAssessment('old')).thenAnswer(
          (_) async => Right(baseEntity.copyWith(sections: [existingSection])),
        );

        final res = await uc(
          const ImportAssessmentFromExcelParams(
            filePath: path,
            existingAssessmentId: 'old',
            mergeWithExisting: true,
            saveAfterImport: false,
          ),
        );

        expect(res.isRight(), isTrue);
        final merged = res.getRight().getOrElse(() => throw 'nope');
        final updated = merged.sections.single.items.single;

        // doesNotMeetDescription should be overridden:
        expect(updated.doesNotMeetDescription, 'New C');
        // other fields remain from existing:
        expect(updated.meetsTargetDescription, 'A');
        expect(updated.partiallyMeetsDescription, 'B');
      },
    );
  });

  group('ImportServiceFactoryAdapter.create', () {
    test('throws ValidationException for unsupported format', () {
      expect(() => adapter.create('pdf'), throwsA(isA<ValidationException>()));
    });
  });

  group('ImportServiceFactoryAdapter.isSupported', () {
    test('returns true for "xlsx"', () {
      expect(adapter.isSupported('xlsx'), isTrue);
    });

    test('returns false for unsupported', () {
      expect(adapter.isSupported('xls'), isFalse);
    });
  });

  group('ImportServiceFactoryAdapter.getSupportedFormats', () {
    test('returns list containing only "xlsx"', () {
      final formats = adapter.getSupportedFormats();
      expect(formats, ['xlsx']);
    });
  });

  group('ImportServiceFactoryAdapter.getMimeTypesForFormat', () {
    test('returns correct MIME types for "xlsx"', () {
      final mimes = adapter.getMimeTypesForFormat('xlsx');
      expect(
        mimes,
        containsAll(<String>[
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'application/vnd.ms-excel',
        ]),
      );
    });

    test('returns empty list for unsupported', () {
      final mimes = adapter.getMimeTypesForFormat('pdf');
      expect(mimes, isEmpty);
    });
  });
  test('default constructor uses default adapter & file provider', () async {
    // With no factory or fileProvider injected, should use the real defaults
    GetIt.I.registerSingleton<FileProvider>(MockFileProvider());

    final repoDefault = MockAssessmentRepository();
    final ucDefault = ImportAssessmentFromExcel(repoDefault);

    // A nonexistent .xlsx file will be checked by FileProviderImpl
    const badPath = '/tmp/does_not_exist.xlsx';
    final res = await ucDefault(
      const ImportAssessmentFromExcelParams(filePath: badPath),
    );

    // Because FileProviderImpl sees no file, validation will pass (no size check on missing),
    // but the service factory create('xlsx') will throw ValidationException → caught as ImportFailure
    expect(res.isLeft(), isTrue);
    res.fold(
      (f) =>
          expect(f, anyOf([isA<FileOperationFailure>(), isA<ImportFailure>()])),
      (_) => fail('expected Left'),
    );
  });
  group('GetImportStatisticsParams', () {
    test('props includes format, filePath, importResult', () {
      final params = GetImportStatisticsParams(
        format: 'fmt',
        filePath: 'p',
        importResult: null,
      );
      expect(params.props, ['fmt', 'p', null]);
    });

    test('value equality', () {
      final p1 = GetImportStatisticsParams(format: 'fmt', filePath: 'p');
      final p2 = GetImportStatisticsParams(format: 'fmt', filePath: 'p');
      expect(p1, equals(p2));
    });

    test('fromFile sets correct values', () {
      final params = GetImportStatisticsParams.fromFile(
        format: 'xlsx',
        filePath: '/tmp/file.xlsx',
      );
      expect(params.format, 'xlsx');
      expect(params.filePath, '/tmp/file.xlsx');
      expect(params.importResult, isNull);
    });
  });

  group('ImportAssessmentParams', () {
    test('props includes filePath, format, options, saveAfterImport', () {
      const params = ImportAssessmentParams(filePath: 'path', format: 'fmt');
      expect(params.props, ['path', 'fmt', null, false]);
    });

    test('value equality', () {
      const p1 = ImportAssessmentParams(filePath: 'path', format: 'fmt');
      const p2 = ImportAssessmentParams(filePath: 'path', format: 'fmt');
      expect(p1, equals(p2));
    });

    test('excel factory sets correct defaults', () {
      final params = ImportAssessmentParams.excel(filePath: '/tmp/file.xlsx');
      expect(params.filePath, '/tmp/file.xlsx');
      expect(params.format, 'xlsx');
      expect(params.options?.importSectionDetails, isTrue);
      expect(params.saveAfterImport, isFalse);
    });
  });

  group('ImportAssessmentFromExcelParams', () {
    test('default values are correct', () {
      const params = ImportAssessmentFromExcelParams(
        filePath: '/tmp/file.xlsx',
      );
      expect(params.filePath, '/tmp/file.xlsx');
      expect(params.importSectionDetails, isTrue);
      expect(params.validateAfterImport, isTrue);
      expect(params.preserveExistingData, isFalse);
      expect(params.saveAfterImport, isFalse);
      expect(params.existingAssessmentId, isNull);
      expect(params.mergeWithExisting, isFalse);
    });

    test('props includes all fields in correct order', () {
      const params = ImportAssessmentFromExcelParams(
        filePath: '/f',
        importSectionDetails: false,
        validateAfterImport: true,
        preserveExistingData: true,
        saveAfterImport: true,
        existingAssessmentId: 'id',
        mergeWithExisting: true,
      );
      expect(params.props, ['/f', false, true, true, true, 'id', true]);
    });

    test('value equality', () {
      const p1 = ImportAssessmentFromExcelParams(filePath: '/f');
      const p2 = ImportAssessmentFromExcelParams(filePath: '/f');
      expect(p1, equals(p2));
    });
  });
}

class TestableImportServiceFactory {
  static ImportService? mockService;
  static bool shouldThrowOnCreate = false;
  static String? throwMessage;

  static ImportService createImportService(String format) {
    if (shouldThrowOnCreate) {
      throw ImportException(message: throwMessage ?? 'Error');
    }
    return mockService!;
  }

  static bool isFormatSupported(String format) {
    return [
      'xlsx',
      'xls',
      'excel',
      'csv',
      'json',
    ].contains(format.toLowerCase());
  }

  static List<String> getSupportedFormats() {
    return ['xlsx', 'xls', 'excel', 'csv', 'json'];
  }
}

class TestableImportServiceFactoryAdapter
    implements ImportServiceFactoryProtocol {
  @override
  ImportService create(String format) =>
      TestableImportServiceFactory.createImportService(format);

  @override
  bool isSupported(String format) =>
      TestableImportServiceFactory.isFormatSupported(format);

  @override
  List<String> getSupportedFormats() =>
      TestableImportServiceFactory.getSupportedFormats();

  @override
  List<String> getMimeTypesForFormat(String format) =>
  // if you have a production method, delegate to that, otherwise just
  // return an empty list or mirror getSupportedFormats
  ImportServiceFactory.getMimeTypesForFormat(format);
}
