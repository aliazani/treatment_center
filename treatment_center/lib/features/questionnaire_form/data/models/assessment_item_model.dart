import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'assessment_rating_model.dart';

class AssessmentItemModel extends AssessmentItemEntity {
  const AssessmentItemModel({
    required super.id,
    required super.sectionNumber,
    required super.area,
    required super.meetsTargetDescription,
    required super.partiallyMeetsDescription,
    required super.doesNotMeetDescription,
    super.selectedRating,
    super.comment,
  });

  factory AssessmentItemModel.fromJson(Map<String, dynamic> json) {
    return AssessmentItemModel(
      id: json['id'],
      sectionNumber: json['section_number'],
      area: json['area'],
      meetsTargetDescription: json['meets_target_description'],
      partiallyMeetsDescription: json['partially_meets_description'],
      doesNotMeetDescription: json['does_not_meet_description'],
      selectedRating:
          json['selected_rating'] != null
              ? AssessmentRatingModel.fromJson(json['selected_rating'])
              : null,
      comment: json['comment'],
    );
  }

  factory AssessmentItemModel.fromEntity(AssessmentItemEntity item) {
    return AssessmentItemModel(
      id: item.id,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
