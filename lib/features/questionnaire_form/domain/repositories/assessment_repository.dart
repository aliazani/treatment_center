import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';

/// Repository interface for managing assessment forms
abstract class AssessmentRepository {
  /// Get all saved assessment forms
  Future<Either<Failure, List<AssessmentFormEntity>>> getAllAssessments();

  /// Get a specific assessment form by ID
  Future<Either<Failure, AssessmentFormEntity>> getAssessment(String id);

  /// Save a new assessment form or update an existing one
  Future<Either<Failure, bool>> saveAssessment(AssessmentFormEntity assessment);

  /// Delete an assessment form
  Future<Either<Failure, bool>> deleteAssessment(String id);

  /// Delete multiple assessment forms by their IDs
  Future<Either<Failure, bool>> deleteAllAssessments(
    List<String> assessmentIds,
  );

  // FIREBASE METHODS *****************
  /// Submits assessment via Firebase Cloud Functions with multiple export formats
  Future<Either<Failure, bool>> submitAssessmentViaFirebaseEmail(
    AssessmentFormEntity assessment,
    String recipientEmail, {
    List<String> exportFormats = const ['pdf'],
    String? subject,
    String? body,
    List<String> photoFilePaths = const [],
    ExportOptions? exportOptions,
  });

  /// Uploads assessment to Firebase Storage
  Future<Either<Failure, String>> uploadAssessmentToFirebase(
    AssessmentFormEntity assessment,
  );

  /// Import assessment from Excel file
  Future<Either<Failure, AssessmentFormEntity>> importAssessmentFromExcel(
    String filePath, {
    ImportOptions? options,
    bool saveAfterImport = false,
  });

  /// Validate file for import
  Future<Either<Failure, bool>> validateFileForImport(
    String filePath,
    String format,
  );
}
