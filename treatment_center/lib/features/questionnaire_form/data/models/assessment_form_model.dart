import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:flutter/foundation.dart';

class AssessmentFormModel extends AssessmentFormEntity {
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
    required super.createdAt,
    required super.updatedAt,
  });

  factory AssessmentFormModel.create({
    required String id,
    required AssessorInfoModel assessorInfo,
    required GeoLocationModel geoLocation,
    required FacilityIdentificationModel facilityIdentification,
    required FacilityServicesModel facilityServices,
    required List<AssessmentSectionModel> sections,
    String? notes,
    bool isSubmitted = false,
    DateTime? submissionDate,
  }) {
    final now = DateTime.now();
    return AssessmentFormModel(
      id: id,
      assessorInfo: assessorInfo,
      geoLocation: geoLocation,
      facilityIdentification: facilityIdentification,
      facilityServices: facilityServices,
      sections: sections,
      notes: notes,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AssessmentFormModel.fromJson(Map<String, dynamic> json) {
    return AssessmentFormModel(
      id: json['id'],
      assessorInfo: AssessorInfoModel.fromJson(json['assessor_info']),
      geoLocation: GeoLocationModel.fromJson(json['geo_location']),
      facilityIdentification: FacilityIdentificationModel.fromJson(
        json['facility_identification'],
      ),
      facilityServices: FacilityServicesModel.fromJson(
        json['facility_services'],
      ),
      sections:
          (json['sections'] as List)
              .map((section) => AssessmentSectionModel.fromJson(section))
              .toList(),
      notes: json['notes'],
      isSubmitted: json['is_submitted'] ?? false,
      submissionDate:
          json['submission_date'] != null
              ? _parseDateTime(json['submission_date'])
              : null,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  factory AssessmentFormModel.fromEntity(AssessmentFormEntity form) {
    return AssessmentFormModel(
      id: form.id,
      assessorInfo:
          form.assessorInfo is AssessorInfoModel
              ? form.assessorInfo as AssessorInfoModel
              : AssessorInfoModel.fromEntity(form.assessorInfo),
      geoLocation:
          form.geoLocation is GeoLocationModel
              ? form.geoLocation as GeoLocationModel
              : GeoLocationModel.fromEntity(form.geoLocation),
      facilityIdentification:
          form.facilityIdentification is FacilityIdentificationModel
              ? form.facilityIdentification as FacilityIdentificationModel
              : FacilityIdentificationModel.fromEntity(
                form.facilityIdentification,
              ),
      facilityServices:
          form.facilityServices is FacilityServicesModel
              ? form.facilityServices as FacilityServicesModel
              : FacilityServicesModel.fromEntity(form.facilityServices),
      sections:
          form.sections
              .map(
                (section) =>
                    section is AssessmentSectionModel
                        ? section
                        : AssessmentSectionModel.fromEntity(section),
              )
              .toList(),
      notes: form.notes,
      isSubmitted: form.isSubmitted,
      submissionDate: form.submissionDate,
      createdAt: form.createdAt,
      updatedAt: form.updatedAt,
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
      'sections':
          sections
              .map((section) => (section as AssessmentSectionModel).toJson())
              .toList(),
      'notes': notes,
      'is_submitted': isSubmitted,
      'submission_date': submissionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  AssessmentFormModel copyWith({
    String? id,
    AssessorInfoEntity? assessorInfo,
    GeoLocationEntity? geoLocation,
    FacilityIdentificationEntity? facilityIdentification,
    FacilityServicesEntity? facilityServices,
    List<AssessmentSectionEntity>? sections,
    String? notes,
    bool? isSubmitted,
    DateTime? submissionDate,
    DateTime? createdAt, // Ignored - preserved for compatibility
    DateTime? updatedAt, // Ignored - automatically managed
  }) {
    return AssessmentFormModel(
      id: id ?? this.id,
      assessorInfo:
          assessorInfo != null
              ? (assessorInfo is AssessorInfoModel
                  ? assessorInfo
                  : AssessorInfoModel.fromEntity(assessorInfo))
              : this.assessorInfo as AssessorInfoModel,
      geoLocation:
          geoLocation != null
              ? (geoLocation is GeoLocationModel
                  ? geoLocation
                  : GeoLocationModel.fromEntity(geoLocation))
              : this.geoLocation as GeoLocationModel,
      facilityIdentification:
          facilityIdentification != null
              ? (facilityIdentification is FacilityIdentificationModel
                  ? facilityIdentification
                  : FacilityIdentificationModel.fromEntity(
                    facilityIdentification,
                  ))
              : this.facilityIdentification as FacilityIdentificationModel,
      facilityServices:
          facilityServices != null
              ? (facilityServices is FacilityServicesModel
                  ? facilityServices
                  : FacilityServicesModel.fromEntity(facilityServices))
              : this.facilityServices as FacilityServicesModel,
      sections:
          sections != null
              ? sections
                  .map(
                    (section) =>
                        section is AssessmentSectionModel
                            ? section
                            : AssessmentSectionModel.fromEntity(section),
                  )
                  .toList()
              : this.sections.map((s) => s as AssessmentSectionModel).toList(),
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
      createdAt: this.createdAt, // NEVER changes
      updatedAt: DateTime.now(), // ALWAYS current time
    );
  }

  /// Convenience method for when you already have model types
  AssessmentFormModel copyWithModels({
    String? id,
    AssessorInfoModel? assessorInfo,
    GeoLocationModel? geoLocation,
    FacilityIdentificationModel? facilityIdentification,
    FacilityServicesModel? facilityServices,
    List<AssessmentSectionModel>? sections,
    String? notes,
    bool? isSubmitted,
    DateTime? submissionDate,
  }) {
    return AssessmentFormModel(
      id: id ?? this.id,
      assessorInfo: assessorInfo ?? this.assessorInfo as AssessorInfoModel,
      geoLocation: geoLocation ?? this.geoLocation as GeoLocationModel,
      facilityIdentification:
          facilityIdentification ??
          this.facilityIdentification as FacilityIdentificationModel,
      facilityServices:
          facilityServices ?? this.facilityServices as FacilityServicesModel,
      sections:
          sections ??
          this.sections.map((s) => s as AssessmentSectionModel).toList(),
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
      createdAt: createdAt, // NEVER changes
      updatedAt: DateTime.now(), // ALWAYS current time
    );
  }

  /// Internal method for system use only - creates copy with specific timestamps
  /// This should only be used by the data layer for database operations
  AssessmentFormModel _copyWithSystemTimestamps({
    String? id,
    AssessorInfoModel? assessorInfo,
    GeoLocationModel? geoLocation,
    FacilityIdentificationModel? facilityIdentification,
    FacilityServicesModel? facilityServices,
    List<AssessmentSectionModel>? sections,
    String? notes,
    bool? isSubmitted,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssessmentFormModel(
      id: id ?? this.id,
      assessorInfo: assessorInfo ?? this.assessorInfo as AssessorInfoModel,
      geoLocation: geoLocation ?? this.geoLocation as GeoLocationModel,
      facilityIdentification:
          facilityIdentification ??
          this.facilityIdentification as FacilityIdentificationModel,
      facilityServices:
          facilityServices ?? this.facilityServices as FacilityServicesModel,
      sections:
          sections ??
          this.sections.map((s) => s as AssessmentSectionModel).toList(),
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  AssessmentFormModel markAsSubmitted() {
    final now = DateTime.now();
    return _copyWithSystemTimestamps(
      isSubmitted: true,
      submissionDate: now,
      updatedAt: now,
    );
  }

  /// Helper method to safely parse DateTime strings
  /// Returns null if parsing fails, allowing fallback to default values
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is! String) return null;
    if (dateValue.isEmpty) return null;

    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      return null;
    }
  }

  /// Test helper method to exercise _copyWithSystemTimestamps with null parameters
  /// This method is only intended for testing coverage of null coalescing operators
  @visibleForTesting
  AssessmentFormModel copyWithSystemTimestampsForTesting({
    String? id,
    AssessorInfoModel? assessorInfo,
    GeoLocationModel? geoLocation,
    FacilityIdentificationModel? facilityIdentification,
    FacilityServicesModel? facilityServices,
    List<AssessmentSectionModel>? sections,
    String? notes,
    bool? isSubmitted,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return _copyWithSystemTimestamps(
      id: id,
      assessorInfo: assessorInfo,
      geoLocation: geoLocation,
      facilityIdentification: facilityIdentification,
      facilityServices: facilityServices,
      sections: sections,
      notes: notes,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
