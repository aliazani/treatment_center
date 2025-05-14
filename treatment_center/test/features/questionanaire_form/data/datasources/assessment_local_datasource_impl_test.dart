import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource_impl.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';
import 'assessment_local_datasource_impl_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late AssessmentLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = AssessmentLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  // Test data
  final tAssessmentId1 = 'test-assessment-id-1';
  final tAssessmentId2 = 'test-assessment-id-2';
  final tAssessmentModel1 = 
      TestAssessmentFixtures.createTestAssessmentFormModel(id: tAssessmentId1);
  final tAssessmentModel2 = 
      TestAssessmentFixtures.createTestAssessmentFormModel(id: tAssessmentId2);
  final tAssessmentModelJson1 = json.encode(tAssessmentModel1.toJson());
  final tAssessmentModelJson2 = json.encode(tAssessmentModel2.toJson());
  
  group('getAssessment', () {
    test('should return AssessmentFormModel from SharedPreferences when there is one', () async {
      // arrange
      when(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'))
          .thenReturn(tAssessmentModelJson1);
      
      // act
      final result = await dataSource.getAssessment(tAssessmentId1);
      
      // assert
      verify(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'));
      expect(result.id, equals(tAssessmentModel1.id));
      expect(result.assessorInfo.name, equals(tAssessmentModel1.assessorInfo.name));
      // Add more assertions for other important fields if needed
    });

    test('should throw a CacheException when there is no cached value', () {
      // arrange
      when(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'))
          .thenReturn(null);
      
      // act
      final call = dataSource.getAssessment;
      
      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'));
    });

    test('should throw a CacheException when there is an error parsing the JSON', () {
      // arrange
      when(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'))
          .thenReturn('invalid json');
      
      // act
      final call = dataSource.getAssessment;
      
      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'));
    });
  });

  group('getAllAssessments', () {
    test('should return all assessments from SharedPreferences when there are some', () async {
      // arrange
      final idsList = [tAssessmentId1, tAssessmentId2];
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenReturn(idsList);
      when(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'))
          .thenReturn(tAssessmentModelJson1);
      when(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId2'))
          .thenReturn(tAssessmentModelJson2);
      
      // act
      final result = await dataSource.getAllAssessments();
      
      // assert
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
      verify(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'));
      verify(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId2'));
      expect(result.length, equals(2));
      expect(result[0].id, equals(tAssessmentModel1.id));
      expect(result[1].id, equals(tAssessmentModel2.id));
    });

    test('should return empty list when no assessments exist', () async {
      // arrange
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenReturn(null);
      
      // act
      final result = await dataSource.getAllAssessments();
      
      // assert
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
      expect(result, isEmpty);
    });

    test('should skip assessments that cannot be retrieved', () async {
      // arrange
      final idsList = [tAssessmentId1, tAssessmentId2];
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenReturn(idsList);
      // First assessment can be retrieved
      when(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'))
          .thenReturn(tAssessmentModelJson1);
      // Second assessment cannot be retrieved
      when(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId2'))
          .thenReturn(null);
      
      // act
      final result = await dataSource.getAllAssessments();
      
      // assert
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
      verify(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId1'));
      verify(mockSharedPreferences.getString('$ASSESSMENT_PREFIX$tAssessmentId2'));
      expect(result.length, equals(1));
      expect(result[0].id, equals(tAssessmentModel1.id));
    });

    test('should throw a CacheException when there is an error getting the list of IDs', () {
      // arrange
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenThrow(Exception('Test error'));
      
      // act
      final call = dataSource.getAllAssessments;
      
      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
    });
  });

  group('saveAssessment', () {
    test('should save a new assessment to SharedPreferences', () async {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenReturn([]);
      when(mockSharedPreferences.setStringList(any, any))
          .thenAnswer((_) async => true);
      
      // act
      final result = await dataSource.saveAssessment(tAssessmentModel1);
      
      // assert
      verify(mockSharedPreferences.setString(
        '$ASSESSMENT_PREFIX${tAssessmentModel1.id}',
        json.encode(tAssessmentModel1.toJson()),
      ));
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
      verify(mockSharedPreferences.setStringList(
        ASSESSMENT_IDS_KEY,
        [tAssessmentModel1.id],
      ));
      expect(result, true);
    });

    test('should update an existing assessment in SharedPreferences', () async {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenReturn([tAssessmentId1]);
      
      // act
      final result = await dataSource.saveAssessment(tAssessmentModel1);
      
      // assert
      verify(mockSharedPreferences.setString(
        '$ASSESSMENT_PREFIX${tAssessmentModel1.id}',
        json.encode(tAssessmentModel1.toJson()),
      ));
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
      // Verify that setStringList is not called since ID already exists
      verifyNever(mockSharedPreferences.setStringList(any, any));
      expect(result, true);
    });

    test('should return false when setting the string fails', () async {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => false);
      
      // act
      final result = await dataSource.saveAssessment(tAssessmentModel1);
      
      // assert
      verify(mockSharedPreferences.setString(
        '$ASSESSMENT_PREFIX${tAssessmentModel1.id}',
        json.encode(tAssessmentModel1.toJson()),
      ));
      // Verify that getStringList is never called since setting failed
      verifyNever(mockSharedPreferences.getStringList(any));
      expect(result, false);
    });

    test('should throw a CacheException when there is an error during save', () {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenThrow(Exception('Test error'));
      
      // act
      final call = dataSource.saveAssessment;
      
      // assert
      expect(() => call(tAssessmentModel1), throwsA(isA<CacheException>()));
      verify(mockSharedPreferences.setString(
        '$ASSESSMENT_PREFIX${tAssessmentModel1.id}',
        json.encode(tAssessmentModel1.toJson()),
      ));
    });
  });

  group('deleteAssessment', () {
    test('should delete an assessment from SharedPreferences', () async {
      // arrange
      when(mockSharedPreferences.remove(any))
          .thenAnswer((_) async => true);
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenReturn([tAssessmentId1]);
      when(mockSharedPreferences.setStringList(any, any))
          .thenAnswer((_) async => true);
      
      // act
      final result = await dataSource.deleteAssessment(tAssessmentId1);
      
      // assert
      verify(mockSharedPreferences.remove('$ASSESSMENT_PREFIX$tAssessmentId1'));
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
      verify(mockSharedPreferences.setStringList(
        ASSESSMENT_IDS_KEY,
        [],
      ));
      expect(result, true);
    });

    test('should handle deletion when ID is not in the list', () async {
      // arrange
      when(mockSharedPreferences.remove(any))
          .thenAnswer((_) async => true);
      when(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY))
          .thenReturn([tAssessmentId2]); // Different ID
      
      // act
      final result = await dataSource.deleteAssessment(tAssessmentId1);
      
      // assert
      verify(mockSharedPreferences.remove('$ASSESSMENT_PREFIX$tAssessmentId1'));
      verify(mockSharedPreferences.getStringList(ASSESSMENT_IDS_KEY));
      // Verify setStringList is not called since ID wasn't in the list
      verifyNever(mockSharedPreferences.setStringList(any, any));
      expect(result, true);
    });

    test('should return false when removing fails', () async {
      // arrange
      when(mockSharedPreferences.remove(any))
          .thenAnswer((_) async => false);
      
      // act
      final result = await dataSource.deleteAssessment(tAssessmentId1);
      
      // assert
      verify(mockSharedPreferences.remove('$ASSESSMENT_PREFIX$tAssessmentId1'));
      // Verify getStringList is never called since removal failed
      verifyNever(mockSharedPreferences.getStringList(any));
      expect(result, false);
    });

    test('should throw a CacheException when there is an error during deletion', () {
      // arrange
      when(mockSharedPreferences.remove(any))
          .thenThrow(Exception('Test error'));
      
      // act
      final call = dataSource.deleteAssessment;
      
      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockSharedPreferences.remove('$ASSESSMENT_PREFIX$tAssessmentId1'));
    });
  });
}