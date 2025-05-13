import 'package:equatable/equatable.dart';

/// Represents services offered by the healthcare facility
class FacilityServices extends Equatable {
  /// Whether the facility offers outpatient services
  final bool hasOutpatientServices;
  
  /// Whether the facility offers inpatient services - if no go to next section
  final bool hasInpatientServices;
  
  /// Total number of inpatient beds (if applicable)
  final int? totalInpatientBeds;
  
  /// Number of intensive care unit beds (if applicable) 
  /// - should be less than total inpatient beds
  final int? icuBeds;
  
  /// Whether the facility has a dedicated 24-hour staffed emergency unit
  final bool? hasEmergencyUnit;
  
  /// Whether the facility has an intensive care or high-dependency unit
  final bool? hasIcuOrHighDependencyUnit;

  const FacilityServices({
    required this.hasOutpatientServices,
    required this.hasInpatientServices,
    this.totalInpatientBeds,
    this.icuBeds,
    this.hasEmergencyUnit = false,
    this.hasIcuOrHighDependencyUnit = false,
  });

  /// Validates that ICU beds count is valid (less than total beds)
  bool get isIcuBedsCountValid {
    if (icuBeds == null || totalInpatientBeds == null) return true;
    return icuBeds! <= totalInpatientBeds!;
  }

  @override
  List<Object?> get props => [
    hasOutpatientServices,
    hasInpatientServices,
    totalInpatientBeds,
    icuBeds,
    hasEmergencyUnit,
    hasIcuOrHighDependencyUnit,
  ];
}