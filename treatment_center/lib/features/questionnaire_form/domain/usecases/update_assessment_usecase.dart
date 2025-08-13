import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

class UpdateAssessmentUsecase implements UseCase<AssessmentFormEntity, Params> {
  final AssessmentRepository repository;

  UpdateAssessmentUsecase(this.repository);

  @override
  Future<Either<Failure, AssessmentFormEntity>> call(Params params) async {
    try {
      // Validate params
      if (params.assessmentId.isEmpty) {
        return Left(
          ValidationFailure(message: 'Assessment ID cannot be empty'),
        );
      }

      // Get the current assessment
      final assessmentResult = await repository.getAssessment(
        params.assessmentId,
      );

      return await assessmentResult.fold((failure) => Left(failure), (
        assessment,
      ) async {
        try {
          // Apply the update function
          final updatedAssessment = params.updateFunction(assessment);

          // Check if anything was actually changed
          if (updatedAssessment == assessment) {
            // If nothing changed, return the original assessment without saving
            return Right(assessment);
          }

          // Run validation if provided
          if (params.validator != null) {
            final validationResult = params.validator!(updatedAssessment);
            if (validationResult != null) {
              return Left(ValidationFailure(message: validationResult));
            }
          }

          // Save the updated assessment
          final saveResult = await repository.saveAssessment(updatedAssessment);

          return saveResult.fold(
            (failure) => Left(failure),
            (success) =>
                success
                    ? Right(updatedAssessment)
                    : Left(
                      ValidationFailure(message: 'Failed to save assessment'),
                    ),
          );
        } catch (e) {
          return Left(
            ValidationFailure(
              message: 'Error applying update: ${e.toString()}',
            ),
          );
        }
      });
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to update assessment: ${e.toString()}',
        ),
      );
    }
  }
}

class Params extends Equatable {
  final String assessmentId;
  final AssessmentFormEntity Function(AssessmentFormEntity assessment)
  updateFunction;
  final String? Function(AssessmentFormEntity assessment)? validator;

  const Params({
    required this.assessmentId,
    required this.updateFunction,
    this.validator,
  });

  @override
  List<Object?> get props => [assessmentId, updateFunction, validator];
}
