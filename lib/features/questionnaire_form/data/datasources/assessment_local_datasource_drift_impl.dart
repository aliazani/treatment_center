import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/database/daos/assessment_dao.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource.dart';

class AssessmentLocalDataSourceDriftImpl implements AssessmentLocalDataSource {
  final AssessmentDao assessmentDao;

  AssessmentLocalDataSourceDriftImpl({required this.assessmentDao});

  @override
  Future<AssessmentFormModel> getAssessment(String id) async {
    try {
      final assessment = await assessmentDao.getAssessment(id);
      if (assessment != null) {
        return assessment;
      } else {
        throw CacheException(
          message: 'Assessment not found',
          s: 'No assessment found with id: $id',
        );
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to get assessment with id: $id',
        s: e.toString(),
      );
    }
  }

  @override
  Future<List<AssessmentFormModel>> getAllAssessments() async {
    try {
      return await assessmentDao.getAllAssessments();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get all assessment',
        s: e.toString(),
      );
    }
  }

  @override
  Future<List<AssessmentFormModel>> getEditableAssessments() async {
    try {
      // Get all unsubmitted assessments (editable)
      return await assessmentDao.getUnsubmittedAssessments();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get editable assessments',
        s: e.toString(),
      );
    }
  }

  @override
  Future<List<AssessmentFormModel>> getSubmittedAssessments() async {
    try {
      // Get all submitted assessments (read-only)
      return await assessmentDao.getSubmittedAssessments();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get submitted assessments',
        s: e.toString(),
      );
    }
  }

  @override
  Future<bool> canEditAssessment(String id) async {
    try {
      final assessment = await assessmentDao.getAssessment(id);
      if (assessment != null) {
        // Can edit if assessment exists and is not submitted
        return !assessment.isSubmitted;
      }
      return false; // Assessment doesn't exist
    } catch (e) {
      return false; // Error occurred, assume can't edit
    }
  }

  @override
  Future<bool> saveAssessment(AssessmentFormModel assessment) async {
    try {
      return await assessmentDao.saveAssessment(assessment);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save assessment',
        s: e.toString(),
      );
    }
  }

  @override
  Future<bool> saveEditableAssessment(AssessmentFormModel assessment) async {
    try {
      // Only save if assessment is not submitted
      if (assessment.isSubmitted) {
        return false; // Cannot save submitted assessments
      }
      return await assessmentDao.saveAssessment(assessment);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save editable assessment',
        s: e.toString(),
      );
    }
  }

  @override
  Future<bool> updateAssessment(
    String id,
    AssessmentFormModel updatedAssessment,
  ) async {
    try {
      // Check if assessment exists and is editable
      final existingAssessment = await assessmentDao.getAssessment(id);
      if (existingAssessment == null) {
        return false; // Assessment doesn't exist
      }

      if (existingAssessment.isSubmitted) {
        return false; // Cannot update submitted assessments
      }

      // Ensure the updated assessment has the same ID
      final assessmentToUpdate = updatedAssessment.copyWith(id: id);
      return await assessmentDao.updateAssessment(assessmentToUpdate);
    } catch (e) {
      throw CacheException(
        message: 'Failed to update assessment with id: $id',
        s: e.toString(),
      );
    }
  }

  @override
  Future<bool> submitAssessment(String id) async {
    try {
      // Get the existing assessment
      final assessment = await assessmentDao.getAssessment(id);
      if (assessment == null) {
        return false; // Assessment doesn't exist
      }

      // Mark as submitted with current timestamp
      final submittedAssessment = assessment.markAsSubmitted();

      // Update the assessment in the database
      return await assessmentDao.updateAssessment(submittedAssessment);
    } catch (e) {
      throw CacheException(
        message: 'Failed to submit assessment with id: $id',
        s: e.toString(),
      );
    }
  }

  @override
  Future<bool> deleteAssessment(String id) async {
    try {
      return await assessmentDao.deleteAssessment(id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete assessment with id: $id',
        s: e.toString(),
      );
    }
  }

  @override
  Future<bool> deleteEditableAssessment(String id) async {
    try {
      // Check if assessment exists and is editable
      final assessment = await assessmentDao.getAssessment(id);
      if (assessment == null) {
        return false; // Assessment doesn't exist
      }

      if (assessment.isSubmitted) {
        return false; // Cannot delete submitted assessments
      }

      return await assessmentDao.deleteAssessment(id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete editable assessment with id: $id',
        s: e.toString(),
      );
    }
  }

  @override
  Future<bool> deleteAllAssessments(List<String> assessmentIds) async {
    try {
      if (assessmentIds.isEmpty) {
        return true; // Nothing to delete, consider it successful
      }

      // Use the DAO to delete multiple assessments
      final deletedCount = await assessmentDao.deleteAllAssessments(
        assessmentIds,
      );

      // Return true if all assessments were deleted
      return deletedCount == assessmentIds.length;
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete ${assessmentIds.length} assessments',
        s: e.toString(),
      );
    }
  }

  /// Get assessments as a stream for real-time UI updates
  Stream<List<AssessmentFormModel>> watchAllAssessments() {
    return assessmentDao.watchAllAssessments();
  }

  /// Get assessments as a stream filtered by submission status
  Stream<List<AssessmentFormModel>> watchEditableAssessments() {
    return assessmentDao.watchUnsubmittedAssessments();
  }

  /// Get assessments as a stream for submitted assessments
  Stream<List<AssessmentFormModel>> watchSubmittedAssessments() {
    return assessmentDao.watchSubmittedAssessments();
  }

  /// Get only unsubmitted assessments
  Future<List<AssessmentFormModel>> getUnsubmittedAssessments() async {
    try {
      return await assessmentDao.getUnsubmittedAssessments();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get unsubmitted assessments',
        s: e.toString(),
      );
    }
  }

  /// Search assessments by facility name
  Future<List<AssessmentFormModel>> searchByFacilityName(
    String searchTerm,
  ) async {
    try {
      if (searchTerm.isEmpty) {
        return await getAllAssessments();
      }
      return await assessmentDao.searchByFacilityName(searchTerm);
    } catch (e) {
      throw CacheException(
        message: 'Failed to search assessments by facility name',
        s: e.toString(),
      );
    }
  }

  /// Search assessments by assessor name
  Future<List<AssessmentFormModel>> searchByAssessorName(
    String searchTerm,
  ) async {
    try {
      if (searchTerm.isEmpty) {
        return await getAllAssessments();
      }
      return await assessmentDao.searchByAssessorName(searchTerm);
    } catch (e) {
      throw CacheException(
        message: 'Failed to search assessments by assessor name',
        s: e.toString(),
      );
    }
  }

  /// Get assessments within a date range
  Future<List<AssessmentFormModel>> getAssessmentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await assessmentDao.getAssessmentsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to get assessments by date range',
        s: e.toString(),
      );
    }
  }

  /// Get assessment count by status
  Future<Map<String, int>> getAssessmentCounts() async {
    try {
      final allAssessments = await getAllAssessments();
      final submittedCount = allAssessments.where((a) => a.isSubmitted).length;
      final editableCount = allAssessments.length - submittedCount;

      return {
        'total': allAssessments.length,
        'submitted': submittedCount,
        'editable': editableCount,
      };
    } catch (e) {
      throw CacheException(
        message: 'Failed to get assessment counts',
        s: e.toString(),
      );
    }
  }

  /// Check if any assessments exist
  Future<bool> hasAssessments() async {
    try {
      final assessments = await getAllAssessments();
      return assessments.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get the most recently created assessment
  Future<AssessmentFormModel?> getLatestAssessment() async {
    try {
      final assessments = await getAllAssessments();
      if (assessments.isEmpty) return null;

      // Sort by creation date descending and return the first one
      assessments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return assessments.first;
    } catch (e) {
      return null;
    }
  }

  /// Clear all assessments (use with caution)
  Future<bool> clearAllAssessments() async {
    try {
      return await assessmentDao.clearAllAssessments();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all assessments',
        s: e.toString(),
      );
    }
  }
}
