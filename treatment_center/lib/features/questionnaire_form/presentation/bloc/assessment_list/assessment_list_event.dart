import 'package:equatable/equatable.dart';

abstract class AssessmentEvent extends Equatable {
  const AssessmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssessments extends AssessmentEvent {
  const LoadAssessments();
}

class DeleteAssessmentEvent extends AssessmentEvent {
  final String assessmentId;

  const DeleteAssessmentEvent({required this.assessmentId});

  @override
  List<Object?> get props => [assessmentId];
}

class FilterAssessments extends AssessmentEvent {
  final AssessmentFilter filter;

  const FilterAssessments({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class SearchAssessments extends AssessmentEvent {
  final String query;

  const SearchAssessments({required this.query});

  @override
  List<Object?> get props => [query];
}

class CreateAssessment extends AssessmentEvent {
  const CreateAssessment();
}

class UpdateAssessment extends AssessmentEvent {
  final String assessmentId;
  final Map<String, dynamic> data;

  const UpdateAssessment({required this.assessmentId, required this.data});

  @override
  List<Object?> get props => [assessmentId, data];
}

enum AssessmentFilter { all, draft, completed, submitted }
