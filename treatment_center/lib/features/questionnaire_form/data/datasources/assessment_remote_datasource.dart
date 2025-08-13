import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';

// firebase remote data source
abstract class AssessmentRemoteDataSource {
  /// Uploads assessment to Firebase Storage
  Future<String> uploadAssessment(AssessmentFormModel assessment);

  /// Submits assessment via Firebase Cloud Functions with email
  Future<bool> submitAssessmentViaFirebaseEmail(
    AssessmentFormModel assessment,
    String recipientEmail, {
    required List<String> exportFormats, // ['pdf', 'excel', 'docx']
    String? subject,
    String? body,
    ExportOptions? exportOptions,
    List<String> photoFilePaths = const [],
  });

  /// Uploads exported file to Firebase Storage
  // Future<String> uploadExportedFile(
  //   String filePath,
  //   String fileName,
  //   String assessmentId,
  // );

  // NEW: Add method that works with ExportResult
  Future<String> uploadExportedFile(
    ExportResult exportResult,
    String assessmentId,
  );

  /// Sends email with multiple attachments via Cloud Functions
  Future<bool> sendEmailWithAttachments(
    String recipientEmail,
    String subject,
    String body,
    List<String> attachmentUrls,
    Map<String, dynamic> assessmentData,
  );
}
