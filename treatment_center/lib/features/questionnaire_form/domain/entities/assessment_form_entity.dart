import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'assessment_section_entity.dart';
import 'assessor_info_entity.dart';
import 'geolocation_entity.dart';
import 'facility_identification_entity.dart';
import 'facility_services_entity.dart';

class AssessmentFormEntity extends Equatable {
  final String id;
  final AssessorInfoEntity assessorInfo;
  final GeoLocationEntity geoLocation;
  final FacilityIdentificationEntity facilityIdentification;
  final FacilityServicesEntity facilityServices;
  final List<AssessmentSectionEntity> sections;
  final String? notes;
  final bool isSubmitted;
  final DateTime? submissionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AssessmentFormEntity({
    required this.id,
    required this.assessorInfo,
    required this.geoLocation,
    required this.facilityIdentification,
    required this.facilityServices,
    required this.sections,
    this.notes,
    this.isSubmitted = false,
    this.submissionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssessmentFormEntity.create({
    required String id,
    required AssessorInfoEntity assessorInfo,
    required GeoLocationEntity geoLocation,
    required FacilityIdentificationEntity facilityIdentification,
    required FacilityServicesEntity facilityServices,
    required List<AssessmentSectionEntity> sections,
    String? notes,
    bool isSubmitted = false,
    DateTime? submissionDate,
  }) {
    final now = DateTime.now();
    return AssessmentFormEntity(
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

  AssessmentFormEntity copyWith({
    String? id,
    AssessorInfoEntity? assessorInfo,
    GeoLocationEntity? geoLocation,
    FacilityIdentificationEntity? facilityIdentification,
    FacilityServicesEntity? facilityServices,
    List<AssessmentSectionEntity>? sections,
    String? notes,
    bool? isSubmitted,
    DateTime? submissionDate,
  }) {
    return AssessmentFormEntity(
      id: id ?? this.id,
      assessorInfo: assessorInfo ?? this.assessorInfo,
      geoLocation: geoLocation ?? this.geoLocation,
      facilityIdentification:
          facilityIdentification ?? this.facilityIdentification,
      facilityServices: facilityServices ?? this.facilityServices,
      sections: sections ?? this.sections,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  AssessmentFormEntity _copyWithSystemTimestamps({
    String? id,
    AssessorInfoEntity? assessorInfo,
    GeoLocationEntity? geoLocation,
    FacilityIdentificationEntity? facilityIdentification,
    FacilityServicesEntity? facilityServices,
    List<AssessmentSectionEntity>? sections,
    String? notes,
    bool? isSubmitted,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssessmentFormEntity(
      id: id ?? this.id,
      assessorInfo: assessorInfo ?? this.assessorInfo,
      geoLocation: geoLocation ?? this.geoLocation,
      facilityIdentification:
          facilityIdentification ?? this.facilityIdentification,
      facilityServices: facilityServices ?? this.facilityServices,
      sections: sections ?? this.sections,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get completionPercentage {
    if (sections.isEmpty) return 0.0;

    int totalItems = 0;
    int completedItems = 0;

    for (final section in sections) {
      totalItems += section.items.length;
      completedItems += section.completedItemsCount;
    }

    return totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;
  }

  bool get isComplete {
    if (sections.isEmpty) return true;
    return sections.every((section) => section.isComplete);
  }

  int get totalItems {
    return sections.fold<int>(0, (sum, section) => sum + section.items.length);
  }

  int get ratedItems {
    return sections.fold<int>(
      0,
      (sum, section) => sum + section.completedItemsCount,
    );
  }

  bool get canEdit => !isSubmitted;

  String get status {
    if (isSubmitted) {
      return 'Submitted';
    } else if (isComplete) {
      return 'Complete (Draft)';
    } else {
      return 'In Progress (${completionPercentage.toStringAsFixed(0)}% complete)';
    }
  }

  Duration get timeSinceLastUpdate {
    return DateTime.now().difference(updatedAt);
  }

  Duration get age {
    return DateTime.now().difference(createdAt);
  }

  /// Mark the form as submitted with current timestamp
  /// This is the ONLY way to set submissionDate and mark as submitted
  /// Updates both submissionDate and updatedAt to the same timestamp
  AssessmentFormEntity markAsSubmitted() {
    final now = DateTime.now();
    return _copyWithSystemTimestamps(
      isSubmitted: true,
      submissionDate: now,
      updatedAt: now,
    );
  }

  /// Test-only method to trigger null coalescing operators in _copyWithSystemTimestamps
  @visibleForTesting
  AssessmentFormEntity copyWithSystemTimestamps({
    String? id,
    AssessorInfoEntity? assessorInfo,
    GeoLocationEntity? geoLocation,
    FacilityIdentificationEntity? facilityIdentification,
    FacilityServicesEntity? facilityServices,
    List<AssessmentSectionEntity>? sections,
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

  @override
  List<Object?> get props => [
    id,
    assessorInfo,
    geoLocation,
    facilityIdentification,
    facilityServices,
    sections,
    notes,
    isSubmitted,
    submissionDate,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'AssessmentForm(id: $id, facility: ${facilityIdentification.facilityName}, '
        'status: $status, created: $createdAt, updated: $updatedAt)';
  }
}
