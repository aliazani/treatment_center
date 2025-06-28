import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';

class FacilityIdentificationModel extends FacilityIdentificationEntity {
  const FacilityIdentificationModel({
    required super.facilityCode,
    required super.facilityName,
    required super.managingAuthority,
    super.otherManagingAuthority,
    required super.directorName,
    required super.directorPhone,
    required super.directorEmail,
    required super.respondentName,
    required super.respondentPosition,
    required super.structureType,
    required super.facilityType,
    super.existingFacilityType,
    super.otherExistingFacilityType,
  });

  factory FacilityIdentificationModel.fromJson(Map<String, dynamic> json) {
    return FacilityIdentificationModel(
      facilityCode: json['facility_code'],
      facilityName: json['facility_name'],
      managingAuthority:
          ManagingAuthorityType.values[json['managing_authority']],
      otherManagingAuthority: json['other_managing_authority'],
      directorName: json['director_name'],
      directorPhone: json['director_phone'],
      directorEmail: json['director_email'],
      respondentName: json['respondent_name'],
      respondentPosition: json['respondent_position'],
      structureType: FacilityStructureType.values[json['structure_type']],
      facilityType: FacilityType.values[json['facility_type']],
      existingFacilityType:
          json['existing_facility_type'] != null
              ? ExistingFacilityType.values[json['existing_facility_type']]
              : null,
      otherExistingFacilityType: json['other_existing_facility_type'],
    );
  }

  factory FacilityIdentificationModel.fromEntity(
    FacilityIdentificationEntity identification,
  ) {
    return FacilityIdentificationModel(
      facilityCode: identification.facilityCode,
      facilityName: identification.facilityName,
      managingAuthority: identification.managingAuthority,
      otherManagingAuthority: identification.otherManagingAuthority,
      directorName: identification.directorName,
      directorPhone: identification.directorPhone,
      directorEmail: identification.directorEmail,
      respondentName: identification.respondentName,
      respondentPosition: identification.respondentPosition,
      structureType: identification.structureType,
      facilityType: identification.facilityType,
      existingFacilityType: identification.existingFacilityType,
      otherExistingFacilityType: identification.otherExistingFacilityType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facility_code': facilityCode,
      'facility_name': facilityName,
      'managing_authority': managingAuthority.index,
      'other_managing_authority': otherManagingAuthority,
      'director_name': directorName,
      'director_phone': directorPhone,
      'director_email': directorEmail,
      'respondent_name': respondentName,
      'respondent_position': respondentPosition,
      'structure_type': structureType.index,
      'facility_type': facilityType.index,
      'existing_facility_type': existingFacilityType?.index,
      'other_existing_facility_type': otherExistingFacilityType,
    };
  }
}
