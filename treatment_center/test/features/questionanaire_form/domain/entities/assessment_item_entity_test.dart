import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';

void main() {
  final testRating = AssessmentRatingEntity.meetsTarget();

  group('AssessmentItem', () {
    test('should create a valid AssessmentItem', () {
      // Arrange & Act
      final item = AssessmentItemEntity(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Health care facility entrances',
        meetsTargetDescription:
            'Patients and staff have dedicated entrances clearly labelled',
        partiallyMeetsDescription:
            'There are two different entrances for patients and staff but NOT properly labelled or NOT properly used',
        doesNotMeetDescription:
            'There is only one common entrance for both staff and patients',
      );

      // Assert
      expect(item.id, 'item1');
      expect(item.sectionNumber, '2.1.1');
      expect(item.area, 'Health care facility entrances');
      expect(
        item.meetsTargetDescription,
        'Patients and staff have dedicated entrances clearly labelled',
      );
      expect(
        item.partiallyMeetsDescription,
        'There are two different entrances for patients and staff but NOT properly labelled or NOT properly used',
      );
      expect(
        item.doesNotMeetDescription,
        'There is only one common entrance for both staff and patients',
      );
      expect(item.selectedRating, isNull);
      expect(item.comment, isNull);
    });

    test('should create a valid AssessmentItem with optional fields', () {
      // Arrange & Act
      final item = AssessmentItemEntity(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Health care facility entrances',
        meetsTargetDescription:
            'Patients and staff have dedicated entrances clearly labelled',
        partiallyMeetsDescription:
            'There are two different entrances for patients and staff but NOT properly labelled or NOT properly used',
        doesNotMeetDescription:
            'There is only one common entrance for both staff and patients',
        selectedRating: testRating,
        comment: 'This is a test comment',
      );

      // Assert
      expect(item.selectedRating, testRating);
      expect(item.comment, 'This is a test comment');
    });

    test('should support equality comparison', () {
      // Arrange
      final item1 = AssessmentItemEntity(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Health care facility entrances',
        meetsTargetDescription:
            'Patients and staff have dedicated entrances clearly labelled',
        partiallyMeetsDescription:
            'There are two different entrances for patients and staff but NOT properly labelled or NOT properly used',
        doesNotMeetDescription:
            'There is only one common entrance for both staff and patients',
      );

      final item2 = AssessmentItemEntity(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Health care facility entrances',
        meetsTargetDescription:
            'Patients and staff have dedicated entrances clearly labelled',
        partiallyMeetsDescription:
            'There are two different entrances for patients and staff but NOT properly labelled or NOT properly used',
        doesNotMeetDescription:
            'There is only one common entrance for both staff and patients',
      );

      // Assert
      expect(item1, equals(item2));
    });

    test('copyWith should create a new instance with updated fields', () {
      // Arrange
      final item = AssessmentItemEntity(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Health care facility entrances',
        meetsTargetDescription:
            'Patients and staff have dedicated entrances clearly labelled',
        partiallyMeetsDescription:
            'There are two different entrances for patients and staff but NOT properly labelled or NOT properly used',
        doesNotMeetDescription:
            'There is only one common entrance for both staff and patients',
      );

      // Act
      final updatedItem = item.copyWith(
        selectedRating: testRating,
        comment: 'New comment',
      );

      // Assert
      expect(updatedItem.id, item.id);
      expect(updatedItem.sectionNumber, item.sectionNumber);
      expect(updatedItem.area, item.area);
      expect(updatedItem.selectedRating, testRating);
      expect(updatedItem.comment, 'New comment');
    });

    test('copyWith should allow changing from one rating to another', () {
      // Arrange
      final initialRating = AssessmentRatingEntity.meetsTarget();
      final newRating = AssessmentRatingEntity.partiallyMeetsTarget();

      final item = AssessmentItemEntity(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Area',
        meetsTargetDescription: 'Description',
        partiallyMeetsDescription: 'Description',
        doesNotMeetDescription: 'Description',
        selectedRating: initialRating,
      );

      // Act
      final updatedItem = item.copyWith(selectedRating: newRating);

      // Assert
      expect(updatedItem.selectedRating, newRating);
      expect(updatedItem.selectedRating, isNot(initialRating));
    });

    test('copyWith should not allow setting rating to null', () {
      // Arrange
      final item = AssessmentItemEntity(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Area',
        meetsTargetDescription: 'Description',
        partiallyMeetsDescription: 'Description',
        doesNotMeetDescription: 'Description',
        selectedRating: AssessmentRatingEntity.meetsTarget(),
      );

      // Act - explicitly set to null
      final updatedItem = item.copyWith(selectedRating: null);

      // Assert
      expect(updatedItem.selectedRating, isNotNull);
    });
  });
}
