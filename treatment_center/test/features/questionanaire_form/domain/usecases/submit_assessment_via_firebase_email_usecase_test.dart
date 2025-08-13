import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/submit_assessment_via_firebase_email_usecase.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate a MockAssessmentRepository
@GenerateMocks([AssessmentRepository])
import 'submit_assessment_via_firebase_email_usecase_test.mocks.dart';

void main() {
  late SubmitAssessmentViaFirebaseEmailUsecase submitUseCase;
  late UploadAssessmentToFirebase uploadUseCase;
  late MockAssessmentRepository mockRepository;

  // Dummy for Either<Failure, bool> and Either<Failure, String>
  setUpAll(() {
    provideDummy<Either<Failure, bool>>(const Right(true));
    provideDummy<Either<Failure, String>>(const Right('uploaded-id'));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    submitUseCase = SubmitAssessmentViaFirebaseEmailUsecase(mockRepository);
    uploadUseCase = UploadAssessmentToFirebase(mockRepository);
  });

  final tAssessment = TestAssessmentFixtures.createTestAssessmentForm(id: 'a1');
  const tEmail = 'test@example.com';
  const List<String> tDefaultFormats = ['pdf'];
  const List<String> tCustomFormats = ['csv', 'pdf'];
  const tSubject = 'Assessment Report';
  const tBody = 'Please see attached.';
  // Assuming ExportOptions has a default constructor; adjust if necessary.
  final tExportOptions = const ExportOptions();

  group('SubmitAssessmentViaFirebaseEmailUsecase', () {
    test('forwards default params and returns success', () async {
      // arrange
      when(
        mockRepository.submitAssessmentViaFirebaseEmail(
          any,
          any,
          exportFormats: anyNamed('exportFormats'),
          subject: anyNamed('subject'),
          body: anyNamed('body'),
          exportOptions: anyNamed('exportOptions'),
        ),
      ).thenAnswer((_) async => const Right(true));

      // act
      final result = await submitUseCase(
        FirebaseEmailParams(
          assessment: TestAssessmentFixtures.createTestAssessmentForm(id: 'a1'),
          recipientEmail: tEmail,
        ),
      );

      // assert
      expect(result, const Right(true));
      verify(
        mockRepository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          tEmail,
          exportFormats: tDefaultFormats,
          subject: null,
          body: null,
          exportOptions: null,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('forwards custom params and returns failure', () async {
      // arrange
      when(
        mockRepository.submitAssessmentViaFirebaseEmail(
          any,
          any,
          exportFormats: anyNamed('exportFormats'),
          subject: anyNamed('subject'),
          body: anyNamed('body'),
          exportOptions: anyNamed('exportOptions'),
        ),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'send error')));

      final params = FirebaseEmailParams(
        assessment: tAssessment,
        recipientEmail: tEmail,
        exportFormats: tCustomFormats,
        subject: tSubject,
        body: tBody,
        exportOptions: tExportOptions,
      );

      // act
      final result = await submitUseCase(params);

      // assert
      expect(result, const Left(CacheFailure(message: 'send error')));
      verify(
        mockRepository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          tEmail,
          exportFormats: tCustomFormats,
          subject: tSubject,
          body: tBody,
          exportOptions: tExportOptions,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('throws when repository method throws', () async {
      // arrange
      when(
        mockRepository.submitAssessmentViaFirebaseEmail(
          any,
          any,
          exportFormats: anyNamed('exportFormats'),
          subject: anyNamed('subject'),
          body: anyNamed('body'),
          exportOptions: anyNamed('exportOptions'),
        ),
      ).thenThrow(Exception('oops'));

      final params = FirebaseEmailParams(
        assessment: tAssessment,
        recipientEmail: tEmail,
      );

      // act & assert
      expect(() => submitUseCase(params), throwsA(isA<Exception>()));
      verify(
        mockRepository.submitAssessmentViaFirebaseEmail(
          tAssessment,
          tEmail,
          exportFormats: tDefaultFormats,
          subject: null,
          body: null,
          exportOptions: null,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('FirebaseEmailParams', () {
    test('supports value equality and default exportFormats', () {
      final p1 = FirebaseEmailParams(
        assessment: TestAssessmentFixtures.createTestAssessmentForm(id: 'a1'),
        recipientEmail: tEmail,
      );
      final p2 = FirebaseEmailParams(
        assessment: TestAssessmentFixtures.createTestAssessmentForm(id: 'a1'),
        recipientEmail: tEmail,
      );
      expect(p1, equals(p2));
      expect(p1.exportFormats, tDefaultFormats);
      expect(p1.subject, isNull);
      expect(p1.body, isNull);
      expect(p1.exportOptions, isNull);
    });

    test('two different params are not equal', () {
      final p1 = FirebaseEmailParams(
        assessment: TestAssessmentFixtures.createTestAssessmentForm(id: 'a1'),
        recipientEmail: tEmail,
      );
      final p2 = FirebaseEmailParams(
        assessment: tAssessment,
        recipientEmail: 'other@example.com',
        exportFormats: tCustomFormats,
        subject: tSubject,
        body: tBody,
        exportOptions: tExportOptions,
      );
      expect(p1, isNot(equals(p2)));
    });
  });

  group('UploadAssessmentToFirebase', () {
    test('returns URL on success', () async {
      // arrange
      when(
        mockRepository.uploadAssessmentToFirebase(any),
      ).thenAnswer((_) async => const Right('url123'));

      // act
      final result = await uploadUseCase(tAssessment);

      // assert
      expect(result, const Right('url123'));
      verify(mockRepository.uploadAssessmentToFirebase(tAssessment));
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns failure on repository Left', () async {
      // arrange
      final failure = CacheFailure(message: 'upload error');
      when(
        mockRepository.uploadAssessmentToFirebase(any),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await uploadUseCase(tAssessment);

      // assert
      expect(result, Left(failure));
      verify(mockRepository.uploadAssessmentToFirebase(tAssessment));
      verifyNoMoreInteractions(mockRepository);
    });

    test('throws when repository method throws', () async {
      // arrange
      when(
        mockRepository.uploadAssessmentToFirebase(any),
      ).thenThrow(Exception('boom'));

      // act & assert
      expect(() => uploadUseCase(tAssessment), throwsA(isA<Exception>()));
      verify(mockRepository.uploadAssessmentToFirebase(tAssessment));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
