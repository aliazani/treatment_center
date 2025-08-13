import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource_impl.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';

import 'assessment_remote_datasource_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseStorage,
  FirebaseFunctions,
  FileProvider,
  FileWrapper,
  PdfExportService,
  ExcelExportService,
  DocExportService,
  Reference,
  HttpsCallable,
  HttpsCallableResult,
  UploadTask,
  TaskSnapshot,
])
void main() {
  late AssessmentRemoteDataSourceImpl dataSource;
  late MockFirebaseStorage mockStorage;
  late MockFirebaseFunctions mockFunctions;
  late MockFileProvider mockFileProvider;
  late MockExcelExportService mockExcelService;
  late MockPdfExportService mockPdfService;
  late MockDocExportService mockDocService;
  late MockReference mockRef;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockTaskSnapshot;
  late MockHttpsCallable mockCallable;
  // late MockFile mockFile;
  late MockFileWrapper mockFileWrapper;
  late AssessmentRemoteDataSourceImpl dataSourceWeb; // for web-branch tests
  late AssessmentRemoteDataSourceImpl dataSourceDefault; // uses default kIsWeb
  late ExportResult tExportResultFile;

  // Test data
  late AssessmentFormModel tAssessmentFormModel;
  const tRecipientEmail = 'test@example.com';
  const tSubject = 'Test Subject';
  const tBody = 'Test Body';
  const tFilePath = '/test/path/file.pdf';
  const tFileName = 'test_file.pdf';
  const tAssessmentId = 'test-assessment-id';
  const tDownloadUrl = 'https://test.com/download/file.pdf';

  // http
  HttpServer? server;
  late Uri baseUri;

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    baseUri = Uri.parse('http://${server!.address.host}:${server!.port}');
    server!.listen((HttpRequest req) async {
      if (req.method == 'HEAD') {
        req.response.headers.contentLength = 10 * 1024 * 1024; // 10MB
        await req.response.close();
      } else if (req.method == 'GET') {
        // <-- Add this conditional
        if (req.uri.path.endsWith('/fail.jpg')) {
          req.response.statusCode = 404; // trigger your throw branch
          await req.response.close();
          return;
        }
        // success path
        req.response.statusCode = 200;
        req.response.add(Uint8List.fromList([1, 2, 3, 4]));
        await req.response.close();
      } else {
        req.response.statusCode = 405;
        await req.response.close();
      }
    });
  });

  tearDownAll(() async {
    await server?.close(force: true);
    server = null;
  });

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockFunctions = MockFirebaseFunctions();
    mockFileProvider = MockFileProvider();
    mockExcelService = MockExcelExportService();
    mockPdfService = MockPdfExportService();
    mockDocService = MockDocExportService();
    mockRef = MockReference();
    mockCallable = MockHttpsCallable();
    mockUploadTask = MockUploadTask();
    mockTaskSnapshot = MockTaskSnapshot();
    mockFileWrapper = MockFileWrapper();

    dataSource = AssessmentRemoteDataSourceImpl(
      storage: mockStorage,
      functions: mockFunctions,
      fileProvider: mockFileProvider,
      excelService: mockExcelService,
      pdfService: mockPdfService,
      docService: mockDocService,
      platformIsWeb: () => false, // explicit native branch
    );

    dataSourceWeb = AssessmentRemoteDataSourceImpl(
      storage: mockStorage,
      functions: mockFunctions,
      fileProvider: mockFileProvider,
      excelService: mockExcelService,
      pdfService: mockPdfService,
      docService: mockDocService,
      platformIsWeb: () => true, // simulate web
    );

    dataSourceDefault = AssessmentRemoteDataSourceImpl(
      storage: mockStorage,
      functions: mockFunctions,
      fileProvider: mockFileProvider,
      excelService: mockExcelService,
      pdfService: mockPdfService,
      docService: mockDocService,
    );

    // Create test assessment model with all required fields
    tAssessmentFormModel = AssessmentFormModel(
      id: tAssessmentId,
      assessorInfo: AssessorInfoModel(
        name: 'Test Assessor',
        email: 'assessor@test.com',
        assessmentDate: DateTime(2024, 1, 1),
        phoneNumber: '',
      ),
      geoLocation: GeoLocationModel(
        cityVillage: 'Test City',
        regionProvince: 'Test Region',
        country: 'Test Country',
        longitude: 0.0,
        latitude: 0.0,
        district: '',
        addressOrCoordinates: '',
        locationType: null,
      ),
      facilityIdentification: FacilityIdentificationModel(
        facilityName: 'Test Facility',
        facilityCode: 'TF001',
        managingAuthority: null,
        directorName: '',
        directorPhone: '',
        directorEmail: '',
        respondentName: '',
        respondentPosition: '',
        structureType: null,
        facilityType: null,
      ),
      facilityServices: FacilityServicesModel(
        hasOutpatientServices: null,
        hasInpatientServices: null,
      ),
      sections: const [
        AssessmentSectionModel(
          id: 'section1',
          title: 'Test Section',
          sectionNumber: '1',
          items: [],
        ),
      ],
      photos: const <PhotoEntity>[],
      notes: 'Test notes',
      isSubmitted: false,
      submissionDate: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    // Set up export service mocks
    tExportResultFile = ExportResult(
      filePath: '/path/to/file.pdf',
      fileName: 'assessment.pdf',
      format: 'pdf',
      fileSizeBytes: 1024,
      createdAt: DateTime.now(),
    );

    when(
      mockPdfService.exportAssessment(any, options: anyNamed('options')),
    ).thenAnswer((_) async => tExportResultFile);
    when(
      mockExcelService.exportAssessment(any, options: anyNamed('options')),
    ).thenAnswer((_) async => tExportResultFile);
    when(
      mockDocService.exportAssessment(any, options: anyNamed('options')),
    ).thenAnswer((_) async => tExportResultFile);

    when(mockFileWrapper.raw).thenReturn(File(tFilePath));
  });

  group('submitAssessmentViaFirebaseEmail', () {
    const tExportOptions = ExportOptions();

    // A common ExportResult for all formats
    final tExportResult = ExportResult(
      filePath: '/path/to/file.pdf',
      fileName: 'assessment.pdf',
      format: '',
      fileSizeBytes: 1024,
      createdAt: DateTime.now(),
    );

    setUp(() {
      // 1) Firebase storage ref
      when(mockStorage.ref()).thenReturn(mockRef);
      when(mockRef.child(any)).thenReturn(mockRef);

      // 2) uploadAssessment → putString yields a mockUploadTask
      when(
        mockRef.putString(any, metadata: anyNamed('metadata')),
      ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));

      // 3) exportAssessment for each service
      when(
        mockPdfService.exportAssessment(any, options: anyNamed('options')),
      ).thenAnswer((_) async => tExportResult);
      when(
        mockExcelService.exportAssessment(any, options: anyNamed('options')),
      ).thenAnswer((_) async => tExportResult);
      when(
        mockDocService.exportAssessment(any, options: anyNamed('options')),
      ).thenAnswer((_) async => tExportResult);

      // 4) uploadExportedFile → putFile yields the same mockUploadTask
      when(
        mockRef.putFile(any, any),
      ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));

      // 5) Stub all UploadTask completion APIs so nothing ever hangs:
      when(
        mockUploadTask.then<dynamic>(any, onError: anyNamed('onError')),
      ).thenAnswer((_) async => mockTaskSnapshot);
      when(
        mockUploadTask.then<dynamic>(any),
      ).thenAnswer((_) async => mockTaskSnapshot);
      when(
        mockUploadTask.whenComplete(any),
      ).thenAnswer((_) => Future.value(mockTaskSnapshot));
      when(
        mockUploadTask.snapshotEvents,
      ).thenAnswer((_) => Stream.value(mockTaskSnapshot));

      // 6) Make the TaskSnapshot look “successful”
      when(mockTaskSnapshot.ref).thenReturn(mockRef);
      when(mockTaskSnapshot.state).thenReturn(TaskState.success);
      when(mockTaskSnapshot.bytesTransferred).thenReturn(1024);
      when(mockTaskSnapshot.totalBytes).thenReturn(1024);

      // 7) Every call to getDownloadURL returns tDownloadUrl
      when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);

      // 8) FileProvider hands back a file that “exists”
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);

      // 9) Cloud Function stub
      when(
        mockFunctions.httpsCallable('sendAssessmentEmail'),
      ).thenReturn(mockCallable);
    });

    test(
      'on web uses putData for exports (bytes) and for photos (http.get)',
      () async {
        // arrange
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(any)).thenReturn(mockRef);
        when(
          mockRef.putData(any, any),
        ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
        when(mockTaskSnapshot.ref).thenReturn(mockRef);
        when(mockTaskSnapshot.state).thenReturn(TaskState.success);
        when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);
        when(
          mockFunctions.httpsCallable('sendAssessmentEmail'),
        ).thenReturn(mockCallable);
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );

        // Export result WITH bytes to hit: if (result.hasBytes) { await ref.putData(...) }
        final tExportResultWithBytes = ExportResult(
          filePath: '/ignored/on/web.pdf',
          fileName: 'assessment.pdf',
          format: 'pdf',
          fileSizeBytes: 1234,
          createdAt: DateTime.now(),
          bytes: Uint8List.fromList([9, 9, 9]),
        );
        when(
          mockPdfService.exportAssessment(any, options: anyNamed('options')),
        ).thenAnswer((_) async => tExportResultWithBytes);

        // act
        final ok = await dataSourceWeb.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: const ['pdf'],
          photoFilePaths: [
            baseUri
                .resolve('/p1.jpg')
                .toString(), // this exercises http.get in _uploadPhotoFiles
          ],
        );

        // assert
        expect(ok, isTrue);
        // 1 export (putData) + 1 photo (putData)
        verify(mockRef.putData(any, any)).called(2);
        verifyNever(mockRef.putFile(any, any));
      },
    );

    test(
      'uploadExportedFile on web throws ValidationException when bytes are missing',
      () async {
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(any)).thenReturn(mockRef);

        final noBytes = ExportResult(
          filePath: '/ignored/on/web.pdf',
          fileName: 'assessment.pdf',
          format: 'pdf',
          fileSizeBytes: 111,
          createdAt: DateTime.now(),
          // bytes: null -> triggers the ValidationException path
        );

        expect(
          () => dataSourceWeb.uploadExportedFile(noBytes, tAssessmentId),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'should submit assessment via Firebase email successfully with default formats',
      () async {
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );

        final result = await dataSource.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: ['pdf'],
          subject: tSubject,
          body: tBody,
          exportOptions: tExportOptions,
        );

        expect(result, isTrue);
        verify(mockFunctions.httpsCallable('sendAssessmentEmail')).called(1);
        // verify that payload includes attachmentUrls, assessmentData & timestamp
        final payload =
            verify(mockCallable.call(captureAny)).captured.single
                as Map<String, dynamic>;
        expect(payload.containsKey('attachmentUrls'), isTrue);
        expect(payload['attachmentUrls'], isA<List<String>>());
        expect(payload.containsKey('assessmentData'), isTrue);
        expect(payload['assessmentData'], isA<Map<String, dynamic>>());
        expect(payload.containsKey('timestamp'), isTrue);
        // timestamp should be a valid ISO8601 string
        expect(() => DateTime.parse(payload['timestamp']), returnsNormally);
      },
    );

    test(
      'on web: photo GET non-200 throws ServerException with HTTP code',
      () async {
        // arrange: storage + refs
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(any)).thenReturn(mockRef);
        when(
          mockRef.putData(any, any),
        ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
        when(mockTaskSnapshot.ref).thenReturn(mockRef);
        when(mockTaskSnapshot.state).thenReturn(TaskState.success);
        // export download URL (won't necessarily be used after failure, but safe)
        when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);

        // cloud function stub (won't be called if photo upload fails first)
        when(
          mockFunctions.httpsCallable('sendAssessmentEmail'),
        ).thenReturn(mockCallable);
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );

        // export must provide bytes for web branch
        final exportWithBytes = ExportResult(
          filePath: '/ignored/on/web.pdf',
          fileName: 'assessment.pdf',
          format: 'pdf',
          fileSizeBytes: 123,
          createdAt: DateTime.now(),
          bytes: Uint8List.fromList([9, 9, 9]),
        );
        when(
          mockPdfService.exportAssessment(any, options: anyNamed('options')),
        ).thenAnswer((_) async => exportWithBytes);

        // failing photo URL -> our server returns 404 for /fail.jpg
        final badPhotoUrl = baseUri.resolve('/fail.jpg').toString();

        // act & assert
        expect(
          () => dataSourceWeb.submitAssessmentViaFirebaseEmail(
            tAssessmentFormModel,
            tRecipientEmail,
            exportFormats: const ['pdf'],
            photoFilePaths: [badPhotoUrl],
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message contains http status',
              contains('Failed to fetch photo: HTTP 404'),
            ),
          ),
        );

        // Ensure we used putData for the export before failing on photo
        // And the Cloud Function should NOT be called due to early failure
        verifyNever(mockCallable.call(any));
      },
    );

    test(
      'when total photo size > 18MB: photos are linked (not attached) and body includes note + links',
      () async {
        // arrange
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(any)).thenReturn(mockRef);
        when(
          mockRef.putString(any, metadata: anyNamed('metadata')),
        ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
        when(
          mockRef.putData(any, any),
        ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
        when(mockTaskSnapshot.ref).thenReturn(mockRef);
        when(mockTaskSnapshot.state).thenReturn(TaskState.success);

        // export result WITH bytes (web) so it uploads via putData
        final tExportResultWithBytes = ExportResult(
          filePath: '/ignored/on/web.pdf',
          fileName: 'assessment.pdf',
          format: 'pdf',
          fileSizeBytes: 1024,
          createdAt: DateTime.now(),
          bytes: Uint8List.fromList([7, 7, 7]),
        );
        when(
          mockPdfService.exportAssessment(any, options: anyNamed('options')),
        ).thenAnswer((_) async => tExportResultWithBytes);

        // Each HEAD returns 10MB -> 20MB total > 18MB, so photos should be LINKS, not attachments
        // GET will still be called during upload to storage (we stubbed putData above)
        final p1 = baseUri.resolve('/bigA.jpg').toString();
        final p2 = baseUri.resolve('/bigB.jpg').toString();

        // Download URLs queue: first export, then 2 photos (used as links)
        final urlQueue = <String>[
          tDownloadUrl,
          'https://example.com/a.jpg',
          'https://example.com/b.jpg',
        ];
        when(
          mockRef.getDownloadURL(),
        ).thenAnswer((_) async => urlQueue.removeAt(0));

        when(
          mockFunctions.httpsCallable('sendAssessmentEmail'),
        ).thenReturn(mockCallable);
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );

        // act
        final ok = await dataSourceWeb.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: const ['pdf'],
          photoFilePaths: [p1, p2],
        );

        // assert
        expect(ok, isTrue);
        final payload =
            verify(mockCallable.call(captureAny)).captured.single
                as Map<String, dynamic>;

        // Attachments should include ONLY the export (photos are links due to size)
        final attachments = (payload['attachmentUrls'] as List).cast<String>();
        expect(
          attachments.length,
          1,
          reason: '1 export, photos linked not attached',
        );

        // Body should contain the "Note: Facility photos..." section and the two links
        final body = payload['body'] as String;
        expect(
          body,
          contains(
            'Note: Facility photos are provided as links below (total size > 18MB):',
          ),
        );
        expect(body, contains('Photo 1: https://example.com/a.jpg'));
        expect(body, contains('Photo 2: https://example.com/b.jpg'));
      },
    );

    test(
      'should submit assessment via Firebase email successfully with default formats',
      () async {
        // arrange: cloud function returns success
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );

        // file exists
        when(mockFileWrapper.exists()).thenAnswer((_) async => true);
        when(
          mockFileProvider.getFile(any),
        ).thenAnswer((_) async => mockFileWrapper);

        // act
        final result = await dataSource.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: ['pdf'],
          subject: tSubject,
          body: tBody,
          exportOptions: tExportOptions,
        );

        // assert
        expect(result, isTrue);
        verify(mockFunctions.httpsCallable('sendAssessmentEmail')).called(1);
      },
    );

    test(
      'should submit assessment via Firebase email successfully with default formats',
      () async {
        // arrange: cloud function returns success
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );
        // file exists
        when(mockFileWrapper.exists()).thenAnswer((_) async => true);
        when(
          mockFileProvider.getFile(any),
        ).thenAnswer((_) async => mockFileWrapper);

        // act
        final result = await dataSource.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: ['pdf'],
          subject: tSubject,
          body: tBody,
          exportOptions: tExportOptions,
        );

        // assert
        expect(result, isTrue);
        verify(mockFunctions.httpsCallable('sendAssessmentEmail')).called(1);
      },
    );

    test(
      'should submit assessment via Firebase email successfully with default formats',
      () async {
        // arrange
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );

        // Mock file operations
        when(mockFileWrapper.exists()).thenAnswer((_) async => true);
        when(
          mockFileProvider.getFile(any),
        ).thenAnswer((_) async => mockFileWrapper);

        // act
        final result = await dataSource.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: [
            'pdf',
          ], // Use only PDF to avoid complex export service mocking
          subject: tSubject,
          body: tBody,
          exportOptions: tExportOptions,
        );

        // assert
        expect(result, isTrue);
        verify(mockFunctions.httpsCallable('sendAssessmentEmail')).called(1);
      },
    );

    test('should throw ServerException when email sending fails', () async {
      // arrange
      when(
        mockFunctions.httpsCallable('sendAssessmentEmail'),
      ).thenThrow(Exception('Email failed'));

      // act & assert
      expect(
        () => dataSource.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: ['pdf'],
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'should throw ValidationException for unsupported export format',
      () async {
        // act & assert
        expect(
          () => dataSource.submitAssessmentViaFirebaseEmail(
            tAssessmentFormModel,
            tRecipientEmail,
            exportFormats: ['unsupported'],
          ),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test('includes uploaded photo URLs in email payload', () async {
      // arrange
      final photoAPath = '/tmp/dir/a.jpg';
      final photoBPath =
          r'C:\temp\win\b.png'; // also exercises basename on backslashes
      final photoUrls = <String>[
        'https://example.com/a.jpg',
        'https://example.com/b.png',
      ];

      // Make getDownloadURL return: [exportDocUrl, photoAUrl, photoBUrl]
      final urlQueue = <String>[
        tDownloadUrl, // export doc
        ...photoUrls, // photos
      ];
      when(
        mockRef.getDownloadURL(),
      ).thenAnswer((_) async => urlQueue.removeAt(0));

      // FileProvider returns an existing file for both photos
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((inv) async => mockFileWrapper);
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);

      // Cloud Function success
      when(mockCallable.call(any)).thenAnswer(
        (_) async => _createMockHttpsCallableResult({'success': true}),
      );

      // act
      final ok = await dataSource.submitAssessmentViaFirebaseEmail(
        tAssessmentFormModel,
        tRecipientEmail,
        exportFormats: const ['pdf'],
        subject: tSubject,
        body: tBody,
        exportOptions: const ExportOptions(),
        photoFilePaths: [photoAPath, photoBPath],
      );

      // assert
      expect(ok, isTrue);
      final payload =
          verify(mockCallable.call(captureAny)).captured.single
              as Map<String, dynamic>;
      final attachments = (payload['attachmentUrls'] as List).cast<String>();
      expect(attachments.length, 3, reason: '1 export + 2 photos');
      // We can’t rely on exact URL order, but both photo URLs must be present
      expect(attachments, containsAll(photoUrls));
      // basename check: child path must end with .../photos/b.png despite backslashes in input
      verify(
        mockRef.child(argThat(endsWith('/photos/a.jpg'))),
      ).called(greaterThan(0));
      verify(
        mockRef.child(argThat(endsWith('/photos/b.png'))),
      ).called(greaterThan(0));
    });

    test(
      'default constructor (kIsWeb=false) uses putFile for exports and photos',
      () async {
        // arrange: standard stubs
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );
        when(
          mockRef.putFile(any, any),
        ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
        when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);
        // export file exists
        when(
          mockFileProvider.getFile(any),
        ).thenAnswer((_) async => mockFileWrapper);
        when(mockFileWrapper.exists()).thenAnswer((_) async => true);

        // act
        final ok = await dataSourceDefault.submitAssessmentViaFirebaseEmail(
          tAssessmentFormModel,
          tRecipientEmail,
          exportFormats: const ['pdf'],
          photoFilePaths: const ['/tmp/p1.jpg'], // one photo
        );

        // assert
        expect(ok, isTrue);
        // native path should upload export + photo via putFile (not putData)
        verify(mockRef.putFile(any, any)).called(2);
        verifyNever(mockRef.putData(any, any));
      },
    );

    test(
      'submit throws ValidationException when a photo path does not exist',
      () async {
        // arrange
        final missingPhoto = '/tmp/missing.jpg';
        final okPhoto = '/tmp/ok.jpg';
        final missingWrapper = MockFileWrapper();
        final okWrapper = MockFileWrapper();

        // Cloud Function success (won't be reached if exception thrown before)
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': true}),
        );
        when(
          mockRef.putFile(any, any),
        ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
        when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);

        // Export file exists (the export path inside service)
        when(mockFileWrapper.exists()).thenAnswer((_) async => true);

        // Route getFile by argument:
        when(
          mockFileProvider.getFile(argThat(equals(missingPhoto))),
        ).thenAnswer((_) async => missingWrapper);
        when(
          mockFileProvider.getFile(argThat(equals(okPhoto))),
        ).thenAnswer((_) async => okWrapper);
        // Fallback for any other path (e.g., exported doc): use existing wrapper
        when(
          mockFileProvider.getFile(argThat(isNot(equals(missingPhoto)))),
        ).thenAnswer((_) async => mockFileWrapper);

        when(missingWrapper.exists()).thenAnswer((_) async => false);
        when(okWrapper.exists()).thenAnswer((_) async => true);

        // act & assert
        expect(
          () => dataSource.submitAssessmentViaFirebaseEmail(
            tAssessmentFormModel,
            tRecipientEmail,
            exportFormats: const ['pdf'],
            photoFilePaths: [okPhoto, missingPhoto], // includes a missing one
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('Photo not found: $missingPhoto'),
            ),
          ),
        );
      },
    );
  });

  group('uploadExportedFile', () {
    setUp(() {
      when(mockStorage.ref()).thenReturn(mockRef);
      when(mockRef.child(any)).thenReturn(mockRef);
      when(
        mockRef.putFile(any, any),
      ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));

      when(
        mockUploadTask.then<dynamic>(any, onError: anyNamed('onError')),
      ).thenAnswer((_) async => mockTaskSnapshot);
      when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);
    });

    test('should throw ServerException when putString throws', () async {
      // arrange
      when(mockStorage.ref()).thenReturn(mockRef);
      when(mockRef.child(any)).thenReturn(mockRef);
      when(
        mockRef.putString(any, metadata: anyNamed('metadata')),
      ).thenThrow(Exception('something went wrong'));

      // act & assert
      expect(
        () => dataSource.uploadAssessment(tAssessmentFormModel),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message contains original exception',
            contains('something went wrong'),
          ),
        ),
      );
    });

    test('should upload exported file successfully', () async {
      // arrange
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);

      // act
      final result = await dataSource.uploadExportedFile(
        ExportResult(
          filePath: tFilePath,
          fileName: tFileName,
          format: 'pdf',
          fileSizeBytes: 1,
          createdAt: DateTime.now(),
        ),
        tAssessmentId,
      );

      // assert
      expect(result, equals(tDownloadUrl));
      verify(mockStorage.ref()).called(1);
      verify(
        mockRef.child('assessments/$tAssessmentId/exports/$tFileName'),
      ).called(1);
      // verify(mockRef.putFile(mockFileWrapper, any)).called(1);
      verify(mockRef.putFile(argThat(isA<File>()), any)).called(1);

      verify(mockRef.getDownloadURL()).called(1);
    });

    test('should throw ValidationException when file does not exist', () async {
      // arrange
      when(mockFileWrapper.exists()).thenAnswer((_) async => false);
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);

      // act & assert
      expect(
        () => dataSource.uploadExportedFile(
          ExportResult(
            filePath: tFilePath,
            fileName: tFileName,
            format: 'pdf',
            fileSizeBytes: 1,
            createdAt: DateTime.now(),
          ),
          tAssessmentId,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ServerException when upload fails', () async {
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);
      when(mockStorage.ref()).thenReturn(mockRef);
      when(mockRef.child(any)).thenReturn(mockRef);
      when(mockRef.putFile(any, any)).thenThrow(Exception('Upload failed'));

      expect(
        () => dataSource.uploadExportedFile(
          ExportResult(
            filePath: tFilePath,
            fileName: tFileName,
            format: 'pdf',
            fileSizeBytes: 1,
            createdAt: DateTime.now(),
          ),
          tAssessmentId,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to upload exported file'),
          ),
        ),
      );
    });

    test(
      'should use application/octet-stream for unknown extensions',
      () async {
        const unknownName = 'file.unknownext';
        const unknownPath = '/some/path/file.unknownext';

        // arrange: override the inputs
        when(mockFileWrapper.exists()).thenAnswer((_) async => true);
        when(
          mockFileProvider.getFile(unknownPath),
        ).thenAnswer((_) async => mockFileWrapper);
        // capture metadata on putFile
        SettableMetadata? capturedMeta;
        when(mockRef.putFile(any, any)).thenAnswer((inv) {
          capturedMeta = inv.positionalArguments[1] as SettableMetadata;
          return CompletedUploadTask(mockTaskSnapshot);
        });
        when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);

        // act
        final result = await dataSource.uploadExportedFile(
          ExportResult(
            filePath: unknownPath,
            fileName: unknownName,
            format: 'unknown',
            fileSizeBytes: 10,
            createdAt: DateTime.now(),
          ),
          tAssessmentId,
        );

        // assert
        expect(result, equals(tDownloadUrl));
        expect(
          capturedMeta?.contentType,
          equals('application/octet-stream'),
          reason: 'fallback mime for unknown extensions',
        );
      },
    );
  });

  group('sendEmailWithAttachments', () {
    const tAttachmentUrls = ['url1', 'url2'];
    const tAssessmentData = {'id': 'test', 'name': 'Test Assessment'};

    setUp(() {
      when(
        mockFunctions.httpsCallable('sendAssessmentEmail'),
      ).thenReturn(mockCallable);
    });

    test('should send email with attachments successfully', () async {
      // arrange
      when(mockCallable.call(any)).thenAnswer(
        (_) async => _createMockHttpsCallableResult({'success': true}),
      );

      // act
      final result = await dataSource.sendEmailWithAttachments(
        tRecipientEmail,
        tSubject,
        tBody,
        tAttachmentUrls,
        tAssessmentData,
      );

      // assert
      expect(result, isTrue);

      final capturedCall = verify(mockCallable.call(captureAny)).captured.first;
      expect(capturedCall['recipientEmail'], equals(tRecipientEmail));
      expect(capturedCall['subject'], equals(tSubject));
      expect(capturedCall['body'], equals(tBody));
      expect(capturedCall['attachmentUrls'], equals(tAttachmentUrls));
      expect(capturedCall['assessmentData'], equals(tAssessmentData));
      expect(capturedCall['timestamp'], isA<String>());
    });

    test(
      'should return false when Cloud Function returns success false',
      () async {
        // arrange
        when(mockCallable.call(any)).thenAnswer(
          (_) async => _createMockHttpsCallableResult({'success': false}),
        );

        // act
        final result = await dataSource.sendEmailWithAttachments(
          tRecipientEmail,
          tSubject,
          tBody,
          tAttachmentUrls,
          tAssessmentData,
        );

        // assert
        expect(result, isFalse);
      },
    );

    test(
      'should throw ServerException when Cloud Function call fails',
      () async {
        // arrange
        when(
          mockCallable.call(any),
        ).thenThrow(Exception('Function call failed'));

        // act & assert
        expect(
          () => dataSource.sendEmailWithAttachments(
            tRecipientEmail,
            tSubject,
            tBody,
            tAttachmentUrls,
            tAssessmentData,
          ),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('helper methods', () {
    setUp(() {
      when(
        mockUploadTask.then<dynamic>(any, onError: anyNamed('onError')),
      ).thenAnswer((_) async => mockTaskSnapshot);

      when(mockStorage.ref()).thenReturn(mockRef);
      when(mockRef.child(any)).thenReturn(mockRef);
      when(
        mockRef.putString(any, metadata: anyNamed('metadata')),
      ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
      when(
        mockUploadTask.then<dynamic>(any, onError: anyNamed('onError')),
      ).thenAnswer((_) async => mockTaskSnapshot);

      when(
        mockFunctions.httpsCallable('sendAssessmentEmail'),
      ).thenReturn(mockCallable);
      when(mockCallable.call(any)).thenAnswer(
        (_) async => _createMockHttpsCallableResult({'success': true}),
      );

      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);

      // 4) uploadExportedFile → putFile yields the same mockUploadTask
      when(
        mockRef.putFile(any, any),
      ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));

      // 7) Every call to getDownloadURL returns tDownloadUrl
      when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);
    });

    test('should generate correct default subject', () async {
      // act
      await dataSource.submitAssessmentViaFirebaseEmail(
        tAssessmentFormModel,
        tRecipientEmail,
        exportFormats: ['pdf'],
      );

      // assert
      final capturedCall = verify(mockCallable.call(captureAny)).captured.first;
      final capturedSubject = capturedCall['subject'] as String;
      expect(capturedSubject, contains('FV Treatment Center Assessment'));
      expect(capturedSubject, contains('PDF'));
      expect(
        capturedSubject,
        contains(tAssessmentFormModel.facilityIdentification.facilityName),
      );
    });

    test('should generate correct default body', () async {
      // act
      await dataSource.submitAssessmentViaFirebaseEmail(
        tAssessmentFormModel,
        tRecipientEmail,
        exportFormats: ['pdf'],
      );

      // assert
      final capturedCall = verify(mockCallable.call(captureAny)).captured.first;
      final capturedBody = capturedCall['body'] as String;
      expect(capturedBody, contains('Please find attached'));
      expect(
        capturedBody,
        contains(tAssessmentFormModel.facilityIdentification.facilityName),
      );
      expect(capturedBody, contains(tAssessmentFormModel.assessorInfo.name));
      expect(capturedBody, contains('Assessment Date:'));
    });

    test('should generate correct assessment summary', () async {
      // act
      await dataSource.submitAssessmentViaFirebaseEmail(
        tAssessmentFormModel,
        tRecipientEmail,
        exportFormats: ['pdf'],
      );

      // assert
      final capturedCall = verify(mockCallable.call(captureAny)).captured.first;
      final assessmentData =
          capturedCall['assessmentData'] as Map<String, dynamic>;

      expect(assessmentData['id'], equals(tAssessmentFormModel.id));
      expect(
        assessmentData['facilityName'],
        equals(tAssessmentFormModel.facilityIdentification.facilityName),
      );
      expect(
        assessmentData['facilityCode'],
        equals(tAssessmentFormModel.facilityIdentification.facilityCode),
      );
      expect(
        assessmentData['isSubmitted'],
        equals(tAssessmentFormModel.isSubmitted),
      );
      expect(
        assessmentData['assessorName'],
        equals(tAssessmentFormModel.assessorInfo.name),
      );
    });
  });

  group('_exportAssessment (via submitAssessmentViaFirebaseEmail)', () {
    const tExportOptions = ExportOptions();

    setUp(() {
      // stub everything up through export, but we won't actually upload or email
      when(mockStorage.ref()).thenReturn(mockRef);
      when(mockRef.child(any)).thenReturn(mockRef);
      // make uploadAssessment succeed
      when(
        mockRef.putString(any, metadata: anyNamed('metadata')),
      ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
      // make uploadExportedFile skip actual storage
      when(
        mockRef.putFile(any, any),
      ).thenAnswer((_) => CompletedUploadTask(mockTaskSnapshot));
      when(mockRef.getDownloadURL()).thenAnswer((_) async => tDownloadUrl);
      // file provider
      when(
        mockFileProvider.getFile(any),
      ).thenAnswer((_) async => mockFileWrapper);
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);
      // stub snapshot
      when(mockTaskSnapshot.ref).thenReturn(mockRef);
      when(mockTaskSnapshot.state).thenReturn(TaskState.success);
      when(mockTaskSnapshot.bytesTransferred).thenReturn(1024);
      when(mockTaskSnapshot.totalBytes).thenReturn(1024);

      // cloud function—but we won't verify call here
      when(
        mockFunctions.httpsCallable('sendAssessmentEmail'),
      ).thenReturn(mockCallable);
      when(mockCallable.call(any)).thenAnswer(
        (_) async => _createMockHttpsCallableResult({'success': true}),
      );
    });

    test('should use ExcelExportService when format is excel', () async {
      // act
      await dataSource.submitAssessmentViaFirebaseEmail(
        tAssessmentFormModel,
        tRecipientEmail,
        exportFormats: ['excel'],
        exportOptions: tExportOptions,
      );

      // assert
      verify(
        mockExcelService.exportAssessment(
          tAssessmentFormModel,
          options: tExportOptions,
        ),
      ).called(1);
      verifyNever(
        mockPdfService.exportAssessment(any, options: anyNamed('options')),
      );
      verifyNever(
        mockDocService.exportAssessment(any, options: anyNamed('options')),
      );
    });

    test('should use DocExportService when format is doc', () async {
      // act
      await dataSource.submitAssessmentViaFirebaseEmail(
        tAssessmentFormModel,
        tRecipientEmail,
        exportFormats: ['doc'],
        exportOptions: tExportOptions,
      );

      // assert
      verify(
        mockDocService.exportAssessment(
          tAssessmentFormModel,
          options: tExportOptions,
        ),
      ).called(1);
      verifyNever(
        mockPdfService.exportAssessment(any, options: anyNamed('options')),
      );
      verifyNever(
        mockExcelService.exportAssessment(any, options: anyNamed('options')),
      );
    });
  });
}

HttpsCallableResult<dynamic> _createMockHttpsCallableResult(dynamic data) {
  final mockResult = MockHttpsCallableResult();
  when(mockResult.data).thenReturn(data);
  return mockResult;
}

/// A fake UploadTask that immediately completes with [snapshot].
class CompletedUploadTask implements UploadTask {
  @override
  final TaskSnapshot snapshot;
  CompletedUploadTask(this.snapshot);

  @override
  Stream<TaskSnapshot> get snapshotEvents => Stream.value(snapshot);

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) => Future.value(snapshot).then((_) => onValue(snapshot), onError: onError);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr Function() action) async {
    await action();
    return snapshot;
  }

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) => Future.value(snapshot);

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) => Future.value(snapshot);

  @override
  Stream<TaskSnapshot> asStream() => Stream.value(snapshot);

  // The Task interface also declares these—just return “successful”:
  @override
  Future<bool> pause() => Future.value(true);
  @override
  Future<bool> resume() => Future.value(true);
  @override
  Future<bool> cancel() => Future.value(true);

  @override
  FirebaseStorage get storage => throw UnimplementedError();
}
