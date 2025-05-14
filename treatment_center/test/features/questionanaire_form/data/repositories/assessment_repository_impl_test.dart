import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/network/network_info.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_data_source.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_data_source.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/repositories/assessment_repository_impl.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';
import 'assessment_repository_impl_test.mocks.dart';

@GenerateMocks([
  AssessmentLocalDataSource,
  AssessmentRemoteDataSource,
  NetworkInfo,
])
void main() {
  late AssessmentRepositoryImpl repository;
  late MockAssessmentLocalDataSource mockLocalDataSource;
  late MockAssessmentRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
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
        when(
          mockLocalDataSource.getAllAssessments(),
        ).thenThrow(CacheException());

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
        when(
          mockLocalDataSource.getAssessment(any),
        ).thenThrow(CacheException());

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
    test(
      'should save assessment locally only when offline and return success',
      () async {
        // arrange
        when(
          mockLocalDataSource.saveAssessment(any),
        ).thenAnswer((_) async => true);
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.saveAssessment(tAssessment);

        // assert
        verify(mockLocalDataSource.saveAssessment(any));
        verify(mockNetworkInfo.isConnected);
        verifyNever(mockRemoteDataSource.saveAssessment(any));
        expect(result, const Right(true));
      },
    );

    test(
      'should save assessment locally and remotely when online and return success',
      () async {
        // arrange
        when(
          mockLocalDataSource.saveAssessment(any),
        ).thenAnswer((_) async => true);
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.saveAssessment(any),
        ).thenAnswer((_) async => true);

        // act
        final result = await repository.saveAssessment(tAssessment);

        // assert
        verify(mockLocalDataSource.saveAssessment(any));
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.saveAssessment(any));
        expect(result, const Right(true));
      },
    );

    test(
      'should still succeed when local save succeeds but remote save fails',
      () async {
        // arrange
        when(
          mockLocalDataSource.saveAssessment(any),
        ).thenAnswer((_) async => true);
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.saveAssessment(any),
        ).thenThrow(ServerException());

        // act
        final result = await repository.saveAssessment(tAssessment);

        // assert
        verify(mockLocalDataSource.saveAssessment(any));
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.saveAssessment(any));
        expect(result, const Right(true));
      },
    );

    test(
      'should return CacheFailure when local data source throws a CacheException',
      () async {
        // arrange
        when(
          mockLocalDataSource.saveAssessment(any),
        ).thenThrow(CacheException());

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
    test(
      'should delete assessment locally only when offline and return success',
      () async {
        // arrange
        when(
          mockLocalDataSource.deleteAssessment(any),
        ).thenAnswer((_) async => true);
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.deleteAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.deleteAssessment(tAssessmentId));
        verify(mockNetworkInfo.isConnected);
        verifyNever(mockRemoteDataSource.deleteAssessment(any));
        expect(result, const Right(true));
      },
    );

    test(
      'should delete assessment locally and remotely when online and return success',
      () async {
        // arrange
        when(
          mockLocalDataSource.deleteAssessment(any),
        ).thenAnswer((_) async => true);
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.deleteAssessment(any),
        ).thenAnswer((_) async => true);

        // act
        final result = await repository.deleteAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.deleteAssessment(tAssessmentId));
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.deleteAssessment(tAssessmentId));
        expect(result, const Right(true));
      },
    );

    test(
      'should still succeed when local delete succeeds but remote delete fails',
      () async {
        // arrange
        when(
          mockLocalDataSource.deleteAssessment(any),
        ).thenAnswer((_) async => true);
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.deleteAssessment(any),
        ).thenThrow(ServerException());

        // act
        final result = await repository.deleteAssessment(tAssessmentId);

        // assert
        verify(mockLocalDataSource.deleteAssessment(tAssessmentId));
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.deleteAssessment(tAssessmentId));
        expect(result, const Right(true));
      },
    );

    test(
      'should return CacheFailure when local data source throws a CacheException',
      () async {
        // arrange
        when(
          mockLocalDataSource.deleteAssessment(any),
        ).thenThrow(CacheException());

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

  group('submitAssessmentViaEmail', () {
    test('should return ConnectionFailure when device is offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.submitAssessmentViaEmail(
        tAssessment,
        tEmail,
      );

      // assert
      verify(mockNetworkInfo.isConnected);
      verifyNever(mockRemoteDataSource.submitAssessmentViaEmail(any, any));
      expect(result.isLeft(), true);
      expect((result as Left).value, isA<ConnectionFailure>());
      result.fold((failure) {
        expect(failure, isA<ConnectionFailure>());
        expect(
          (failure as ConnectionFailure).message,
          contains('No internet connection'),
        );
      }, (_) => fail('Expected Left, but got Right'));
    });

    test(
      'should submit assessment via email when online and return success',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaEmail(any, any),
        ).thenAnswer((_) async => true);

        // act
        final result = await repository.submitAssessmentViaEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.submitAssessmentViaEmail(any, tEmail));
        expect(result, const Right(true));
      },
    );

    test(
      'should return ServerFailure when remote data source throws a ServerException',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaEmail(any, any),
        ).thenThrow(ServerException());

        // act
        final result = await repository.submitAssessmentViaEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.submitAssessmentViaEmail(any, tEmail));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<ServerFailure>());

        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            contains('Failed to send email'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return EmailFailure when remote data source throws an EmailException',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaEmail(any, any),
        ).thenThrow(EmailException());

        // act
        final result = await repository.submitAssessmentViaEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.submitAssessmentViaEmail(any, tEmail));
        expect(result.isLeft(), true);
        expect((result as Left).value, isA<EmailFailure>());

        result.fold((failure) {
          expect(failure, isA<EmailFailure>());
          expect(
            (failure as EmailFailure).message,
            contains('Failed to send email'),
          );
        }, (_) => fail('Expected Left, but got Right'));
      },
    );

    test(
      'should return UnexpectedFailure when remote data source throws an unexpected exception',
      () async {
        // arrange
        final tException = Exception('Unexpected error');
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.submitAssessmentViaEmail(any, any),
        ).thenThrow(tException);

        // act
        final result = await repository.submitAssessmentViaEmail(
          tAssessment,
          tEmail,
        );

        // assert
        verify(mockNetworkInfo.isConnected);
        verify(mockRemoteDataSource.submitAssessmentViaEmail(any, tEmail));
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
}
