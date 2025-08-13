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

  /// Factory constructor to create FacilityIdentificationModel from JSON
  /// Used for deserializing data from APIs or local storage
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

  /// Factory constructor to create FacilityIdentificationModel from FacilityIdentificationEntity
  /// Useful for converting domain entities to data models
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

  /// Converts FacilityIdentificationModel back to FacilityIdentificationEntity
  /// Useful for converting data models to domain entities
  FacilityIdentificationEntity toEntity() {
    return FacilityIdentificationEntity(
      facilityCode: facilityCode,
      facilityName: facilityName,
      managingAuthority: managingAuthority,
      otherManagingAuthority: otherManagingAuthority,
      directorName: directorName,
      directorPhone: directorPhone,
      directorEmail: directorEmail,
      respondentName: respondentName,
      respondentPosition: respondentPosition,
      structureType: structureType,
      facilityType: facilityType,
      existingFacilityType: existingFacilityType,
      otherExistingFacilityType: otherExistingFacilityType,
    );
  }

  /// Converts FacilityIdentificationModel to JSON
  /// Used for serializing data to APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'facility_code': facilityCode,
      'facility_name': facilityName,
      'managing_authority': managingAuthority?.index,
      'other_managing_authority': otherManagingAuthority,
      'director_name': directorName,
      'director_phone': directorPhone,
      'director_email': directorEmail,
      'respondent_name': respondentName,
      'respondent_position': respondentPosition,
      'structure_type': structureType?.index,
      'facility_type': facilityType?.index,
      'existing_facility_type': existingFacilityType?.index,
      'other_existing_facility_type': otherExistingFacilityType,
    };
  }
}