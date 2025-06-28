import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';

void main() {
  final DateTime testDate = DateTime(2023, 5, 10);

  final tAssessorInfoModel = AssessorInfoModel(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phoneNumber: '1234567890',
    assessmentDate: testDate,
  );

  final tAssessorInfoJson = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone_number': '1234567890',
    'assessment_date': '2023-05-10T00:00:00.000',
  };

  group('AssessorInfoModel', () {
    test('should be a subclass of AssessorInfo entity', () {
      // Arrange and Act
      // assert
      expect(tAssessorInfoModel, isA<AssessorInfoEntity>());
    });

    group('fromJson', () {
      test('should return a valid model when the JSON is valid', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tAssessorInfoJson;
        // Act
        final result = AssessorInfoModel.fromJson(jsonMap);
        // Assert
        expect(result, tAssessorInfoModel);
      });

      test('should correctly parse date from JSON string', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tAssessorInfoJson;
        // Act
        final result = AssessorInfoModel.fromJson(jsonMap);
        // Assert
        expect(result.assessmentDate, testDate);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // Arrange
        // Act
        final result = tAssessorInfoModel.toJson();
        // Assert
        expect(result, tAssessorInfoJson);
      });

      test('should correctly convert date to ISO-8601 string', () {
        // Arrange
        // Act
        final result = tAssessorInfoModel.toJson();
        // Assert
        expect(result['assessment_date'], testDate.toIso8601String());
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // Arrange
        final entity = AssessorInfoEntity(
          name: 'John Doe',
          email: 'john.doe@example.com',
          phoneNumber: '1234567890',
          assessmentDate: testDate,
        );
        // Act
        final result = AssessorInfoModel.fromEntity(entity);
        // Assert
        expect(result, tAssessorInfoModel);
        expect(result.name, entity.name);
        expect(result.email, entity.email);
        expect(result.phoneNumber, entity.phoneNumber);
        expect(result.assessmentDate, entity.assessmentDate);
      });
    });
  });
}
