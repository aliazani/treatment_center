import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form.dart';

import 'assessor_info_model.dart';
import 'geolocation_model.dart';
import 'facility_identification_model.dart';
import 'facility_services_model.dart';

class AssessmentFormModel extends AssessmentForm {
  const AssessmentFormModel({
    required super.id,
    required super.assessorInfo,
    required super.geoLocation,
    required super.facilityIdentification,
    required super.facilityServices,
    required super.sections,
    super.notes,
    super.isSubmitted,
    super.submissionDate,
  });

  factory AssessmentFormModel.fromJson(Map<String, dynamic> json) {
    return AssessmentFormModel(
      id: json['id'],
      assessorInfo: AssessorInfoModel.fromJson(json['assessor_info']),
      geoLocation: GeoLocationModel.fromJson(json['geo_location']),
      facilityIdentification: FacilityIdentificationModel.fromJson(
          json['facility_identification']),
      facilityServices: FacilityServicesModel.fromJson(json['facility_services']),
      sections: (json['sections'] as List)
          .map((section) => AssessmentSectionModel.fromJson(section))
          .toList(),
      notes: json['notes'],
      isSubmitted: json['is_submitted'] ?? false,
      submissionDate: json['submission_date'] != null
          ? DateTime.parse(json['submission_date'])
          : null,
    );
  }

  factory AssessmentFormModel.fromEntity(AssessmentForm form) {
    return AssessmentFormModel(
      id: form.id,
      assessorInfo: AssessorInfoModel.fromEntity(form.assessorInfo),
      geoLocation: GeoLocationModel.fromEntity(form.geoLocation),
      facilityIdentification: FacilityIdentificationModel.fromEntity(
          form.facilityIdentification),
      facilityServices: FacilityServicesModel.fromEntity(form.facilityServices),
      sections: form.sections
          .map((section) => AssessmentSectionModel.fromEntity(section))
          .toList(),
      notes: form.notes,
      isSubmitted: form.isSubmitted,
      submissionDate: form.submissionDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessor_info': (assessorInfo as AssessorInfoModel).toJson(),
      'geo_location': (geoLocation as GeoLocationModel).toJson(),
      'facility_identification':
          (facilityIdentification as FacilityIdentificationModel).toJson(),
      'facility_services': (facilityServices as FacilityServicesModel).toJson(),
      'sections': sections
          .map((section) => (section as AssessmentSectionModel).toJson())
          .toList(),
      'notes': notes,
      'is_submitted': isSubmitted,
      'submission_date': submissionDate?.toIso8601String(),
    };
  }
}