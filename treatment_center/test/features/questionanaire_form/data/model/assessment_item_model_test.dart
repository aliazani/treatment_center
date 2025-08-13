import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';


void main() {
  // Test model instances
  late AssessmentItemModel tItemModel;
  late AssessmentItemModel tItemModelWithoutRating;
  late AssessmentRatingModel tRatingModel;

  setUp(() {
    // Use test fixtures for consistent test data
    tRatingModel = AssessmentRatingModel.meetsTarget();
    
    tItemModel = TestAssessmentFixtures.createTestAssessmentItemModel(
      id: 1,
      sectionNumber: '2.1',
      selectedRating: tRatingModel,
      comment: 'This is a test comment',
    );

    tItemModelWithoutRating = TestAssessmentFixtures.createTestAssessmentItemModel(
      id: 2,
      sectionNumber: '2.2',
      selectedRating: null,
      comment: null,
    );
  });

  group('AssessmentItemModel', () {
    test('should be a subclass of AssessmentItemEntity', () {
      expect(tItemModel, isA<AssessmentItemEntity>());
    });

    group('fromJson factory constructor', () {
      late Map<String, dynamic> validJsonWithRating;
      late Map<String, dynamic> validJsonWithoutRating;

      setUp(() {
        validJsonWithRating = tItemModel.toJson();
        validJsonWithoutRating = tItemModelWithoutRating.toJson();
      });

      test('should correctly deserialize from JSON with rating', () {
        final result = AssessmentItemModel.fromJson(validJsonWithRating);

        expect(result.id, tItemModel.id);
        expect(result.itemNumber, tItemModel.itemNumber);
        expect(result.sectionNumber, tItemModel.sectionNumber);
        expect(result.area, tItemModel.area);
        expect(result.meetsTargetDescription, tItemModel.meetsTargetDescription);
        expect(result.partiallyMeetsDescription, tItemModel.partiallyMeetsDescription);
        expect(result.doesNotMeetDescription, tItemModel.doesNotMeetDescription);
        expect(result.selectedRating?.value, tItemModel.selectedRating?.value);
        expect(result.comment, tItemModel.comment);
      });

      test('should correctly deserialize from JSON without rating', () {
        final result = AssessmentItemModel.fromJson(validJsonWithoutRating);

        expect(result.id, tItemModelWithoutRating.id);
        expect(result.itemNumber, tItemModelWithoutRating.itemNumber);
        expect(result.sectionNumber, tItemModelWithoutRating.sectionNumber);
        expect(result.area, tItemModelWithoutRating.area);
        expect(result.selectedRating, isNull);
        expect(result.comment, isNull);
      });

      test('should handle null rating in JSON', () {
        final jsonWithNullRating = Map<String, dynamic>.from(validJsonWithRating);
        jsonWithNullRating['selected_rating'] = null;

        final result = AssessmentItemModel.fromJson(jsonWithNullRating);

        expect(result.selectedRating, isNull);
        expect(result.id, tItemModel.id);
        expect(result.area, tItemModel.area);
      });

      test('should handle missing comment field', () {
        final jsonWithoutComment = Map<String, dynamic>.from(validJsonWithRating);
        jsonWithoutComment.remove('comment');

        final result = AssessmentItemModel.fromJson(jsonWithoutComment);

        expect(result.comment, isNull);
        expect(result.id, tItemModel.id);
      });

      test('should handle various rating types', () {
        final testRatings = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        for (final rating in testRatings) {
          final itemWithRating = TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: rating,
          );
          
          final json = itemWithRating.toJson();
          final result = AssessmentItemModel.fromJson(json);

          expect(result.selectedRating?.value, rating.value);
          expect(result.selectedRating?.label, rating.label);
        }
      });

      group('JSON edge cases', () {
        test('should handle integer IDs correctly', () {
          final json = validJsonWithRating;
          json['id'] = 42;

          final result = AssessmentItemModel.fromJson(json);

          expect(result.id, 42);
        });

        test('should handle empty strings in required fields', () {
          final json = validJsonWithRating;
          json['area'] = '';
          json['meets_target_description'] = '';

          final result = AssessmentItemModel.fromJson(json);

          expect(result.area, '');
          expect(result.meetsTargetDescription, '');
        });

        test('should handle very long text fields', () {
          final longText = 'A' * 1000;
          final json = validJsonWithRating;
          json['area'] = longText;
          json['comment'] = longText;

          final result = AssessmentItemModel.fromJson(json);

          expect(result.area, longText);
          expect(result.comment, longText);
        });

        test('should handle special characters in text fields', () {
          const specialText = 'Special chars: àáâãäå & < > " \' €';
          final json = validJsonWithRating;
          json['area'] = specialText;

          final result = AssessmentItemModel.fromJson(json);

          expect(result.area, specialText);
        });
      });
    });

    group('toJson method', () {
      test('should serialize correctly to JSON with rating', () {
        final result = tItemModel.toJson();

        expect(result['id'], tItemModel.id);
        expect(result['item_number'], tItemModel.itemNumber);
        expect(result['section_number'], tItemModel.sectionNumber);
        expect(result['area'], tItemModel.area);
        expect(result['meets_target_description'], tItemModel.meetsTargetDescription);
        expect(result['partially_meets_description'], tItemModel.partiallyMeetsDescription);
        expect(result['does_not_meet_description'], tItemModel.doesNotMeetDescription);
        expect(result['selected_rating'], isA<Map<String, dynamic>>());
        expect(result['comment'], tItemModel.comment);
      });

      test('should serialize correctly to JSON without rating', () {
        final result = tItemModelWithoutRating.toJson();

        expect(result['id'], tItemModelWithoutRating.id);
        expect(result['selected_rating'], isNull);
        expect(result['comment'], isNull);
      });

      test('should handle null comment correctly', () {
        final itemWithNullComment = TestAssessmentFixtures.createTestAssessmentItemModel(
          id: 1,
          sectionNumber: '1.1',
          comment: null,
        );

        final result = itemWithNullComment.toJson();

        expect(result['comment'], isNull);
      });
    });

    group('fromEntity factory constructor', () {
      test('should convert entity with rating to model', () {
        final ratingEntity = AssessmentRatingEntity.meetsTarget();
        final entity = TestAssessmentFixtures.createTestAssessmentItem(
          id: 1,
          sectionNumber: '2.1',
          selectedRating: ratingEntity,
          comment: 'Entity comment',
        );

        final result = AssessmentItemModel.fromEntity(entity);

        expect(result, isA<AssessmentItemModel>());
        expect(result.id, entity.id);
        expect(result.itemNumber, entity.itemNumber);
        expect(result.sectionNumber, entity.sectionNumber);
        expect(result.area, entity.area);
        expect(result.meetsTargetDescription, entity.meetsTargetDescription);
        expect(result.partiallyMeetsDescription, entity.partiallyMeetsDescription);
        expect(result.doesNotMeetDescription, entity.doesNotMeetDescription);
        expect(result.selectedRating, isA<AssessmentRatingModel>());
        expect(result.selectedRating?.value, ratingEntity.value);
        expect(result.comment, entity.comment);
      });

      test('should convert entity without rating to model', () {
        final entity = TestAssessmentFixtures.createTestAssessmentItem(
          id: 2,
          sectionNumber: '2.2',
          selectedRating: null,
          comment: null,
        );

        final result = AssessmentItemModel.fromEntity(entity);

        expect(result, isA<AssessmentItemModel>());
        expect(result.selectedRating, isNull);
        expect(result.comment, isNull);
        expect(result.id, entity.id);
        expect(result.area, entity.area);
      });

      test('should handle entity with model rating correctly', () {
        final ratingModel = AssessmentRatingModel.partiallyMeetsTarget();
        final entity = AssessmentItemEntity(
          id: 1,
          itemNumber: '1.1',
          sectionNumber: '1',
          area: 'Test Area',
          meetsTargetDescription: 'Meets description',
          partiallyMeetsDescription: 'Partially meets description',
          doesNotMeetDescription: 'Does not meet description',
          selectedRating: ratingModel, // Already a model
          comment: 'Test comment',
        );

        final result = AssessmentItemModel.fromEntity(entity);

        expect(result.selectedRating, isA<AssessmentRatingModel>());
        expect(result.selectedRating?.value, ratingModel.value);
      });

      test('should convert all rating types from entity', () {
        final ratingTypes = [
          AssessmentRatingEntity.meetsTarget(),
          AssessmentRatingEntity.partiallyMeetsTarget(),
          AssessmentRatingEntity.doesNotMeetTarget(),
          AssessmentRatingEntity.dontKnow(),
          AssessmentRatingEntity.notApplicable(),
        ];

        for (final ratingEntity in ratingTypes) {
          final entity = TestAssessmentFixtures.createTestAssessmentItem(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: ratingEntity,
          );

          final result = AssessmentItemModel.fromEntity(entity);

          expect(result.selectedRating, isA<AssessmentRatingModel>());
          expect(result.selectedRating?.value, ratingEntity.value);
          expect(result.selectedRating?.label, ratingEntity.label);
        }
      });
    });

    group('toEntity method', () {
      test('should convert model with rating to entity', () {
        final result = tItemModel.toEntity();

        expect(result, isA<AssessmentItemEntity>());
        expect(result.id, tItemModel.id);
        expect(result.itemNumber, tItemModel.itemNumber);
        expect(result.sectionNumber, tItemModel.sectionNumber);
        expect(result.area, tItemModel.area);
        expect(result.meetsTargetDescription, tItemModel.meetsTargetDescription);
        expect(result.partiallyMeetsDescription, tItemModel.partiallyMeetsDescription);
        expect(result.doesNotMeetDescription, tItemModel.doesNotMeetDescription);
        expect(result.selectedRating, isA<AssessmentRatingEntity>());
        expect(result.comment, tItemModel.comment);
      });

      test('should convert model without rating to entity', () {
        final result = tItemModelWithoutRating.toEntity();

        expect(result, isA<AssessmentItemEntity>());
        expect(result.selectedRating, isNull);
        expect(result.comment, isNull);
        expect(result.id, tItemModelWithoutRating.id);
      });
    });

    group('JSON round-trip tests', () {
      test('should maintain data integrity through JSON serialization cycle', () {
        final json = tItemModel.toJson();
        final restored = AssessmentItemModel.fromJson(json);
        final jsonAgain = restored.toJson();

        expect(jsonAgain, equals(json));
      });

      test('should handle round-trip without rating', () {
        final json = tItemModelWithoutRating.toJson();
        final restored = AssessmentItemModel.fromJson(json);
        final jsonAgain = restored.toJson();

        expect(jsonAgain, equals(json));
      });

      test('should handle complex data in round-trip', () {
        final complexItem = TestAssessmentFixtures.createTestAssessmentItemModel(
          id: 99,
          sectionNumber: '10.5',
          selectedRating: AssessmentRatingModel.dontKnow(),
          comment: 'Complex comment with special chars: àáâãäå & < > " \'',
          area: 'Complex area with symbols: €\$¥£',
        );

        final json = complexItem.toJson();
        final restored = AssessmentItemModel.fromJson(json);

        expect(restored.id, complexItem.id);
        expect(restored.sectionNumber, complexItem.sectionNumber);
        expect(restored.comment, complexItem.comment);
        expect(restored.area, complexItem.area);
        expect(restored.selectedRating?.value, complexItem.selectedRating?.value);
      });
    });

    group('Entity-Model conversion round-trip tests', () {
      test('should maintain data integrity through entity conversion cycle', () {
        final entity = tItemModel.toEntity();
        final restored = AssessmentItemModel.fromEntity(entity);

        expect(restored.id, tItemModel.id);
        expect(restored.itemNumber, tItemModel.itemNumber);
        expect(restored.sectionNumber, tItemModel.sectionNumber);
        expect(restored.area, tItemModel.area);
        expect(restored.selectedRating?.value, tItemModel.selectedRating?.value);
        expect(restored.comment, tItemModel.comment);
      });

      test('should handle entity conversion without rating', () {
        final entity = tItemModelWithoutRating.toEntity();
        final restored = AssessmentItemModel.fromEntity(entity);

        expect(restored.selectedRating, isNull);
        expect(restored.comment, isNull);
        expect(restored.id, tItemModelWithoutRating.id);
      });
    });

    group('Edge cases and error handling', () {
      test('should handle empty string values', () {
        final item = TestAssessmentFixtures.createTestAssessmentItemModel(
          id: 1,
          sectionNumber: '',
          area: '',
          comment: '',
        );

        expect(item.sectionNumber, '');
        expect(item.area, '');
        expect(item.comment, '');

        final json = item.toJson();
        final restored = AssessmentItemModel.fromJson(json);

        expect(restored.sectionNumber, '');
        expect(restored.area, '');
        expect(restored.comment, '');
      });

      test('should handle very long text content', () {
        final longText = 'A' * 10000;
        final item = TestAssessmentFixtures.createTestAssessmentItemModel(
          id: 1,
          sectionNumber: '1.1',
          area: longText,
          comment: longText,
        );

        expect(item.area, longText);
        expect(item.comment, longText);

        final json = item.toJson();
        final restored = AssessmentItemModel.fromJson(json);

        expect(restored.area, longText);
        expect(restored.comment, longText);
      });

      test('should handle extreme ID values', () {
        const extremeId = 999999999;
        final item = TestAssessmentFixtures.createTestAssessmentItemModel(
          id: extremeId,
          sectionNumber: '1.1',
        );

        expect(item.id, extremeId);

        final json = item.toJson();
        final restored = AssessmentItemModel.fromJson(json);

        expect(restored.id, extremeId);
      });

      test('should handle unicode and special characters', () {
        const unicodeText = 'Unicode: 🏥⚕️🩺 Arabic: العربية Chinese: 中文';
        final item = TestAssessmentFixtures.createTestAssessmentItemModel(
          id: 1,
          sectionNumber: '1.1',
          area: unicodeText,
          comment: unicodeText,
        );

        final json = item.toJson();
        final restored = AssessmentItemModel.fromJson(json);

        expect(restored.area, unicodeText);
        expect(restored.comment, unicodeText);
      });
    });

    group('Test fixture integration tests', () {
      test('should work with various fixture configurations', () {
        final testConfigurations = [
          {'id': 1, 'section': '1.1', 'hasRating': true, 'hasComment': true},
          {'id': 2, 'section': '2.2', 'hasRating': false, 'hasComment': false},
          {'id': 3, 'section': '3.3', 'hasRating': true, 'hasComment': false},
          {'id': 4, 'section': '4.4', 'hasRating': false, 'hasComment': true},
        ];

        for (final config in testConfigurations) {
          final item = TestAssessmentFixtures.createTestAssessmentItemModel(
            id: config['id'] as int,
            sectionNumber: config['section'] as String,
            selectedRating: config['hasRating'] as bool ? AssessmentRatingModel.meetsTarget() : null,
            comment: config['hasComment'] as bool ? 'Test comment' : null,
          );

          expect(item.id, config['id']);
          expect(item.sectionNumber, config['section']);
          expect(item.selectedRating != null, config['hasRating']);
          expect(item.comment != null, config['hasComment']);

          // Test JSON serialization
          final json = item.toJson();
          final restored = AssessmentItemModel.fromJson(json);
          expect(restored.id, item.id);
          expect(restored.selectedRating?.value, item.selectedRating?.value);
        }
      });

      test('should work with all predefined rating types from fixtures', () {
        final ratingTypes = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        for (int i = 0; i < ratingTypes.length; i++) {
          final item = TestAssessmentFixtures.createTestAssessmentItemModel(
            id: i + 1,
            sectionNumber: '${i + 1}.1',
            selectedRating: ratingTypes[i],
          );

          expect(item.selectedRating?.value, ratingTypes[i].value);
          expect(item.selectedRating?.label, ratingTypes[i].label);

          // Test entity conversion
          final entity = item.toEntity();
          final restored = AssessmentItemModel.fromEntity(entity);
          expect(restored.selectedRating?.value, item.selectedRating?.value);
        }
      });
    });

    group('Fixture consistency tests', () {
      test('should maintain consistency between createTestAssessmentItem and createTestAssessmentItemModel', () {
        const testId = 1;
        const testSection = '1.1';
        final testRating = AssessmentRatingEntity.meetsTarget();

        final entity = TestAssessmentFixtures.createTestAssessmentItem(
          id: testId,
          sectionNumber: testSection,
          selectedRating: testRating,
        );

        final model = TestAssessmentFixtures.createTestAssessmentItemModel(
          id: testId,
          sectionNumber: testSection,
          selectedRating: AssessmentRatingModel.fromEntity(testRating),
        );

        expect(entity.id, model.id);
        expect(entity.sectionNumber, model.sectionNumber);
        expect(entity.area, model.area);
        expect(entity.selectedRating?.value, model.selectedRating?.value);
      });

      test('should convert between entity and model fixtures correctly', () {
        final entity = TestAssessmentFixtures.createTestAssessmentItem(
          id: 1,
          sectionNumber: '1.1',
          selectedRating: AssessmentRatingEntity.partiallyMeetsTarget(),
          comment: 'Fixture test comment',
        );

        final convertedModel = AssessmentItemModel.fromEntity(entity);
        final convertedEntity = convertedModel.toEntity();

        expect(convertedEntity.id, entity.id);
        expect(convertedEntity.sectionNumber, entity.sectionNumber);
        expect(convertedEntity.comment, entity.comment);
        expect(convertedEntity.selectedRating?.value, entity.selectedRating?.value);
      });
    });

    group('Performance and boundary tests', () {
      test('should handle multiple items efficiently', () {
        final items = List.generate(100, (index) => 
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: index,
            sectionNumber: '${(index ~/ 10) + 1}.${(index % 10) + 1}',
            selectedRating: index % 2 == 0 ? AssessmentRatingModel.meetsTarget() : null,
          )
        );

        expect(items.length, 100);

        // Test that all items can be serialized/deserialized
        for (final item in items.take(10)) { // Test first 10 for performance
          final json = item.toJson();
          final restored = AssessmentItemModel.fromJson(json);
          expect(restored.id, item.id);
        }
      });

      test('should handle boundary ID values', () {
        final boundaryIds = [0, 1, -1, 2147483647, -2147483648]; // int32 boundaries

        for (final id in boundaryIds) {
          final item = TestAssessmentFixtures.createTestAssessmentItemModel(
            id: id,
            sectionNumber: '1.1',
          );

          expect(item.id, id);

          final json = item.toJson();
          final restored = AssessmentItemModel.fromJson(json);
          expect(restored.id, id);
        }
      });
    });
  });
}