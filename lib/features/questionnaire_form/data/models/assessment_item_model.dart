import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'assessment_rating_model.dart';

class AssessmentItemModel extends AssessmentItemEntity {
  const AssessmentItemModel({
    required super.id,
    required super.itemNumber,
    required super.sectionNumber,
    required super.area,
    required super.meetsTargetDescription,
    required super.partiallyMeetsDescription,
    required super.doesNotMeetDescription,
    super.selectedRating,
    super.comment,
  });

  /// Factory constructor to create AssessmentItemModel from JSON
  /// Used for deserializing data from APIs or local storage
  factory AssessmentItemModel.fromJson(Map<String, dynamic> json) {
    return AssessmentItemModel(
      id: json['id'] as int,
      itemNumber: json['item_number'] as String,
      sectionNumber: json['section_number'] as String,
      area: json['area'] as String,
      meetsTargetDescription: json['meets_target_description'] as String,
      partiallyMeetsDescription: json['partially_meets_description'] as String,
      doesNotMeetDescription: json['does_not_meet_description'] as String,
      selectedRating:
          json['selected_rating'] != null
              ? AssessmentRatingModel.fromJson(
                json['selected_rating'] as Map<String, dynamic>,
              )
              : null,
      comment: json['comment'] as String?,
    );
  }

  /// Factory constructor to create AssessmentItemModel from AssessmentItemEntity
  /// Useful for converting domain entities to data models
  factory AssessmentItemModel.fromEntity(AssessmentItemEntity item) {
    return AssessmentItemModel(
      id: item.id,
      itemNumber: item.itemNumber,
      sectionNumber: item.sectionNumber,
      area: item.area,
      meetsTargetDescription: item.meetsTargetDescription,
      partiallyMeetsDescription: item.partiallyMeetsDescription,
      doesNotMeetDescription: item.doesNotMeetDescription,
      selectedRating:
          item.selectedRating != null
              ? AssessmentRatingModel.fromEntity(item.selectedRating!)
              : null,
      comment: item.comment,
    );
  }

  /// Converts AssessmentItemModel back to AssessmentItemEntity
  /// Useful for converting data models to domain entities
  AssessmentItemEntity toEntity() {
    return AssessmentItemEntity(
      id: id,
      itemNumber: itemNumber,
      sectionNumber: sectionNumber,
      area: area,
      meetsTargetDescription: meetsTargetDescription,
      partiallyMeetsDescription: partiallyMeetsDescription,
      doesNotMeetDescription: doesNotMeetDescription,
      selectedRating:
          selectedRating != null
              ? (selectedRating as AssessmentRatingModel).toEntity()
              : null,
      comment: comment,
    );
  }

  /// Converts AssessmentItemModel to JSON
  /// Used for serializing data to APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_number': itemNumber,
      'section_number': sectionNumber,
      'area': area,
      'meets_target_description': meetsTargetDescription,
      'partially_meets_description': partiallyMeetsDescription,
      'does_not_meet_description': doesNotMeetDescription,
      'selected_rating':
          selectedRating != null
              ? (selectedRating as AssessmentRatingModel).toJson()
              : null,
      'comment': comment,
    };
  }
}
