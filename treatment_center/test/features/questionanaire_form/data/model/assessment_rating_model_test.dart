import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating.dart';

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
      // assert
      expect(tRatingModel, isA<AssessmentRating>());
    });

    group('fromJson', () {
      test('should return a valid model when the JSON is valid', () {
        // arrange
        final Map<String, dynamic> jsonMap = tRatingJson;
        // act
        final result = AssessmentRatingModel.fromJson(jsonMap);
        // assert
        expect(result, tRatingModel);
      });

      test('should create model with correct properties from JSON', () {
        // arrange
        final Map<String, dynamic> jsonMap = tRatingJson;
        // act
        final result = AssessmentRatingModel.fromJson(jsonMap);
        // assert
        expect(result.id, 'rating_id_1');
        expect(result.value, 3);
        expect(result.label, 'Meets target (+++) (3)');
        expect(result.description, 'Fully meets requirements');
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // act
        final result = tRatingModel.toJson();
        // assert
        expect(result, tRatingJson);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // arrange
        final entity = AssessmentRating(
          id: 'rating_id_1',
          value: 3,
          label: 'Meets target (+++) (3)',
          description: 'Fully meets requirements',
        );
        // act
        final result = AssessmentRatingModel.fromEntity(entity);
        // assert
        expect(result, tRatingModel);
        expect(result.id, entity.id);
        expect(result.value, entity.value);
        expect(result.label, entity.label);
        expect(result.description, entity.description);
      });
    });

    group('factory constructors', () {
      test('meetsTarget constructor should create correct model', () {
        // act
        final result = AssessmentRatingModel.meetsTarget();
        // assert
        expect(result.id, 'meets_target');
        expect(result.value, 3);
        expect(result.label, 'Meets target (+++) (3)');
      });

      test('partiallyMeetsTarget constructor should create correct model', () {
        // act
        final result = AssessmentRatingModel.partiallyMeetsTarget();
        // assert
        expect(result.id, 'partially_meets');
        expect(result.value, 2);
        expect(result.label, 'Partially meets target (++) (2)');
      });

      test('doesNotMeetTarget constructor should create correct model', () {
        // act
        final result = AssessmentRatingModel.doesNotMeetTarget();
        // assert
        expect(result.id, 'does_not_meet');
        expect(result.value, 1);
        expect(result.label, 'Does not meet target (+) (1)');
      });

      test('dontKnow constructor should create correct model', () {
        // act
        final result = AssessmentRatingModel.dontKnow();
        // assert
        expect(result.id, 'dont_know');
        expect(result.value, 0);
        expect(result.label, 'Don\'t Know (DK)');
      });

      test('notApplicable constructor should create correct model', () {
        // act
        final result = AssessmentRatingModel.notApplicable();
        // assert
        expect(result.id, 'not_applicable');
        expect(result.value, -1);
        expect(result.label, 'Not Applicable (NA)');
      });
    });
  });
}