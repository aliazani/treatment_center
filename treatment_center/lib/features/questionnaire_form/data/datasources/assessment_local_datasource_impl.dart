import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/assessment_form_model.dart';
import './assessment_local_datasource.dart';

const ASSESSMENT_PREFIX = 'ASSESSMENT_';
const ASSESSMENT_IDS_KEY = 'ASSESSMENT_IDS';

class AssessmentLocalDataSourceImpl implements AssessmentLocalDataSource {
  final SharedPreferences sharedPreferences;

  AssessmentLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AssessmentFormModel> getAssessment(String id) async {
    try {
      final jsonString = sharedPreferences.getString('$ASSESSMENT_PREFIX$id');
      if (jsonString != null) {
        return AssessmentFormModel.fromJson(json.decode(jsonString));
      } else {
        throw CacheException();
      }
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<AssessmentFormModel>> getAllAssessments() async {
    try {
      // Get list of assessment IDs
      final idsList = sharedPreferences.getStringList(ASSESSMENT_IDS_KEY) ?? [];

      // Retrieve each assessment by ID
      final assessments = <AssessmentFormModel>[];
      for (final id in idsList) {
        try {
          final assessment = await getAssessment(id);
          assessments.add(assessment);
        } catch (e) {
          // Skip if individual assessment can't be retrieved
          continue;
        }
      }

      return assessments;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> saveAssessment(AssessmentFormModel assessment) async {
    try {
      // Save the assessment
      final jsonString = json.encode(assessment.toJson());
      final success = await sharedPreferences.setString(
        '$ASSESSMENT_PREFIX${assessment.id}',
        jsonString,
      );

      if (!success) return false;

      // Update the list of assessment IDs
      final idsList = sharedPreferences.getStringList(ASSESSMENT_IDS_KEY) ?? [];
      if (!idsList.contains(assessment.id)) {
        idsList.add(assessment.id);
        await sharedPreferences.setStringList(ASSESSMENT_IDS_KEY, idsList);
      }

      return true;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> deleteAssessment(String id) async {
    try {
      // Remove the assessment
      final success = await sharedPreferences.remove('$ASSESSMENT_PREFIX$id');

      if (!success) return false;

      // Update the list of assessment IDs
      final idsList = sharedPreferences.getStringList(ASSESSMENT_IDS_KEY) ?? [];
      if (idsList.contains(id)) {
        idsList.remove(id);
        await sharedPreferences.setStringList(ASSESSMENT_IDS_KEY, idsList);
      }

      return true;
    } catch (e) {
      throw CacheException();
    }
  }
}
