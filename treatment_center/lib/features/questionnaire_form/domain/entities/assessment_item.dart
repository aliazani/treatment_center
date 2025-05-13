import 'package:equatable/equatable.dart';
import 'assessment_rating.dart';

/// Represents an individual assessment item/question within a section
class AssessmentItem extends Equatable {
  /// Unique identifier for the assessment item
  final String id;
  
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
  final AssessmentRating? selectedRating;
  
  /// Optional additional comments provided by the assessor
  final String? comment;

  const AssessmentItem({
    required this.id,
    required this.sectionNumber,
    required this.area,
    required this.meetsTargetDescription,
    required this.partiallyMeetsDescription,
    required this.doesNotMeetDescription,
    this.selectedRating,
    this.comment,
  });

  /// Creates a copy of this AssessmentItem with the given fields replaced
  AssessmentItem copyWith({
    String? id,
    String? sectionNumber,
    String? area,
    String? meetsTargetDescription,
    String? partiallyMeetsDescription,
    String? doesNotMeetDescription,
    AssessmentRating? selectedRating,
    String? comment,
  }) {
    return AssessmentItem(
      id: id ?? this.id,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      area: area ?? this.area,
      meetsTargetDescription: meetsTargetDescription ?? this.meetsTargetDescription,
      partiallyMeetsDescription: partiallyMeetsDescription ?? this.partiallyMeetsDescription,
      doesNotMeetDescription: doesNotMeetDescription ?? this.doesNotMeetDescription,
      selectedRating: selectedRating ?? this.selectedRating,
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    sectionNumber, 
    area, 
    meetsTargetDescription,
    partiallyMeetsDescription,
    doesNotMeetDescription,
    selectedRating,
    comment,
  ];
}