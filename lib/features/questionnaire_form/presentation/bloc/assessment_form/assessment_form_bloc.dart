import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/export_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_assessment_usecase.dart'
    as get_assessment;
import 'package:treatment_center/features/questionnaire_form/domain/usecases/save_assessment_usecase.dart'
    as save_assessment;
import 'package:treatment_center/features/questionnaire_form/domain/usecases/submit_assessment_via_firebase_email_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/validate_section_usecase.dart';
import 'package:uuid/uuid.dart';

import 'assessment_form_event.dart';
import 'assessment_form_state.dart';

class AssessmentFormBloc
    extends Bloc<AssessmentFormEvent, AssessmentFormState> {
  final get_assessment.GetAssessmentUsecase getAssessment;
  final save_assessment.SaveAssessmentUsecase saveAssessment;
  final ValidateSectionUsecase validateSection;
  final ExportAssessmentUsecase? exportAssessment;
  final SubmitAssessmentViaFirebaseEmailUsecase? submitFirebaseEmail;
  final GetExportStatistics? getExportStatistics;
  final ValidateAssessmentForExport? validateAssessmentForExport;
  final _uuid = const Uuid();

  String? _currentFormId;
  bool _isInitialized = false;
  Timer? _saveDebounceTimer;

  AssessmentFormBloc({
    required this.getAssessment,
    required this.saveAssessment,
    required this.validateSection,
    this.exportAssessment,
    this.submitFirebaseEmail,
    this.getExportStatistics,
    this.validateAssessmentForExport,
  }) : super(const AssessmentFormInitial()) {
    on<InitializeAssessmentForm>(_onInitializeAssessmentForm);
    on<UpdateAssessmentForm>(_onUpdateAssessmentForm);
    on<SaveAssessmentForm>(_onSaveAssessmentForm);
    on<NavigateToStep>(_onNavigateToStep);
    on<NavigateToNextStep>(_onNavigateToNextStep);
    on<NavigateToPreviousStep>(_onNavigateToPreviousStep);
    on<ValidateCurrentSection>(_onValidateCurrentSection);
    on<CompleteAssessment>(_onCompleteAssessment);
    on<CompleteAssessmentOnly>(_onCompleteAssessmentOnly);
    on<SubmitAssessmentViaEmail>(_onSubmitAssessmentViaEmail);
    on<ExportAssessment>(_onExportAssessment);
    on<LoadExportHistory>(_onLoadExportHistory);
    on<ShareExportedFile>(_onShareExportedFile);
    on<DeleteExportedFile>(_onDeleteExportedFile);
    on<ClearUnsavedChanges>(_onClearUnsavedChanges);
    on<MarkFormAsChanged>(_onMarkFormAsChanged);
    on<ShowExportDialog>(_onShowExportDialog);
    on<HideExportDialog>(_onHideExportDialog);
    on<ShowCompletionDialog>(_onShowCompletionDialog);
    on<HideCompletionDialog>(_onHideCompletionDialog);
  }

  @override
  Future<void> close() {
    _saveDebounceTimer?.cancel();
    return super.close();
  }

  Future<void> _onInitializeAssessmentForm(
    InitializeAssessmentForm event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (_isInitialized && event.assessmentId == _currentFormId) {
      return;
    }

    _currentFormId = event.assessmentId;
    _isInitialized = false;

    emit(const AssessmentFormLoaded(isInitializing: true));

    try {
      final exportHistory = await _loadExportHistory();

      if (event.assessmentId != null) {
        final result = await getAssessment.call(
          get_assessment.Params(assessmentId: event.assessmentId!),
        );

        result.fold(
          (failure) {
            emit(
              AssessmentFormInitializationError(
                message: 'Failed to load assessment: ${failure.message}',
              ),
            );
          },
          (assessment) {
            if (assessment.id == _currentFormId) {
              final fixedAssessment = _ensureProperSectionsStructure(
                assessment,
              );

              _isInitialized = true;
              emit(
                AssessmentFormLoaded(
                  assessmentForm: fixedAssessment,
                  isEditMode: true,
                  exportHistory: exportHistory,
                  isInitializing: false,
                ),
              );
            } else {
              emit(
                AssessmentFormInitializationError(
                  message: 'Form ID mismatch during loading',
                ),
              );
            }
          },
        );
      } else {
        final newAssessment = _createEmptyForm();

        _currentFormId = newAssessment.id;
        _isInitialized = true;

        emit(
          AssessmentFormLoaded(
            assessmentForm: newAssessment,
            isEditMode: false,
            exportHistory: exportHistory,
            isInitializing: false,
          ),
        );
      }
    } catch (e) {
      emit(
        AssessmentFormInitializationError(
          message: 'Unexpected error loading assessment: $e',
        ),
      );
    }
  }

  AssessmentFormEntity _ensureProperSectionsStructure(
    AssessmentFormEntity assessment,
  ) {
    final sectionMap = {
      for (final s in assessment.sections) s.sectionNumber: s,
    };

    final finalSections = <AssessmentSectionEntity>[];

    // Add sections 1, 2, 3, 4 (create empty ones if missing)
    for (final sectionNum in ["1", "2", "3", "4"]) {
      if (sectionMap.containsKey(sectionNum)) {
        final existingSection = sectionMap[sectionNum]!;
        if (sectionNum == "1") {
          final updatedSection1 = _ensureSection1Items(
            existingSection,
            assessment,
          );
          finalSections.add(updatedSection1);
        } else {
          finalSections.add(existingSection);
        }
      } else {
        finalSections.add(_createEmptySection(sectionNum, assessment));
      }
    }

    return assessment.copyWith(sections: finalSections);
  }

  AssessmentSectionEntity _ensureSection1Items(
    AssessmentSectionEntity section1,
    AssessmentFormEntity form,
  ) {
    final expectedItems = <AssessmentItemEntity>[];

    if (section1.items.isEmpty) {
      return section1.copyWith(items: expectedItems);
    }

    final updatedItems =
        section1.items.map((item) {
          final autoRating = _getAutoRatingForSection1Item(
            item.itemNumber,
            form,
          );
          return item.copyWith(selectedRating: autoRating);
        }).toList();

    return section1.copyWith(items: updatedItems);
  }

  void _onUpdateAssessmentForm(
    UpdateAssessmentForm event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (!_isInitialized) {
      return;
    }

    if (event.updatedForm.id != _currentFormId) {
      return;
    }

    if (state is AssessmentFormLoaded) {
      final currentState = state as AssessmentFormLoaded;

      final validatedForm = _validateFormUpdate(
        currentState.assessmentForm,
        event.updatedForm,
      );

      if (validatedForm != null) {
        emit(
          currentState.copyWith(
            assessmentForm: validatedForm,
            hasUnsavedChanges: true,
            clearValidationError: true,
            clearLastSaveResult: true,
          ),
        );
      }
    }
  }

  Future<ValidationResultEntity> _validateCurrentSectionWithUseCase(
    int sectionNumber,
  ) async {
    if (state is! AssessmentFormLoaded) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Form State',
        message: 'Form is not properly loaded',
      );
    }

    final currentState = state as AssessmentFormLoaded;
    final form = currentState.assessmentForm;
    if (form == null) {
      return const ValidationResultEntity.invalid(
        fieldName: 'Assessment Form',
        message: 'Assessment form is not available',
      );
    }

    final result = await validateSection.call(
      ValidateSectionParams(assessmentForm: form, sectionNumber: sectionNumber),
    );

    return result.fold(
      (failure) => ValidationResultEntity.invalid(
        fieldName: 'Validation Error',
        message: failure.message,
      ),
      (validationResult) => validationResult,
    );
  }

  AssessmentFormEntity? _validateFormUpdate(
    AssessmentFormEntity? currentForm,
    AssessmentFormEntity updatedForm,
  ) {
    if (currentForm == null) return null;
    if (currentForm.id != updatedForm.id) return null;

    final currentSectionMap = {
      for (final s in currentForm.sections) s.sectionNumber: s,
    };
    final updatedSectionMap = {
      for (final s in updatedForm.sections) s.sectionNumber: s,
    };
    final allSectionNumbers =
        <String>{...currentSectionMap.keys, ...updatedSectionMap.keys}.toList()
          ..sort();
    final mergedSections = <AssessmentSectionEntity>[];
    for (final n in allSectionNumbers) {
      final upd = updatedSectionMap[n];
      final cur = currentSectionMap[n];
      if (upd != null) {
        if (n == "1") {
          final updatedSection1 = _updateSection1WithFormData(upd, updatedForm);
          mergedSections.add(updatedSection1);
        } else {
          mergedSections.add(upd);
        }
      } else if (cur != null) {
        mergedSections.add(cur);
      }
    }

    AssessorInfoEntity pickAssessor() {
      final u = updatedForm.assessorInfo;
      final c = currentForm.assessorInfo;
      return AssessorInfoEntity(
        name: u.name,
        email: u.email,
        phoneNumber: u.phoneNumber,
        assessmentDate: u.assessmentDate ?? c.assessmentDate,
      );
    }

    GeoLocationEntity pickGeo() {
      final u = updatedForm.geoLocation;
      final c = currentForm.geoLocation;
      return GeoLocationEntity(
        country: u.country,
        regionProvince: u.regionProvince,
        cityVillage: u.cityVillage,
        district: u.district,
        addressOrCoordinates: u.addressOrCoordinates,
        latitude: u.latitude ?? c.latitude,
        longitude: u.longitude ?? c.longitude,
        locationType: u.locationType ?? c.locationType,
      );
    }

    FacilityIdentificationEntity pickFacilityId() {
      final u = updatedForm.facilityIdentification;
      final c = currentForm.facilityIdentification;

      final effFacilityType = u.facilityType ?? c.facilityType;

      final effExistingFacilityType = () {
        if (effFacilityType == FacilityType.screeningAndTemporaryIsolation) {
          return u.existingFacilityType ?? c.existingFacilityType;
        }
        return null;
      }();

      return FacilityIdentificationEntity(
        facilityCode: u.facilityCode,
        facilityName: u.facilityName,
        managingAuthority: u.managingAuthority ?? c.managingAuthority,
        otherManagingAuthority:
            u.otherManagingAuthority ?? c.otherManagingAuthority,
        directorName: u.directorName,
        directorPhone: u.directorPhone,
        directorEmail: u.directorEmail,
        respondentName: u.respondentName,
        respondentPosition: u.respondentPosition,
        structureType: u.structureType ?? c.structureType,
        facilityType: effFacilityType,
        existingFacilityType: effExistingFacilityType,
      );
    }

    FacilityServicesEntity pickServices() {
      final u = updatedForm.facilityServices;
      final c = currentForm.facilityServices;

      return FacilityServicesEntity(
        hasOutpatientServices:
            u.hasOutpatientServices ?? c.hasOutpatientServices,
        hasInpatientServices: u.hasInpatientServices ?? c.hasInpatientServices,
        totalInpatientBeds: u.totalInpatientBeds ?? c.totalInpatientBeds,
        icuBeds: u.icuBeds ?? c.icuBeds,
        hasEmergencyUnit: u.hasEmergencyUnit ?? c.hasEmergencyUnit,
        hasIcuOrHighDependencyUnit:
            u.hasIcuOrHighDependencyUnit ?? c.hasIcuOrHighDependencyUnit,
      );
    }

    List<PhotoEntity> pickPhotos() {
      final u = updatedForm.photos;
      final c = currentForm.photos;
      if (u.isEmpty && c.isNotEmpty) return const [];
      if (u.isNotEmpty) return u;
      return c;
    }

    final next = AssessmentFormEntity(
      id: currentForm.id,
      assessorInfo: pickAssessor(),
      geoLocation: pickGeo(),
      facilityIdentification: pickFacilityId(),
      facilityServices: pickServices(),
      sections: mergedSections,
      photos: pickPhotos(),
      notes: updatedForm.notes ?? currentForm.notes,
      isSubmitted: updatedForm.isSubmitted || currentForm.isSubmitted,
      submissionDate: updatedForm.submissionDate ?? currentForm.submissionDate,
      createdAt: currentForm.createdAt,
      updatedAt: DateTime.now(),
    );

    return next;
  }

  AssessmentSectionEntity _updateSection1WithFormData(
    AssessmentSectionEntity section1,
    AssessmentFormEntity form,
  ) {
    final updatedItems =
        section1.items.map((item) {
          final autoRating = _getAutoRatingForSection1Item(
            item.itemNumber,
            form,
          );
          return item.copyWith(selectedRating: autoRating);
        }).toList();

    return section1.copyWith(items: updatedItems);
  }

  AssessmentRatingEntity? _getAutoRatingForSection1Item(
    String itemNumber,
    AssessmentFormEntity form,
  ) {
    switch (itemNumber) {
      case '1.1.1':
        return _evaluateAssessorInfo(form.assessorInfo);
      case '1.2.1':
        return _evaluateGeoLocation(form.geoLocation);
      case '1.3.1':
        return _evaluateFacilityId(form.facilityIdentification);
      case '1.4.1':
        return _evaluateFacilityServices(form.facilityServices);
      default:
        return null;
    }
  }

  AssessmentRatingEntity? _evaluateAssessorInfo(AssessorInfoEntity info) {
    final hasName = info.name.trim().isNotEmpty;
    final hasEmail = info.email.trim().isNotEmpty;
    final hasPhone = info.phoneNumber.trim().isNotEmpty;
    final hasDate = info.assessmentDate != null;

    final completeCount =
        [hasName, hasEmail, hasPhone, hasDate].where((x) => x).length;

    if (completeCount == 4) return AssessmentRatingEntity.meetsTarget();
    if (completeCount >= 2) {
      return AssessmentRatingEntity.partiallyMeetsTarget();
    }
    return AssessmentRatingEntity.doesNotMeetTarget();
  }

  AssessmentRatingEntity? _evaluateGeoLocation(GeoLocationEntity geo) {
    final hasCountry = geo.country.trim().isNotEmpty;
    final hasRegion = geo.regionProvince.trim().isNotEmpty;
    final hasAddress = geo.addressOrCoordinates.trim().isNotEmpty;
    final hasCoords = geo.latitude != null && geo.longitude != null;
    final hasLocationType = geo.locationType != null;

    final completeCount =
        [
          hasCountry,
          hasRegion,
          hasAddress,
          hasCoords,
          hasLocationType,
        ].where((x) => x).length;

    if (completeCount >= 4) return AssessmentRatingEntity.meetsTarget();
    if (completeCount >= 2) {
      return AssessmentRatingEntity.partiallyMeetsTarget();
    }
    return AssessmentRatingEntity.doesNotMeetTarget();
  }

  AssessmentRatingEntity? _evaluateFacilityId(
    FacilityIdentificationEntity facility,
  ) {
    final hasCode = facility.facilityCode.trim().isNotEmpty;
    final hasName = facility.facilityName.trim().isNotEmpty;
    final hasAuthority = facility.managingAuthority != null;
    final hasDirector = facility.directorName.trim().isNotEmpty;
    final hasStructure = facility.structureType != null;
    final hasFacilityType = facility.facilityType != null;

    final completeCount =
        [
          hasCode,
          hasName,
          hasAuthority,
          hasDirector,
          hasStructure,
          hasFacilityType,
        ].where((x) => x).length;

    if (completeCount >= 5) return AssessmentRatingEntity.meetsTarget();
    if (completeCount >= 3) {
      return AssessmentRatingEntity.partiallyMeetsTarget();
    }
    return AssessmentRatingEntity.doesNotMeetTarget();
  }

  AssessmentRatingEntity? _evaluateFacilityServices(
    FacilityServicesEntity services,
  ) {
    final hasOutpatient = services.hasOutpatientServices != null;
    final hasInpatient = services.hasInpatientServices != null;

    if (!hasOutpatient && !hasInpatient) {
      return AssessmentRatingEntity.doesNotMeetTarget();
    }

    if (services.hasInpatientServices == true) {
      final hasBeds = services.totalInpatientBeds != null;
      final hasEmergency = services.hasEmergencyUnit != null;
      if (hasOutpatient && hasInpatient && hasBeds && hasEmergency) {
        return AssessmentRatingEntity.meetsTarget();
      }
      return AssessmentRatingEntity.partiallyMeetsTarget();
    }

    return hasOutpatient
        ? AssessmentRatingEntity.meetsTarget()
        : AssessmentRatingEntity.partiallyMeetsTarget();
  }

  Future<void> _onSaveAssessmentForm(
    SaveAssessmentForm event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;
    if (currentState.assessmentForm == null) return;

    if (currentState.assessmentForm!.id != _currentFormId) {
      return;
    }

    emit(currentState.copyWith(isSaving: true, clearLastSaveResult: true));

    try {
      final result = await saveAssessment.call(
        save_assessment.Params(assessment: currentState.assessmentForm!),
      );

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              isSaving: false,
              lastSaveResult: 'Failed to save: ${failure.message}',
            ),
          );
        },
        (success) {
          if (success) {
            emit(
              currentState.copyWith(
                isSaving: false,
                hasUnsavedChanges: false,
                lastSaveResult: 'Assessment saved successfully',
              ),
            );
          } else {
            emit(
              currentState.copyWith(
                isSaving: false,
                lastSaveResult: 'Failed to save: Unknown error',
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSaving: false,
          lastSaveResult: 'Unexpected error saving: $e',
        ),
      );
    }
  }

  void _onNavigateToStep(
    NavigateToStep event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;

    if (!currentState.canNavigate) return;

    if (event.step >= 1 && event.step <= currentState.totalSteps) {
      emit(
        currentState.copyWith(
          currentStep: event.step,
          clearValidationError: true,
        ),
      );
    }
  }

  Future<void> _onNavigateToNextStep(
    NavigateToNextStep event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;

    if (!currentState.canGoToNextStep) return;

    final validationResult = await _validateCurrentSectionWithUseCase(
      currentState.currentStep,
    );

    if (!validationResult.isValid) {
      emit(
        currentState.copyWith(validationError: validationResult.userMessage),
      );
      return;
    }

    emit(
      currentState.copyWith(
        currentStep: currentState.currentStep + 1,
        clearValidationError: true,
      ),
    );
  }

  void _onNavigateToPreviousStep(
    NavigateToPreviousStep event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;

    if (!currentState.canGoToPreviousStep) return;

    emit(
      currentState.copyWith(
        currentStep: currentState.currentStep - 1,
        clearValidationError: true,
      ),
    );
  }

  Future<void> _onValidateCurrentSection(
    ValidateCurrentSection event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;

    emit(currentState.copyWith(isValidating: true));

    final validationResult = await _validateCurrentSectionWithUseCase(
      currentState.currentStep,
    );

    if (validationResult.isValid) {
      emit(
        currentState.copyWith(isValidating: false, clearValidationError: true),
      );
    } else {
      emit(
        currentState.copyWith(
          isValidating: false,
          validationError: validationResult.userMessage,
        ),
      );
    }
  }

  Future<void> _onCompleteAssessment(
    CompleteAssessment event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;
    if (currentState.assessmentForm == null) return;

    final form = currentState.assessmentForm!;

    final allSectionsValid = await _validateAllSections(form);

    if (!allSectionsValid.isValid) {
      emit(
        currentState.copyWith(validationError: allSectionsValid.userMessage),
      );
      return;
    }

    emit(currentState.copyWith(lastSaveResult: 'show_completion_dialog'));
  }

  Future<ValidationResultEntity> _validateAllSections(
    AssessmentFormEntity form,
  ) async {
    for (int sectionNum = 1; sectionNum <= 4; sectionNum++) {
      final result = await validateSection.call(
        ValidateSectionParams(assessmentForm: form, sectionNumber: sectionNum),
      );

      final validationResult = result.fold(
        (failure) => ValidationResultEntity.invalid(
          fieldName: 'Section $sectionNum',
          message: failure.message,
        ),
        (validationResult) => validationResult,
      );

      if (!validationResult.isValid) {
        return validationResult;
      }
    }

    return const ValidationResultEntity.valid();
  }

  Future<void> _onCompleteAssessmentOnly(
    CompleteAssessmentOnly event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;
    if (currentState.assessmentForm == null) return;

    emit(currentState.copyWith(isSaving: true));

    try {
      final result = await saveAssessment.call(
        save_assessment.Params(assessment: currentState.assessmentForm!),
      );

      result.fold(
        (failure) => emit(
          currentState.copyWith(
            isSaving: false,
            lastSaveResult: 'Failed to save: ${failure.message}',
          ),
        ),
        (success) {
          if (success) {
            final completedAssessment = currentState.assessmentForm!.copyWith();

            emit(
              currentState.copyWith(
                isSaving: false,
                assessmentForm: completedAssessment,
                hasUnsavedChanges: false,
                lastSaveResult:
                    'Assessment completed successfully! Ready for submission.',
              ),
            );
          } else {
            emit(
              currentState.copyWith(
                isSaving: false,
                lastSaveResult: 'Failed to complete: Unknown error',
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSaving: false,
          lastSaveResult: 'Unexpected error completing: $e',
        ),
      );
    }
  }

  Future<void> _onSubmitAssessmentViaEmail(
    SubmitAssessmentViaEmail event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;
    if (currentState.assessmentForm == null || submitFirebaseEmail == null) {
      emit(
        currentState.copyWith(
          lastSubmissionResult: 'Firebase email service not available',
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        isSubmittingEmail: true,
        clearLastSubmissionResult: true,
      ),
    );

    try {
      final extracted = _extractPhotoPaths(currentState.assessmentForm);
      final photoPaths = (event.photoFilePaths.isNotEmpty
              ? event.photoFilePaths
              : extracted)
          .toList(growable: false);

      final result = await submitFirebaseEmail!.call(
        FirebaseEmailParams(
          assessment: currentState.assessmentForm!,
          recipientEmail: event.recipientEmail,
          exportFormats: event.exportFormats,
          subject: event.customSubject,
          body: event.customBody,
          photoFilePaths: photoPaths,
          exportOptions: ExportOptions(
            includeAnalysis: true,
            includeSectionDetails: true,
            includeSignaturePage: true,
          ),
        ),
      );

      result.fold(
        (failure) => emit(
          currentState.copyWith(
            isSubmittingEmail: false,
            lastSubmissionResult: 'Failed to send email: ${failure.message}',
          ),
        ),
        (success) {
          if (success) {
            final submittedAssessment =
                currentState.assessmentForm!.markAsSubmitted();

            emit(
              currentState.copyWith(
                isSubmittingEmail: false,
                assessmentForm: submittedAssessment,
                hasUnsavedChanges: false,
                lastSubmissionResult:
                    'Assessment submitted via email successfully!',
              ),
            );
          } else {
            emit(
              currentState.copyWith(
                isSubmittingEmail: false,
                lastSubmissionResult: 'Failed to send email: Unknown error',
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSubmittingEmail: false,
          lastSubmissionResult: 'Unexpected error sending email: $e',
        ),
      );
    }
  }

  List<String> _extractPhotoPaths(AssessmentFormEntity? form) {
    if (form == null) return const <String>[];
    return form.photos
        .map((p) => p.filePath)
        .where((String s) => s.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _onExportAssessment(
    ExportAssessment event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;
    if (currentState.assessmentForm == null || exportAssessment == null) {
      emit(
        currentState.copyWith(
          lastSaveResult: 'Export functionality not available',
        ),
      );
      return;
    }

    emit(currentState.copyWith(isExporting: true, clearLastExportResult: true));

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final facilityCode =
          currentState.assessmentForm!.facilityIdentification.facilityCode;
      final sanitizedCode = facilityCode.replaceAll(RegExp(r'[^\w\-_]'), '_');
      final fileExtension = _getFileExtension(event.format);
      final fileName =
          'FVD_Assessment_${sanitizedCode}_$timestamp.$fileExtension';
      String? outputPath;
      if (!kIsWeb) {
        final exportDir = await getExportPath(
          fileName: fileName,
          mimeType: _getMimeType(fileExtension),
        );
        outputPath = '$exportDir/$fileName';
      }

      final exportResult = await exportAssessment!.call(
        ExportAssessmentParams(
          assessment: currentState.assessmentForm!,
          format: event.format,
          outputPath: outputPath,
          options: event.options,
        ),
      );

      switch (exportResult) {
        case Left(value: final failure):
          emit(
            currentState.copyWith(
              isExporting: false,
              lastSaveResult: 'Export failed: ${failure.message}',
            ),
          );
        case Right(value: final result):
          final correctedResult = ExportResult(
            fileName: result.fileName,
            filePath: result.filePath,
            format: _getFormatDisplayName(event.format),
            fileSizeBytes: result.fileSizeBytes,
            createdAt: result.createdAt,
            metadata: result.metadata,
          );

          emit(
            currentState.copyWith(
              isExporting: false,
              lastExportResult: correctedResult,
              exportHistory: [...currentState.exportHistory, correctedResult],
            ),
          );

          unawaited(_saveExportToHistory(correctedResult));
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isExporting: false,
          lastSaveResult: 'Unexpected error during export: $e',
        ),
      );
    }
  }

  String _getFileExtension(String format) {
    return switch (format.toLowerCase()) {
      'excel' || 'xlsx' => 'xlsx',
      'docx' || 'doc' || 'word' => 'docx',
      'pdf' || _ => 'pdf',
    };
  }

  String _getFormatDisplayName(String format) {
    switch (format.toLowerCase()) {
      case 'excel':
      case 'xlsx':
        return 'Microsoft Excel';
      case 'docx':
      case 'doc':
      case 'word':
        return 'Microsoft Word';
      case 'pdf':
      default:
        return 'Adobe PDF';
    }
  }

  Future<void> _onLoadExportHistory(
    LoadExportHistory event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;

    try {
      final exportHistory = await _loadExportHistory();
      emit(currentState.copyWith(exportHistory: exportHistory));
    } catch (e) {
      emit(
        currentState.copyWith(
          lastSaveResult: 'Failed to load export history: $e',
        ),
      );
    }
  }

  Future<void> _onShareExportedFile(
    ShareExportedFile event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;

    try {
      final file = io.File(event.file.filePath);
      if (kIsWeb) {
        try {
          final exportResult = event.file;
          final fileName = exportResult.fileName;
          await SharePlus.instance.share(
            ShareParams(
              text:
                  'Here\'s your FVD Assessment Report – '
                  '${currentState.assessmentForm?.facilityIdentification.facilityName ?? "Assessment"}. '
                  'Attach the file "$fileName" to share this report with others.',
              subject: 'Assessment Report',
            ),
          );
          emit(
            currentState.copyWith(lastSaveResult: 'Text shared successfully'),
          );
        } catch (e) {
          emit(
            currentState.copyWith(lastSaveResult: 'Failed to fetch/share: $e'),
          );
        }
        return;
      }

      if (await file.exists()) {
        final params = ShareParams(
          files: [XFile(event.file.filePath)],
          text:
              'FVD Assessment Report - ${currentState.assessmentForm?.facilityIdentification.facilityName ?? "Assessment"}',
          subject: 'Assessment Report',
        );

        await SharePlus.instance.share(params);

        emit(currentState.copyWith(lastSaveResult: 'File shared successfully'));
      } else {
        emit(
          currentState.copyWith(
            lastSaveResult:
                'File not found. It may have been moved or deleted.',
          ),
        );
      }
    } catch (e) {
      emit(currentState.copyWith(lastSaveResult: 'Failed to share file: $e'));
    }
  }

  Future<void> _onDeleteExportedFile(
    DeleteExportedFile event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (state is! AssessmentFormLoaded) return;

    final currentState = state as AssessmentFormLoaded;

    try {
      final fileToDelete = io.File(event.file.filePath);

      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }

      final updatedHistory = List<ExportResult>.from(
        currentState.exportHistory,
      );
      updatedHistory.removeAt(event.index);

      await _updateExportHistoryInStorage(updatedHistory);

      emit(
        currentState.copyWith(
          exportHistory: updatedHistory,
          lastSaveResult: 'File deleted successfully',
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(lastSaveResult: 'Failed to delete file: $e'));
    }
  }

  void _onClearUnsavedChanges(
    ClearUnsavedChanges event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is AssessmentFormLoaded) {
      final currentState = state as AssessmentFormLoaded;
      emit(currentState.copyWith(hasUnsavedChanges: false));
    }
  }

  void _onMarkFormAsChanged(
    MarkFormAsChanged event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is AssessmentFormLoaded) {
      final currentState = state as AssessmentFormLoaded;
      emit(currentState.copyWith(hasUnsavedChanges: true));
    }
  }

  void _onShowExportDialog(
    ShowExportDialog event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is AssessmentFormLoaded) {
      final currentState = state as AssessmentFormLoaded;
      emit(currentState.copyWith(lastSaveResult: 'show_export_dialog'));
    }
  }

  void _onHideExportDialog(
    HideExportDialog event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is AssessmentFormLoaded) {
      final currentState = state as AssessmentFormLoaded;
      emit(currentState.copyWith(clearLastSaveResult: true));
    }
  }

  void _onShowCompletionDialog(
    ShowCompletionDialog event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is AssessmentFormLoaded) {
      final currentState = state as AssessmentFormLoaded;
      emit(currentState.copyWith(lastSaveResult: 'show_completion_dialog'));
    }
  }

  void _onHideCompletionDialog(
    HideCompletionDialog event,
    Emitter<AssessmentFormState> emit,
  ) {
    if (state is AssessmentFormLoaded) {
      final currentState = state as AssessmentFormLoaded;
      emit(currentState.copyWith(clearLastSaveResult: true));
    }
  }

  // Helper Methods

  AssessmentFormEntity _createEmptyForm() {
    final uuid = _uuid.v4();
    return AssessmentFormEntity(
      id: uuid,
      assessorInfo: AssessorInfoEntity(
        name: '',
        email: '',
        phoneNumber: '',
        assessmentDate: null,
      ),
      geoLocation: GeoLocationEntity(
        country: '',
        regionProvince: '',
        district: '',
        cityVillage: '',
        addressOrCoordinates: '',
        locationType: null,
      ),
      facilityIdentification: FacilityIdentificationEntity(
        facilityCode: '',
        facilityName: '',
        managingAuthority: null,
        directorName: '',
        directorPhone: '',
        directorEmail: '',
        respondentName: '',
        respondentPosition: '',
        structureType: null,
        facilityType: null,
        existingFacilityType: null,
      ),
      facilityServices: FacilityServicesEntity(
        hasOutpatientServices: false,
        hasInpatientServices: false,
        totalInpatientBeds: null,
        icuBeds: null,
        hasEmergencyUnit: null,
        hasIcuOrHighDependencyUnit: null,
      ),
      sections: _createEmptySections(),
      photos: const [],
      isSubmitted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<AssessmentSectionEntity> _createEmptySections() {
    final uuid = Uuid();

    return [
      AssessmentSectionEntity(
        id: uuid.v4(),
        sectionNumber: "1",
        title: "Facility Information Assessment",
        description:
            "Assessment of facility information completeness and accuracy",
        items: <AssessmentItemEntity>[],
      ),
      AssessmentSectionEntity(
        id: uuid.v4(),
        sectionNumber: "2",
        title: "Overall Facility Assessment",
        description: "Overall facility assessment",
        items: [],
      ),
      AssessmentSectionEntity(
        id: uuid.v4(),
        sectionNumber: "3",
        title: "Screening with Temporary Isolation",
        description: "Screening and isolation capabilities",
        items: [],
      ),
      AssessmentSectionEntity(
        id: uuid.v4(),
        sectionNumber: "4",
        title: "FVD Stand-alone Treatment Centre",
        description: "Treatment center facilities",
        items: [],
      ),
    ];
  }

  AssessmentSectionEntity _createEmptySection(
    String sectionNumber, [
    AssessmentFormEntity? form,
  ]) {
    final titles = {
      "1": "Facility Information Assessment",
      "2": "Overall Facility Assessment",
      "3": "Screening with Temporary Isolation",
      "4": "FVD Stand-alone Treatment Centre",
    };

    final descriptions = {
      "1": "Assessment of facility information completeness and accuracy",
      "2": "Overall facility assessment",
      "3": "Screening and isolation capabilities",
      "4": "Treatment center facilities",
    };

    final items =
        sectionNumber == "1"
            ? <AssessmentItemEntity>[]
            : <AssessmentItemEntity>[];

    final finalItems =
        (sectionNumber == "1" && form != null)
            ? items.map((item) {
              final autoRating = _getAutoRatingForSection1Item(
                item.itemNumber,
                form,
              );
              return item.copyWith(selectedRating: autoRating);
            }).toList()
            : items;

    return AssessmentSectionEntity(
      id: _uuid.v4(),
      sectionNumber: sectionNumber,
      title: titles[sectionNumber] ?? "Section $sectionNumber",
      description: descriptions[sectionNumber] ?? "",
      items: finalItems,
    );
  }

  Future<List<ExportResult>> _loadExportHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('export_history');

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.map((item) {
          return ExportResult(
            fileName: item['fileName'] ?? '',
            filePath: item['filePath'] ?? '',
            format: item['format'] ?? '',
            createdAt: DateTime.parse(
              item['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
            metadata:
                item['metadata'] != null
                    ? Map<String, dynamic>.from(item['metadata'])
                    : null,
            fileSizeBytes: item['fileSize'] ?? 0,
          );
        }).toList();
      }
    } catch (e) {
      // Return empty list on error
    }
    return [];
  }

  Future<void> _saveExportToHistory(ExportResult result) async {
    try {
      final currentHistory = await _loadExportHistory();
      final updatedHistory = [result, ...currentHistory];
      await _updateExportHistoryInStorage(updatedHistory);
    } catch (e) {
      // Ignore storage errors
    }
  }

  Future<void> _updateExportHistoryInStorage(List<ExportResult> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList =
          history
              .map(
                (file) => {
                  'fileName': file.fileName,
                  'filePath': file.filePath,
                  'format': file.format,
                  'createdAt': file.createdAt.toIso8601String(),
                  'metadata': file.metadata,
                  'fileSize': file.fileSizeBytes,
                },
              )
              .toList();

      await prefs.setString('export_history', json.encode(historyList));
    } catch (e) {
      // Ignore storage errors
    }
  }

  Future<String> getExportPath({
    required String fileName,
    required String mimeType,
    Uint8List? bytes,
  }) async {
    if (kIsWeb) {
      if (bytes == null) {
        throw ArgumentError('bytes are required when saving a file on the web');
      }

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save "$fileName"',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: [fileName.split('.').last],
      );

      if (savedPath == null) {
        throw Exception('Save operation cancelled by the user.');
      }
      return savedPath;
    }

    try {
      final docDir = await path_provider.getApplicationDocumentsDirectory();
      final exportDir = io.Directory('${docDir.path}/FVD_Assessments');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);
      return exportDir.path;
    } catch (_) {
      final tmp = await path_provider.getTemporaryDirectory();
      return tmp.path;
    }
  }

  String _getMimeType(String ext) => switch (ext) {
    'pdf' => 'application/pdf',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ => 'application/octet-stream',
  };
}
