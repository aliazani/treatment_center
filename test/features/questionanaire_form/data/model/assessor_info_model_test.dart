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

  group('toEntity', () {
    test('should return a valid entity when converting from model', () {
      // Arrange
      // Act
      final result = tAssessorInfoModel.toEntity();
      // Assert
      expect(result, isA<AssessorInfoEntity>());
      expect(result.name, tAssessorInfoModel.name);
      expect(result.email, tAssessorInfoModel.email);
      expect(result.phoneNumber, tAssessorInfoModel.phoneNumber);
      expect(result.assessmentDate, tAssessorInfoModel.assessmentDate);
    });

    test('should correctly preserve date when converting to entity', () {
      // Arrange
      // Act
      final result = tAssessorInfoModel.toEntity();
      // Assert
      expect(result.assessmentDate, testDate);
      expect(result.assessmentDate?.year, 2023);
      expect(result.assessmentDate?.month, 5);
      expect(result.assessmentDate?.day, 10);
    });

    test('should maintain type consistency after conversion', () {
      // Arrange
      // Act
      final entity = tAssessorInfoModel.toEntity();
      final backToModel = AssessorInfoModel.fromEntity(entity);
      // Assert
      expect(backToModel.name, tAssessorInfoModel.name);
      expect(backToModel.email, tAssessorInfoModel.email);
      expect(backToModel.phoneNumber, tAssessorInfoModel.phoneNumber);
      expect(backToModel.assessmentDate, tAssessorInfoModel.assessmentDate);
    });

    test('should create entity with same values but different type', () {
      // Arrange
      // Act
      final result = tAssessorInfoModel.toEntity();
      // Assert
      expect(result, isNot(isA<AssessorInfoModel>()));
      expect(result, isA<AssessorInfoEntity>());
      expect(result.name, equals(tAssessorInfoModel.name));
      expect(result.email, equals(tAssessorInfoModel.email));
      expect(result.phoneNumber, equals(tAssessorInfoModel.phoneNumber));
      expect(result.assessmentDate, equals(tAssessorInfoModel.assessmentDate));
    });

    test('should handle different date values correctly', () {
      // Arrange
      final futureDate = DateTime(2024, 12, 25, 14, 30, 45);
      final modelWithFutureDate = AssessorInfoModel(
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phoneNumber: '0987654321',
        assessmentDate: futureDate,
      );
      // Act
      final result = modelWithFutureDate.toEntity();
      // Assert
      expect(result.assessmentDate, futureDate);
      expect(result.assessmentDate?.year, 2024);
      expect(result.assessmentDate?.month, 12);
      expect(result.assessmentDate?.day, 25);
      expect(result.assessmentDate?.hour, 14);
      expect(result.assessmentDate?.minute, 30);
      expect(result.assessmentDate?.second, 45);
    });
  });
}
