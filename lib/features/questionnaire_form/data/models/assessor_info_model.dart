import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';

class AssessorInfoModel extends AssessorInfoEntity {
  const AssessorInfoModel({
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.assessmentDate,
  });

  /// Factory constructor to create AssessorInfoModel from JSON
  /// Used for deserializing data from APIs or local storage
  factory AssessorInfoModel.fromJson(Map<String, dynamic> json) {
    return AssessorInfoModel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      assessmentDate: DateTime.parse(json['assessment_date']),
    );
  }

  /// Factory constructor to create AssessorInfoModel from AssessorInfoEntity
  /// Useful for converting domain entities to data models
  factory AssessorInfoModel.fromEntity(AssessorInfoEntity info) {
    return AssessorInfoModel(
      name: info.name,
      email: info.email,
      phoneNumber: info.phoneNumber,
      assessmentDate: info.assessmentDate,
    );
  }

  /// Converts AssessorInfoModel back to AssessorInfoEntity
  /// Useful for converting data models to domain entities
  AssessorInfoEntity toEntity() {
    return AssessorInfoEntity(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      assessmentDate: assessmentDate,
    );
  }

  /// Converts AssessorInfoModel to JSON
  /// Used for serializing data to APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'assessment_date': assessmentDate?.toIso8601String(),
    };
  }
}