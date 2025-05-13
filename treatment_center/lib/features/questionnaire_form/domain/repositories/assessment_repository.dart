import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/assessment_form.dart';

/// Repository interface for managing assessment forms
abstract class AssessmentRepository {
  /// Get all saved assessment forms
  Future<Either<Failure, List<AssessmentForm>>> getAllAssessments();

  /// Get a specific assessment form by ID
  Future<Either<Failure, AssessmentForm>> getAssessment(String id);

  /// Save a new assessment form or update an existing one
  Future<Either<Failure, bool>> saveAssessment(AssessmentForm assessment);

  /// Delete an assessment form
  Future<Either<Failure, bool>> deleteAssessment(String id);

  /// Submit an assessment form via email
  Future<Either<Failure, bool>> submitAssessmentViaEmail(
    AssessmentForm assessment,
    String recipientEmail,
  );
}
