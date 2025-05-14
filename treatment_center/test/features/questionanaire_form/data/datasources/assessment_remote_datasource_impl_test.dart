import 'dart:io';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/services/email_sender.dart';
import 'package:treatment_center/core/providers/file_provider.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource_impl.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';
import 'assessment_remote_datasource_impl_test.mocks.dart';

// Generate mocks for external dependencies
@GenerateMocks([Directory, File, EmailSender, FileProvider])
void main() {
  late AssessmentRemoteDataSourceImpl dataSource;
  late MockEmailSender mockEmailSender;
  late MockDirectory mockDirectory;
  late MockFile mockFile;
  late MockFileProvider mockFileProvider;
  late Future<Directory> Function() mockGetTempDir;

  // Test data
  final tAssessmentId = 'test-assessment-id';
  final tAssessmentModel = TestAssessmentFixtures.createTestAssessmentFormModel(
    id: tAssessmentId,
  );
  final tEmail = 'test@example.com';
  final tFilePath = '/temp/assessment_$tAssessmentId.pdf';
  final tCustomSubject = 'Custom Subject';
  final tCustomBody = 'Custom Body';

  setUp(() {
    mockDirectory = MockDirectory();
    mockFile = MockFile();
    mockEmailSender = MockEmailSender();
    mockFileProvider = MockFileProvider();

    // Mock the getTempDir function to return a predictable directory
    mockGetTempDir = () async => mockDirectory;

    // Set up common expectations
    when(mockDirectory.path).thenReturn('/temp');
    
    // Setup file provider methods
    when(mockFileProvider.getFile(any)).thenAnswer((_) async => mockFile);
    when(mockFileProvider.writeAsBytes(any, any)).thenAnswer((_) async => mockFile);
    when(mockFileProvider.writeAsString(any, any)).thenAnswer((_) async => mockFile);

    dataSource = AssessmentRemoteDataSourceImpl(
      emailSender: mockEmailSender,
      fileProvider: mockFileProvider,
      getTempDir: mockGetTempDir,
    );
  });

  group('exportAssessmentToFile', () {
    test('should create and return path to a PDF file', () async {
      // act
      final result = await dataSource.exportAssessmentToFile(
        tAssessmentModel,
        'pdf',
      );

      // assert
      expect(result, equals(tFilePath));
      verify(mockDirectory.path);
      verify(mockFileProvider.getFile(tFilePath));
      verify(mockFileProvider.writeAsBytes(mockFile, any));
    });

    test('should create and return path to a DOC file', () async {
      // arrange
      final docPath = '/temp/assessment_$tAssessmentId.doc';

      // act
      final result = await dataSource.exportAssessmentToFile(
        tAssessmentModel,
        'doc',
      );

      // assert
      expect(result, equals(docPath));
      verify(mockDirectory.path);
      verify(mockFileProvider.getFile(docPath));
      verify(mockFileProvider.writeAsString(mockFile, any));
    });

    test('should throw FileException for invalid format', () async {
      // act & assert
      expect(
        () => dataSource.exportAssessmentToFile(tAssessmentModel, 'invalid'),
        throwsA(isA<FileException>()),
      );
    });

    test('should convert general exceptions to FileException', () async {
      // arrange
      when(mockDirectory.path).thenThrow(Exception('Test error'));

      // act & assert
      expect(
        () => dataSource.exportAssessmentToFile(tAssessmentModel, 'pdf'),
        throwsA(isA<FileException>()),
      );
    });

    test('should pass through FileException if already thrown', () async {
      // arrange
      when(mockDirectory.path).thenThrow(FileException());

      // act & assert
      expect(
        () => dataSource.exportAssessmentToFile(tAssessmentModel, 'pdf'),
        throwsA(isA<FileException>()),
      );
    });
  });

  group('submitAssessmentViaEmail', () {
    test('should send email with PDF attachment', () async {
      // arrange
      when(mockEmailSender.send(any)).thenAnswer((_) async => '');

      // act
      final result = await dataSource.submitAssessmentViaEmail(
        tAssessmentModel,
        tEmail,
        exportFormat: 'pdf',
      );

      // assert
      expect(result, equals(true));
      verify(mockEmailSender.send(any));
    });

    test('should send email with DOC attachment', () async {
      // arrange
      final docPath = '/temp/assessment_$tAssessmentId.doc';
      when(mockEmailSender.send(any)).thenAnswer((_) async => '');

      // act
      final result = await dataSource.submitAssessmentViaEmail(
        tAssessmentModel,
        tEmail,
        exportFormat: 'doc',
      );

      // assert
      expect(result, equals(true));
      verify(mockEmailSender.send(any));
    });

    test('should use custom subject and body when provided', () async {
      // arrange
      when(mockEmailSender.send(any)).thenAnswer((_) async => '');

      // act
      final result = await dataSource.submitAssessmentViaEmail(
        tAssessmentModel,
        tEmail,
        exportFormat: 'pdf',
        subject: tCustomSubject,
        body: tCustomBody,
      );

      // assert
      expect(result, equals(true));

      final emailVerification = verify(mockEmailSender.send(captureAny));
      final capturedEmail = emailVerification.captured.first as Email;

      expect(capturedEmail.subject, equals(tCustomSubject));
      expect(capturedEmail.body, equals(tCustomBody));
    });

    test('should use default subject and body when not provided', () async {
      // arrange
      when(mockEmailSender.send(any)).thenAnswer((_) async => '');

      // act
      final result = await dataSource.submitAssessmentViaEmail(
        tAssessmentModel,
        tEmail,
        exportFormat: 'pdf',
      );

      // assert
      expect(result, equals(true));

      final emailVerification = verify(mockEmailSender.send(captureAny));
      final capturedEmail = emailVerification.captured.first as Email;

      expect(
        capturedEmail.subject,
        contains(tAssessmentModel.facilityIdentification.facilityName),
      );
      expect(capturedEmail.body, contains(tAssessmentModel.assessorInfo.name));
    });

    test('should throw EmailException when email sending fails', () async {
      // arrange
      when(mockEmailSender.send(any)).thenThrow(Exception('Email error'));

      // act & assert
      expect(
        () => dataSource.submitAssessmentViaEmail(
          tAssessmentModel,
          tEmail,
          exportFormat: 'pdf',
        ),
        throwsA(isA<EmailException>()),
      );
    });
  });
}