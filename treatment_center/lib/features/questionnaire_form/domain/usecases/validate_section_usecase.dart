import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

class ValidationResultEntity extends Equatable {
  final bool isValid;
  final String? incompleteFieldName;
  final String? incompleteFieldMessage;
  final String? subsectionName;

  const ValidationResultEntity({
    required this.isValid,
    this.incompleteFieldName,
    this.incompleteFieldMessage,
    this.subsectionName,
  });

  const ValidationResultEntity.valid() : this(isValid: true);

  const ValidationResultEntity.invalid({
    required String fieldName,
    required String message,
    String? subsection,
  }) : this(
         isValid: false,
         incompleteFieldName: fieldName,
         incompleteFieldMessage: message,
         subsectionName: subsection,
       );

  String get userMessage {
    if (isValid) return '';

    if (subsectionName != null) {
      return '$incompleteFieldMessage\n\nLocation: $subsectionName';
    }

    return incompleteFieldMessage ??
        'Please complete the required field: $incompleteFieldName';
  }

  @override
  List<Object?> get props => [
    isValid,
    incompleteFieldName,
    incompleteFieldMessage,
    subsectionName,
  ];
}

class ValidateSectionUsecase
    implements UseCase<ValidationResultEntity, ValidateSectionParams> {
  @override
  Future<Either<Failure, ValidationResultEntity>> call(
    ValidateSectionParams params,
  ) async {
    try {
      final validationResult = _validateSection(
        params.assessmentForm,
        params.sectionNumber,
      );
      return Right(validationResult);
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to validate section: ${e.toString()}',
        ),
      );
    }
  }

  ValidationResultEntity _validateSection(
    AssessmentFormEntity form,
    int sectionNumber,
  ) {
    switch (sectionNumber) {
      case 1:
        return _validateSection1(form);
      case 2:
      case 3:
      case 4:
        return _validateAssessmentSection(form, sectionNumber.toString());
      case 5:
      case 6:
        return const ValidationResultEntity.valid();
      default:
        return const ValidationResultEntity.invalid(
          fieldName: 'Section Number',
          message: 'Invalid section number. Please contact support.',
        );
    }
  }

  ValidationResultEntity _validateSection1(AssessmentFormEntity form) {
    // 1.1 Assessor Information
    final assessorResult = _validateAssessorInfo(form.assessorInfo);
    if (!assessorResult.isValid) return assessorResult;

    // 1.2 Geolocation
    final geoResult = _validateGeolocation(form.geoLocation);
    if (!geoResult.isValid) return geoResult;

    // 1.3 Facility Identification
    final facilityResult = _validateFacilityIdentification(
      form.facilityIdentification,
    );
    if (!facilityResult.isValid) return facilityResult;

    // 1.4 Facility Services
    final servicesResult = _validateFacilityServices(form.facilityServices);
    if (!servicesResult.isValid) return servicesResult;

    return const ValidationResultEntity.valid();
  }

  ValidationResultEntity _validateAssessorInfo(
    AssessorInfoEntity assessorInfo,
  ) {
    if (assessorInfo.assessmentDate == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Assessment Date',
        message: 'Assessment date is required',
        subsection: 'Section 1.1 - Assessment Information',
      );
    }

    if (_isNullOrEmpty(assessorInfo.name)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Assessor Name',
        message: 'Assessor name is required',
        subsection: 'Section 1.1 - Assessment Information',
      );
    }

    if (_isNullOrEmpty(assessorInfo.email)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Assessor Email',
        message: 'Assessor email address is required',
        subsection: 'Section 1.1 - Assessment Information',
      );
    }

    if (!_isValidEmail(assessorInfo.email)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Assessor Email',
        message: 'Assessor email format is invalid',
        subsection: 'Section 1.1 - Assessment Information',
      );
    }

    if (_isNullOrEmpty(assessorInfo.phoneNumber)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Assessor Phone Number',
        message: 'Assessor phone number is required',
        subsection: 'Section 1.1 - Assessment Information',
      );
    }

    return const ValidationResultEntity.valid();
  }

  ValidationResultEntity _validateGeolocation(GeoLocationEntity geoLocation) {
    if (_isNullOrEmpty(geoLocation.country)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Country',
        message: 'Country is required',
        subsection: 'Section 1.2 - Geographic Location',
      );
    }

    if (_isNullOrEmpty(geoLocation.regionProvince)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Region/Province',
        message: 'Region/Province is required',
        subsection: 'Section 1.2 - Geographic Location',
      );
    }

    if (_isNullOrEmpty(geoLocation.district)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'District',
        message: 'District is required',
        subsection: 'Section 1.2 - Geographic Location',
      );
    }

    if (_isNullOrEmpty(geoLocation.cityVillage)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'City/Village',
        message: 'City/Village is required',
        subsection: 'Section 1.2 - Geographic Location',
      );
    }

    if (_isNullOrEmpty(geoLocation.addressOrCoordinates)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Address/Coordinates',
        message: 'Address or coordinates is required',
        subsection: 'Section 1.2 - Geographic Location',
      );
    }

    if (geoLocation.locationType == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Location Type',
        message: 'Location type is required',
        subsection: 'Section 1.2 - Geographic Location',
      );
    }

    return const ValidationResultEntity.valid();
  }

  ValidationResultEntity _validateFacilityIdentification(
    FacilityIdentificationEntity facilityId,
  ) {
    if (_isNullOrEmpty(facilityId.facilityCode)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Facility Code',
        message: 'Facility code is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (_isNullOrEmpty(facilityId.facilityName)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Facility Name',
        message: 'Facility name is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (facilityId.managingAuthority == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Managing Authority',
        message: 'Managing authority is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (_isNullOrEmpty(facilityId.directorName)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Director Name',
        message: 'Director name is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (_isNullOrEmpty(facilityId.directorPhone)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Director Phone',
        message: 'Director phone number is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (_isNullOrEmpty(facilityId.directorEmail)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Director Email',
        message: 'Director email address is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (!_isValidEmail(facilityId.directorEmail)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Director Email',
        message: 'Director email format is invalid',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (_isNullOrEmpty(facilityId.respondentName)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Respondent Name',
        message: 'Respondent name is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (_isNullOrEmpty(facilityId.respondentPosition)) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Respondent Position',
        message: 'Respondent position is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (facilityId.structureType == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Structure Type',
        message: 'Structure type is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    if (facilityId.facilityType == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Facility Type',
        message: 'Facility type is required',
        subsection: 'Section 1.3 - Facility Identification',
      );
    }

    // Special validation for screening facilities
    if (facilityId.facilityType ==
        FacilityType.screeningAndTemporaryIsolation) {
      if (facilityId.existingFacilityType == null) {
        return const ValidationResultEntity.invalid(
          fieldName: 'Existing Facility Type',
          message: 'Existing facility type is required for screening centers',
          subsection: 'Section 1.3 - Facility Identification',
        );
      }
    }

    return const ValidationResultEntity.valid();
  }

  ValidationResultEntity _validateFacilityServices(
    FacilityServicesEntity facilityServices,
  ) {
    if (facilityServices.hasOutpatientServices == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Outpatient Services',
        message: 'Outpatient services selection is required',
        subsection: 'Section 1.4 - Facility Services',
      );
    }

    if (facilityServices.hasInpatientServices == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Inpatient Services',
        message: 'Inpatient services selection is required',
        subsection: 'Section 1.4 - Facility Services',
      );
    }

    // Additional validations for inpatient services
    if (facilityServices.hasInpatientServices == true) {
      if (facilityServices.totalInpatientBeds == null) {
        return const ValidationResultEntity.invalid(
          fieldName: 'Total Inpatient Beds',
          message: 'Total inpatient beds is required',
          subsection: 'Section 1.4 - Facility Services',
        );
      }

      if (facilityServices.icuBeds == null) {
        return const ValidationResultEntity.invalid(
          fieldName: 'ICU Beds',
          message: 'ICU beds count is required (enter 0 if none)',
          subsection: 'Section 1.4 - Facility Services',
        );
      }

      // Business rule: ICU beds can't exceed total inpatient beds
      if (facilityServices.totalInpatientBeds != null &&
          facilityServices.icuBeds != null &&
          facilityServices.icuBeds! > facilityServices.totalInpatientBeds!) {
        return ValidationResultEntity.invalid(
          fieldName: 'ICU Beds',
          message:
              'ICU beds (${facilityServices.icuBeds}) cannot exceed total beds (${facilityServices.totalInpatientBeds})',
          subsection: 'Section 1.4 - Facility Services',
        );
      }

      if (facilityServices.hasEmergencyUnit == null) {
        return const ValidationResultEntity.invalid(
          fieldName: 'Emergency Unit',
          message: 'Emergency unit availability is required',
          subsection: 'Section 1.4 - Facility Services',
        );
      }

      if (facilityServices.hasIcuOrHighDependencyUnit == null) {
        return const ValidationResultEntity.invalid(
          fieldName: 'ICU/High Dependency Unit',
          message: 'ICU/High dependency unit availability is required',
          subsection: 'Section 1.4 - Facility Services',
        );
      }
    }

    return const ValidationResultEntity.valid();
  }

  ValidationResultEntity _validateAssessmentSection(
    AssessmentFormEntity form,
    String sectionNumber,
  ) {
    try {
      final section = form.sections.firstWhere(
        (s) => s.sectionNumber == sectionNumber,
      );

      // Check if section has items - sections 2, 3, 4 cannot be empty
      if (section.items.isEmpty) {
        return ValidationResultEntity.invalid(
          fieldName: 'Section $sectionNumber',
          message: 'This section must have assessment items',
          subsection: 'Section ${section.sectionNumber} - ${section.title}',
        );
      }

      // Check if any items are rated - if so, all must be rated (no partial completion)
      final ratedItemsCount =
          section.items.where((item) => item.selectedRating != null).length;
      final totalItemsCount = section.items.length;

      if (ratedItemsCount > 0 && ratedItemsCount < totalItemsCount) {
        // Some items rated but not all - find first unrated item
        for (int i = 0; i < section.items.length; i++) {
          final item = section.items[i];
          if (item.selectedRating == null) {
            return ValidationResultEntity.invalid(
              fieldName: item.itemNumber,
              message: 'Please rate this item',
              subsection:
                  'Section ${section.sectionNumber} - ${section.title} - ${item.itemNumber}',
            );
          }
        }
      }

      // For sections 2, 3, 4 - require ALL items to be rated (no bypassing allowed)
      if (ratedItemsCount == 0) {
        return ValidationResultEntity.invalid(
          fieldName: 'Section $sectionNumber',
          message: 'Please complete all ratings in this section',
          subsection: 'Section ${section.sectionNumber} - ${section.title}',
        );
      }

      // Check that ALL items are rated
      for (int i = 0; i < section.items.length; i++) {
        final item = section.items[i];
        if (item.selectedRating == null) {
          return ValidationResultEntity.invalid(
            fieldName: item.itemNumber,
            message: 'Please rate this item',
            subsection:
                'Section ${section.sectionNumber} - ${section.title} - ${item.itemNumber}',
          );
        }
      }

      return const ValidationResultEntity.valid();
    } catch (e) {
      return ValidationResultEntity.invalid(
        fieldName: 'Section $sectionNumber',
        message: 'Section not found or improperly configured',
      );
    }
  }

  /// Helper method to check if a string is null or empty
  /// This addresses the issue where null values bypass validation
  bool _isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Improved email validation that handles null values
  bool _isValidEmail(String? email) {
    if (_isNullOrEmpty(email)) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email!.trim());
  }
}

class ValidateSectionParams extends Equatable {
  final AssessmentFormEntity assessmentForm;
  final int sectionNumber;

  const ValidateSectionParams({
    required this.assessmentForm,
    required this.sectionNumber,
  });

  @override
  List<Object?> get props => [assessmentForm, sectionNumber];
}
