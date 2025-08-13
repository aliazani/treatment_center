import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/network/network_info.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  final AssessmentLocalDataSource localDataSource;
  final AssessmentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AssessmentRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // Local Data Source Methods *****************
  @override
  Future<Either<Failure, List<AssessmentFormEntity>>>
  getAllAssessments() async {
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
  Future<Either<Failure, AssessmentFormEntity>> getAssessment(String id) async {
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
    AssessmentFormEntity assessment,
  ) async {
    try {
      final assessmentModel = AssessmentFormModel.fromEntity(assessment);
      final success = await localDataSource.saveAssessment(assessmentModel);
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
      final success = await localDataSource.deleteAssessment(id);
      return Right(success);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Failed to delete assessment locally.'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // Import/Export Methods *****************
  @override
  Future<Either<Failure, bool>> validateFileForImport(
    String filePath,
    String format,
  ) async {
    try {
      final importService = ImportServiceFactory.createImportService(format);
      await importService.validateFileForImport(filePath);
      return const Right(true);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on FileException catch (e) {
      return Left(FileOperationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AssessmentFormEntity>> importAssessment(
    String filePath,
    String format, {
    ImportOptions? options,
  }) async {
    try {
      // Create the appropriate import service
      final importService = ImportServiceFactory.createImportService(format);

      // Import the assessment
      final importResult = await importService.importAssessment(
        filePath,
        options: options,
      );

      return Right(importResult.assessment);
    } on ImportException catch (e) {
      return Left(ImportFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on FileException catch (e) {
      return Left(FileOperationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssessmentFormEntity>> importAssessmentFromExcel(
    String filePath, {
    ImportOptions? options,
    bool saveAfterImport = true,
  }) async {
    try {
      // Import the assessment first
      final importResult = await importAssessment(
        filePath,
        'excel',
        options: options,
      );

      return importResult.fold((failure) => Left(failure), (entity) async {
        if (saveAfterImport) {
          // Save the assessment and return the original entity if successful
          final saveResult = await saveAssessment(entity);
          return saveResult.fold(
            (failure) => Left(failure),
            (success) =>
                success
                    ? Right(entity)
                    : Left(
                      UnexpectedFailure(message: 'Failed to save assessment'),
                    ),
          );
        }
        return Right(entity);
      });
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // Remote Data Source Methods *****************
  @override
  Future<Either<Failure, bool>> submitAssessmentViaFirebaseEmail(
    AssessmentFormEntity assessment,
    String recipientEmail, {
    List<String> exportFormats = const ['pdf'],
    String? subject,
    String? body,
    List<String> photoFilePaths = const [],
    ExportOptions? exportOptions,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(
          ConnectionFailure(
            message:
                'No internet connection. Please connect to submit assessment via Firebase email.',
          ),
        );
      }

      final assessmentModel = AssessmentFormModel.fromEntity(assessment);
      final success = await remoteDataSource.submitAssessmentViaFirebaseEmail(
        assessmentModel,
        recipientEmail,
        exportFormats: exportFormats,
        subject: subject,
        body: body,
        exportOptions: exportOptions,
        photoFilePaths: photoFilePaths, 
      );

      if (success) {
        final updatedEntity = assessment.copyWith(isSubmitted: true);
        final updatedModel = AssessmentFormModel.fromEntity(updatedEntity);
        await localDataSource.saveAssessment(updatedModel);
      }

      return Right(success);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: 'Firebase server error: ${e.message}'),
      );
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: 'Validation error: ${e.message}'));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to submit via Firebase: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadAssessmentToFirebase(
    AssessmentFormEntity assessment,
  ) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(
          ConnectionFailure(
            message:
                'No internet connection. Please connect to upload to Firebase.',
          ),
        );
      }

      final assessmentModel = AssessmentFormModel.fromEntity(assessment);
      final storagePath = await remoteDataSource.uploadAssessment(
        assessmentModel,
      );

      return Right(storagePath);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: 'Firebase upload error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to upload to Firebase: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllAssessments(
    List<String> assessmentIds,
  ) async {
    try {
      if (assessmentIds.isEmpty) {
        return Left(ValidationFailure(message: 'No assessment IDs provided'));
      }

      // Validate that assessments exist before deletion (optional safety check)
      final existingAssessments = await localDataSource.getAllAssessments();
      final existingIds = existingAssessments.map((a) => a.id).toSet();
      final validIds =
          assessmentIds.where((id) => existingIds.contains(id)).toList();

      if (validIds.isEmpty) {
        return Left(
          ValidationFailure(message: 'No valid assessments found to delete'),
        );
      }

      // Perform bulk deletion through local data source
      final success = await localDataSource.deleteAllAssessments(validIds);

      if (success) {
        return const Right(true);
      } else {
        return Left(
          CacheFailure(message: 'Failed to delete some or all assessments'),
        );
      }
    } on CacheException catch (e) {
      return Left(
        CacheFailure(
          message:
              'Failed to delete assessments from local storage: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Unexpected error during bulk deletion: ${e.toString()}',
        ),
      );
    }
  }
}
