import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import './usecase.dart';
import '../entities/assessment_form.dart';
import '../repositories/assessment_repository.dart';

class UpdateAssessment implements UseCase<AssessmentForm, Params> {
  final AssessmentRepository repository;

  UpdateAssessment(this.repository);

  @override
  Future<Either<Failure, AssessmentForm>> call(Params params) async {
    try {
      // Validate params
      if (params.assessmentId.isEmpty) {
        return Left(ValidationFailure(message: 'Assessment ID cannot be empty'));
      }

      // Get the current assessment
      final assessmentResult = await repository.getAssessment(params.assessmentId);
      
      return await assessmentResult.fold(
        (failure) => Left(failure),
        (assessment) async {
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
              (success) => success ? Right(updatedAssessment) : 
                  Left(ValidationFailure(message: 'Failed to save assessment')),
            );
          } catch (e) {
            return Left(ValidationFailure(
              message: 'Error applying update: ${e.toString()}'
            ));
          }
        },
      );
    } catch (e) {
      return Left(ValidationFailure(
        message: 'Failed to update assessment: ${e.toString()}'
      ));
    }
  }
}

class Params extends Equatable {
  final String assessmentId;
  final AssessmentForm Function(AssessmentForm assessment) updateFunction;
  final String? Function(AssessmentForm assessment)? validator;
  
  const Params({
    required this.assessmentId,
    required this.updateFunction,
    this.validator,
  });
  
  @override
  List<Object?> get props => [assessmentId, updateFunction, validator];
}