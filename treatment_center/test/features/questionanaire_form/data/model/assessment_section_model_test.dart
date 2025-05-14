import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section.dart';

void main() {
  // Create test item models for the section
  final tItemModel1 = AssessmentItemModel(
    id: 'item_1',
    sectionNumber: '2.1',
    area: 'Area 1',
    meetsTargetDescription: 'Meets description 1',
    partiallyMeetsDescription: 'Partially meets description 1',
    doesNotMeetDescription: 'Does not meet description 1',
  );

  final tItemModel2 = AssessmentItemModel(
    id: 'item_2',
    sectionNumber: '2.1',
    area: 'Area 2',
    meetsTargetDescription: 'Meets description 2',
    partiallyMeetsDescription: 'Partially meets description 2',
    doesNotMeetDescription: 'Does not meet description 2',
  );

  final tItemJson1 = {
    'id': 'item_1',
    'section_number': '2.1',
    'area': 'Area 1',
    'meets_target_description': 'Meets description 1',
    'partially_meets_description': 'Partially meets description 1',
    'does_not_meet_description': 'Does not meet description 1',
    'selected_rating': null,
    'comment': null,
  };

  final tItemJson2 = {
    'id': 'item_2',
    'section_number': '2.1',
    'area': 'Area 2',
    'meets_target_description': 'Meets description 2',
    'partially_meets_description': 'Partially meets description 2',
    'does_not_meet_description': 'Does not meet description 2',
    'selected_rating': null,
    'comment': null,
  };

  final tSectionModel = AssessmentSectionModel(
    id: 'section_1',
    sectionNumber: '2.1',
    title: 'Facility Access and Flow',
    description: 'This section evaluates facility access',
    items: [tItemModel1, tItemModel2],
  );

  final tSectionJson = {
    'id': 'section_1',
    'section_number': '2.1',
    'title': 'Facility Access and Flow',
    'description': 'This section evaluates facility access',
    'items': [tItemJson1, tItemJson2],
  };

  final tSectionModelWithoutDescription = AssessmentSectionModel(
    id: 'section_1',
    sectionNumber: '2.1',
    title: 'Facility Access and Flow',
    items: [tItemModel1, tItemModel2],
  );

  final tSectionJsonWithoutDescription = {
    'id': 'section_1',
    'section_number': '2.1',
    'title': 'Facility Access and Flow',
    'description': null,
    'items': [tItemJson1, tItemJson2],
  };

  final tEmptySectionModel = AssessmentSectionModel(
    id: 'section_1',
    sectionNumber: '2.1',
    title: 'Facility Access and Flow',
    description: 'This section evaluates facility access',
    items: [],
  );

  final tEmptySectionJson = {
    'id': 'section_1',
    'section_number': '2.1',
    'title': 'Facility Access and Flow',
    'description': 'This section evaluates facility access',
    'items': [],
  };

  group('AssessmentSectionModel', () {
    test('should be a subclass of AssessmentSection entity', () {
      // assert
      expect(tSectionModel, isA<AssessmentSection>());
    });

    group('fromJson', () {
      test(
        'should return a valid model when the JSON is valid with items and description',
        () {
          // arrange
          final Map<String, dynamic> jsonMap = tSectionJson;
          // act
          final result = AssessmentSectionModel.fromJson(jsonMap);
          // assert
          expect(result.id, tSectionModel.id);
          expect(result.sectionNumber, tSectionModel.sectionNumber);
          expect(result.title, tSectionModel.title);
          expect(result.description, tSectionModel.description);
          expect(result.items.length, tSectionModel.items.length);
        },
      );

      test(
        'should return a valid model when the JSON is valid without description',
        () {
          // arrange
          final Map<String, dynamic> jsonMap = tSectionJsonWithoutDescription;
          // act
          final result = AssessmentSectionModel.fromJson(jsonMap);
          // assert
          expect(result.id, tSectionModelWithoutDescription.id);
          expect(
            result.sectionNumber,
            tSectionModelWithoutDescription.sectionNumber,
          );
          expect(result.title, tSectionModelWithoutDescription.title);
          expect(
            result.description,
            tSectionModelWithoutDescription.description,
          );
          expect(
            result.items.length,
            tSectionModelWithoutDescription.items.length,
          );
        },
      );

      test(
        'should return a valid model when the JSON has empty items list',
        () {
          // arrange
          final Map<String, dynamic> jsonMap = tEmptySectionJson;
          // act
          final result = AssessmentSectionModel.fromJson(jsonMap);
          // assert
          expect(result.id, tEmptySectionModel.id);
          expect(result.items.length, 0);
        },
      );
    });

    group('toJson', () {
      test(
        'should return a JSON map containing the proper data with items and description',
        () {
          // act
          final result = tSectionModel.toJson();
          // assert
          expect(result['id'], tSectionJson['id']);
          expect(result['section_number'], tSectionJson['section_number']);
          expect(result['title'], tSectionJson['title']);
          expect(result['description'], tSectionJson['description']);
          expect(
            (result['items'] as List).length,
            (tSectionJson['items'] as List).length,
          );
        },
      );

      test(
        'should return a JSON map containing the proper data without description',
        () {
          // act
          final result = tSectionModelWithoutDescription.toJson();
          // assert
          expect(result['description'], null);
        },
      );

      test('should return a JSON map with empty items list', () {
        // act
        final result = tEmptySectionModel.toJson();
        // assert
        expect(result['items'], []);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // arrange
        final entity = AssessmentSection(
          id: 'section_1',
          sectionNumber: '2.1',
          title: 'Facility Access and Flow',
          description: 'This section evaluates facility access',
          items: [tItemModel1, tItemModel2],
        );
        // act
        final result = AssessmentSectionModel.fromEntity(entity);
        // assert
        expect(result.id, entity.id);
        expect(result.sectionNumber, entity.sectionNumber);
        expect(result.title, entity.title);
        expect(result.description, entity.description);
        expect(result.items.length, entity.items.length);
      });
    });

    group('completion status', () {
      test('isComplete should return true when all items have ratings', () {
        // arrange
        final itemWithRating1 = tItemModel1.copyWith(
          selectedRating: AssessmentRatingModel.meetsTarget(),
        );
        final itemWithRating2 = tItemModel2.copyWith(
          selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
        );

        final section = AssessmentSectionModel(
          id: 'section_1',
          sectionNumber: '2.1',
          title: 'Facility Access and Flow',
          items: [itemWithRating1, itemWithRating2],
        );

        // assert
        expect(section.isComplete, true);
      });

      test('isComplete should return false when any item has no rating', () {
        // assert
        expect(tSectionModel.isComplete, false);
      });

      test('completedItemsCount should return correct count', () {
        // arrange
        final itemWithRating1 = tItemModel1.copyWith(
          selectedRating: AssessmentRatingModel.meetsTarget(),
        );

        final section = AssessmentSectionModel(
          id: 'section_1',
          sectionNumber: '2.1',
          title: 'Facility Access and Flow',
          items: [itemWithRating1, tItemModel2], // Only one item has rating
        );

        // assert
        expect(section.completedItemsCount, 1);
      });
    });
  });
}
