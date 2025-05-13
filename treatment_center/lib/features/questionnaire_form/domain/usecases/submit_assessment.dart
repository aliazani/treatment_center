import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import './usecase.dart';
import '../repositories/assessment_repository.dart';

class SubmitAssessment implements UseCase<bool, Params> {
  final AssessmentRepository repository;

  SubmitAssessment(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    try {
      // Get the assessment
      final assessmentResult = await repository.getAssessment(
        params.assessmentId,
      );

      return await assessmentResult.fold((failure) => Left(failure), (
        assessment,
      ) async {
        // Check if assessment is complete
        if (!assessment.isComplete) {
          return Left(
            ValidationFailure(
              message:
                  'Cannot submit incomplete assessment. Please complete all required items.',
            ),
          );
        }

        // Only mark as submitted if not already submitted
        final updatedAssessment =
            assessment.isSubmitted ? assessment : assessment.markAsSubmitted();

        // Save the submitted assessment
        final saveResult = await repository.saveAssessment(updatedAssessment);

        return await saveResult.fold((failure) => Left(failure), (
          success,
        ) async {
          // If email is provided and the save was successful, send via email
          if (success && params.recipientEmail != null) {
            final emailResult = await repository.submitAssessmentViaEmail(
              updatedAssessment,
              params.recipientEmail!,
            );

            return emailResult;
          }

          return Right(success);
        });
      });
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to submit assessment: ${e.toString()}',
        ),
      );
    }
  }
}

class Params extends Equatable {
  final String assessmentId;
  final String? recipientEmail;

  const Params({required this.assessmentId, this.recipientEmail});

  @override
  List<Object?> get props => [assessmentId, recipientEmail];
}
