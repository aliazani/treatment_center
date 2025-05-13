import 'package:equatable/equatable.dart';
import 'assessment_item.dart';

/// Represents a section within the assessment form
class AssessmentSection extends Equatable {
  /// Unique identifier for the section
  final String id;
  
  /// The section number (e.g., "2.1", "3.4")
  final String sectionNumber;
  
  /// The title of the section
  final String title;
  
  /// Description or instructions for this section
  final String? description;
  
  /// List of assessment items in this section
  final List<AssessmentItem> items;

  const AssessmentSection({
    required this.id,
    required this.sectionNumber,
    required this.title,
    this.description,
    required this.items,
  });

  /// Creates a copy of this AssessmentSection with the given fields replaced
  AssessmentSection copyWith({
    String? id,
    String? sectionNumber,
    String? title,
    String? description,
    List<AssessmentItem>? items,
  }) {
    return AssessmentSection(
      id: id ?? this.id,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }
  
  /// Get completion status for this section
  bool get isComplete => items.every((item) => item.selectedRating != null);
  
  /// Get the count of completed items
  int get completedItemsCount => items.where((item) => item.selectedRating != null).length;

  @override
  List<Object?> get props => [id, sectionNumber, title, description, items];
}