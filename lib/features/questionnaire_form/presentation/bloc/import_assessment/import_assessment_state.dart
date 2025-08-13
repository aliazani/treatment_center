import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';

abstract class ImportAssessmentState extends Equatable {
  const ImportAssessmentState();

  @override
  List<Object?> get props => [];
}

class ImportAssessmentInitial extends ImportAssessmentState {}

class ImportAssessmentLoading extends ImportAssessmentState {}

class ImportAssessmentSuccess extends ImportAssessmentState {
  final AssessmentFormEntity assessment;
  final Map<String, dynamic>? statistics;
  final String message;

  const ImportAssessmentSuccess({
    required this.assessment,
    this.statistics,
    this.message = 'Assessment imported successfully',
  });

  @override
  List<Object?> get props => [assessment, statistics, message];
}

class ImportStatisticsLoaded extends ImportAssessmentState {
  final Map<String, dynamic> statistics;

  const ImportStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class ImportAssessmentError extends ImportAssessmentState {
  final String message;
  final String? errorCode;

  const ImportAssessmentError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}
