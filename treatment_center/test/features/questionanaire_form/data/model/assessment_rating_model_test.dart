import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';

void main() {
  final tRatingModel = AssessmentRatingModel(
    id: 'rating_id_1',
    value: 3,
    label: 'Meets target (+++) (3)',
    description: 'Fully meets requirements',
  );

  final tRatingJson = {
    'id': 'rating_id_1',
    'value': 3,
    'label': 'Meets target (+++) (3)',
    'description': 'Fully meets requirements',
  };

  group('AssessmentRatingModel', () {
    test('should be a subclass of AssessmentRating entity', () {
      // Arrange
      // Act
      // Assert
      expect(tRatingModel, isA<AssessmentRatingEntity>());
    });

    group('fromJson', () {
      test('should return a valid model when the JSON is valid', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tRatingJson;
        // Act
        final result = AssessmentRatingModel.fromJson(jsonMap);
        // Assert
        expect(result, tRatingModel);
      });

      test('should create model with correct properties from JSON', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tRatingJson;
        // Act
        final result = AssessmentRatingModel.fromJson(jsonMap);
        // Assert
        expect(result.id, 'rating_id_1');
        expect(result.value, 3);
        expect(result.label, 'Meets target (+++) (3)');
        expect(result.description, 'Fully meets requirements');
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // Arrange
        // Act
        final result = tRatingModel.toJson();
        // Assert
        expect(result, tRatingJson);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // Arrange
        final entity = AssessmentRatingEntity(
          id: 'rating_id_1',
          value: 3,
          label: 'Meets target (+++) (3)',
          description: 'Fully meets requirements',
        );
        // Act
        final result = AssessmentRatingModel.fromEntity(entity);
        // Assert
        expect(result, tRatingModel);
        expect(result.id, entity.id);
        expect(result.value, entity.value);
        expect(result.label, entity.label);
        expect(result.description, entity.description);
      });
    });

    group('factory constructors', () {
      test('meetsTarget constructor should create correct model', () {
        // Arrange
        // Act
        final result = AssessmentRatingModel.meetsTarget();
        // Assert
        expect(result.id, 'meets_target');
        expect(result.value, 3);
        expect(result.label, 'Meets target (+++) (3)');
      });

      test('partiallyMeetsTarget constructor should create correct model', () {
        // Arrange
        // Act
        final result = AssessmentRatingModel.partiallyMeetsTarget();
        // Assert
        expect(result.id, 'partially_meets');
        expect(result.value, 2);
        expect(result.label, 'Partially meets target (++) (2)');
      });

      test('doesNotMeetTarget constructor should create correct model', () {
        // Arrange
        // Act
        final result = AssessmentRatingModel.doesNotMeetTarget();
        // Assert
        expect(result.id, 'does_not_meet');
        expect(result.value, 1);
        expect(result.label, 'Does not meet target (+) (1)');
      });

      test('dontKnow constructor should create correct model', () {
        // Arrange
        // Act
        final result = AssessmentRatingModel.dontKnow();
        // Assert
        expect(result.id, 'dont_know');
        expect(result.value, 0);
        expect(result.label, 'Don\'t Know (DK)');
      });

      test('notApplicable constructor should create correct model', () {
        // Arrange
        // Act
        final result = AssessmentRatingModel.notApplicable();
        // Assert
        expect(result.id, 'not_applicable');
        expect(result.value, -1);
        expect(result.label, 'Not Applicable (NA)');
      });
    });
  });
}
