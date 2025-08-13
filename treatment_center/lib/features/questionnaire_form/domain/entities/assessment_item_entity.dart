import 'package:equatable/equatable.dart';
import 'assessment_rating_entity.dart';

/// Represents an individual assessment item/question within a section
class AssessmentItemEntity extends Equatable {
  /// Unique integer identifier for the assessment item
  final int? id;

  /// A human‑readable item number (e.g., "2.1.1")
  final String itemNumber;

  /// The section number this item belongs to (e.g., "2.1", "3.4")
  final String sectionNumber;

  /// The area or aspect being assessed (e.g., "Facility accesses and flows")
  final String area;

  /// Description of what constitutes "Meets target" condition
  final String meetsTargetDescription;

  /// Description of what constitutes "Partially meets target" condition
  final String partiallyMeetsDescription;

  /// Description of what constitutes "Does not meet target" condition
  final String doesNotMeetDescription;

  /// The currently selected rating for this assessment item (null if not rated yet)
  final AssessmentRatingEntity? selectedRating;

  /// Optional additional comments provided by the assessor
  final String? comment;

  const AssessmentItemEntity({
    required this.id,
    required this.itemNumber,
    required this.sectionNumber,
    required this.area,
    required this.meetsTargetDescription,
    required this.partiallyMeetsDescription,
    required this.doesNotMeetDescription,
    this.selectedRating,
    this.comment,
  });

  /// Returns a copy of this item, replacing only the fields you pass.
  AssessmentItemEntity copyWith({
    int? id,
    String? itemNumber,
    String? sectionNumber,
    String? area,
    String? meetsTargetDescription,
    String? partiallyMeetsDescription,
    String? doesNotMeetDescription,
    AssessmentRatingEntity? selectedRating,
    String? comment,
  }) {
    return AssessmentItemEntity(
      id: id ?? this.id,
      itemNumber: itemNumber ?? this.itemNumber,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      area: area ?? this.area,
      meetsTargetDescription:
          meetsTargetDescription ?? this.meetsTargetDescription,
      partiallyMeetsDescription:
          partiallyMeetsDescription ?? this.partiallyMeetsDescription,
      doesNotMeetDescription:
          doesNotMeetDescription ?? this.doesNotMeetDescription,
      selectedRating: selectedRating ?? this.selectedRating,
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [
    id,
    itemNumber,
    sectionNumber,
    area,
    meetsTargetDescription,
    partiallyMeetsDescription,
    doesNotMeetDescription,
    selectedRating,
    comment,
  ];
}
