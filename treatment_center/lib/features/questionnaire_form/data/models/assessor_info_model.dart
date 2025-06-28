import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';

class AssessorInfoModel extends AssessorInfoEntity {
  const AssessorInfoModel({
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.assessmentDate,
  });

  factory AssessorInfoModel.fromJson(Map<String, dynamic> json) {
    return AssessorInfoModel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      assessmentDate: DateTime.parse(json['assessment_date']),
    );
  }

  factory AssessorInfoModel.fromEntity(AssessorInfoEntity info) {
    return AssessorInfoModel(
      name: info.name,
      email: info.email,
      phoneNumber: info.phoneNumber,
      assessmentDate: info.assessmentDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'assessment_date': assessmentDate.toIso8601String(),
    };
  }
}
