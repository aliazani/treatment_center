import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';

abstract class AssessmentComparisonState extends Equatable {
  const AssessmentComparisonState();

  @override
  List<Object?> get props => [];
}

class AssessmentComparisonInitial extends AssessmentComparisonState {
  const AssessmentComparisonInitial();
}

class AssessmentComparisonLoading extends AssessmentComparisonState {
  const AssessmentComparisonLoading();
}

class AssessmentSelectionLoaded extends AssessmentComparisonState {
  final List<AssessmentFormEntity> availableAssessments;
  final AssessmentFormEntity? firstSelectedAssessment;
  final AssessmentFormEntity? secondSelectedAssessment;

  const AssessmentSelectionLoaded({
    required this.availableAssessments,
    this.firstSelectedAssessment,
    this.secondSelectedAssessment,
  });

  @override
  List<Object?> get props => [
    availableAssessments,
    firstSelectedAssessment,
    secondSelectedAssessment,
  ];

  AssessmentSelectionLoaded copyWith({
    List<AssessmentFormEntity>? availableAssessments,
    AssessmentFormEntity? firstSelectedAssessment,
    AssessmentFormEntity? secondSelectedAssessment,
    bool clearFirst = false,
    bool clearSecond = false,
  }) {
    return AssessmentSelectionLoaded(
      availableAssessments: availableAssessments ?? this.availableAssessments,
      firstSelectedAssessment:
          clearFirst
              ? null
              : firstSelectedAssessment ?? this.firstSelectedAssessment,
      secondSelectedAssessment:
          clearSecond
              ? null
              : secondSelectedAssessment ?? this.secondSelectedAssessment,
    );
  }

  bool get canCompare =>
      firstSelectedAssessment != null &&
      secondSelectedAssessment != null &&
      firstSelectedAssessment!.id != secondSelectedAssessment!.id;
}

/// Comparison results loaded
class AssessmentComparisonLoaded extends AssessmentComparisonState {
  final AssessmentFormEntity firstAssessment;
  final AssessmentFormEntity secondAssessment;
  final AssessmentComparisonResult comparisonResult;
  final Set<String> expandedSections;
  final ComparisonFilter currentFilter;

  const AssessmentComparisonLoaded({
    required this.firstAssessment,
    required this.secondAssessment,
    required this.comparisonResult,
    this.expandedSections = const {},
    this.currentFilter = ComparisonFilter.all,
  });

  @override
  List<Object?> get props => [
    firstAssessment,
    secondAssessment,
    comparisonResult,
    expandedSections,
    currentFilter,
  ];

  AssessmentComparisonLoaded copyWith({
    AssessmentFormEntity? firstAssessment,
    AssessmentFormEntity? secondAssessment,
    AssessmentComparisonResult? comparisonResult,
    Set<String>? expandedSections,
    ComparisonFilter? currentFilter,
  }) {
    return AssessmentComparisonLoaded(
      firstAssessment: firstAssessment ?? this.firstAssessment,
      secondAssessment: secondAssessment ?? this.secondAssessment,
      comparisonResult: comparisonResult ?? this.comparisonResult,
      expandedSections: expandedSections ?? this.expandedSections,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class AssessmentComparisonError extends AssessmentComparisonState {
  final String message;

  const AssessmentComparisonError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AssessmentComparisonResult extends Equatable {
  final List<SectionComparison> sectionComparisons;
  final AssessmentOverviewComparison overviewComparison;
  final ComparisonStatistics statistics;

  const AssessmentComparisonResult({
    required this.sectionComparisons,
    required this.overviewComparison,
    required this.statistics,
  });

  @override
  List<Object?> get props => [
    sectionComparisons,
    overviewComparison,
    statistics,
  ];
}

class SectionComparison extends Equatable {
  final String sectionId;
  final String sectionTitle;
  final List<ItemComparison> itemComparisons;
  final bool hasChanges;

  const SectionComparison({
    required this.sectionId,
    required this.sectionTitle,
    required this.itemComparisons,
    required this.hasChanges,
  });

  @override
  List<Object?> get props => [
    sectionId,
    sectionTitle,
    itemComparisons,
    hasChanges,
  ];
}

class ItemComparison extends Equatable {
  final String itemId;
  final String area;
  final String? firstValue;
  final String? secondValue;
  final ComparisonType type;
  final String? description;

  const ItemComparison({
    required this.itemId,
    required this.area,
    this.firstValue,
    this.secondValue,
    required this.type,
    this.description,
  });

  @override
  List<Object?> get props => [
    itemId,
    area,
    firstValue,
    secondValue,
    type,
    description,
  ];
}

class AssessmentOverviewComparison extends Equatable {
  final String firstFacilityName;
  final String secondFacilityName;
  final DateTime firstAssessmentDate;
  final DateTime secondAssessmentDate;
  final String firstAssessorName;
  final String secondAssessorName;

  const AssessmentOverviewComparison({
    required this.firstFacilityName,
    required this.secondFacilityName,
    required this.firstAssessmentDate,
    required this.secondAssessmentDate,
    required this.firstAssessorName,
    required this.secondAssessorName,
  });

  @override
  List<Object?> get props => [
    firstFacilityName,
    secondFacilityName,
    firstAssessmentDate,
    secondAssessmentDate,
    firstAssessorName,
    secondAssessorName,
  ];
}

class ComparisonStatistics extends Equatable {
  final int totalItems;
  final int changedItems;
  final int improvedItems;
  final int declinedItems;
  final int unchangedItems;
  final double improvementPercentage;

  const ComparisonStatistics({
    required this.totalItems,
    required this.changedItems,
    required this.improvedItems,
    required this.declinedItems,
    required this.unchangedItems,
    required this.improvementPercentage,
  });

  @override
  List<Object?> get props => [
    totalItems,
    changedItems,
    improvedItems,
    declinedItems,
    unchangedItems,
    improvementPercentage,
  ];
}

enum ComparisonType {
  unchanged,
  improved,
  declined,
  firstOnly,
  secondOnly,
  different,
}

enum ComparisonFilter { all, differences, similarities, improved, declined }
