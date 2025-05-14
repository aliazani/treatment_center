import '../../domain/entities/facility_services.dart';

class FacilityServicesModel extends FacilityServices {
  const FacilityServicesModel({
    required super.hasOutpatientServices,
    required super.hasInpatientServices,
    super.totalInpatientBeds,
    super.icuBeds,
    super.hasEmergencyUnit = null,
    super.hasIcuOrHighDependencyUnit = null,
  });

  factory FacilityServicesModel.fromJson(Map<String, dynamic> json) {
    return FacilityServicesModel(
      hasOutpatientServices: json['has_outpatient_services'],
      hasInpatientServices: json['has_inpatient_services'],
      totalInpatientBeds: json['total_inpatient_beds'],
      icuBeds: json['icu_beds'],
      hasEmergencyUnit: json['has_emergency_unit'],
      hasIcuOrHighDependencyUnit: json['has_icu_or_high_dependency_unit'],
    );
  }

  factory FacilityServicesModel.fromEntity(FacilityServices services) {
    return FacilityServicesModel(
      hasOutpatientServices: services.hasOutpatientServices,
      hasInpatientServices: services.hasInpatientServices,
      totalInpatientBeds: services.totalInpatientBeds,
      icuBeds: services.icuBeds,
      hasEmergencyUnit: services.hasEmergencyUnit,
      hasIcuOrHighDependencyUnit: services.hasIcuOrHighDependencyUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_outpatient_services': hasOutpatientServices,
      'has_inpatient_services': hasInpatientServices,
      'total_inpatient_beds': totalInpatientBeds,
      'icu_beds': icuBeds,
      'has_emergency_unit': hasEmergencyUnit,
      'has_icu_or_high_dependency_unit': hasIcuOrHighDependencyUnit,
    };
  }
}
