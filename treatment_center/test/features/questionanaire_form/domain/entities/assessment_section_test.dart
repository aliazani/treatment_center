import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section.dart';

void main() {
  // Sample assessment items for testing
  final item1 = AssessmentItem(
    id: 'item1',
    sectionNumber: '2.1.1',
    area: 'Health care facility entrances',
    meetsTargetDescription: 'Description 1',
    partiallyMeetsDescription: 'Description 2',
    doesNotMeetDescription: 'Description 3',
  );

  final item2 = AssessmentItem(
    id: 'item2',
    sectionNumber: '2.1.2',
    area: 'Area distribution',
    meetsTargetDescription: 'Description 1',
    partiallyMeetsDescription: 'Description 2',
    doesNotMeetDescription: 'Description 3',
    selectedRating: AssessmentRating.meetsTarget(),
  );

  group('AssessmentSection', () {
    test('should create a valid AssessmentSection', () {
      // Arrange & Act
      final section = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [item1, item2],
      );

      // Assert
      expect(section.id, 'section1');
      expect(section.sectionNumber, '2.1');
      expect(section.title, 'Facility accesses and flows');
      expect(section.description, isNull);
      expect(section.items, [item1, item2]);
    });

    test('should correctly calculate completion status', () {
      // Arrange
      final incompletedSection = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [item1, item2], // item1 has no rating
      );

      final completedItem1 = item1.copyWith(
        selectedRating: AssessmentRating.partiallyMeetsTarget(),
      );

      final completedSection = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [completedItem1, item2], // both items have ratings
      );

      // Assert
      expect(incompletedSection.isComplete, false);
      expect(incompletedSection.completedItemsCount, 1);

      expect(completedSection.isComplete, true);
      expect(completedSection.completedItemsCount, 2);
    });

    test('copyWith should create a new instance with updated fields', () {
      // Arrange
      final section = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [item1],
      );

      // Act
      final updatedSection = section.copyWith(
        title: 'Updated Title',
        description: 'New description',
        items: [item1, item2],
      );

      // Assert
      expect(updatedSection.id, section.id);
      expect(updatedSection.sectionNumber, section.sectionNumber);
      expect(updatedSection.title, 'Updated Title');
      expect(updatedSection.description, 'New description');
      expect(updatedSection.items, [item1, item2]);
    });

    test('should create a valid AssessmentSection with description', () {
      final section = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        description: 'This section evaluates facility access',
        items: [item1, item2],
      );

      expect(section.description, 'This section evaluates facility access');
    });

    test('should handle empty items list', () {
      final section = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [],
      );

      expect(section.items, isEmpty);
      expect(
        section.isComplete,
        true,
      ); // An empty section is technically complete
      expect(section.completedItemsCount, 0);
    });

    test('should support equality comparison', () {
      final section1 = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [item1, item2],
      );

      final section2 = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [item1, item2],
      );

      final differentSection = AssessmentSection(
        id: 'section2',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [item1, item2],
      );

      expect(section1, equals(section2));
      expect(section1, isNot(equals(differentSection)));
    });

    test('copyWith should update id and sectionNumber', () {
      final section = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [item1],
      );

      final updatedSection = section.copyWith(
        id: 'newId',
        sectionNumber: '3.2',
      );

      expect(updatedSection.id, 'newId');
      expect(updatedSection.sectionNumber, '3.2');
    });

    test('copyWith should not set description to null', () {
      final section = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        description: 'Some description',
        items: [item1],
      );

      final updatedSection = section.copyWith(description: null);

      expect(updatedSection.description, isNotNull);
    });

    test('should correctly handle completion status edge cases', () {
      // Create items without ratings
      final unratedItem1 = AssessmentItem(
        id: 'item1',
        sectionNumber: '2.1.1',
        area: 'Health care facility entrances',
        meetsTargetDescription: 'Description 1',
        partiallyMeetsDescription: 'Description 2',
        doesNotMeetDescription: 'Description 3',
      );

      final unratedItem2 = AssessmentItem(
        id: 'item2',
        sectionNumber: '2.1.2',
        area: 'Area distribution',
        meetsTargetDescription: 'Description 1',
        partiallyMeetsDescription: 'Description 2',
        doesNotMeetDescription: 'Description 3',
      );

      // Section with all unrated items
      final allUnratedSection = AssessmentSection(
        id: 'section1',
        sectionNumber: '2.1',
        title: 'Facility accesses and flows',
        items: [unratedItem1, unratedItem2],
      );

      expect(allUnratedSection.isComplete, false);
      expect(allUnratedSection.completedItemsCount, 0);
    });
  });
}
