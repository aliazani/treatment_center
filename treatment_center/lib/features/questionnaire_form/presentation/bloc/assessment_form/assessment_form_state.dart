import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/core/services/export_service.dart';

abstract class AssessmentFormState extends Equatable {
  const AssessmentFormState();

  @override
  List<Object?> get props => [];
}

class AssessmentFormLoaded extends AssessmentFormState {
  final AssessmentFormEntity? assessmentForm;
  final int currentStep;
  final int totalSteps;
  final bool hasUnsavedChanges;
  final bool isEditMode;
  final List<ExportResult> exportHistory;
  final bool showExportDialog;
  final bool showCompletionDialog;
  final bool showExportSuccessDialog;

  // Loading states for different operations
  final bool isInitializing;
  final bool isSaving;
  final bool isExporting;
  final bool isSubmittingEmail;
  final bool isValidating;

  // Operation results
  final String? lastSaveResult;
  final ExportResult? lastExportResult;
  final String? lastSubmissionResult;
  final String? validationError;

  const AssessmentFormLoaded({
    this.assessmentForm,
    this.currentStep = 1,
    this.totalSteps = 6,
    this.hasUnsavedChanges = false,
    this.isEditMode = false,
    this.exportHistory = const [],
    this.isInitializing = false,
    this.isSaving = false,
    this.isExporting = false,
    this.isSubmittingEmail = false,
    this.isValidating = false,
    this.lastSaveResult,
    this.lastExportResult,
    this.lastSubmissionResult,
    this.validationError,
    this.showExportDialog = false,
    this.showCompletionDialog = false,
    this.showExportSuccessDialog = false,
  });

  @override
  List<Object?> get props => [
    assessmentForm,
    currentStep,
    totalSteps,
    hasUnsavedChanges,
    isEditMode,
    exportHistory,
    isInitializing,
    isSaving,
    isExporting,
    isSubmittingEmail,
    isValidating,
    lastSaveResult,
    lastExportResult,
    lastSubmissionResult,
    validationError,
    showExportDialog,
    showCompletionDialog,
    showExportSuccessDialog,
  ];

  AssessmentFormLoaded copyWith({
    AssessmentFormEntity? assessmentForm,
    int? currentStep,
    int? totalSteps,
    bool? hasUnsavedChanges,
    bool? isEditMode,
    List<ExportResult>? exportHistory,
    bool? isInitializing,
    bool? isSaving,
    bool? isExporting,
    bool? isSubmittingEmail,
    bool? isValidating,
    String? lastSaveResult,
    ExportResult? lastExportResult,
    String? lastSubmissionResult,
    String? validationError,
    bool clearLastSaveResult = false,
    bool clearLastExportResult = false,
    bool clearLastSubmissionResult = false,
    bool clearValidationError = false,
    bool? showExportDialog,
    bool? showCompletionDialog,
    bool? showExportSuccessDialog,
  }) {
    return AssessmentFormLoaded(
      assessmentForm: assessmentForm ?? this.assessmentForm,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isEditMode: isEditMode ?? this.isEditMode,
      exportHistory: exportHistory ?? this.exportHistory,
      isInitializing: isInitializing ?? this.isInitializing,
      isSaving: isSaving ?? this.isSaving,
      isExporting: isExporting ?? this.isExporting,
      isSubmittingEmail: isSubmittingEmail ?? this.isSubmittingEmail,
      isValidating: isValidating ?? this.isValidating,
      lastSaveResult:
          clearLastSaveResult ? null : (lastSaveResult ?? this.lastSaveResult),
      lastExportResult:
          clearLastExportResult
              ? null
              : (lastExportResult ?? this.lastExportResult),
      lastSubmissionResult:
          clearLastSubmissionResult
              ? null
              : (lastSubmissionResult ?? this.lastSubmissionResult),
      validationError:
          clearValidationError
              ? null
              : (validationError ?? this.validationError),
      showExportDialog: showExportDialog ?? this.showExportDialog,
      showCompletionDialog: showCompletionDialog ?? this.showCompletionDialog,
      showExportSuccessDialog:
          showExportSuccessDialog ?? this.showExportSuccessDialog,
    );
  }

  bool get isLoading =>
      isInitializing ||
      isSaving ||
      isExporting ||
      isSubmittingEmail ||
      isValidating;
  bool get canNavigate => !isLoading;
  bool get canSave => assessmentForm != null && !isLoading;
  bool get canExport => assessmentForm != null && !isLoading;
  bool get isOnLastStep => currentStep >= totalSteps;
  bool get canGoToNextStep => currentStep < totalSteps && canNavigate;
  bool get canGoToPreviousStep => currentStep > 1 && canNavigate;
}

/// Initial state before any operations
class AssessmentFormInitial extends AssessmentFormState {
  const AssessmentFormInitial();
}

/// Error state for initialization
class AssessmentFormInitializationError extends AssessmentFormState {
  final String message;

  const AssessmentFormInitializationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state for save operations
class AssessmentFormSaveError extends AssessmentFormState {
  final String message;
  final AssessmentFormEntity? assessmentForm;
  final int currentStep;

  const AssessmentFormSaveError({
    required this.message,
    this.assessmentForm,
    this.currentStep = 1,
  });

  @override
  List<Object?> get props => [message, assessmentForm, currentStep];
}

/// Error state for export operations
class AssessmentFormExportError extends AssessmentFormState {
  final String message;
  final AssessmentFormEntity assessmentForm;

  const AssessmentFormExportError({
    required this.message,
    required this.assessmentForm,
  });

  @override
  List<Object?> get props => [message, assessmentForm];
}

/// Error state for email submission
class AssessmentFormSubmissionError extends AssessmentFormState {
  final String message;
  final AssessmentFormEntity assessmentForm;

  const AssessmentFormSubmissionError({
    required this.message,
    required this.assessmentForm,
  });

  @override
  List<Object?> get props => [message, assessmentForm];
}

/// Success state for save operations
class AssessmentFormSaved extends AssessmentFormState {
  final String message;
  final AssessmentFormEntity assessmentForm;

  const AssessmentFormSaved({
    required this.message,
    required this.assessmentForm,
  });

  @override
  List<Object?> get props => [message, assessmentForm];
}

/// Success state for export operations
class AssessmentFormExported extends AssessmentFormState {
  final ExportResult exportResult;
  final AssessmentFormEntity assessmentForm;

  const AssessmentFormExported({
    required this.exportResult,
    required this.assessmentForm,
  });

  @override
  List<Object?> get props => [exportResult, assessmentForm];
}

/// Success state for email submission
class AssessmentFormSubmitted extends AssessmentFormState {
  final String message;
  final AssessmentFormEntity assessmentForm;

  const AssessmentFormSubmitted({
    required this.message,
    required this.assessmentForm,
  });

  @override
  List<Object?> get props => [message, assessmentForm];
}

/// State for validation errors
class AssessmentFormValidationError extends AssessmentFormState {
  final String message;
  final int sectionNumber;
  final AssessmentFormEntity? assessmentForm;

  const AssessmentFormValidationError({
    required this.message,
    required this.sectionNumber,
    this.assessmentForm,
  });

  @override
  List<Object?> get props => [message, sectionNumber, assessmentForm];
}

/// State for requesting user confirmation (e.g., unsaved changes)
class AssessmentFormConfirmationRequired extends AssessmentFormState {
  final String message;
  final String confirmationId;
  final AssessmentFormEntity? assessmentForm;
  final Map<String, dynamic>? data;

  const AssessmentFormConfirmationRequired({
    required this.message,
    required this.confirmationId,
    this.assessmentForm,
    this.data,
  });

  @override
  List<Object?> get props => [message, confirmationId, assessmentForm, data];
}