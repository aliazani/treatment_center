import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

class GetAllAssessmentsUsecase
    implements UseCase<List<AssessmentFormEntity>, NoParams> {
  final AssessmentRepository repository;

  GetAllAssessmentsUsecase(this.repository);

  @override
  Future<Either<Failure, List<AssessmentFormEntity>>> call(
    NoParams params,
  ) async {
    try {
      final result = await repository.getAllAssessments();

      return result;
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to get all assessments: ${e.toString()}',
        ),
      );
    }
  }
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}
