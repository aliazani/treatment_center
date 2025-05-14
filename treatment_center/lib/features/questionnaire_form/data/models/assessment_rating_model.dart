import '../../domain/entities/assessment_rating.dart';

class AssessmentRatingModel extends AssessmentRating {
  const AssessmentRatingModel({
    required super.id,
    required super.value,
    required super.label,
    required super.description,
  });

  /// Creates a model from a JSON map
  factory AssessmentRatingModel.fromJson(Map<String, dynamic> json) {
    return AssessmentRatingModel(
      id: json['id'],
      value: json['value'],
      label: json['label'],
      description: json['description'],
    );
  }

  /// Creates a model from an entity instance
  factory AssessmentRatingModel.fromEntity(AssessmentRating rating) {
    return AssessmentRatingModel(
      id: rating.id,
      value: rating.value,
      label: rating.label,
      description: rating.description,
    );
  }

  /// Predefined rating: Meets target (value 3)
  factory AssessmentRatingModel.meetsTarget() => const AssessmentRatingModel(
    id: 'meets_target',
    value: 3,
    label: 'Meets target (+++) (3)',
    description:
        'The facility fully meets the requirements for this aspect of the assessment.',
  );

  /// Predefined rating: Partially meets target (value 2)
  factory AssessmentRatingModel.partiallyMeetsTarget() =>
      const AssessmentRatingModel(
        id: 'partially_meets',
        value: 2,
        label: 'Partially meets target (++) (2)',
        description:
            'The facility partially meets the requirements for this aspect of the assessment.',
      );

  /// Predefined rating: Does not meet target (value 1)
  factory AssessmentRatingModel.doesNotMeetTarget() => const AssessmentRatingModel(
    id: 'does_not_meet',
    value: 1,
    label: 'Does not meet target (+) (1)',
    description:
        'The facility does not meet the requirements for this aspect of the assessment.',
  );

  /// Special value for "Don't Know" (DK)
  factory AssessmentRatingModel.dontKnow() => const AssessmentRatingModel(
    id: 'dont_know',
    value: 0,
    label: 'Don\'t Know (DK)',
    description:
        'It is not possible to determine if the facility meets this requirement.',
  );

  /// Special value for "Not Applicable" (NA)
  factory AssessmentRatingModel.notApplicable() => const AssessmentRatingModel(
    id: 'not_applicable',
    value: -1,
    label: 'Not Applicable (NA)',
    description: 'This requirement does not apply to this facility.',
  );

  /// Converts the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'label': label,
      'description': description,
    };
  }
}
