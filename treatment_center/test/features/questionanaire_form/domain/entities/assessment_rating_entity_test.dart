import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';

void main() {
  group('AssessmentRating', () {
    test(
      'factory meetsTarget should create a predefined rating with value 3',
      () {
        // Arrange & Act
        final rating = AssessmentRatingEntity.meetsTarget();

        // Assert
        expect(rating.id, 'meets_target');
        expect(rating.value, 3);
        expect(rating.label, 'Meets target (+++) (3)');
        expect(rating.description, contains('fully meets'));
      },
    );

    test(
      'factory partiallyMeetsTarget should create a predefined rating with value 2',
      () {
        // Arrange & Act
        final rating = AssessmentRatingEntity.partiallyMeetsTarget();

        // Assert
        expect(rating.id, 'partially_meets');
        expect(rating.value, 2);
        expect(rating.label, 'Partially meets target (++) (2)');
        expect(rating.description, contains('partially meets'));
      },
    );

    test(
      'factory doesNotMeetTarget should create a predefined rating with value 1',
      () {
        // Arrange & Act
        final rating = AssessmentRatingEntity.doesNotMeetTarget();

        // Assert
        expect(rating.id, 'does_not_meet');
        expect(rating.value, 1);
        expect(rating.label, 'Does not meet target (+) (1)');
        expect(rating.description, contains('does not meet'));
      },
    );

    test('factory dontKnow should create a special rating with value 0', () {
      // Arrange & Act
      final rating = AssessmentRatingEntity.dontKnow();

      // Assert
      expect(rating.id, 'dont_know');
      expect(rating.value, 0);
      expect(rating.label, 'Don\'t Know (DK)');
      expect(rating.description, contains('not possible to determine'));
    });

    test(
      'factory notApplicable should create a special rating with value -1',
      () {
        // Arrange & Act
        final rating = AssessmentRatingEntity.notApplicable();

        // Assert
        expect(rating.id, 'not_applicable');
        expect(rating.value, -1);
        expect(rating.label, 'Not Applicable (NA)');
        expect(rating.description, contains('does not apply'));
      },
    );

    // Optional: Add a test for the custom constructor
    test('custom constructor creates rating with specified values', () {
      // Arrange & Act
      const rating = AssessmentRatingEntity(
        id: 'custom_id',
        value: 5,
        label: 'Custom Label',
        description: 'Custom description',
      );

      // Assert
      expect(rating.id, 'custom_id');
      expect(rating.value, 5);
      expect(rating.label, 'Custom Label');
      expect(rating.description, 'Custom description');
    });

    test('should be equal when all properties are equal', () {
      // Arrange
      final rating1 = AssessmentRatingEntity.meetsTarget();
      final rating2 = AssessmentRatingEntity.meetsTarget();

      // Assert
      expect(rating1, equals(rating2));
    });

    test('should not be equal when any property differs', () {
      // Arrange
      final rating1 = AssessmentRatingEntity.meetsTarget();
      final rating2 = AssessmentRatingEntity.partiallyMeetsTarget();

      // Assert
      expect(rating1, isNot(equals(rating2)));
    });
  });
}
