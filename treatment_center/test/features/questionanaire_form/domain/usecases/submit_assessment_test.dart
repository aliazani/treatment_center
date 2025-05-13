import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/submit_assessment.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';

// Generate mock for the repository
@GenerateMocks([AssessmentRepository])
import 'submit_assessment_test.mocks.dart';

void main() {
  late SubmitAssessment useCase;
  late MockAssessmentRepository mockRepository;
  final tAssessmentId = 'test-assessment-id';
  final tEmail = 'recipient@example.com';

  // Create test assessments with different states
  final tIncompleteAssessment = TestAssessmentFixtures.createPartiallyRatedAssessment(
    id: tAssessmentId,
  );
  
  final tCompleteAssessment = TestAssessmentFixtures.createTestAssessmentForm(
    id: tAssessmentId,
    sectionCount: 1,
    itemsPerSection: 3,
    withRatings: true, // All items have ratings = complete
  );
  
  // Submitted version of the complete assessment with a known submission date
  final testSubmissionDate = DateTime(2023, 5, 11, 12, 30); 
  final tSubmittedAssessment = tCompleteAssessment.copyWith(
    isSubmitted: true,
    submissionDate: testSubmissionDate,
  );

  setUpAll(() {
    // Register dummy values for ALL the Either types used by Mockito when generating mocks
    // This is necessary to avoid MissingDummyValueError
    provideDummy<Either<Failure, AssessmentForm>>(Right(tCompleteAssessment));
    provideDummy<Either<Failure, bool>>(const Right(true));
  });

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = SubmitAssessment(mockRepository);
  });

  // Helper functions to reduce code duplication
  void setupGetAssessmentSuccess(AssessmentForm assessment) {
    when(mockRepository.getAssessment(any))
        .thenAnswer((_) async => Right(assessment));
  }

  void setupGetAssessmentFailure(Failure failure) {
    when(mockRepository.getAssessment(any))
        .thenAnswer((_) async => Left(failure));
  }

  void setupSaveAssessmentSuccess() {
    when(mockRepository.saveAssessment(any))
        .thenAnswer((_) async => const Right(true));
  }

  void setupSaveAssessmentFailure(Failure failure) {
    when(mockRepository.saveAssessment(any))
        .thenAnswer((_) async => Left(failure));
  }

  void setupEmailSuccess() {
    when(mockRepository.submitAssessmentViaEmail(any, any))
        .thenAnswer((_) async => const Right(true));
  }

  void setupEmailFailure(Failure failure) {
    when(mockRepository.submitAssessmentViaEmail(any, any))
        .thenAnswer((_) async => Left(failure));
  }

  group('SubmitAssessment', () {
    test(
      'should return ValidationFailure for incomplete assessment',
      () async {
        // arrange
        setupGetAssessmentSuccess(tIncompleteAssessment);
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
        ));
        
        // assert
        expect(result.isLeft(), true);
        final failure = (result as Left).value as ValidationFailure;
        expect(failure.message, contains('incomplete'));
        
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should mark assessment as submitted and save it when complete',
      () async {
        // arrange
        setupGetAssessmentSuccess(tCompleteAssessment);
        setupSaveAssessmentSuccess();
        
        // Capture the DateTime.now() by using clock freezing or capture
        final beforeSubmit = DateTime.now();
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
        ));
        
        final afterSubmit = DateTime.now();
        
        // assert
        expect(result, const Right(true));
        
        // Verify that saveAssessment was called with a submitted assessment
        final verificationResult = verify(mockRepository.saveAssessment(captureAny));
        final capturedAssessment = verificationResult.captured.first as AssessmentForm;
        
        expect(capturedAssessment.isSubmitted, true);
        expect(capturedAssessment.submissionDate, isNotNull);
        
        // Verify the timestamp is reasonable (between before and after test execution)
        expect(
          capturedAssessment.submissionDate!.isAfter(beforeSubmit) || 
          capturedAssessment.submissionDate!.isAtSameMomentAs(beforeSubmit), 
          true
        );
        expect(
          capturedAssessment.submissionDate!.isBefore(afterSubmit) || 
          capturedAssessment.submissionDate!.isAtSameMomentAs(afterSubmit), 
          true
        );
        
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should email assessment when email is provided and submission succeeds',
      () async {
        // arrange
        setupGetAssessmentSuccess(tCompleteAssessment);
        setupSaveAssessmentSuccess();
        setupEmailSuccess();
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
          recipientEmail: tEmail,
        ));
        
        // assert
        expect(result, const Right(true));
        
        // Verify the correct flow of calls
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(any));
        verify(mockRepository.submitAssessmentViaEmail(any, tEmail));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should not attempt to email when no email is provided',
      () async {
        // arrange
        setupGetAssessmentSuccess(tCompleteAssessment);
        setupSaveAssessmentSuccess();
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
          // No email provided
        ));
        
        // assert
        expect(result, const Right(true));
        
        // Verify that email was NOT called
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(any));
        verifyNever(mockRepository.submitAssessmentViaEmail(any, any));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return failure when getAssessment returns failure',
      () async {
        // arrange
        final tFailure = ServerFailure(message: 'Failed to get assessment');
        setupGetAssessmentFailure(tFailure);
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
        ));
        
        // assert
        expect(result, Left(tFailure));
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return failure when saveAssessment fails',
      () async {
        // arrange
        setupGetAssessmentSuccess(tCompleteAssessment);
        final tFailure = CacheFailure(message: 'Failed to save');
        setupSaveAssessmentFailure(tFailure);
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
        ));
        
        // assert
        expect(result, Left(tFailure));
        
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(any));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should test the "unreachable" branch in saveResult.fold',
      () async {
        // arrange
        setupGetAssessmentSuccess(tCompleteAssessment);
        
        // This mock makes saveAssessment return a Right, but we'll modify
        // the implementation to specifically test the unreachable branch
        when(mockRepository.saveAssessment(any))
            .thenAnswer((_) async => const Right(false)); // Return false
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
        ));
        
        // assert
        // In the current implementation, the result should still be Right(true)
        // but with our test implementation, we should get Right(false)
        expect(result, const Right(false));
        
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(any));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return failure when email sending fails',
      () async {
        // arrange
        setupGetAssessmentSuccess(tCompleteAssessment);
        setupSaveAssessmentSuccess();
        final tFailure = EmailFailure(message: 'Failed to send email');
        setupEmailFailure(tFailure);
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
          recipientEmail: tEmail,
        ));
        
        // assert
        expect(result, Left(tFailure));
        
        verify(mockRepository.getAssessment(tAssessmentId));
        verify(mockRepository.saveAssessment(any));
        verify(mockRepository.submitAssessmentViaEmail(any, tEmail));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should handle exceptions and return ValidationFailure',
      () async {
        // arrange
        when(mockRepository.getAssessment(any))
            .thenThrow(Exception('Test exception'));
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
        ));
        
        // assert
        expect(result.isLeft(), true);
        final failure = (result as Left).value as ValidationFailure;
        expect(failure.message, contains('Failed to submit assessment'));
        expect(failure.message, contains('Test exception'));
        
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should not update submission date of an already submitted assessment',
      () async {
        // arrange
        setupGetAssessmentSuccess(tSubmittedAssessment);
        setupSaveAssessmentSuccess();
        
        // act
        final result = await useCase(Params(
          assessmentId: tAssessmentId,
        ));
        
        // assert
        expect(result, const Right(true));
        
        // Verify the assessment wasn't modified since it was already submitted
        final verificationResult = verify(mockRepository.saveAssessment(captureAny));
        final capturedAssessment = verificationResult.captured.first as AssessmentForm;
        
        // Verify the original submission date was preserved
        expect(capturedAssessment.submissionDate, equals(testSubmissionDate));
        expect(capturedAssessment.isSubmitted, true);
        
        verify(mockRepository.getAssessment(tAssessmentId));
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });

  group('Params', () {
    test('should consider two Params with same values equal', () {
      // arrange
      final params1 = Params(assessmentId: tAssessmentId, recipientEmail: tEmail);
      final params2 = Params(assessmentId: tAssessmentId, recipientEmail: tEmail);
      
      // assert
      expect(params1, equals(params2));
    });
    
    test('should consider two Params with different assessmentId not equal', () {
      // arrange
      final params1 = Params(assessmentId: 'id1', recipientEmail: tEmail);
      final params2 = Params(assessmentId: 'id2', recipientEmail: tEmail);
      
      // assert
      expect(params1, isNot(equals(params2)));
    });
    
    test('should consider two Params with different recipientEmail not equal', () {
      // arrange
      final params1 = Params(assessmentId: tAssessmentId, recipientEmail: 'email1@example.com');
      final params2 = Params(assessmentId: tAssessmentId, recipientEmail: 'email2@example.com');
      
      // assert
      expect(params1, isNot(equals(params2)));
    });
    
    test('should consider one Params with email and one without not equal', () {
      // arrange
      final params1 = Params(assessmentId: tAssessmentId, recipientEmail: tEmail);
      final params2 = Params(assessmentId: tAssessmentId);
      
      // assert
      expect(params1, isNot(equals(params2)));
    });
  });
}