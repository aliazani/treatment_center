import 'package:equatable/equatable.dart';

class ValidationResultEntity extends Equatable {
  final bool isValid;
  final String? incompleteFieldName;
  final String? incompleteFieldMessage;
  final String? subsectionName;

  const ValidationResultEntity({
    required this.isValid,
    this.incompleteFieldName,
    this.incompleteFieldMessage,
    this.subsectionName,
  });

  /// Creates a successful validation result
  const ValidationResultEntity.valid() : this(isValid: true);

  /// Creates a failed validation result with specific field information
  const ValidationResultEntity.invalid({
    required String fieldName,
    required String message,
    String? subsection,
  }) : this(
         isValid: false,
         incompleteFieldName: fieldName,
         incompleteFieldMessage: message,
         subsectionName: subsection,
       );

  /// Get the user-friendly validation message
  String get userMessage {
    if (isValid) return '';

    if (subsectionName != null) {
      return 'Please complete "$incompleteFieldName" in $subsectionName';
    }

    return incompleteFieldMessage ??
        'Please complete the required field: $incompleteFieldName';
  }

  @override
  List<Object?> get props => [
    isValid,
    incompleteFieldName,
    incompleteFieldMessage,
    subsectionName,
  ];
}
