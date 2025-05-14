import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';

abstract class AssessmentRemoteDataSource {
  /// Submits an assessment via email with a PDF or DOC attachment
  ///
  /// Returns true if successful, false otherwise
  /// Throws an [EmailException] if email sending fails
  Future<bool> submitAssessmentViaEmail(
    AssessmentFormModel assessment,
    String recipientEmail,
    {required String exportFormat, // 'pdf' or 'doc' 
    String? subject,
    String? body}
  );
  
  /// Converts an assessment to a file (PDF or DOC)
  /// 
  /// Returns the file path of the generated document
  /// Throws a [FileException] if file generation fails
  Future<String> exportAssessmentToFile(
    AssessmentFormModel assessment,
    String format, // 'pdf' or 'doc'
  );
}