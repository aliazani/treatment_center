import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';

class AssessmentRatingModel extends AssessmentRatingEntity {
  const AssessmentRatingModel({
    required super.id,
    required super.value,
    required super.label,
    required super.description,
  });

  /// Factory constructor to create AssessmentRatingModel from JSON
  /// Used for deserializing data from APIs or local storage
  factory AssessmentRatingModel.fromJson(Map<String, dynamic> json) {
    return AssessmentRatingModel(
      id: json['id'],
      value: json['value'],
      label: json['label'],
      description: json['description'],
    );
  }

  /// Factory constructor to create AssessmentRatingModel from AssessmentRatingEntity
  /// Useful for converting domain entities to data models
  factory AssessmentRatingModel.fromEntity(AssessmentRatingEntity rating) {
    return AssessmentRatingModel(
      id: rating.id,
      value: rating.value,
      label: rating.label,
      description: rating.description,
    );
  }

  /// Converts AssessmentRatingModel back to AssessmentRatingEntity
  /// Useful for converting data models to domain entities
  AssessmentRatingEntity toEntity() {
    return AssessmentRatingEntity(
      id: id,
      value: value,
      label: label,
      description: description,
    );
  }

  /// Factory constructor for "Meets target" rating
  factory AssessmentRatingModel.meetsTarget() => const AssessmentRatingModel(
    id: 'meets_target',
    value: 3,
    label: 'Meets target (+++) (3)',
    description:
        'The facility fully meets the requirements for this aspect of the assessment.',
  );

  /// Factory constructor for "Partially meets target" rating
  factory AssessmentRatingModel.partiallyMeetsTarget() =>
      const AssessmentRatingModel(
        id: 'partially_meets',
        value: 2,
        label: 'Partially meets target (++) (2)',
        description:
            'The facility partially meets the requirements for this aspect of the assessment.',
      );

  /// Factory constructor for "Does not meet target" rating
  factory AssessmentRatingModel.doesNotMeetTarget() => const AssessmentRatingModel(
    id: 'does_not_meet',
    value: 1,
    label: 'Does not meet target (+) (1)',
    description:
        'The facility does not meet the requirements for this aspect of the assessment.',
  );

  /// Factory constructor for "Don't Know" rating
  factory AssessmentRatingModel.dontKnow() => const AssessmentRatingModel(
    id: 'dont_know',
    value: 0,
    label: 'Don\'t Know (DK)',
    description:
        'It is not possible to determine if the facility meets this requirement.',
  );

  /// Factory constructor for "Not Applicable" rating
  factory AssessmentRatingModel.notApplicable() => const AssessmentRatingModel(
    id: 'not_applicable',
    value: -1,
    label: 'Not Applicable (NA)',
    description: 'This requirement does not apply to this facility.',
  );

  /// Converts AssessmentRatingModel to JSON
  /// Used for serializing data to APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'label': label,
      'description': description,
    };
  }
}