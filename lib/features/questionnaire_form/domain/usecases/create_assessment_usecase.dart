import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

/// Use case for creating a new assessment form
class CreateAssessmentUsecase implements UseCase<AssessmentFormEntity, Params> {
  final AssessmentRepository repository;
  static const _uuid = Uuid();

  CreateAssessmentUsecase(this.repository);

  @override
  Future<Either<Failure, AssessmentFormEntity>> call(Params params) async {
    try {
      // Validate the input parameters
      final validationError = _validateCreationParams(params);
      if (validationError != null) {
        return Left(ValidationFailure(message: validationError));
      }

      // Generate a unique ID for the new assessment
      final assessmentId = _uuid.v4();

      // Create the new assessment entity using the factory method
      final newAssessment = AssessmentFormEntity.create(
        id: assessmentId,
        assessorInfo: params.assessorInfo,
        geoLocation: params.geoLocation,
        facilityIdentification: params.facilityIdentification,
        facilityServices: params.facilityServices,
        sections: params.sections,
        notes: params.notes,
      );

      // Save the new assessment to repository
      final saveResult = await repository.saveAssessment(newAssessment);

      return saveResult.fold(
        (failure) => Left(failure),
        (success) =>
            success
                ? Right(newAssessment)
                : Left(
                  ValidationFailure(
                    message: 'Failed to save the new assessment',
                  ),
                ),
      );
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to create assessment: ${e.toString()}',
        ),
      );
    }
  }

  /// Validates the parameters required for creating a new assessment
  String? _validateCreationParams(Params params) {
    // Validate assessor information
    if (params.assessorInfo.name.isEmpty) {
      return 'Assessor name is required';
    }

    if (params.assessorInfo.email.isEmpty) {
      return 'Assessor email is required';
    }

    // Basic email validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(params.assessorInfo.email)) {
      return 'Assessor email format is invalid';
    }

    // Validate facility identification
    if (params.facilityIdentification.facilityName.isEmpty) {
      return 'Facility name is required';
    }

    if (params.facilityIdentification.facilityCode.isEmpty) {
      return 'Facility code is required';
    }

    // Validate geolocation
    if (params.geoLocation.country.isEmpty) {
      return 'Country is required';
    }

    if (params.geoLocation.regionProvince.isEmpty) {
      return 'Region/Province is required';
    }

    // Validate sections
    if (params.sections.isEmpty) {
      return 'Assessment must have at least one section';
    }

    // Validate that each section has items
    for (final section in params.sections) {
      if (section.items.isEmpty) {
        return 'Section "${section.title}" must have at least one item';
      }
    }

    // Additional business validations can be added here
    // For example:
    // - Assessment date should not be in the future
    // - Facility type combinations should be valid
    // - Required sections must be present

    return null; // No validation errors
  }
}

/// Parameters for the CreateAssessment use case
class Params extends Equatable {
  final AssessorInfoEntity assessorInfo;
  final GeoLocationEntity geoLocation;
  final FacilityIdentificationEntity facilityIdentification;
  final FacilityServicesEntity facilityServices;
  final List<AssessmentSectionEntity> sections;
  final String? notes;

  const Params({
    required this.assessorInfo,
    required this.geoLocation,
    required this.facilityIdentification,
    required this.facilityServices,
    required this.sections,
    this.notes,
  });

  @override
  List<Object?> get props => [
    assessorInfo,
    geoLocation,
    facilityIdentification,
    facilityServices,
    sections,
    notes,
  ];
}
