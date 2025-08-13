import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';

abstract class AssessmentLocalDataSource {
  /// Gets all saved assessments from local storage
  ///
  /// Throws a [CacheException] if no data is available or an error occurs
  Future<List<AssessmentFormModel>> getAllAssessments();

  /// Gets an assessment by ID from local storage
  ///
  /// Throws a [CacheException] if no data is available or an error occurs
  Future<AssessmentFormModel> getAssessment(String id);

  /// Gets all unsubmitted assessments (editable forms)
  ///
  /// Returns only assessments where isSubmitted = false
  /// Throws a [CacheException] if an error occurs
  Future<List<AssessmentFormModel>> getEditableAssessments();

  /// Gets all submitted assessments (read-only forms)
  ///
  /// Returns only assessments where isSubmitted = true
  /// Throws a [CacheException] if an error occurs
  Future<List<AssessmentFormModel>> getSubmittedAssessments();

  /// Checks if an assessment can be edited
  ///
  /// Returns true if assessment exists and isSubmitted = false
  /// Returns false if assessment is submitted or doesn't exist
  Future<bool> canEditAssessment(String id);

  /// Saves an assessment to local storage
  ///
  /// Returns true if successful, false otherwise
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> saveAssessment(AssessmentFormModel assessment);

  /// Saves an assessment only if it's not submitted yet
  ///
  /// Returns true if successful, false if assessment is already submitted
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> saveEditableAssessment(AssessmentFormModel assessment);

  /// Updates an existing assessment only if it's not submitted
  ///
  /// Returns true if successful, false if assessment is already submitted or doesn't exist
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> updateAssessment(
    String id,
    AssessmentFormModel updatedAssessment,
  );

  /// Marks an assessment as submitted (makes it read-only)
  ///
  /// Returns true if successful, false if assessment doesn't exist
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> submitAssessment(String id);

  /// Deletes an assessment from local storage
  ///
  /// Returns true if successful, false otherwise
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> deleteAssessment(String id);

  /// Deletes an assessment only if it's not submitted yet
  ///
  /// Returns true if successful, false if assessment is already submitted or doesn't exist
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> deleteEditableAssessment(String id);

  /// Deletes multiple assessments by their IDs
  ///
  /// Returns true if all assessments were successfully deleted, false otherwise
  /// Throws a [CacheException] if an error occurs during the process
  Future<bool> deleteAllAssessments(List<String> assessmentIds);
}
