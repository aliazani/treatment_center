import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'assessment_list_event.dart';

abstract class AssessmentListState extends Equatable {
  const AssessmentListState();

  @override
  List<Object?> get props => [];
}

class AssessmentInitial extends AssessmentListState {
  const AssessmentInitial();
}

class AssessmentLoading extends AssessmentListState {
  const AssessmentLoading();
}

class AssessmentLoaded extends AssessmentListState {
  final List<AssessmentFormEntity> allAssessments;
  final List<AssessmentFormEntity> filteredAssessments;
  final AssessmentFilter currentFilter;
  final String searchQuery;

  const AssessmentLoaded({
    required this.allAssessments,
    required this.filteredAssessments,
    required this.currentFilter,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [
    allAssessments,
    filteredAssessments,
    currentFilter,
    searchQuery,
  ];

  AssessmentLoaded copyWith({
    List<AssessmentFormEntity>? allAssessments,
    List<AssessmentFormEntity>? filteredAssessments,
    AssessmentFilter? currentFilter,
    String? searchQuery,
  }) {
    return AssessmentLoaded(
      allAssessments: allAssessments ?? this.allAssessments,
      filteredAssessments: filteredAssessments ?? this.filteredAssessments,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AssessmentError extends AssessmentListState {
  final String message;

  const AssessmentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AssessmentDeleted extends AssessmentListState {
  final String message;

  const AssessmentDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class AssessmentCreated extends AssessmentListState {
  final String assessmentId;

  const AssessmentCreated({required this.assessmentId});

  @override
  List<Object?> get props => [assessmentId];
}

class AssessmentUpdated extends AssessmentListState {
  final String message;

  const AssessmentUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}
