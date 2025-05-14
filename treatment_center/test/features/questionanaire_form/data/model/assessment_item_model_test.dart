import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item.dart';

void main() {
  final tRatingModel = AssessmentRatingModel(
    id: 'meets_target',
    value: 3,
    label: 'Meets target (+++) (3)',
    description: 'Fully meets requirements',
  );

  final tRatingJson = {
    'id': 'meets_target',
    'value': 3,
    'label': 'Meets target (+++) (3)',
    'description': 'Fully meets requirements',
  };

  final tItemModel = AssessmentItemModel(
    id: 'item_1',
    sectionNumber: '2.1',
    area: 'Facility Access',
    meetsTargetDescription: 'All requirements are met',
    partiallyMeetsDescription: 'Some requirements are met',
    doesNotMeetDescription: 'No requirements are met',
    selectedRating: tRatingModel,
    comment: 'This is a comment',
  );

  final tItemJson = {
    'id': 'item_1',
    'section_number': '2.1',
    'area': 'Facility Access',
    'meets_target_description': 'All requirements are met',
    'partially_meets_description': 'Some requirements are met',
    'does_not_meet_description': 'No requirements are met',
    'selected_rating': tRatingJson,
    'comment': 'This is a comment',
  };

  final tItemModelWithoutRating = AssessmentItemModel(
    id: 'item_1',
    sectionNumber: '2.1',
    area: 'Facility Access',
    meetsTargetDescription: 'All requirements are met',
    partiallyMeetsDescription: 'Some requirements are met',
    doesNotMeetDescription: 'No requirements are met',
  );

  final tItemJsonWithoutRating = {
    'id': 'item_1',
    'section_number': '2.1',
    'area': 'Facility Access',
    'meets_target_description': 'All requirements are met',
    'partially_meets_description': 'Some requirements are met',
    'does_not_meet_description': 'No requirements are met',
    'selected_rating': null,
    'comment': null,
  };

  group('AssessmentItemModel', () {
    test('should be a subclass of AssessmentItem entity', () {
      // assert
      expect(tItemModel, isA<AssessmentItem>());
    });

    group('fromJson', () {
      test('should return a valid model when the JSON is valid with rating', () {
        // arrange
        final Map<String, dynamic> jsonMap = tItemJson;
        // act
        final result = AssessmentItemModel.fromJson(jsonMap);
        // assert
        expect(result, tItemModel);
      });

      test('should return a valid model when the JSON is valid without rating', () {
        // arrange
        final Map<String, dynamic> jsonMap = tItemJsonWithoutRating;
        // act
        final result = AssessmentItemModel.fromJson(jsonMap);
        // assert
        expect(result, tItemModelWithoutRating);
      });

      test('should create model with correct properties from JSON', () {
        // arrange
        final Map<String, dynamic> jsonMap = tItemJson;
        // act
        final result = AssessmentItemModel.fromJson(jsonMap);
        // assert
        expect(result.id, 'item_1');
        expect(result.sectionNumber, '2.1');
        expect(result.area, 'Facility Access');
        expect(result.meetsTargetDescription, 'All requirements are met');
        expect(result.partiallyMeetsDescription, 'Some requirements are met');
        expect(result.doesNotMeetDescription, 'No requirements are met');
        expect(result.selectedRating, tRatingModel);
        expect(result.comment, 'This is a comment');
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data with rating', () {
        // act
        final result = tItemModel.toJson();
        // assert
        expect(result, tItemJson);
      });

      test('should return a JSON map containing the proper data without rating', () {
        // act
        final result = tItemModelWithoutRating.toJson();
        // assert
        expect(result, tItemJsonWithoutRating);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity with rating', () {
        // arrange
        final entity = AssessmentItem(
          id: 'item_1',
          sectionNumber: '2.1',
          area: 'Facility Access',
          meetsTargetDescription: 'All requirements are met',
          partiallyMeetsDescription: 'Some requirements are met',
          doesNotMeetDescription: 'No requirements are met',
          selectedRating: tRatingModel,
          comment: 'This is a comment',
        );
        // act
        final result = AssessmentItemModel.fromEntity(entity);
        // assert
        expect(result, tItemModel);
        expect(result.id, entity.id);
        expect(result.sectionNumber, entity.sectionNumber);
        expect(result.area, entity.area);
        expect(result.meetsTargetDescription, entity.meetsTargetDescription);
        expect(result.partiallyMeetsDescription, entity.partiallyMeetsDescription);
        expect(result.doesNotMeetDescription, entity.doesNotMeetDescription);
        expect(result.selectedRating, entity.selectedRating);
        expect(result.comment, entity.comment);
      });

      test('should return a valid model when converting from entity without rating', () {
        // arrange
        final entity = AssessmentItem(
          id: 'item_1',
          sectionNumber: '2.1',
          area: 'Facility Access',
          meetsTargetDescription: 'All requirements are met',
          partiallyMeetsDescription: 'Some requirements are met',
          doesNotMeetDescription: 'No requirements are met',
        );
        // act
        final result = AssessmentItemModel.fromEntity(entity);
        // assert
        expect(result, tItemModelWithoutRating);
      });
    });
  });
}