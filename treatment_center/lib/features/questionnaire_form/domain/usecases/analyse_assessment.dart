import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import './usecase.dart';
import '../repositories/assessment_repository.dart';

/// Assessment analysis result containing various metrics
class AssessmentAnalysis extends Equatable {
  /// The ID of the assessment
  final String assessmentId;
  
  /// The name of the facility
  final String facilityName;
  
  /// Date when the assessment was conducted
  final DateTime assessmentDate;
  
  /// Overall completion percentage (0-100)
  final double completionPercentage;
  
  /// Whether the assessment has been submitted
  final bool isSubmitted;
  
  /// Total number of assessment items
  final int totalItems;
  
  /// Number of completed items
  final int completedItems;
  
  /// Count of items rated as "Meets target"
  final int meetsTargetCount;
  
  /// Count of items rated as "Partially meets target"
  final int partiallyMeetsCount;
  
  /// Count of items rated as "Does not meet target"
  final int doesNotMeetCount;
  
  /// Count of items marked "Don't know"
  final int dontKnowCount;
  
  /// Count of items marked "Not applicable"
  final int notApplicableCount;
  
  /// DateTime when the assessment was submitted (if applicable)
  final DateTime? submissionDate;

  const AssessmentAnalysis({
    required this.assessmentId,
    required this.facilityName,
    required this.assessmentDate,
    required this.completionPercentage,
    required this.isSubmitted,
    required this.totalItems,
    required this.completedItems,
    required this.meetsTargetCount,
    required this.partiallyMeetsCount,
    required this.doesNotMeetCount,
    required this.dontKnowCount,
    required this.notApplicableCount,
    this.submissionDate,
  });

  @override
  List<Object?> get props => [
    assessmentId,
    facilityName,
    assessmentDate,
    completionPercentage,
    isSubmitted,
    totalItems,
    completedItems,
    meetsTargetCount,
    partiallyMeetsCount,
    doesNotMeetCount,
    dontKnowCount,
    notApplicableCount,
    submissionDate,
  ];
}

/// Use case to analyze an assessment and generate statistics
class AnalyzeAssessment implements UseCase<AssessmentAnalysis, Params> {
  final AssessmentRepository repository;

  AnalyzeAssessment(this.repository);

  @override
  Future<Either<Failure, AssessmentAnalysis>> call(Params params) async {
    try {
      // Get the assessment
      final assessmentResult = await repository.getAssessment(params.assessmentId);
      
      return assessmentResult.fold(
        (failure) => Left(failure),
        (assessment) {
          // Calculate statistics
          int totalItems = 0;
          int completedItems = 0;
          int meetsTargetCount = 0;
          int partiallyMeetsCount = 0;
          int doesNotMeetCount = 0;
          int dontKnowCount = 0;
          int notApplicableCount = 0;
          
          // Iterate through all sections and items
          for (final section in assessment.sections) {
            for (final item in section.items) {
              totalItems++;
              
              if (item.selectedRating != null) {
                completedItems++;
                
                // Count by rating type
                final ratingValue = item.selectedRating!.value;
                if (ratingValue == 3) {
                  meetsTargetCount++;
                } else if (ratingValue == 2) {
                  partiallyMeetsCount++;
                } else if (ratingValue == 1) {
                  doesNotMeetCount++;
                } else if (ratingValue == 0) {
                  dontKnowCount++;
                } else if (ratingValue == -1) {
                  notApplicableCount++;
                }
              }
            }
          }
          
          // Create the analysis result
          final analysis = AssessmentAnalysis(
            assessmentId: assessment.id,
            facilityName: assessment.facilityIdentification.facilityName,
            assessmentDate: assessment.assessorInfo.assessmentDate,
            completionPercentage: assessment.completionPercentage,
            isSubmitted: assessment.isSubmitted,
            totalItems: totalItems,
            completedItems: completedItems,
            meetsTargetCount: meetsTargetCount,
            partiallyMeetsCount: partiallyMeetsCount,
            doesNotMeetCount: doesNotMeetCount,
            dontKnowCount: dontKnowCount,
            notApplicableCount: notApplicableCount,
            submissionDate: assessment.submissionDate,
          );
          
          return Right(analysis);
        },
      );
    } catch (e) {
      return Left(ValidationFailure(message: 'Failed to analyze assessment: ${e.toString()}'));
    }
  }
}

class Params extends Equatable {
  final String assessmentId;

  const Params({required this.assessmentId});

  @override
  List<Object> get props => [assessmentId];
}