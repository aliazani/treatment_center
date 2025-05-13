import 'package:equatable/equatable.dart';

/// Represents the rating options for assessment items in the domain layer
class AssessmentRating extends Equatable {
  final String id;
  final int value;
  final String label;
  final String description;

  const AssessmentRating({
    required this.id,
    required this.value,
    required this.label,
    required this.description,
  });

  /// Predefined rating: Meets target (value 3)
  factory AssessmentRating.meetsTarget() => const AssessmentRating(
    id: 'meets_target',
    value: 3,
    label: 'Meets target (+++) (3)',
    description: 'The facility fully meets the requirements for this aspect of the assessment.',
  );
  
  /// Predefined rating: Partially meets target (value 2)
  factory AssessmentRating.partiallyMeetsTarget() => const AssessmentRating(
    id: 'partially_meets',
    value: 2,
    label: 'Partially meets target (++) (2)',
    description: 'The facility partially meets the requirements for this aspect of the assessment.',
  );
  
  /// Predefined rating: Does not meet target (value 1)
  factory AssessmentRating.doesNotMeetTarget() => const AssessmentRating(
    id: 'does_not_meet',
    value: 1,
    label: 'Does not meet target (+) (1)',
    description: 'The facility does not meet the requirements for this aspect of the assessment.',
  );
  
  /// Special value for "Don't Know" (DK)
  factory AssessmentRating.dontKnow() => const AssessmentRating(
    id: 'dont_know',
    value: 0,
    label: 'Don\'t Know (DK)',
    description: 'It is not possible to determine if the facility meets this requirement.',
  );
  
  /// Special value for "Not Applicable" (NA)
  factory AssessmentRating.notApplicable() => const AssessmentRating(
    id: 'not_applicable',
    value: -1,
    label: 'Not Applicable (NA)',
    description: 'This requirement does not apply to this facility.',
  );

  @override
  List<Object> get props => [id, value, label, description];
}