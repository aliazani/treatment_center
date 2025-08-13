import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';

void main() {
  group('AssessorInfo', () {
    final testDate = DateTime(2023, 5, 15);

    test('should create a valid AssessorInfo instance', () {
      // Arrange & Act
      final assessorInfo = AssessorInfoEntity(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        assessmentDate: testDate,
      );

      // Assert
      expect(assessorInfo.name, 'John Doe');
      expect(assessorInfo.email, 'john.doe@example.com');
      expect(assessorInfo.phoneNumber, '+1234567890');
      expect(assessorInfo.assessmentDate, testDate);
    });

    test('two instances with the same values should be equal', () {
      // Arrange
      final assessorInfo1 = AssessorInfoEntity(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        assessmentDate: testDate,
      );

      final assessorInfo2 = AssessorInfoEntity(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        assessmentDate: testDate,
      );

      // Act & Assert
      expect(assessorInfo1, equals(assessorInfo2));
    });

    test('two instances with different values should not be equal', () {
      // Arrange
      final assessorInfo1 = AssessorInfoEntity(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        assessmentDate: testDate,
      );

      final assessorInfo2 = AssessorInfoEntity(
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phoneNumber: '+0987654321',
        assessmentDate: testDate,
      );

      // Act & Assert
      expect(assessorInfo1, isNot(equals(assessorInfo2)));
    });
  });
}
