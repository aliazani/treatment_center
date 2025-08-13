import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_state.dart';

abstract class CompareAssessmentsEvent extends Equatable {
  const CompareAssessmentsEvent();

  @override
  List<Object?> get props => [];
}

/// Load assessments for comparison selection
class LoadAssessmentsForComparison extends CompareAssessmentsEvent {
  const LoadAssessmentsForComparison();
}

/// Select first assessment for comparison
class SelectFirstAssessment extends CompareAssessmentsEvent {
  final String assessmentId;

  const SelectFirstAssessment({required this.assessmentId});

  @override
  List<Object?> get props => [assessmentId];
}

/// Select second assessment for comparison
class SelectSecondAssessment extends CompareAssessmentsEvent {
  final String assessmentId;

  const SelectSecondAssessment({required this.assessmentId});

  @override
  List<Object?> get props => [assessmentId];
}

/// Compare the two selected assessments
class CompareAssessments extends CompareAssessmentsEvent {
  const CompareAssessments();
}

/// Switch the order of the two selected assessments
class SwitchComparisonOrder extends CompareAssessmentsEvent {
  const SwitchComparisonOrder();
}

/// Reset comparison selection
class ResetComparison extends CompareAssessmentsEvent {
  const ResetComparison();
}

/// Toggle comparison section visibility
class ToggleComparisonSection extends CompareAssessmentsEvent {
  final String sectionId;

  const ToggleComparisonSection({required this.sectionId});

  @override
  List<Object?> get props => [sectionId];
}

/// Filter comparison by difference type
class FilterComparisonByType extends CompareAssessmentsEvent {
  final ComparisonFilter filter;

  const FilterComparisonByType({required this.filter});

  @override
  List<Object?> get props => [filter];
}
