import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'assessment_item_model.dart';

class AssessmentSectionModel extends AssessmentSectionEntity {
  const AssessmentSectionModel({
    required super.id,
    required super.sectionNumber,
    required super.title,
    super.description,
    required super.items,
  });

  /// Factory constructor to create AssessmentSectionModel from JSON
  /// Used for deserializing data from APIs or local storage
  factory AssessmentSectionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentSectionModel(
      id: json['id'],
      sectionNumber: json['section_number'],
      title: json['title'],
      description: json['description'],
      items:
          (json['items'] as List)
              .map((item) => AssessmentItemModel.fromJson(item))
              .toList(),
    );
  }

  /// Factory constructor to create AssessmentSectionModel from AssessmentSectionEntity
  /// Useful for converting domain entities to data models
  factory AssessmentSectionModel.fromEntity(AssessmentSectionEntity section) {
    return AssessmentSectionModel(
      id: section.id,
      sectionNumber: section.sectionNumber,
      title: section.title,
      description: section.description,
      items:
          section.items
              .map((item) => AssessmentItemModel.fromEntity(item))
              .toList(),
    );
  }

  /// Converts AssessmentSectionModel back to AssessmentSectionEntity
  /// Useful for converting data models to domain entities
  AssessmentSectionEntity toEntity() {
    return AssessmentSectionEntity(
      id: id,
      sectionNumber: sectionNumber,
      title: title,
      description: description,
      items:
          items
              .map((item) => (item as AssessmentItemModel).toEntity())
              .toList(),
    );
  }

  /// Converts AssessmentSectionModel to JSON
  /// Used for serializing data to APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_number': sectionNumber,
      'title': title,
      'description': description,
      'items':
          items.map((item) => (item as AssessmentItemModel).toJson()).toList(),
    };
  }
}
