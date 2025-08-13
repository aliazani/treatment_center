import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/network/network_info.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';
import 'package:treatment_center/core/services/excel_import_service.dart';
import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/repositories/assessment_repository_impl.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/injection_container.dart' as di;

import '../../../../fixtures/test_assessment_fixtures.dart';
import 'assessment_repository_impl_test.mocks.dart';

@GenerateMocks([
  AssessmentLocalDataSource,
  AssessmentRemoteDataSource,
  NetworkInfo,
  FileProvider,
  FileWrapper,
  ImportService,
  ExcelImportService,
])
void main() {
  late MockFileProvider mockFileProvider;
  late File realTempFile;
  late MockAssessmentLocalDataSource mockLocalDataSource;
  late MockAssessmentRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late AssessmentRepositoryImpl repository;
  late MockFileWrapper mockFileWrapper;

  const dummyName = '/dummy.xlsx';

  setUp(() async {
    // 1 Reset GetIt before anything else
    await di.sl.reset();

    // 2 Register your FileProvider mock
    mockFileProvider = MockFileProvider();
    mockFileWrapper = MockFileWrapper();
    di.sl.registerLazySingleton<FileProvider>(() => mockFileProvider);

    // 3 Create a real temp file so all File methods work out‐of‐the‐box
    realTempFile = File('${Directory.systemTemp.path}$dummyName');
    if (!await realTempFile.exists()) {
      await realTempFile.create(recursive: true);
    }
    // write at least one byte
    await realTempFile.writeAsBytes(<int>[0]);

    // 4 Stub FileProvider to return a FileWrapper around the real file
    when(
      mockFileProvider.getFile(any),
    ).thenAnswer((_) async => mockFileWrapper);

    // 4a️ Stub the FileWrapper async APIs
    when(mockFileWrapper.exists()).thenAnswer((_) async => true);
    when(
      mockFileWrapper.length(),
    ).thenAnswer((_) async => realTempFile.length());
    when(mockFileWrapper.raw).thenReturn(realTempFile);

    // 4b️ Stub readAsBytes to accept a FileWrapper
    when(
      mockFileProvider.readAsBytes(mockFileWrapper),
    ).thenAnswer((_) async => await realTempFile.readAsBytes());

    // 5 Now build your other mocks & the repository
    mockLocalDataSource = MockAssessmentLocalDataSource();
    mockRemoteDataSource = MockAssessmentRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AssessmentRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tAssessmentId = 'test-assessment-id';
  final tAssessment = TestAssessmentFixtures.createTestAssessmentForm(
    id: tAssessmentId,
  );
  final tAssessmentModel = AssessmentFormModel.fromEntity(tAssessment);
  final tAssessments = [tAssessment];
  final tAssessmentModels = [tAssessmentModel];
  final tEmail = 'test@example.com';

  // Helper function to create ImportedAssessmentForm
  group('getAllAssessments', () {
    test(
      'should return list of assessment forms when local data source call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getAllAssessments(),
        ).thenAnswer((_) async => tAssessmentModels);

        // act
        final result = await repository.getAllAssessments();

        // assert
        verify(mockLocalDataSource.getAllAssessments());
        result.fold(
          (failure) => fail('Expected Right, but got Left: $failure'),
          (assessments) {
            expect(assessments.length, tAssessments.length);
            expect(assessments.first.id, tAssessments.first.id);

            // Verify other important fields if needed
            expect(
              assessments.first.assessorInfo.name,
              tAssessments.first.assessorInfo.name,
            );
            expect(
              assessments.first.geoLocation.country,
              tAssessments.first.geoLocation.country,
            );
            expect(
              assessments.first.facilityIdentification.facilityName,
              tAssessments.first.facilityIdentification.facilityName,
            );
          },
        );
      },
    );

    test(
      'should return CacheFailure when local data source throws a CacheException',
      () async {
        // arrange
        when(mockLocalDataSource.getAllAssessments()).thenThrow(
          CacheException(
            message: 'Failed to fetch assessments from local storage',
            code: 'CACHE_ERROR',
            s: 'getAllAssessments',
          ),
        );

        // act
        final result = await repository.getAllAssessments();

        // assert
        verify(mockLocalDataSource.getAllAssessments());
        expect(result.isLeft(), true);
        expect(
          (result as Left).value,
          isA<CacheFailure>().having(
            (f) => f.message,
            'message',
            contains('Failed to fetch assessments'),
          ),
        );
      },
    );

    test(
      'should return UnexpectedFailure when local data source throws an unexpected exception',
      () async {
        // arrange
        final tException = Exception('Unexpected error');
        when(mockLocalDataSource.getAllAssessments()).thenThrow(tException);

        // act
        final result = await repository.getAllAssessments();

        // assert
        verify(mockLocalDataSource.getAllAssessments());
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<UnexpectedFailure>());

        result.fold((failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Unexpected error'));
        }, (_) => fail('Expected Left, but got Right'));
      },
    );
  });

  group('getAssessment', () {
    test(
      'should return assessment form when local data source call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getAssessment(any),
        ).thenAnswer((_) async => tAssessmentModel);

        // act
        final result = await repository.getAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.getAssessment(tAssessmentId));
        result.fold(
          (failure) => fail('Expected Right, but got Left: $failure'),
          (assessment) {
            expect(assessment.id, tAssessment.id);
            expect(assessment.assessorInfo.name, tAssessment.assessorInfo.name);
            expect(
              assessment.geoLocation.country,
              tAssessment.geoLocation.country,
            );
            expect(
              assessment.facilityIdentification.facilityName,
              tAssessment.facilityIdentification.facilityName,
            );
          },
        );
      },
    );

    test(
      'should return CacheFailure when local data source throws a CacheException',
      () async {
        // arrange
        when(mockLocalDataSource.getAssessment(any)).thenThrow(
          CacheException(
            message: 'Failed to fetch assessment from local storage',
            code: 'CACHE_ERROR',
            s: 'getAssessment',
          ),
        );

        // act
        final result = await repository.getAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.getAssessment(tAssessmentId));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<CacheFailure>());
        result.fold((failure) {
          expect(failure, isA<CacheFailure>());
          expect(
            (failure as CacheFailure).message,
            contains('Failed to fetch assessment from local storage.'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return UnexpectedFailure when local data source throws an unexpected exception',
      () async {
        // arrange
        final tException = Exception('Unexpected error');
        when(mockLocalDataSource.getAssessment(any)).thenThrow(tException);

        // act
        final result = await repository.getAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.getAssessment(tAssessmentId));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<UnexpectedFailure>());

        result.fold((failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(
            (failure as UnexpectedFailure).message,
            contains('Unexpected error'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );
  });

  group('saveAssessment', () {
    test('should save assessment locally and return success', () async {
      // arrange
      when(
        mockLocalDataSource.saveAssessment(any),
      ).thenAnswer((_) async => true);

      // act
      final result = await repository.saveAssessment(tAssessment);

      // assert
      verify(mockLocalDataSource.saveAssessment(any));
      expect(result, const Right(true));
    });

    test(
      'should return CacheFailure when local data source throws a CacheException',
      () async {
        // arrange
        when(mockLocalDataSource.saveAssessment(any)).thenThrow(
          CacheException(
            message: 'Failed to save assessment',
            code: 'CACHE_ERROR',
            s: 'saveAssessment',
          ),
        );

        // act
        final result = await repository.saveAssessment(tAssessment);

        // assert
        verify(mockLocalDataSource.saveAssessment(any));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<CacheFailure>());
        result.fold((failure) {
          expect(failure, isA<CacheFailure>());
          expect(
            (failure as CacheFailure).message,
            contains('Failed to save assessment'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return UnexpectedFailure when local data source throws an unexpected exception',
      () async {
        // arrange
        final tException = Exception('Unexpected error');
        when(mockLocalDataSource.saveAssessment(any)).thenThrow(tException);

        // act
        final result = await repository.saveAssessment(tAssessment);

        // assert
        verify(mockLocalDataSource.saveAssessment(any));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<UnexpectedFailure>());

        result.fold((failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(
            (failure as UnexpectedFailure).message,
            contains('Unexpected error'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );
  });

  group('deleteAssessment', () {
    test('should delete assessment locally and return success', () async {
      // arrange
      when(
        mockLocalDataSource.deleteAssessment(any),
      ).thenAnswer((_) async => true);

      // act
      final result = await repository.deleteAssessment(tAssessmentId);

      // assert
      verify(mockLocalDataSource.deleteAssessment(tAssessmentId));
      expect(result, const Right(true));
    });

    test(
      'should return CacheFailure when local data source throws a CacheException',
      () async {
        // arrange
        when(mockLocalDataSource.deleteAssessment(any)).thenThrow(
          CacheException(
            message: 'Failed to delete assessment',
            code: 'CACHE_ERROR',
            s: 'deleteAssessment',
          ),
        );

        // act
        final result = await repository.deleteAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.deleteAssessment(tAssessmentId));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<CacheFailure>());

        result.fold((failure) {
          expect(failure, isA<CacheFailure>());
          expect(
            (failure as CacheFailure).message,
            contains('Failed to delete assessment'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return UnexpectedFailure when local data source throws an unexpected exception',
      () async {
        // arrange
        final tException = Exception('Unexpected error');
        when(mockLocalDataSource.deleteAssessment(any)).thenThrow(tException);

        // act
        final result = await repository.deleteAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.deleteAssessment(tAssessmentId));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<UnexpectedFailure>());

        result.fold((failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(
            (failure as UnexpectedFailure).message,
            contains('Unexpected error'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );
  });

  group('validateFileForImport', () {
    const validFormat = 'xlsx';

    setUp(() async {
      await di.sl.reset();

      // Provide the FileProvider the service asks GetIt for
      di.sl.registerLazySingleton<FileProvider>(() => mockFileProvider);

      // Happy-path stub: a 1-byte XLSX temp file that passes all checks
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);
      when(
        mockFileProvider.readAsBytes(any),
      ).thenAnswer((_) async => realTempFile.readAsBytes());
    });

    test(
      'returns FileOperationFailure when FileProvider throws FileException',
      () async {
        when(
          mockFileProvider.getFile(any),
        ).thenThrow(FileException(message: 'I/O error while reading'));

        final result = await repository.validateFileForImport(
          '/any/path.xlsx',
          validFormat,
        );

        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<FileOperationFailure>());
          expect(f.message, 'I/O error while reading');
        }, (_) => fail('Expected Left(FileOperationFailure)'));
      },
    );

    test(
      'returns UnexpectedFailure when FileProvider throws generic Exception',
      () async {
        when(
          mockFileProvider.getFile(any),
        ).thenThrow(Exception('Something went sideways'));

        final result = await repository.validateFileForImport(
          '/any/path.xlsx',
          validFormat,
        );

        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<UnexpectedFailure>());
          expect(f.message, contains('Something went sideways'));
        }, (_) => fail('Expected Left(UnexpectedFailure)'));
      },
    );

    test('returns Right(true) when validation succeeds', () async {
      // Default stubs in setUp() already point to a tiny valid file.
      final result = await repository.validateFileForImport(
        realTempFile.path,
        validFormat,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right(true)'),
        (ok) => expect(ok, isTrue),
      );
    });

    test('returns ValidationFailure for unsupported format', () async {
      final result = await repository.validateFileForImport(
        '/invalid/path/file.txt',
        'invalid_format',
      );

      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ValidationFailure>());
        expect(f.message, contains('Unsupported import format'));
      }, (_) => fail('Expected Left(ValidationFailure)'));
    });
  });

  group('importAssessment', () {
    setUp(() async {
      await di.sl.reset();
      di.sl.registerLazySingleton<FileProvider>(() => mockFileProvider);
    });

    test('returns ValidationFailure for unsupported format', () async {
      final result = await repository.importAssessment(
        '/any/path.xlsx',
        'invalid',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
      'returns FileOperationFailure when FileProvider throws FileException',
      () async {
        when(
          mockFileProvider.getFile(any),
        ).thenThrow(FileException(message: 'disk error'));

        final result = await repository.importAssessment(
          '/any/path.xlsx',
          'xlsx',
        );

        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<FileOperationFailure>());
          expect((f as FileOperationFailure).message, 'disk error');
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      'returns ImportFailure when FileProvider throws generic Exception',
      () async {
        // Arrange – FileProvider blows up with a generic exception
        when(mockFileProvider.getFile(any)).thenThrow(Exception('oops'));

        // Act
        final result = await repository.importAssessment(
          '/any/path.xlsx',
          'xlsx',
        );

        // Assert – ExcelImportService wraps the Exception into ImportException
        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<ImportFailure>());
          expect(
            f.message,
            contains('oops'),
          ); // wrapped message still contains 'oops'
        }, (_) => fail('Expected Left(ImportFailure)'));
      },
    );

    test(
      'returns ImportFailure when ExcelImportService throws ImportException',
      () async {
        // Stub readAsBytes so Excel package will throw ImportException
        when(
          mockFileProvider.readAsBytes(any),
        ).thenThrow(ImportException(message: 'import failed'));

        final result = await repository.importAssessment(
          '/any/path.xlsx',
          'xlsx',
        );

        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<ImportFailure>());
          expect((f as ImportFailure).message, 'import failed');
        }, (_) => fail('Expected Left'));
      },
    );

    test('returns Right(entity) when real import succeeds', () async {
      // 1️⃣ Build a tiny workbook the ExcelImportService understands
      final excel = Excel.createExcel();
      excel['Sheet1'].cell(CellIndex.indexByString('A1')).value = TextCellValue(
        'dummy',
      );
      final bytes = excel.encode()!;

      final file = File('${Directory.systemTemp.path}/good.xlsx');
      await file.writeAsBytes(bytes);

      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);
      when(
        mockFileProvider.readAsBytes(any),
      ).thenAnswer((_) async => Uint8List.fromList(bytes));

      // 2️⃣ Act
      final result = await repository.importAssessment(file.path, 'xlsx');

      // 3️⃣ Assert – now the real service can succeed
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (entity) => expect(entity, isA<AssessmentFormEntity>()),
      );
    });

    test('returns UnexpectedFailure when DI is mis-configured', () async {
      //  Remove FileProvider from GetIt so ExcelImportService’s constructor fails
      await di.sl.reset(); // wipes the previous registration
      // (do NOT re-register FileProvider)

      // Act – the factory will try to sl<FileProvider>() → throws, bubbles up
      final result = await repository.importAssessment(
        '/any/path.xlsx',
        'xlsx',
      );

      //  Assert – repository falls through to the generic catch → UnexpectedFailure
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left(UnexpectedFailure)'),
      );
    });
  });

  group('importAssessmentFromExcel', () {
    late AssessmentRepositoryImpl repo;

    setUp(() async {
      await di.sl.reset();
      di.sl.registerLazySingleton<FileProvider>(() => mockFileProvider);

      // default happy-path local save
      when(
        mockLocalDataSource.saveAssessment(any),
      ).thenAnswer((_) async => true);
    });

    test(
      'Right(entity) when import succeeds & saveAfterImport = false',
      () async {
        repo = _RepoStub(
          local: mockLocalDataSource,
          remote: mockRemoteDataSource,
          net: mockNetworkInfo,
          behaviour: () async => Right(tAssessmentModel),
        );

        final result = await repo.importAssessmentFromExcel(
          '/tmp/file.xlsx',
          saveAfterImport: false,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (e) => expect(e, tAssessmentModel),
        );
        verifyNever(mockLocalDataSource.saveAssessment(any));
      },
    );

    test('Right(entity) when import succeeds and save succeeds', () async {
      // (saveAssessment already stubbed to return true)
      repo = _RepoStub(
        local: mockLocalDataSource,
        remote: mockRemoteDataSource,
        net: mockNetworkInfo,
        behaviour: () async => Right(tAssessmentModel),
      );

      final result = await repo.importAssessmentFromExcel('/tmp/file.xlsx');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (e) => expect(e, tAssessmentModel),
      );
      verify(mockLocalDataSource.saveAssessment(any)).called(1);
    });

    test('UnexpectedFailure when saveAssessment returns false', () async {
      when(
        mockLocalDataSource.saveAssessment(any),
      ).thenAnswer((_) async => false);

      repo = _RepoStub(
        local: mockLocalDataSource,
        remote: mockRemoteDataSource,
        net: mockNetworkInfo,
        behaviour: () async => Right(tAssessmentModel),
      );

      final result = await repo.importAssessmentFromExcel('/tmp/file.xlsx');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('UnexpectedFailure when importAssessment itself throws', () async {
      repo = _RepoStub(
        local: mockLocalDataSource,
        remote: mockRemoteDataSource,
        net: mockNetworkInfo,
        behaviour: () async => throw StateError('boom'),
      );

      final result = await repo.importAssessmentFromExcel('/tmp/file.xlsx');

      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<UnexpectedFailure>());
        expect(f.message, contains('boom'));
      }, (_) => fail('Expected Left'));
    });

    test(
      'propagates failure when saveAssessment throws CacheException',
      () async {
        // Arrange
        // importAssessment succeeds
        final importResult = createMockImportResult(tAssessmentModel);
        final repo = _RepoStub(
          local: mockLocalDataSource,
          remote: mockRemoteDataSource,
          net: mockNetworkInfo,
          behaviour: () async => Right(importResult.assessment),
        );

        // saveAssessment → Left(CacheFailure) (via CacheException)
        when(mockLocalDataSource.saveAssessment(any)).thenThrow(
          CacheException(
            message: 'Failed to save assessment locally.',
            code: 'CACHE_ERR',
            s: 'saveAssessment',
          ),
        );

        // Act
        final result = await repo.importAssessmentFromExcel('/tmp/file.xlsx');

        // Assert – the failure is returned unchanged by the fold
        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, contains('Failed to save assessment locally.'));
        }, (_) => fail('Expected Left(CacheFailure)'));
      },
    );
  });

  group('submitAssessmentViaFirebaseEmail', () {
    test(
      'should return true when submission is successful and network is connected',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            any,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        ).thenAnswer((_) async => true);
        when(
          mockLocalDataSource.saveAssessment(any),
        ).thenAnswer((_) async => true);

        // act
        final result = await repository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            tEmail,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        );
        verify(mockLocalDataSource.saveAssessment(any));
        expect(result, const Right(true));
      },
    );

    test(
      'should return ConnectionFailure when network is not connected',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verifyNever(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            any,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        );
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ConnectionFailure>());
          expect(
            (failure as ConnectionFailure).message,
            contains('No internet connection'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return ServerFailure when ServerException is thrown',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            any,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        ).thenThrow(
          ServerException(
            message: 'Firebase server error',
            code: 'SERVER_ERROR',
          ),
        );

        // act
        final result = await repository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            tEmail,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        );
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            contains('Firebase server error'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return ValidationFailure when ValidationException is thrown',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            any,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        ).thenThrow(ValidationException(message: 'Invalid email format'));

        // act
        final result = await repository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          'invalid-email',
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            'invalid-email',
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        );
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            (failure as ValidationFailure).message,
            contains('Validation error'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return UnexpectedFailure when unexpected exception occurs',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            any,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        ).thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(
          mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
            any,
            tEmail,
            exportFormats: anyNamed('exportFormats'),
            subject: anyNamed('subject'),
            body: anyNamed('body'),
            exportOptions: anyNamed('exportOptions'),
          ),
        );
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(
            (failure as UnexpectedFailure).message,
            contains('Failed to submit via Firebase'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test('should not save locally when submission fails', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
          any,
          any,
          exportFormats: anyNamed('exportFormats'),
          subject: anyNamed('subject'),
          body: anyNamed('body'),
          exportOptions: anyNamed('exportOptions'),
        ),
      ).thenAnswer((_) async => false);

      // act
      final result = await repository.submitAssessmentViaFirebaseEmail(
        tAssessment,
        tEmail,
      );

      // assert
      verify(mockNetworkInfo.isConnected);
      verify(
        mockRemoteDataSource.submitAssessmentViaFirebaseEmail(
          any,
          tEmail,
          exportFormats: anyNamed('exportFormats'),
          subject: anyNamed('subject'),
          body: anyNamed('body'),
          exportOptions: anyNamed('exportOptions'),
        ),
      );
      verifyNever(mockLocalDataSource.saveAssessment(any));
      expect(result, const Right(false));
    });
  });

  group('uploadAssessmentToFirebase', () {
    const tStoragePath = 'assessments/test-assessment-id.json';

    test(
      'should return storage path when upload is successful and network is connected',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.uploadAssessment(any),
        ).thenAnswer((_) async => tStoragePath);

        // act
        final result = await repository.uploadAssessmentToFirebase(tAssessment);

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.uploadAssessment(any));
        expect(result, const Right(tStoragePath));
      },
    );

    test(
      'should return ConnectionFailure when network is not connected',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.uploadAssessmentToFirebase(tAssessment);

        // assert
        verify(mockNetworkInfo.isConnected);
        verifyNever(mockRemoteDataSource.uploadAssessment(any));
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ConnectionFailure>());
          expect(
            (failure as ConnectionFailure).message,
            contains('No internet connection'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return ServerFailure when ServerException is thrown',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.uploadAssessment(any)).thenThrow(
          ServerException(
            message: 'Firebase upload failed',
            code: 'UPLOAD_ERROR',
          ),
        );

        // act
        final result = await repository.uploadAssessmentToFirebase(tAssessment);

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.uploadAssessment(any));
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            contains('Firebase upload error'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return UnexpectedFailure when unexpected exception occurs',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.uploadAssessment(any),
        ).thenThrow(Exception('Network timeout'));

        // act
        final result = await repository.uploadAssessmentToFirebase(tAssessment);

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.uploadAssessment(any));
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(
            (failure as UnexpectedFailure).message,
            contains('Failed to upload to Firebase'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );
  });
  group('deleteAllAssessments', () {
    test('returns ValidationFailure when given empty list', () async {
      // act
      final result = await repository.deleteAllAssessments([]);
      // assert
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ValidationFailure>());
        expect(f.message, 'No assessment IDs provided');
      }, (_) => fail('Expected Left(ValidationFailure), got Right'));
    });

    test('returns ValidationFailure when none of the IDs exist', () async {
      // arrange: local has only tAssessmentModel.id
      when(
        mockLocalDataSource.getAllAssessments(),
      ).thenAnswer((_) async => tAssessmentModels);
      // act
      final result = await repository.deleteAllAssessments(['foo', 'bar']);
      // assert
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ValidationFailure>());
        expect(f.message, 'No valid assessments found to delete');
      }, (_) => fail('Expected Left(ValidationFailure), got Right'));
    });

    test(
      'returns Right(true) when some IDs are valid and deletion succeeds',
      () async {
        // arrange: local has tAssessmentModel.id only
        when(
          mockLocalDataSource.getAllAssessments(),
        ).thenAnswer((_) async => tAssessmentModels);
        when(
          mockLocalDataSource.deleteAllAssessments(['test-assessment-id']),
        ).thenAnswer((_) async => true);
        // act
        final result = await repository.deleteAllAssessments([
          'test-assessment-id',
          'non-existent',
        ]);
        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right(true), got Left'),
          (ok) => expect(ok, isTrue),
        );
        verify(
          mockLocalDataSource.deleteAllAssessments(['test-assessment-id']),
        );
      },
    );

    test('returns CacheFailure when deletion returns false', () async {
      // arrange: local has tAssessmentModel.id only
      when(
        mockLocalDataSource.getAllAssessments(),
      ).thenAnswer((_) async => tAssessmentModels);
      when(
        mockLocalDataSource.deleteAllAssessments(['test-assessment-id']),
      ).thenAnswer((_) async => false);
      // act
      final result = await repository.deleteAllAssessments([
        'test-assessment-id',
      ]);
      // assert
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<CacheFailure>());
        expect(f.message, 'Failed to delete some or all assessments');
      }, (_) => fail('Expected Left(CacheFailure), got Right'));
    });

    test(
      'returns CacheFailure when localDataSource.deleteAllAssessments throws CacheException',
      () async {
        // arrange
        when(
          mockLocalDataSource.getAllAssessments(),
        ).thenAnswer((_) async => tAssessmentModels);
        when(mockLocalDataSource.deleteAllAssessments(any)).thenThrow(
          CacheException(
            message: 'boom!',
            code: 'C1',
            s: 'deleteAllAssessments',
          ),
        );
        // act
        final result = await repository.deleteAllAssessments([
          'test-assessment-id',
        ]);
        // assert
        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<CacheFailure>());
          expect(
            f.message,
            contains('Failed to delete assessments from local storage: boom!'),
          );
        }, (_) => fail('Expected Left(CacheFailure), got Right'));
      },
    );

    test(
      'returns UnexpectedFailure when getAllAssessments throws generic Exception',
      () async {
        // arrange
        when(
          mockLocalDataSource.getAllAssessments(),
        ).thenThrow(Exception('uh oh'));
        // act
        final result = await repository.deleteAllAssessments(['id1']);
        // assert
        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<UnexpectedFailure>());
          expect(
            f.message,
            contains('Unexpected error during bulk deletion: Exception: uh oh'),
          );
        }, (_) => fail('Expected Left(UnexpectedFailure), got Right'));
      },
    );
  });
}

/// Handy helper so the import-service mock can return a valid result
ImportedAssessmentForm createMockImportResult(
  AssessmentFormModel model, {
  String path = '/tmp/mock.xlsx',
  String format = 'excel',
}) {
  return ImportedAssessmentForm(
    assessment: model,
    filePath: path,
    format: format,
    importedAt: DateTime.now(),
  );
}

/// Helper stub so we can force `importAssessment` to return or throw
class _RepoStub extends AssessmentRepositoryImpl {
  _RepoStub({
    required AssessmentLocalDataSource local,
    required AssessmentRemoteDataSource remote,
    required NetworkInfo net,
    required this.behaviour,
  }) : super(
         localDataSource: local,
         remoteDataSource: remote,
         networkInfo: net,
       );

  /// What `importAssessment` should do for this test
  final Future<Either<Failure, AssessmentFormEntity>> Function() behaviour;

  @override
  Future<Either<Failure, AssessmentFormEntity>> importAssessment(
    String filePath,
    String format, {
    ImportOptions? options,
  }) => behaviour();
}
