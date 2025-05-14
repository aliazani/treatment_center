import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/assessment_form.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasources/assessment_local_data_source.dart';
import '../datasources/assessment_remote_data_source.dart';
import '../models/assessment_form_model.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  final AssessmentLocalDataSource localDataSource;
  final AssessmentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AssessmentRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AssessmentForm>>> getAllAssessments() async {
    try {
      final assessmentModels = await localDataSource.getAllAssessments();
      return Right(assessmentModels);
    } on CacheException {
      return Left(
        CacheFailure(
          message: 'Failed to fetch assessments from local storage.',
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssessmentForm>> getAssessment(String id) async {
    try {
      final assessmentModel = await localDataSource.getAssessment(id);
      return Right(assessmentModel);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Failed to fetch assessment from local storage.'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveAssessment(
    AssessmentForm assessment,
  ) async {
    try {
      // Convert domain entity to data model
      final assessmentModel = AssessmentFormModel.fromEntity(assessment);

      // Save locally
      final success = await localDataSource.saveAssessment(assessmentModel);

      // If user is online, also save remotely for backup/sync
      if (success && await networkInfo.isConnected) {
        try {
          await remoteDataSource.saveAssessment(assessmentModel);
        } on ServerException {
          // Continue even if remote save fails
          // We prioritize local storage success
        }
      }

      return Right(success);
    } on CacheException {
      return Left(CacheFailure(message: 'Failed to save assessment locally.'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAssessment(String id) async {
    try {
      // Delete locally
      final success = await localDataSource.deleteAssessment(id);

      // If user is online, also delete remotely
      if (success && await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteAssessment(id);
        } on ServerException {
          // Continue even if remote delete fails
          // We prioritize local deletion success
        }
      }

      return Right(success);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Failed to delete assessment locally.'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> submitAssessmentViaEmail(
    AssessmentForm assessment,
    String recipientEmail,
  ) async {
    try {
      // Check if device is online
      if (!await networkInfo.isConnected) {
        return Left(
          ConnectionFailure(
            message:
                'No internet connection. Please connect to submit assessment via email.',
          ),
        );
      }

      // Convert domain entity to data model
      final assessmentModel = AssessmentFormModel.fromEntity(assessment);

      // Submit via email
      final success = await remoteDataSource.submitAssessmentViaEmail(
        assessmentModel,
        recipientEmail,
      );

      return Right(success);
    } on ServerException {
      return Left(
        ServerFailure(
          message: 'Failed to send email. Please check your server settings.',
        ),
      );
    } on EmailException {
      return Left(
        EmailFailure(
          message:
              'Failed to send email. Please check your email client settings.',
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
