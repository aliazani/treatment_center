import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';

class AssessmentRatingModel extends AssessmentRatingEntity {
  const AssessmentRatingModel({
    required super.id,
    required super.value,
    required super.label,
    required super.description,
  });

  factory AssessmentRatingModel.fromJson(Map<String, dynamic> json) {
    return AssessmentRatingModel(
      id: json['id'],
      value: json['value'],
      label: json['label'],
      description: json['description'],
    );
  }

  factory AssessmentRatingModel.fromEntity(AssessmentRatingEntity rating) {
    return AssessmentRatingModel(
      id: rating.id,
      value: rating.value,
      label: rating.label,
      description: rating.description,
    );
  }

  factory AssessmentRatingModel.meetsTarget() => const AssessmentRatingModel(
    id: 'meets_target',
    value: 3,
    label: 'Meets target (+++) (3)',
    description:
        'The facility fully meets the requirements for this aspect of the assessment.',
  );

  factory AssessmentRatingModel.partiallyMeetsTarget() =>
      const AssessmentRatingModel(
        id: 'partially_meets',
        value: 2,
        label: 'Partially meets target (++) (2)',
        description:
            'The facility partially meets the requirements for this aspect of the assessment.',
      );

  factory AssessmentRatingModel.doesNotMeetTarget() => const AssessmentRatingModel(
    id: 'does_not_meet',
    value: 1,
    label: 'Does not meet target (+) (1)',
    description:
        'The facility does not meet the requirements for this aspect of the assessment.',
  );

  factory AssessmentRatingModel.dontKnow() => const AssessmentRatingModel(
    id: 'dont_know',
    value: 0,
    label: 'Don\'t Know (DK)',
    description:
        'It is not possible to determine if the facility meets this requirement.',
  );

  factory AssessmentRatingModel.notApplicable() => const AssessmentRatingModel(
    id: 'not_applicable',
    value: -1,
    label: 'Not Applicable (NA)',
    description: 'This requirement does not apply to this facility.',
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'label': label,
      'description': description,
    };
  }
}
