import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

class DeleteAssessmentUsecase {
  final AssessmentRepository repository;

  DeleteAssessmentUsecase(this.repository);

  Future<Either<Failure, void>> call(DeleteAssessmentParams params) {
    return repository.deleteAssessment(params.id);
  }
}

class DeleteAssessmentParams {
  final String id;

  DeleteAssessmentParams({required this.id});
}
