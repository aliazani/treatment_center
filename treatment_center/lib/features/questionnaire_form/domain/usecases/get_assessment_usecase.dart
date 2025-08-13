import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

/// Use case for retrieving a specific assessment form by ID
class GetAssessmentUsecase implements UseCase<AssessmentFormEntity, Params> {
  final AssessmentRepository repository;

  GetAssessmentUsecase(this.repository);

  @override
  Future<Either<Failure, AssessmentFormEntity>> call(Params params) async {
    try {
      // Validate that the assessment ID is not empty
      if (params.assessmentId.isEmpty) {
        return Left(
          ValidationFailure(message: 'Assessment ID cannot be empty'),
        );
      }

      // Get the assessment from the repository
      final result = await repository.getAssessment(params.assessmentId);

      return result;
    } catch (e) {
      return Left(
        ValidationFailure(message: 'Failed to get assessment: ${e.toString()}'),
      );
    }
  }
}

/// Parameters for the GetAssessment use case
class Params extends Equatable {
  final String assessmentId;

  const Params({required this.assessmentId});

  @override
  List<Object> get props => [assessmentId];
}
