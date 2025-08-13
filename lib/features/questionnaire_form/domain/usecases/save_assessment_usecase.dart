import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

/// Use case for saving an assessment form
class SaveAssessmentUsecase implements UseCase<bool, Params> {
  final AssessmentRepository repository;

  SaveAssessmentUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    try {
      // Validate the assessment
      final validationError = _validateAssessment(params.assessment);
      if (validationError != null) {
        return Left(ValidationFailure(message: validationError));
      }

      // Save the assessment to repository
      final result = await repository.saveAssessment(params.assessment);

      return result;
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to save assessment: ${e.toString()}',
        ),
      );
    }
  }

  /// Validates the assessment before saving
  String? _validateAssessment(AssessmentFormEntity assessment) {
    // Check if assessment ID is empty
    if (assessment.id.isEmpty) {
      return 'Assessment ID cannot be empty';
    }

    // Check if assessor info is valid
    if (assessment.assessorInfo.name.isEmpty) {
      return 'Assessor name is required';
    }

    if (assessment.assessorInfo.email.isEmpty) {
      return 'Assessor email is required';
    }

    // Check if facility identification is valid
    if (assessment.facilityIdentification.facilityName.isEmpty) {
      return 'Facility name is required';
    }

    if (assessment.facilityIdentification.facilityCode.isEmpty) {
      return 'Facility code is required';
    }

    // Check if sections exist
    if (assessment.sections.isEmpty) {
      return 'Assessment must have at least one section';
    }

    // Additional business rule validations can be added here
    // For example:
    // - Check if assessment date is not in the future
    // - Validate facility type combinations
    // - Check required sections are present

    return null; // No validation errors
  }
}

/// Parameters for the SaveAssessment use case
class Params extends Equatable {
  final AssessmentFormEntity assessment;

  const Params({required this.assessment});

  @override
  List<Object> get props => [assessment];
}
