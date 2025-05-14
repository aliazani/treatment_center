import '../models/assessment_form_model.dart';

abstract class AssessmentLocalDataSource {
  /// Gets all saved assessments from local storage
  ///
  /// Throws a [CacheException] if no data is available or an error occurs
  Future<List<AssessmentFormModel>> getAllAssessments();

  /// Gets an assessment by ID from local storage
  ///
  /// Throws a [CacheException] if no data is available or an error occurs
  Future<AssessmentFormModel> getAssessment(String id);

  /// Saves an assessment to local storage
  ///
  /// Returns true if successful, false otherwise
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> saveAssessment(AssessmentFormModel assessment);

  /// Deletes an assessment from local storage
  ///
  /// Returns true if successful, false otherwise
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> deleteAssessment(String id);
}
