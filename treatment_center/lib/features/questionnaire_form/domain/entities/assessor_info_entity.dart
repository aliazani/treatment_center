import 'package:equatable/equatable.dart';

/// Represents information about the person conducting the assessment
class AssessorInfoEntity extends Equatable {
  /// Name of the person conducting the assessment
  final String name;

  /// Email of the assessor
  final String email;

  /// Phone number of the assessor
  final String phoneNumber;

  /// Date when the assessment was conducted
  final DateTime assessmentDate;

  const AssessorInfoEntity({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.assessmentDate,
  });

  @override
  List<Object> get props => [name, email, phoneNumber, assessmentDate];
}
