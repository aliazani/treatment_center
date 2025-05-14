import '../../domain/entities/assessment_section.dart';
import 'assessment_item_model.dart';

class AssessmentSectionModel extends AssessmentSection{
  const AssessmentSectionModel({
    required super.id,
    required super.sectionNumber,
    required super.title,
    super.description,
    required super.items,
  });

  factory AssessmentSectionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentSectionModel(
      id: json['id'],
      sectionNumber: json['section_number'],
      title: json['title'],
      description: json['description'],
      items: (json['items'] as List)
          .map((item) => AssessmentItemModel.fromJson(item))
          .toList(),
    );
  }

  factory AssessmentSectionModel.fromEntity(AssessmentSection section) {
    return AssessmentSectionModel(
      id: section.id,
      sectionNumber: section.sectionNumber,
      title: section.title,
      description: section.description,
      items: section.items
          .map((item) => AssessmentItemModel.fromEntity(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_number': sectionNumber,
      'title': title,
      'description': description,
      'items': items
          .map((item) => (item as AssessmentItemModel).toJson())
          .toList(),
    };
  }
}