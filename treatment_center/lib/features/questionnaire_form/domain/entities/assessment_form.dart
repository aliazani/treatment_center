import 'package:equatable/equatable.dart';
import 'assessment_section.dart';
import 'assessor_info.dart';
import 'geolocation.dart';
import 'facility_identification.dart';
import 'facility_services.dart';

/// Represents a complete assessment form
class AssessmentForm extends Equatable {
  /// Unique identifier for this assessment form
  final String id;
  
  /// Information about the assessor
  final AssessorInfo assessorInfo;
  
  /// Geographical location of the facility
  final GeoLocation geoLocation;
  
  /// Identification information of the facility
  final FacilityIdentification facilityIdentification;
  
  /// Services offered by the facility
  final FacilityServices facilityServices;
  
  /// List of all assessment sections
  final List<AssessmentSection> sections;
  
  /// Additional notes about the assessment
  final String? notes;
  
  /// Whether the assessment has been submitted/finalized
  final bool isSubmitted;
  
  /// Date when the assessment was submitted (if applicable)
  final DateTime? submissionDate;

  const AssessmentForm({
    required this.id,
    required this.assessorInfo,
    required this.geoLocation,
    required this.facilityIdentification,
    required this.facilityServices,
    required this.sections,
    this.notes,
    this.isSubmitted = false,
    this.submissionDate,
  });

  /// Creates a copy of this AssessmentForm with the given fields replaced
  AssessmentForm copyWith({
    String? id,
    AssessorInfo? assessorInfo,
    GeoLocation? geoLocation,
    FacilityIdentification? facilityIdentification,
    FacilityServices? facilityServices,
    List<AssessmentSection>? sections,
    String? notes,
    bool? isSubmitted,
    DateTime? submissionDate,
  }) {
    return AssessmentForm(
      id: id ?? this.id,
      assessorInfo: assessorInfo ?? this.assessorInfo,
      geoLocation: geoLocation ?? this.geoLocation,
      facilityIdentification: facilityIdentification ?? this.facilityIdentification,
      facilityServices: facilityServices ?? this.facilityServices,
      sections: sections ?? this.sections,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
    );
  }

  /// Calculate overall completion percentage
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

  /// Check if the form is complete (all sections are complete)
  bool get isComplete => sections.every((section) => section.isComplete);

  /// Mark the form as submitted
  AssessmentForm markAsSubmitted() {
    return copyWith(
      isSubmitted: true,
      submissionDate: DateTime.now(),
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
  ];
}