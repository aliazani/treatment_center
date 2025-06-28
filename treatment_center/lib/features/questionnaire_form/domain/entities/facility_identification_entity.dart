import 'package:equatable/equatable.dart';

/// Managing authority types for healthcare facilities
enum ManagingAuthorityType {
  government,
  privateForProfit,
  privateNotForProfit,
  militaryPoliceNationalGuard,
  university,
  other,
}

/// Facility structure types
enum FacilityStructureType {
  permanent, // Concrete, bricks, etc.
  temporaryMediumTerm, // Concrete slabs and wooden structure, rub halls
  temporaryShortTerm, // Tents, etc.
}

/// Facility types
enum FacilityType { screeningAndTemporaryIsolation, standaloneTreatmentCenter }

/// Existing healthcare facility types
enum ExistingFacilityType {
  firstReferralHospital,
  regionalProvincialReferralHospital,
  nationalReferralHospital,
  otherGeneralHospital,
  infectiousDiseasesUnit,
  primaryHealthClinic,
  other,
}

/// Represents identification information of the healthcare facility
class FacilityIdentificationEntity extends Equatable {
  /// Facility code or ID
  final String facilityCode;

  /// Name of the facility
  final String facilityName;

  /// Type of authority managing the facility
  final ManagingAuthorityType managingAuthority;

  /// Description if "other" is selected for managing authority
  final String? otherManagingAuthority;

  /// Name of the facility director or manager
  final String directorName;

  /// Telephone number of the facility director
  final String directorPhone;

  /// Email address of the facility director
  final String directorEmail;

  /// Name of respondent or key informant
  final String respondentName;

  /// Position of respondent or key informant
  final String respondentPosition;

  /// Type of facility structure
  final FacilityStructureType structureType;

  /// Type of facility (screening/isolation or standalone treatment center)
  /// if screening/isolation is selected, go to existing facility type,
  /// otherwise go to next section
  final FacilityType facilityType;

  /// Type of existing healthcare facility (if applicable)
  final ExistingFacilityType? existingFacilityType;

  /// Description if "other" is selected for existing facility type
  final String? otherExistingFacilityType;

  const FacilityIdentificationEntity({
    required this.facilityCode,
    required this.facilityName,
    required this.managingAuthority,
    this.otherManagingAuthority,
    required this.directorName,
    required this.directorPhone,
    required this.directorEmail,
    required this.respondentName,
    required this.respondentPosition,
    required this.structureType,
    required this.facilityType,
    this.existingFacilityType,
    this.otherExistingFacilityType,
  });

  @override
  List<Object?> get props => [
    facilityCode,
    facilityName,
    managingAuthority,
    otherManagingAuthority,
    directorName,
    directorPhone,
    directorEmail,
    respondentName,
    respondentPosition,
    structureType,
    facilityType,
    existingFacilityType,
    otherExistingFacilityType,
  ];
}
