import 'package:equatable/equatable.dart';

/// Represents the rating options for assessment items in the domain layer
class AssessmentRatingEntity extends Equatable {
  final String id;
  final int value;
  final String label;
  final String description;

  const AssessmentRatingEntity({
    required this.id,
    required this.value,
    required this.label,
    required this.description,
  });

  /// Predefined rating: Meets target (value 3)
  factory AssessmentRatingEntity.meetsTarget() => const AssessmentRatingEntity(
    id: 'meets_target',
    value: 3,
    label: 'Meets target (+++) (3)',
    description:
        'The facility fully meets the requirements for this aspect of the assessment.',
  );

  /// Predefined rating: Partially meets target (value 2)
  factory AssessmentRatingEntity.partiallyMeetsTarget() =>
      const AssessmentRatingEntity(
        id: 'partially_meets',
        value: 2,
        label: 'Partially meets target (++) (2)',
        description:
            'The facility partially meets the requirements for this aspect of the assessment.',
      );

  /// Predefined rating: Does not meet target (value 1)
  factory AssessmentRatingEntity.doesNotMeetTarget() =>
      const AssessmentRatingEntity(
        id: 'does_not_meet',
        value: 1,
        label: 'Does not meet target (+) (1)',
        description:
            'The facility does not meet the requirements for this aspect of the assessment.',
      );

  /// Special value for "Don't Know" (DK)
  factory AssessmentRatingEntity.dontKnow() => const AssessmentRatingEntity(
    id: 'dont_know',
    value: 0,
    label: 'Don\'t Know (DK)',
    description:
        'It is not possible to determine if the facility meets this requirement.',
  );

  /// Special value for "Not Applicable" (NA)
  factory AssessmentRatingEntity.notApplicable() =>
      const AssessmentRatingEntity(
        id: 'not_applicable',
        value: -1,
        label: 'Not Applicable (NA)',
        description: 'This requirement does not apply to this facility.',
      );

  @override
  List<Object> get props => [id, value, label, description];
}
