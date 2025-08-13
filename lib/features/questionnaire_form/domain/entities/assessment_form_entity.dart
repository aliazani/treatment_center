import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
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
  final List<PhotoEntity> photos;
  final String? notes;
  final bool isSubmitted;
  final DateTime? submissionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  static const List<String> expectedSectionNumbers = ['1', '2', '3', '4'];

  const AssessmentFormEntity({
    required this.id,
    required this.assessorInfo,
    required this.geoLocation,
    required this.facilityIdentification,
    required this.facilityServices,
    required this.sections,
    this.photos = const [],
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
    List<PhotoEntity>? photos,
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
      photos: photos ?? this.photos,
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
    List<PhotoEntity>? photos,
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
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get completionPercentage {
    // Section 1 uses metadata-based progress
    final s1 = _getSection1Progress();
    final p1 = s1.total > 0 ? (s1.completed / s1.total) : 0.0;

    // Sections 2–4: if section exists but has 0 items, treat as 0% (not complete).
    double pctFor(String n) {
      final s = _findSectionByNumber(n);
      if (s == null) return 0.0;
      final t = s.items.length;
      if (t == 0) return 0.0;
      final c = s.completedItemsCount;
      return (c / t).clamp(0.0, 1.0);
    }

    final p2 = pctFor('2');
    final p3 = pctFor('3');
    final p4 = pctFor('4');

    // Average of 4 sections, then convert to percent
    final avg = (p1 + p2 + p3 + p4) / 4.0;
    final percent = avg * 100.0;

    return percent;
  }

  AssessmentSectionEntity? _findSectionByNumber(String num) {
    for (final s in sections) {
      if (s.sectionNumber == num) return s;
    }
    return null; // null means "section missing" → contributes 0 completed/0 total (except S1, which we compute from metadata)
  }

  int get totalItems {
    return sections.fold<int>(0, (sum, section) {
      if (section.sectionNumber == '1') {
        // add both the 1.1–1.5 metadata fields *and* the actual items in section 1
        return sum + _getSection1Progress().total + section.items.length;
      }
      return sum + section.items.length;
    });
  }

  int get completedItems {
    return sections.fold<int>(0, (sum, section) {
      if (section.sectionNumber == '1') {
        // add both the completed metadata fields *and* the completed question‑items
        return sum +
            _getSection1Progress().completed +
            section.completedItemsCount;
      }
      return sum + section.completedItemsCount;
    });
  }

  bool get isComplete {
    // Section 1 must be fully complete (same rules as your metadata flags)
    final s1 = _getSection1Progress();
    if (s1.completed < s1.total) return false;

    // Sections 2–4 must exist, have items, and be complete
    for (final n in expectedSectionNumbers.where((n) => n != '1')) {
      final s = _findSectionByNumber(n);
      if (s == null) return false; // missing section -> not complete
      if (s.items.isEmpty) return false; // no items yet -> not complete
      if (!s.isComplete) return false; // has items but not complete
    }

    return true;
  }

  // =======================================================================
  // SECTION 1 SPECIFIC GETTERS
  // =======================================================================

  /// Returns the total number of fields in Section 1
  /// Includes: Assessor Info (4) + Geolocation (8) + Facility ID (11) + Services (2-6) + Photos (1)
  int get section1TotalItems {
    return _getSection1Progress().total;
  }

  /// Returns the number of completed fields in Section 1
  int get section1CompletedItems {
    return _getSection1Progress().completed;
  }

  /// Returns the number of unanswered fields in Section 1
  int get section1UnansweredItems {
    final progress = _getSection1Progress();
    return progress.total - progress.completed;
  }

  /// Returns the completion percentage for Section 1 only
  double get section1Progress {
    final progress = _getSection1Progress();
    return progress.total > 0
        ? (progress.completed / progress.total) * 100.0
        : 0.0;
  }

  /// Returns true if Section 1 is complete
  bool get isSection1Complete {
    final progress = _getSection1Progress();
    return progress.completed >= progress.total;
  }

  /// Returns a detailed breakdown of Section 1 completion status
  Section1Status get section1Status {
    final progress = _getSection1Progress();

    // Get individual subsection progress
    final assessorProgress = _getAssessorInfoProgress();
    final geoProgress = _getGeolocationProgress();
    final facilityProgress = _getFacilityIdentificationProgress();
    final servicesProgress = _getFacilityServicesProgress();
    final photoProgress = _getPhotoProgress();

    return Section1Status(
      totalItems: progress.total,
      completedItems: progress.completed,
      unansweredItems: progress.total - progress.completed,
      isComplete: progress.completed >= progress.total,
      assessorInfo: assessorProgress,
      geolocation: geoProgress,
      facilityIdentification: facilityProgress,
      facilityServices: servicesProgress,
      photoDocumentation: photoProgress,
    );
  }

  // =======================================================================
  // PRIVATE HELPER METHODS FOR SECTION 1 PROGRESS
  // =======================================================================

  /// This matches the Excel export service calculation exactly
  _Section1Progress _getSection1Progress() {
    // 1.1 Assessor Info (4 fields)
    final assessorFlags = [
      assessorInfo.assessmentDate != null,
      assessorInfo.name.trim().isNotEmpty,
      assessorInfo.email.trim().isNotEmpty,
      assessorInfo.phoneNumber.trim().isNotEmpty,
    ];

    // 1.2 Geolocation (6 fields) - REMOVED lat/lng as they're optional
    final geoFlags = [
      geoLocation.country.trim().isNotEmpty,
      geoLocation.regionProvince.trim().isNotEmpty,
      geoLocation.district.trim().isNotEmpty,
      geoLocation.cityVillage.trim().isNotEmpty,
      geoLocation.addressOrCoordinates.trim().isNotEmpty,
      geoLocation.locationType != null,
    ];

    // 1.3 Facility Identification (11 fields)
    final facilityFlags = [
      facilityIdentification.facilityCode.trim().isNotEmpty,
      facilityIdentification.facilityName.trim().isNotEmpty,
      facilityIdentification.managingAuthority != null,
      facilityIdentification.directorName.trim().isNotEmpty,
      facilityIdentification.directorPhone.trim().isNotEmpty,
      facilityIdentification.directorEmail.trim().isNotEmpty,
      facilityIdentification.respondentName.trim().isNotEmpty,
      facilityIdentification.respondentPosition.trim().isNotEmpty,
      facilityIdentification.structureType != null,
      facilityIdentification.facilityType != null,
      if (_requiresExistingFacilityType)
        facilityIdentification.existingFacilityType != null,
    ];

    // 1.4 Facility Services (2-6 fields depending on inpatient services)
    final serviceFlags = <bool>[
      facilityServices.hasOutpatientServices != null,
      facilityServices.hasInpatientServices != null,
    ];
    if (facilityServices.hasInpatientServices == true) {
      serviceFlags.addAll([
        facilityServices.totalInpatientBeds != null,
        facilityServices.icuBeds != null,
        facilityServices.hasEmergencyUnit != null,
        facilityServices.hasIcuOrHighDependencyUnit != null,
      ]);
    }

    // 1.5 Photo Summary (1 field)
    final photoFlags = [photos.isNotEmpty];

    final allFlags = [
      ...assessorFlags,
      ...geoFlags,
      ...facilityFlags,
      ...serviceFlags,
      ...photoFlags,
    ];

    return _Section1Progress(
      total: allFlags.length,
      completed: allFlags.where((f) => f).length,
    );
  }

  /// Get Assessor Info subsection progress (1.1)
  SubsectionProgress _getAssessorInfoProgress() {
    final flags = [
      assessorInfo.assessmentDate != null,
      assessorInfo.name.trim().isNotEmpty,
      assessorInfo.email.trim().isNotEmpty,
      assessorInfo.phoneNumber.trim().isNotEmpty,
    ];

    final completed = flags.where((f) => f).length;
    return SubsectionProgress(
      subsectionName: '1.1 Assessment Information',
      totalItems: flags.length,
      completedItems: completed,
    );
  }

  /// Get Geolocation subsection progress (1.2)
  SubsectionProgress _getGeolocationProgress() {
    final flags = [
      geoLocation.country.trim().isNotEmpty,
      geoLocation.regionProvince.trim().isNotEmpty,
      geoLocation.district.trim().isNotEmpty,
      geoLocation.cityVillage.trim().isNotEmpty,
      geoLocation.addressOrCoordinates.trim().isNotEmpty,
      geoLocation.locationType != null,
    ];

    final completed = flags.where((f) => f).length;
    return SubsectionProgress(
      subsectionName: '1.2 Geographical Location',
      totalItems: flags.length,
      completedItems: completed,
    );
  }

  /// Get Facility Identification subsection progress (1.3)
  SubsectionProgress _getFacilityIdentificationProgress() {
    final flags = [
      facilityIdentification.facilityCode.trim().isNotEmpty,
      facilityIdentification.facilityName.trim().isNotEmpty,
      facilityIdentification.managingAuthority != null,
      facilityIdentification.directorName.trim().isNotEmpty,
      facilityIdentification.directorPhone.trim().isNotEmpty,
      facilityIdentification.directorEmail.trim().isNotEmpty,
      facilityIdentification.respondentName.trim().isNotEmpty,
      facilityIdentification.respondentPosition.trim().isNotEmpty,
      facilityIdentification.structureType != null,
      facilityIdentification.facilityType != null,
      if (_requiresExistingFacilityType)
        facilityIdentification.existingFacilityType != null,
    ];

    final completed = flags.where((f) => f).length;
    return SubsectionProgress(
      subsectionName: '1.3 Facility Identification',
      totalItems: flags.length,
      completedItems: completed,
    );
  }

  /// Get Facility Services subsection progress (1.4)
  SubsectionProgress _getFacilityServicesProgress() {
    final baseFlags = [
      facilityServices.hasOutpatientServices != null,
      facilityServices.hasInpatientServices != null,
    ];

    final conditionalFlags = <bool>[];
    if (facilityServices.hasInpatientServices == true) {
      conditionalFlags.addAll([
        facilityServices.totalInpatientBeds != null,
        facilityServices.icuBeds != null,
        facilityServices.hasEmergencyUnit != null,
        facilityServices.hasIcuOrHighDependencyUnit != null,
      ]);
    }

    final allFlags = [...baseFlags, ...conditionalFlags];
    final completed = allFlags.where((f) => f).length;

    return SubsectionProgress(
      subsectionName: '1.4 Existing Health Care Facility Services',
      totalItems: allFlags.length,
      completedItems: completed,
    );
  }

  /// Get Photo Documentation subsection progress (1.5)
  SubsectionProgress _getPhotoProgress() {
    final flags = [photos.isNotEmpty];
    final completed = flags.where((f) => f).length;

    return SubsectionProgress(
      subsectionName: '1.5 Photo Documentation Summary',
      totalItems: flags.length,
      completedItems: completed,
    );
  }

  // =======================================================================
  // EXISTING GETTERS AND METHODS
  // =======================================================================

  AssessmentFormEntity get markedAsSubmitted => markAsSubmitted();

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
    List<PhotoEntity>? photos,
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
      photos: photos,
      notes: notes,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  bool get _requiresExistingFacilityType {
    final ft = facilityIdentification.facilityType;
    return ft == FacilityType.screeningAndTemporaryIsolation;
  }

  @override
  List<Object?> get props => [
    id,
    assessorInfo,
    geoLocation,
    facilityIdentification,
    facilityServices,
    sections,
    photos,
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

/// Helper class for section 1 progress calculation
class _Section1Progress {
  final int total;
  final int completed;

  _Section1Progress({required this.total, required this.completed});
}

/// Detailed Section 1 status with subsection breakdown
class Section1Status {
  final int totalItems;
  final int completedItems;
  final int unansweredItems;
  final bool isComplete;
  final SubsectionProgress assessorInfo;
  final SubsectionProgress geolocation;
  final SubsectionProgress facilityIdentification;
  final SubsectionProgress facilityServices;
  final SubsectionProgress photoDocumentation;

  const Section1Status({
    required this.totalItems,
    required this.completedItems,
    required this.unansweredItems,
    required this.isComplete,
    required this.assessorInfo,
    required this.geolocation,
    required this.facilityIdentification,
    required this.facilityServices,
    required this.photoDocumentation,
  });

  /// Calculate progress percentage from total and completed items
  double get progressPercentage {
    return totalItems > 0 ? (completedItems / totalItems) * 100.0 : 0.0;
  }

  @override
  String toString() {
    return 'Section1Status(total: $totalItems, completed: $completedItems, '
        'unanswered: $unansweredItems, progress: ${progressPercentage.toStringAsFixed(1)}%, '
        'complete: $isComplete)';
  }
}

/// Progress information for a subsection within Section 1
class SubsectionProgress {
  final String subsectionName;
  final int totalItems;
  final int completedItems;

  const SubsectionProgress({
    required this.subsectionName,
    required this.totalItems,
    required this.completedItems,
  });

  /// Calculate unanswered items from total and completed
  int get unansweredItems => totalItems - completedItems;

  /// Calculate completion status from completed and total items
  bool get isComplete => completedItems >= totalItems;

  /// Calculate progress percentage from total and completed items
  double get progressPercentage {
    return totalItems > 0 ? (completedItems / totalItems) * 100.0 : 0.0;
  }

  @override
  String toString() {
    return 'SubsectionProgress($subsectionName: $completedItems/$totalItems - ${progressPercentage.toStringAsFixed(1)}%)';
  }
}
