import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

/// Use case for deleting all assessment forms
class DeleteAllAssessmentsUsecase
    implements UseCase<bool, DeleteAllAssessmentsParams> {
  final AssessmentRepository repository;

  DeleteAllAssessmentsUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteAllAssessmentsParams params) async {
    try {
      // Validate parameters
      if (params.confirmationText != 'DELETE ALL') {
        return Left(
          ValidationFailure(
            message: 'Invalid confirmation text. Type "DELETE ALL" to confirm.',
          ),
        );
      }

      // Get all assessments first to validate the operation
      final assessmentsResult = await repository.getAllAssessments();

      return await assessmentsResult.fold((failure) => Left(failure), (
        assessments,
      ) async {
        if (assessments.isEmpty) {
          return Left(ValidationFailure(message: 'No assessments to delete.'));
        }

        // Apply filter if specified
        List<String> assessmentIdsToDelete;

        if (params.filter != null) {
          switch (params.filter!) {
            case AssessmentFilterType.draft:
              assessmentIdsToDelete =
                  assessments
                      .where((a) => !a.isComplete && !a.isSubmitted)
                      .map((a) => a.id)
                      .toList();
              break;
            case AssessmentFilterType.completed:
              assessmentIdsToDelete =
                  assessments
                      .where((a) => a.isComplete && !a.isSubmitted)
                      .map((a) => a.id)
                      .toList();
              break;
            case AssessmentFilterType.submitted:
              assessmentIdsToDelete =
                  assessments
                      .where((a) => a.isSubmitted)
                      .map((a) => a.id)
                      .toList();
              break;
            case AssessmentFilterType.all:
              assessmentIdsToDelete = assessments.map((a) => a.id).toList();
              break;
          }
        } else {
          assessmentIdsToDelete = assessments.map((a) => a.id).toList();
        }

        if (assessmentIdsToDelete.isEmpty) {
          return Left(
            ValidationFailure(
              message: 'No assessments match the specified filter.',
            ),
          );
        }

        // Perform bulk deletion
        final result = await repository.deleteAllAssessments(
          assessmentIdsToDelete,
        );

        return result;
      });
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to delete all assessments: ${e.toString()}',
        ),
      );
    }
  }
}

/// Parameters for the DeleteAllAssessments use case
class DeleteAllAssessmentsParams extends Equatable {
  final String confirmationText;
  final AssessmentFilterType? filter;

  const DeleteAllAssessmentsParams({
    required this.confirmationText,
    this.filter,
  });

  @override
  List<Object?> get props => [confirmationText, filter];
}

/// Filter types for bulk deletion
enum AssessmentFilterType { all, draft, completed, submitted }

/// Extension to convert from UI filter to usecase filter
extension AssessmentFilterTypeExtension on AssessmentFilterType {
  static AssessmentFilterType fromUIFilter(dynamic filter) {
    if (filter == null) return AssessmentFilterType.all;

    switch (filter.toString()) {
      case 'AssessmentFilter.draft':
        return AssessmentFilterType.draft;
      case 'AssessmentFilter.completed':
        return AssessmentFilterType.completed;
      case 'AssessmentFilter.submitted':
        return AssessmentFilterType.submitted;
      default:
        return AssessmentFilterType.all;
    }
  }
}
