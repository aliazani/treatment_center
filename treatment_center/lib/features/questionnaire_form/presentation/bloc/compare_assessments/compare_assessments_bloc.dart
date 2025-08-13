import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_assessment_usecase.dart';
import 'compare_assessments_event.dart';
import 'compare_assessments_state.dart';

class CompareAssessmentsBloc
    extends Bloc<CompareAssessmentsEvent, AssessmentComparisonState> {
  final GetAllAssessmentsUsecase getAllAssessments;
  final GetAssessmentUsecase getAssessmentById;

  CompareAssessmentsBloc({
    required this.getAllAssessments,
    required this.getAssessmentById,
  }) : super(const AssessmentComparisonInitial()) {
    on<LoadAssessmentsForComparison>(_onLoadAssessmentsForComparison);
    on<SelectFirstAssessment>(_onSelectFirstAssessment);
    on<SelectSecondAssessment>(_onSelectSecondAssessment);
    on<CompareAssessments>(_onCompareAssessments);
    on<SwitchComparisonOrder>(_onSwitchComparisonOrder);
    on<ResetComparison>(_onResetComparison);
    on<ToggleComparisonSection>(_onToggleComparisonSection);
    on<FilterComparisonByType>(_onFilterComparisonByType);
  }

  Future<void> _onLoadAssessmentsForComparison(
    LoadAssessmentsForComparison event,
    Emitter<AssessmentComparisonState> emit,
  ) async {
    emit(const AssessmentComparisonLoading());
    try {
      final result = await getAllAssessments.call(const NoParams());
      result.fold(
        (failure) => emit(AssessmentComparisonError(message: failure.message)),
        (assessments) {
          final valid =
              assessments.where((a) => a.sections.isNotEmpty).toList();
          if (valid.length < 2) {
            emit(
              const AssessmentComparisonError(
                message: 'At least 2 assessments are required for comparison',
              ),
            );
            return;
          }
          emit(AssessmentSelectionLoaded(availableAssessments: valid));
        },
      );
    } catch (e) {
      emit(
        AssessmentComparisonError(message: 'Failed to load assessments: $e'),
      );
    }
  }

  Future<void> _onSelectFirstAssessment(
    SelectFirstAssessment event,
    Emitter<AssessmentComparisonState> emit,
  ) async {
    if (state is AssessmentSelectionLoaded) {
      final current = state as AssessmentSelectionLoaded;
      try {
        final result = await getAssessmentById.call(
          Params(assessmentId: event.assessmentId),
        );
        result.fold(
          (failure) =>
              emit(AssessmentComparisonError(message: failure.message)),
          (a) => emit(current.copyWith(firstSelectedAssessment: a)),
        );
      } catch (e) {
        emit(
          AssessmentComparisonError(
            message: 'Failed to load first assessment: $e',
          ),
        );
      }
    }
  }

  Future<void> _onSelectSecondAssessment(
    SelectSecondAssessment event,
    Emitter<AssessmentComparisonState> emit,
  ) async {
    if (state is AssessmentSelectionLoaded) {
      final current = state as AssessmentSelectionLoaded;
      try {
        final result = await getAssessmentById.call(
          Params(assessmentId: event.assessmentId),
        );
        result.fold(
          (failure) =>
              emit(AssessmentComparisonError(message: failure.message)),
          (a) => emit(current.copyWith(secondSelectedAssessment: a)),
        );
      } catch (e) {
        emit(
          AssessmentComparisonError(
            message: 'Failed to load second assessment: $e',
          ),
        );
      }
    }
  }

  Future<void> _onCompareAssessments(
    CompareAssessments event,
    Emitter<AssessmentComparisonState> emit,
  ) async {
    if (state is AssessmentSelectionLoaded) {
      final current = state as AssessmentSelectionLoaded;
      if (!current.canCompare) {
        emit(
          const AssessmentComparisonError(
            message: 'Please select two different assessments to compare',
          ),
        );
        return;
      }
      try {
        final result = generateComparisonResult(
          current.firstSelectedAssessment!,
          current.secondSelectedAssessment!,
        );
        emit(
          AssessmentComparisonLoaded(
            firstAssessment: current.firstSelectedAssessment!,
            secondAssessment: current.secondSelectedAssessment!,
            comparisonResult: result,
          ),
        );
      } catch (e) {
        emit(
          AssessmentComparisonError(
            message: 'Failed to generate comparison: $e',
          ),
        );
      }
    }
  }

  Future<void> _onSwitchComparisonOrder(
    SwitchComparisonOrder event,
    Emitter<AssessmentComparisonState> emit,
  ) async {
    try {
      // If we're in comparison results view, switch and regenerate
      if (state is AssessmentComparisonLoaded) {
        final current = state as AssessmentComparisonLoaded;

        // Swap the assessments
        final swappedFirstAssessment = current.secondAssessment;
        final swappedSecondAssessment = current.firstAssessment;

        // Regenerate comparison with swapped order
        final result = generateComparisonResult(
          swappedFirstAssessment,
          swappedSecondAssessment,
        );

        emit(
          AssessmentComparisonLoaded(
            firstAssessment: swappedFirstAssessment,
            secondAssessment: swappedSecondAssessment,
            comparisonResult: result,
            expandedSections: current.expandedSections,
            currentFilter: current.currentFilter,
          ),
        );
        return;
      }
      if (state is AssessmentSelectionLoaded) {
        final current = state as AssessmentSelectionLoaded;

        if (current.firstSelectedAssessment != null &&
            current.secondSelectedAssessment != null) {
          emit(
            current.copyWith(
              firstSelectedAssessment: current.secondSelectedAssessment,
              secondSelectedAssessment: current.firstSelectedAssessment,
            ),
          );
        }
        return;
      }
    } catch (e) {
      emit(
        AssessmentComparisonError(
          message: 'Failed to switch comparison order: $e',
        ),
      );
    }
  }

  void _onResetComparison(
    ResetComparison event,
    Emitter<AssessmentComparisonState> emit,
  ) {
    if (state is AssessmentSelectionLoaded) {
      final current = state as AssessmentSelectionLoaded;
      emit(current.copyWith(clearFirst: true, clearSecond: true));
    } else if (state is AssessmentComparisonLoaded) {
      add(const LoadAssessmentsForComparison());
    }
  }

  void _onToggleComparisonSection(
    ToggleComparisonSection event,
    Emitter<AssessmentComparisonState> emit,
  ) {
    if (state is AssessmentComparisonLoaded) {
      final current = state as AssessmentComparisonLoaded;
      final expanded = Set<String>.from(current.expandedSections);
      if (!expanded.remove(event.sectionId)) expanded.add(event.sectionId);
      emit(current.copyWith(expandedSections: expanded));
    }
  }

  void _onFilterComparisonByType(
    FilterComparisonByType event,
    Emitter<AssessmentComparisonState> emit,
  ) {
    if (state is AssessmentComparisonLoaded) {
      final current = state as AssessmentComparisonLoaded;
      emit(current.copyWith(currentFilter: event.filter));
    }
  }

  /// Helper to compare any two fields of type T
  ItemComparison _compareField<T>(String label, T? firstValue, T? secondValue) {
    final f = firstValue?.toString() ?? '';
    final s = secondValue?.toString() ?? '';
    final type = f == s ? ComparisonType.unchanged : ComparisonType.different;
    return ItemComparison(
      itemId: label,
      area: label,
      firstValue: f,
      secondValue: s,
      type: type,
      description:
          type == ComparisonType.unchanged
              ? 'No change'
              : 'Changed from $f to $s',
    );
  }

  @visibleForTesting
  AssessmentComparisonResult generateComparisonResult(
    AssessmentFormEntity first,
    AssessmentFormEntity second,
  ) {
    final sections = <SectionComparison>[];
    final titles = <String>{};
    final firstMap = <String, AssessmentSectionEntity>{};
    final secondMap = <String, AssessmentSectionEntity>{};

    // Build map by title
    for (var s in first.sections) {
      titles.add(s.title);
      firstMap[s.title] = s;
    }
    for (var s in second.sections) {
      titles.add(s.title);
      secondMap[s.title] = s;
    }

    for (var title in titles) {
      // SPECIAL: Section 1 = "Facility Information Assessment"
      if (title == 'Facility Information Assessment') {
        final fields = <ItemComparison>[];

        // 1.1 Assessment Information
        fields.add(
          _compareField<DateTime>(
            'Assessment Date',
            first.assessorInfo.assessmentDate,
            second.assessorInfo.assessmentDate,
          ),
        );
        fields.add(
          _compareField<String>(
            'Assessor Name',
            first.assessorInfo.name,
            second.assessorInfo.name,
          ),
        );
        fields.add(
          _compareField<String>(
            'Assessor Email',
            first.assessorInfo.email,
            second.assessorInfo.email,
          ),
        );
        fields.add(
          _compareField<String>(
            'Assessor Phone',
            first.assessorInfo.phoneNumber,
            second.assessorInfo.phoneNumber,
          ),
        );

        // 1.2 Geographical Location
        fields.add(
          _compareField<String>(
            'Country',
            first.geoLocation.country,
            second.geoLocation.country,
          ),
        );
        fields.add(
          _compareField<String>(
            'Region/Province',
            first.geoLocation.regionProvince,
            second.geoLocation.regionProvince,
          ),
        );
        fields.add(
          _compareField<String>(
            'District',
            first.geoLocation.district,
            second.geoLocation.district,
          ),
        );
        fields.add(
          _compareField<String>(
            'City/Village',
            first.geoLocation.cityVillage,
            second.geoLocation.cityVillage,
          ),
        );
        fields.add(
          _compareField<String>(
            'Address/GPS',
            first.geoLocation.addressOrCoordinates,
            second.geoLocation.addressOrCoordinates,
          ),
        );

        // 1.3 Facility Identification
        fields.add(
          _compareField<String>(
            'Facility Code',
            first.facilityIdentification.facilityCode,
            second.facilityIdentification.facilityCode,
          ),
        );
        fields.add(
          _compareField<String>(
            'Facility Name',
            first.facilityIdentification.facilityName,
            second.facilityIdentification.facilityName,
          ),
        );
        fields.add(
          _compareField<String>(
            'Director Name',
            first.facilityIdentification.directorName,
            second.facilityIdentification.directorName,
          ),
        );
        fields.add(
          _compareField<String>(
            'Director Phone',
            first.facilityIdentification.directorPhone,
            second.facilityIdentification.directorPhone,
          ),
        );
        fields.add(
          _compareField<String>(
            'Director Email',
            first.facilityIdentification.directorEmail,
            second.facilityIdentification.directorEmail,
          ),
        );
        fields.add(
          _compareField<String>(
            'Respondent Name',
            first.facilityIdentification.respondentName,
            second.facilityIdentification.respondentName,
          ),
        );
        fields.add(
          _compareField<String>(
            'Respondent Position',
            first.facilityIdentification.respondentPosition,
            second.facilityIdentification.respondentPosition,
          ),
        );

        // 1.4 Facility Services
        fields.add(
          _compareField<bool>(
            'Offers Outpatient Services',
            first.facilityServices.hasOutpatientServices,
            second.facilityServices.hasOutpatientServices,
          ),
        );
        fields.add(
          _compareField<bool>(
            'Offers Inpatient Services',
            first.facilityServices.hasInpatientServices,
            second.facilityServices.hasInpatientServices,
          ),
        );
        fields.add(
          _compareField<String>(
            'Total Inpatient Beds',
            first.facilityServices.totalInpatientBeds?.toString(),
            second.facilityServices.totalInpatientBeds?.toString(),
          ),
        );
        fields.add(
          _compareField<String>(
            'ICU Beds',
            first.facilityServices.icuBeds?.toString(),
            second.facilityServices.icuBeds?.toString(),
          ),
        );
        fields.add(
          _compareField<bool>(
            '24h Emergency Unit',
            first.facilityServices.hasEmergencyUnit,
            second.facilityServices.hasEmergencyUnit,
          ),
        );
        fields.add(
          _compareField<bool>(
            'Intensive Care Unit',
            first.facilityServices.hasIcuOrHighDependencyUnit,
            second.facilityServices.hasIcuOrHighDependencyUnit,
          ),
        );

        fields.add(
          _compareField<int>(
            'Photo Count',
            first.photos.length,
            second.photos.length,
          ),
        );

        final hasChanges = fields.any(
          (f) => f.type != ComparisonType.unchanged,
        );

        sections.add(
          SectionComparison(
            sectionId: title,
            sectionTitle: title,
            itemComparisons: fields,
            hasChanges: hasChanges,
          ),
        );
        continue;
      }

      // ALL OTHER SECTIONS: item‑based
      final fSec = firstMap[title];
      final sSec = secondMap[title];
      final fItems = fSec?.items ?? [];
      final sItems = sSec?.items ?? [];

      final comparisons = _compareItems(fItems, sItems);
      final hasChanges = comparisons.any(
        (c) => c.type != ComparisonType.unchanged,
      );

      sections.add(
        SectionComparison(
          sectionId: title,
          sectionTitle: title,
          itemComparisons: comparisons,
          hasChanges: hasChanges,
        ),
      );
    }

    final overview = AssessmentOverviewComparison(
      firstFacilityName: first.facilityIdentification.facilityName,
      secondFacilityName: second.facilityIdentification.facilityName,
      firstAssessmentDate: first.assessorInfo.assessmentDate ?? DateTime.now(),
      secondAssessmentDate:
          second.assessorInfo.assessmentDate ?? DateTime.now(),
      firstAssessorName: first.assessorInfo.name,
      secondAssessorName: second.assessorInfo.name,
    );
    final stats = _calculateStatistics(sections);

    return AssessmentComparisonResult(
      sectionComparisons: sections,
      overviewComparison: overview,
      statistics: stats,
    );
  }

  List<ItemComparison> _compareItems(
    List<dynamic> firstItems,
    List<dynamic> secondItems,
  ) {
    final comps = <ItemComparison>[];
    final len = max(firstItems.length, secondItems.length);
    for (var i = 0; i < len; i++) {
      final f = i < firstItems.length ? firstItems[i] : null;
      final s = i < secondItems.length ? secondItems[i] : null;
      comps.add(_compareItem(f, s, i.toString()));
    }
    return comps;
  }

  @visibleForTesting
  ItemComparison compareItemForTest(
    dynamic firstItem,
    dynamic secondItem,
    String itemId,
  ) {
    return _compareItem(firstItem, secondItem, itemId);
  }

  ItemComparison _compareItem(
    dynamic firstItem,
    dynamic secondItem,
    String itemId,
  ) {
    if (firstItem == null && secondItem == null) {
      return ItemComparison(
        itemId: itemId,
        area: 'Unknown',
        type: ComparisonType.unchanged,
      );
    }
    if (firstItem == null) {
      return ItemComparison(
        itemId: itemId,
        area: _getItemArea(secondItem),
        secondValue: _getItemValue(secondItem),
        type: ComparisonType.secondOnly,
        description: 'Only in second assessment',
      );
    }
    if (secondItem == null) {
      return ItemComparison(
        itemId: itemId,
        area: _getItemArea(firstItem),
        firstValue: _getItemValue(firstItem),
        type: ComparisonType.firstOnly,
        description: 'Only in first assessment',
      );
    }

    final v1 = _getItemValue(firstItem);
    final v2 = _getItemValue(secondItem);
    if (v1 == v2) {
      return ItemComparison(
        itemId: itemId,
        area: _getItemArea(firstItem),
        firstValue: v1,
        secondValue: v2,
        type: ComparisonType.unchanged,
        description: 'No change',
      );
    }
    final type = _determineComparisonType(v1, v2);
    return ItemComparison(
      itemId: itemId,
      area: _getItemArea(firstItem),
      firstValue: v1,
      secondValue: v2,
      type: type,
      description: _getComparisonDescription(type, v1, v2),
    );
  }

  String _getItemArea(dynamic item) => item?.area?.toString() ?? 'Unknown Area';

  String? _getItemValue(dynamic item) {
    final rating = item?.selectedRating?.value;
    switch (rating) {
      case 3:
        return 'Meets target (+++) (3)';
      case 2:
        return 'Partially meets target (++) (2)';
      case 1:
        return 'Does not meet target (+) (1)';
      case 0:
        return 'Don\'t Know (DK)';
      case -1:
        return 'Not Applicable (NA)';
      default:
        return 'No rating';
    }
  }

  ComparisonType _determineComparisonType(String? a, String? b) {
    final x = _extractRatingValue(a);
    final y = _extractRatingValue(b);
    if (x == null || y == null) return ComparisonType.different;
    if (y > x) return ComparisonType.improved;
    if (y < x) return ComparisonType.declined;
    return ComparisonType.unchanged;
  }

  int? _extractRatingValue(String? s) {
    if (s?.contains('(3)') == true) return 3;
    if (s?.contains('(2)') == true) return 2;
    if (s?.contains('(1)') == true) return 1;
    if (s?.contains('(DK)') == true) return 0;
    if (s?.contains('(NA)') == true) return -1;
    return null;
  }

  String _getComparisonDescription(ComparisonType type, String? a, String? b) {
    switch (type) {
      case ComparisonType.improved:
        return 'Improved from $a to $b';
      case ComparisonType.declined:
        return 'Declined from $a to $b';
      case ComparisonType.different:
        return 'Changed from $a to $b';
      case ComparisonType.firstOnly:
        return 'Only in first assessment';
      case ComparisonType.secondOnly:
        return 'Only in second assessment';
      case ComparisonType.unchanged:
        return 'No change';
    }
  }

  ComparisonStatistics _calculateStatistics(List<SectionComparison> sections) {
    int total = 0, changed = 0, imp = 0, dec = 0, unch = 0;
    for (var sec in sections) {
      for (var itm in sec.itemComparisons) {
        total++;
        switch (itm.type) {
          case ComparisonType.improved:
            imp++;
            changed++;
            break;
          case ComparisonType.declined:
            dec++;
            changed++;
            break;
          case ComparisonType.unchanged:
            unch++;
            break;
          case ComparisonType.different:
          case ComparisonType.firstOnly:
          case ComparisonType.secondOnly:
            changed++;
            break;
        }
      }
    }

    final improvedRate = total > 0 ? imp / total * 100 : 0.0;
    final declinedRate = total > 0 ? dec / total * 100 : 0.0;
    final netRate = improvedRate - declinedRate;
    return ComparisonStatistics(
      totalItems: total,
      changedItems: changed,
      improvedItems: imp,
      declinedItems: dec,
      unchangedItems: unch,
      improvementPercentage: netRate,
    );
  }
}
