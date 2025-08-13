import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_state.dart';
import 'assessment_list_event.dart';

class AssessmentListBloc extends Bloc<AssessmentEvent, AssessmentListState> {
  final GetAllAssessmentsUsecase getAllAssessments;
  final DeleteAssessmentUsecase deleteAssessment;

  AssessmentListBloc({
    required this.getAllAssessments,
    required this.deleteAssessment,
  }) : super(const AssessmentInitial()) {
    on<LoadAssessments>(_onLoadAssessments);
    on<DeleteAssessmentEvent>(_onDeleteAssessment);
    on<FilterAssessments>(_onFilterAssessments);
    on<SearchAssessments>(_onSearchAssessments);
  }

  Future<void> _onLoadAssessments(
    LoadAssessments event,
    Emitter<AssessmentListState> emit,
  ) async {
    emit(const AssessmentLoading());

    final failureOrAssessments = await getAllAssessments(const NoParams());

    failureOrAssessments.fold(
      (failure) =>
          emit(AssessmentError(message: _mapFailureToMessage(failure))),
      (assessments) => emit(
        AssessmentLoaded(
          allAssessments: assessments,
          filteredAssessments: assessments,
          currentFilter: AssessmentFilter.all,
          searchQuery: '',
        ),
      ),
    );
  }

  Future<void> _onDeleteAssessment(
    DeleteAssessmentEvent event,
    Emitter<AssessmentListState> emit,
  ) async {
    if (state is! AssessmentLoaded) return;

    final currentState = state as AssessmentLoaded;
    emit(const AssessmentLoading());

    final failureOrSuccess = await deleteAssessment(
      DeleteAssessmentParams(id: event.assessmentId),
    );

    failureOrSuccess.fold(
      (failure) =>
          emit(AssessmentError(message: _mapFailureToMessage(failure))),
      (_) {
        final updatedAssessments =
            currentState.allAssessments
                .where((assessment) => assessment.id != event.assessmentId)
                .toList();

        final filteredAssessments = _applyFilterAndSearch(
          updatedAssessments,
          currentState.currentFilter,
          currentState.searchQuery,
        );

        emit(
          currentState.copyWith(
            allAssessments: updatedAssessments,
            filteredAssessments: filteredAssessments,
          ),
        );
      },
    );
  }

  void _onFilterAssessments(
    FilterAssessments event,
    Emitter<AssessmentListState> emit,
  ) {
    if (state is! AssessmentLoaded) return;

    final currentState = state as AssessmentLoaded;
    final filteredAssessments = _applyFilterAndSearch(
      currentState.allAssessments,
      event.filter,
      currentState.searchQuery,
    );

    emit(
      currentState.copyWith(
        currentFilter: event.filter,
        filteredAssessments: filteredAssessments,
      ),
    );
  }

  void _onSearchAssessments(
    SearchAssessments event,
    Emitter<AssessmentListState> emit,
  ) {
    if (state is! AssessmentLoaded) return;

    final currentState = state as AssessmentLoaded;
    final filteredAssessments = _applyFilterAndSearch(
      currentState.allAssessments,
      currentState.currentFilter,
      event.query,
    );

    emit(
      currentState.copyWith(
        searchQuery: event.query,
        filteredAssessments: filteredAssessments,
      ),
    );
  }

  List<AssessmentFormEntity> _applyFilterAndSearch(
    List<AssessmentFormEntity> assessments,
    AssessmentFilter filter,
    String searchQuery,
  ) {
    List<AssessmentFormEntity> filtered = assessments;

    switch (filter) {
      case AssessmentFilter.draft:
        filtered =
            assessments.where((a) => !a.isComplete && !a.isSubmitted).toList();
        break;
      case AssessmentFilter.completed:
        filtered =
            assessments.where((a) => a.isComplete && !a.isSubmitted).toList();
        break;
      case AssessmentFilter.submitted:
        filtered = assessments.where((a) => a.isSubmitted).toList();
        break;
      case AssessmentFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (assessment) => assessment.assessorInfo.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()),
              )
              .toList();
    }

    return filtered;
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error occurred. Please try again later.';
    } else if (failure is CacheFailure) {
      return 'Local storage error occurred.';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is ValidationFailure) {
      return 'Validation error: ${failure.message}';
    } else {
      return 'An unexpected error occurred: ${failure.message}';
    }
  }
}
