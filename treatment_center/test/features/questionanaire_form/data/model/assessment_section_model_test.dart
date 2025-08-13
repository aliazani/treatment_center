import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';

void main() {
  // Create test item models for the section
  final tItemModel1 = AssessmentItemModel(
    id: 1,
    itemNumber: 'item_1',
    sectionNumber: '2.1',
    area: 'Area 1',
    meetsTargetDescription: 'Meets description 1',
    partiallyMeetsDescription: 'Partially meets description 1',
    doesNotMeetDescription: 'Does not meet description 1',
  );

  final tItemModel2 = AssessmentItemModel(
    id: 2,
    itemNumber: 'item_2',
    sectionNumber: '2.1',
    area: 'Area 2',
    meetsTargetDescription: 'Meets description 2',
    partiallyMeetsDescription: 'Partially meets description 2',
    doesNotMeetDescription: 'Does not meet description 2',
  );

  final tItemJson1 = {
    'id': 1,
    'section_number': '2.1',
    'item_number': 'item_1',
    'area': 'Area 1',
    'meets_target_description': 'Meets description 1',
    'partially_meets_description': 'Partially meets description 1',
    'does_not_meet_description': 'Does not meet description 1',
    'selected_rating': null,
    'comment': null,
  };

  final tItemJson2 = {
    'id': 2,
    'section_number': '2.1',
    'item_number': 'item_2',
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
      // Arrange
      // Act
      // Assert
      expect(tSectionModel, isA<AssessmentSectionEntity>());
    });

    group('fromJson', () {
      test(
        'should return a valid model when the JSON is valid with items and description',
        () {
          // Arrange
          final Map<String, dynamic> jsonMap = tSectionJson;
          // Act
          final result = AssessmentSectionModel.fromJson(jsonMap);
          // Assert
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
          // Arrange
          final Map<String, dynamic> jsonMap = tSectionJsonWithoutDescription;
          // Act
          final result = AssessmentSectionModel.fromJson(jsonMap);
          // Assert
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
          // Arrange
          final Map<String, dynamic> jsonMap = tEmptySectionJson;
          // Act
          final result = AssessmentSectionModel.fromJson(jsonMap);
          // Assert
          expect(result.id, tEmptySectionModel.id);
          expect(result.items.length, 0);
        },
      );
    });

    group('toJson', () {
      test(
        'should return a JSON map containing the proper data with items and description',
        () {
          // Arrange
          // Act
          final result = tSectionModel.toJson();
          // Assert
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
          // Arrange
          // Act
          final result = tSectionModelWithoutDescription.toJson();
          // Assert
          expect(result['description'], null);
        },
      );

      test('should return a JSON map with empty items list', () {
        // Arrange
        // Act
        final result = tEmptySectionModel.toJson();
        // Assert
        expect(result['items'], []);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // Arrange
        final entity = AssessmentSectionEntity(
          id: 'section_1',
          sectionNumber: '2.1',
          title: 'Facility Access and Flow',
          description: 'This section evaluates facility access',
          items: [tItemModel1, tItemModel2],
        );
        // Act
        final result = AssessmentSectionModel.fromEntity(entity);
        // Assert
        expect(result.id, entity.id);
        expect(result.sectionNumber, entity.sectionNumber);
        expect(result.title, entity.title);
        expect(result.description, entity.description);
        expect(result.items.length, entity.items.length);
      });
    });

    group('completion status', () {
      test('isComplete should return true when all items have ratings', () {
        // Arrange
        final itemWithRating1 = tItemModel1.copyWith(
          selectedRating: AssessmentRatingModel.meetsTarget(),
        );
        final itemWithRating2 = tItemModel2.copyWith(
          selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
        );
        // Act
        final section = AssessmentSectionModel(
          id: 'section_1',
          sectionNumber: '2.1',
          title: 'Facility Access and Flow',
          items: [itemWithRating1, itemWithRating2],
        );
        // Assert
        expect(section.isComplete, true);
      });

      test('isComplete should return false when any item has no rating', () {
        // Arrange
        // Act
        // Assert
        expect(tSectionModel.isComplete, false);
      });

      test('completedItemsCount should return correct count', () {
        // Arrange
        final itemWithRating1 = tItemModel1.copyWith(
          selectedRating: AssessmentRatingModel.meetsTarget(),
        );
        // Act
        final section = AssessmentSectionModel(
          id: 'section_1',
          sectionNumber: '2.1',
          title: 'Facility Access and Flow',
          items: [itemWithRating1, tItemModel2], // Only one item has rating
        );
        // Assert
        expect(section.completedItemsCount, 1);
      });
    });
  });

  group('toEntity', () {
    test(
      'should return a valid entity when converting from model with description',
      () {
        // Arrange
        // Act
        final result = tSectionModel.toEntity();
        // Assert
        expect(result, isA<AssessmentSectionEntity>());
        expect(result.id, tSectionModel.id);
        expect(result.sectionNumber, tSectionModel.sectionNumber);
        expect(result.title, tSectionModel.title);
        expect(result.description, tSectionModel.description);
        expect(result.items.length, tSectionModel.items.length);
        // Verify that items are correctly converted
        for (int i = 0; i < result.items.length; i++) {
          expect(result.items[i].id, tSectionModel.items[i].id);
          expect(result.items[i].itemNumber, tSectionModel.items[i].itemNumber);
          expect(
            result.items[i].sectionNumber,
            tSectionModel.items[i].sectionNumber,
          );
          expect(result.items[i].area, tSectionModel.items[i].area);
        }
      },
    );

    test(
      'should return a valid entity when converting from model without description',
      () {
        // Arrange
        // Act
        final result = tSectionModelWithoutDescription.toEntity();
        // Assert
        expect(result, isA<AssessmentSectionEntity>());
        expect(result.id, tSectionModelWithoutDescription.id);
        expect(
          result.sectionNumber,
          tSectionModelWithoutDescription.sectionNumber,
        );
        expect(result.title, tSectionModelWithoutDescription.title);
        expect(result.description, tSectionModelWithoutDescription.description);
        expect(
          result.items.length,
          tSectionModelWithoutDescription.items.length,
        );
      },
    );

    test(
      'should return a valid entity when converting from model with empty items',
      () {
        // Arrange
        // Act
        final result = tEmptySectionModel.toEntity();
        // Assert
        expect(result, isA<AssessmentSectionEntity>());
        expect(result.id, tEmptySectionModel.id);
        expect(result.sectionNumber, tEmptySectionModel.sectionNumber);
        expect(result.title, tEmptySectionModel.title);
        expect(result.description, tEmptySectionModel.description);
        expect(result.items.length, 0);
        expect(result.items, isEmpty);
      },
    );

    test('should preserve item ratings when converting to entity', () {
      // Arrange
      final itemWithRating1 = tItemModel1;
      final itemWithRating2 = tItemModel2;
      final sectionWithRatings = AssessmentSectionModel(
        id: 'section_1',
        sectionNumber: '2.1',
        title: 'Facility Access and Flow',
        description: 'This section evaluates facility access',
        items: [itemWithRating1, itemWithRating2],
      );
      // Act
      final result = sectionWithRatings.toEntity();
      // Assert
      expect(
        result.items[0].selectedRating?.value,
        itemWithRating1.selectedRating?.value,
      );
      expect(
        result.items[1].selectedRating?.value,
        itemWithRating2.selectedRating?.value,
      );
    });

    test('should maintain type consistency after conversion', () {
      // Arrange
      // Act
      final entity = tSectionModel.toEntity();
      final backToModel = AssessmentSectionModel.fromEntity(entity);
      // Assert
      expect(backToModel.id, tSectionModel.id);
      expect(backToModel.sectionNumber, tSectionModel.sectionNumber);
      expect(backToModel.title, tSectionModel.title);
      expect(backToModel.description, tSectionModel.description);
      expect(backToModel.items.length, tSectionModel.items.length);
    });
  });
}
