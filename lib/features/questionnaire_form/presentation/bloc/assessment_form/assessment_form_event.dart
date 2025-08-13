import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/core/services/export_service.dart';

abstract class AssessmentFormEvent extends Equatable {
  const AssessmentFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form - load existing or create new
class InitializeAssessmentForm extends AssessmentFormEvent {
  final String? assessmentId;

  const InitializeAssessmentForm({this.assessmentId});

  @override
  List<Object?> get props => [assessmentId];
}

/// Update form data
class UpdateAssessmentForm extends AssessmentFormEvent {
  final AssessmentFormEntity updatedForm;

  const UpdateAssessmentForm({required this.updatedForm});

  @override
  List<Object?> get props => [updatedForm];
}

class NavigateToNextStep extends AssessmentFormEvent {
  const NavigateToNextStep();
}

class NavigateToPreviousStep extends AssessmentFormEvent {
  const NavigateToPreviousStep();
}

class NavigateToStep extends AssessmentFormEvent {
  final int step;
  const NavigateToStep({required this.step});
  @override
  List<Object?> get props => [step];
}

/// Form operations
class SaveAssessmentForm extends AssessmentFormEvent {
  const SaveAssessmentForm();
}

class ValidateCurrentSection extends AssessmentFormEvent {
  const ValidateCurrentSection();
}

/// Export events
class ExportAssessment extends AssessmentFormEvent {
  final String format;
  final ExportOptions options;

  const ExportAssessment({required this.format, required this.options});

  @override
  List<Object?> get props => [format, options];
}

class LoadExportHistory extends AssessmentFormEvent {
  const LoadExportHistory();
}

class DeleteExportedFile extends AssessmentFormEvent {
  final ExportResult file;
  final int index;

  const DeleteExportedFile({required this.file, required this.index});

  @override
  List<Object?> get props => [file, index];
}

class ShareExportedFile extends AssessmentFormEvent {
  final ExportResult file;

  const ShareExportedFile({required this.file});

  @override
  List<Object?> get props => [file];
}

/// Email submission events
class SubmitAssessmentViaEmail extends AssessmentFormEvent {
  final String recipientEmail;
  final List<String> exportFormats;
  final String? customSubject;
  final String? customBody;
  final List<String> photoFilePaths;

  const SubmitAssessmentViaEmail({
    required this.recipientEmail,
    required this.exportFormats,
    this.customSubject,
    this.customBody,
    this.photoFilePaths = const [],
  });

  @override
  List<Object?> get props => [
    recipientEmail,
    exportFormats,
    customSubject,
    customBody,
    photoFilePaths,
  ];
}

/// Completion events
class CompleteAssessmentOnly extends AssessmentFormEvent {
  const CompleteAssessmentOnly();
}

class CompleteAssessment extends AssessmentFormEvent {
  const CompleteAssessment();
}

/// Utility events
class ShowExportDialog extends AssessmentFormEvent {
  const ShowExportDialog();
}

class HideExportDialog extends AssessmentFormEvent {
  const HideExportDialog();
}

class ShowCompletionDialog extends AssessmentFormEvent {
  const ShowCompletionDialog();
}

class HideCompletionDialog extends AssessmentFormEvent {
  const HideCompletionDialog();
}

class ClearUnsavedChanges extends AssessmentFormEvent {
  const ClearUnsavedChanges();
}

class MarkFormAsChanged extends AssessmentFormEvent {
  const MarkFormAsChanged();
}

class ExportFailed extends AssessmentFormEvent {
  final String error;

  const ExportFailed({required this.error});

  @override
  List<Object> get props => [error];
}
