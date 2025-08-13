import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/services/excel_import_service.dart';

import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/import_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_state.dart';

@GenerateMocks([
  ImportAssessmentUsecase,
  ImportAssessmentFromExcel,
  GetImportStatistics,
  AssessmentRepository,
  ExcelImportService,
  ImportService,
])
import 'import_assessment_bloc_test.mocks.dart';

void main() {
  late MockImportAssessmentUsecase mockImportUsecase;
  late MockImportAssessmentFromExcel mockExcelUsecase;
  late MockGetImportStatistics mockGetStats;
  late MockAssessmentRepository mockRepo;
  late ImportAssessmentBloc bloc;
  late MockExcelImportService mockExcelService;

  final dummyAssessment = AssessmentFormModel(
    id: '1',
    assessorInfo: AssessorInfoEntity(
      name: 'John',
      email: 'a@b.com',
      phoneNumber: '123',
      assessmentDate: DateTime(2021),
    ),
    geoLocation: GeoLocationEntity(
      country: 'X',
      regionProvince: 'Y',
      district: 'Z',
      cityVillage: 'V',
      addressOrCoordinates: 'Addr',
      latitude: 0,
      longitude: 0,
      locationType: FacilityLocationType.urban,
    ),
    facilityIdentification: FacilityIdentificationEntity(
      facilityCode: 'C',
      facilityName: 'N',
      managingAuthority: ManagingAuthorityType.government,
      otherManagingAuthority: null,
      directorName: 'D',
      directorPhone: 'P',
      directorEmail: 'E',
      respondentName: 'R',
      respondentPosition: 'Pos',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.standaloneTreatmentCenter,
      existingFacilityType: null,
    ),
    facilityServices: FacilityServicesEntity(
      hasOutpatientServices: true,
      hasInpatientServices: true,
      totalInpatientBeds: 10,
      icuBeds: 2,
      hasEmergencyUnit: true,
      hasIcuOrHighDependencyUnit: false,
    ),
    sections: [],
    photos: [],
    isSubmitted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // A dummy stats map
  final Map<String, dynamic> dummyStats = {'rows': 5, 'cols': 3};

  provideDummy<Either<Failure, AssessmentFormEntity>>(right(dummyAssessment));
  provideDummy<Either<Failure, Map<String, dynamic>>>(right(dummyStats));
  provideDummy<Either<Failure, bool>>(right(true));

  setUp(() {
    mockImportUsecase = MockImportAssessmentUsecase();
    mockExcelUsecase = MockImportAssessmentFromExcel();
    mockGetStats = MockGetImportStatistics();
    mockRepo = MockAssessmentRepository();
    mockExcelService = MockExcelImportService();

    bloc = ImportAssessmentBloc(
      importAssessmentUsecase: mockImportUsecase,
      importAssessmentFromExcel: mockExcelUsecase,
      getImportStatistics: mockGetStats,
      assessmentRepository: mockRepo,
      excelImportService: mockExcelService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ImportAssessmentFromFileEvent', () {
    const path = '/tmp/f.json';
    const fmt = 'json';
    final opts = ImportOptions();

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'success → [Loading, Success]',
      build: () {
        when(
          mockImportUsecase(any),
        ).thenAnswer((_) async => right(dummyAssessment));
        return bloc;
      },
      act:
          (b) => b.add(
            ImportAssessmentFromFileEvent(
              filePath: path,
              format: fmt,
              options: opts,
              saveAfterImport: true,
            ),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentSuccess(
              assessment: dummyAssessment,
              message: 'Assessment imported successfully from JSON',
            ),
          ],
      verify: (_) {
        final captured =
            verify(mockImportUsecase(captureAny)).captured.single
                as ImportAssessmentParams;
        expect(captured.filePath, path);
        expect(captured.format, fmt);
        expect(captured.options, opts);
        expect(captured.saveAfterImport, true);
      },
    );

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'failure → [Loading, Failure]',
      build: () {
        when(
          mockImportUsecase(any),
        ).thenAnswer((_) async => left(ImportFailure(message: 'oops')));
        return bloc;
      },
      act:
          (b) => b.add(
            ImportAssessmentFromFileEvent(
              filePath: path,
              format: fmt,
              options: null,
              saveAfterImport: false,
            ),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentError(message: 'oops'),
          ],
    );
  });

  group('ImportAssessmentFromExcelEvent', () {
    const path = '/tmp/f.xlsx';

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'success → [Loading, Success]',
      build: () {
        when(
          mockExcelUsecase(any),
        ).thenAnswer((_) async => right(dummyAssessment));
        return bloc;
      },
      act: (b) => b.add(const ImportAssessmentFromExcelEvent(filePath: path)),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentSuccess(
              assessment: dummyAssessment,
              message: 'Excel assessment imported successfully',
            ),
          ],
      verify: (_) {
        final p =
            verify(mockExcelUsecase(captureAny)).captured.single
                as ImportAssessmentFromExcelParams;
        expect(p.filePath, path);
        expect(p.importSectionDetails, isTrue);
        expect(p.validateAfterImport, isTrue);
        expect(p.saveAfterImport, isFalse);
      },
    );

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'failure → [Loading, Failure]',
      build: () {
        when(
          mockExcelUsecase(any),
        ).thenAnswer((_) async => left(ImportFailure(message: 'bad excel')));
        return bloc;
      },
      act:
          (b) => b.add(
            const ImportAssessmentFromExcelEvent(
              filePath: path,
              importSectionDetails: false,
              validateAfterImport: false,
              saveAfterImport: true,
            ),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentError(message: 'bad excel'),
          ],
    );
  });

  group('GetImportStatisticsEvent', () {
    const path = '/tmp/stats.csv';
    const fmt = 'csv';

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'success → [Loading, StatisticsLoaded]',
      build: () {
        when(mockGetStats(any)).thenAnswer((_) async => right(dummyStats));
        return bloc;
      },
      act:
          (b) => b.add(
            const GetImportStatisticsEvent(filePath: path, format: fmt),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportStatisticsLoaded(statistics: dummyStats),
          ],
      verify: (_) {
        final p =
            verify(mockGetStats(captureAny)).captured.single
                as GetImportStatisticsParams;
        expect(p.filePath, path);
        expect(p.format, fmt);
      },
    );

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'failure → [Loading, Failure]',
      build: () {
        when(
          mockGetStats(any),
        ).thenAnswer((_) async => left(ImportFailure(message: 'stat err')));
        return bloc;
      },
      act:
          (b) => b.add(
            const GetImportStatisticsEvent(filePath: path, format: fmt),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentError(message: 'stat err'),
          ],
    );
  });

  group('ResetImportStateEvent', () {
    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'always → [ImportInitial]',
      build: () => bloc,
      seed: () => ImportAssessmentLoading(),
      act: (b) => b.add(ResetImportStateEvent()),
      expect: () => [ImportAssessmentInitial()],
    );
  });

  group('ImportAssessmentFromExcelBytes', () {
    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'success without saveAfterImport → [Loading, Success] and no repo.save',
      build: () {
        when(
          mockExcelService.importFromBytes(
            any,
            originalName: anyNamed('originalName'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => ImportedAssessmentForm(
            assessment: dummyAssessment,
            format: 'xlsx',
            filePath: '',
            importedAt: DateTime.now(),
          ),
        );
        return bloc;
      },
      act:
          (b) => b.add(
            ImportAssessmentFromExcelBytes(
              bytes: Uint8List.fromList(const [1, 2, 3]),
              originalName: 'f.xlsx',
              saveAfterImport: false,
            ),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentSuccess(
              assessment: dummyAssessment,
              message: 'Excel assessment imported successfully',
            ),
          ],
      verify: (_) {
        verify(
          mockExcelService.importFromBytes(
            Uint8List.fromList([1, 2, 3]),
            originalName: 'f.xlsx',
            options: null,
          ),
        ).called(1);
        verifyNever(mockRepo.saveAssessment(any));
      },
    );

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'success with saveAfterImport → [Loading, Success] and repo.save called',
      build: () {
        when(
          mockExcelService.importFromBytes(
            any,
            originalName: anyNamed('originalName'),
          ),
        ).thenAnswer(
          (_) async => ImportedAssessmentForm(
            assessment: dummyAssessment,
            format: 'xlsx',
            filePath: '',
            importedAt: DateTime.now(),
          ),
        );
        when(mockRepo.saveAssessment(any)).thenAnswer((_) async => right(true));
        return bloc;
      },
      act:
          (b) => b.add(
            ImportAssessmentFromExcelBytes(
              bytes: Uint8List.fromList(const [4, 5, 6]),
              originalName: 'g.xlsx',
              saveAfterImport: true,
            ),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentSuccess(
              assessment: dummyAssessment,
              message: 'Excel assessment imported successfully',
            ),
          ],
      verify: (_) {
        verify(
          mockExcelService.importFromBytes(
            Uint8List.fromList([4, 5, 6]),
            originalName: 'g.xlsx',
          ),
        ).called(1);
        verify(mockRepo.saveAssessment(any)).called(1);
      },
    );

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'throws ImportException → [Loading, ImportError]',
      build: () {
        when(
          mockExcelService.importFromBytes(
            any,
            originalName: anyNamed('originalName'),
          ),
        ).thenThrow(ImportException(message: 'corrupt'));
        return bloc;
      },
      act:
          (b) => b.add(
            ImportAssessmentFromExcelBytes(
              bytes: Uint8List.fromList(const [9, 9, 9]),
              originalName: 'bad.xlsx',
              saveAfterImport: false,
            ),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentError(message: 'corrupt'),
          ],
    );

    blocTest<ImportAssessmentBloc, ImportAssessmentState>(
      'throws generic Exception → [Loading, Error with e.toString()]',
      build: () {
        when(
          mockExcelService.importFromBytes(
            any,
            originalName: anyNamed('originalName'),
            options: anyNamed('options'),
          ),
        ).thenThrow(Exception('boom'));
        return bloc;
      },
      act:
          (b) => b.add(
            ImportAssessmentFromExcelBytes(
              bytes: Uint8List.fromList(const [7, 8, 9]),
              originalName: 'x.xlsx',
              saveAfterImport: false,
            ),
          ),
      expect:
          () => [
            ImportAssessmentLoading(),
            ImportAssessmentError(message: 'Exception: boom'),
          ],
    );
  });
}
