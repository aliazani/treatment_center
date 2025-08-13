import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_state.dart';

void main() {
  final dummyForm = AssessmentFormEntity(
    id: 'id',
    sections: const [],
    assessorInfo: const AssessorInfoEntity(
      name: 'n',
      email: 'e',
      phoneNumber: '',
      assessmentDate: null,
    ),
    isSubmitted: false,
    geoLocation: const GeoLocationEntity(
      country: '',
      regionProvince: '',
      district: '',
      cityVillage: '',
      addressOrCoordinates: '',
      locationType: FacilityLocationType.periUrban,
    ),
    facilityIdentification: const FacilityIdentificationEntity(
      facilityCode: '',
      facilityName: '',
      managingAuthority: ManagingAuthorityType.government,
      directorName: '',
      directorPhone: '',
      directorEmail: '',
      respondentName: '',
      respondentPosition: '',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.screeningAndTemporaryIsolation,
    ),
    facilityServices: const FacilityServicesEntity(
      hasOutpatientServices: false,
      hasInpatientServices: false,
    ),
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  // Dummy export objects:
  final dummyResult = ExportResult(
    filePath: 'path',
    fileName: '',
    format: '',
    fileSizeBytes: 2048,
    createdAt: DateTime.now(),
  );

  group('Basic Equatable & props', () {
    test('AssessmentFormInitial is equal & has no props', () {
      const s1 = AssessmentFormInitial();
      const s2 = AssessmentFormInitial();
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1.props, isEmpty);
    });

    test('AssessmentFormInitializationError props & equality', () {
      const m1 = 'err1';
      const m2 = 'err2';
      final e1 = const AssessmentFormInitializationError(message: m1);
      final e2 = const AssessmentFormInitializationError(message: m1);
      final e3 = const AssessmentFormInitializationError(message: m2);

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
      expect(e1, isNot(equals(e3)));
      expect(e1.props, equals([m1]));
    });

    test('AssessmentFormSaveError props & equality', () {
      const m1 = 'saveErr';
      const m2 = 'saveErr2';
      final e1 = AssessmentFormSaveError(
        message: m1,
        assessmentForm: dummyForm,
        currentStep: 3,
      );
      final e2 = AssessmentFormSaveError(
        message: m1,
        assessmentForm: dummyForm,
        currentStep: 3,
      );
      final e3 = AssessmentFormSaveError(
        message: m2,
        assessmentForm: dummyForm,
        currentStep: 3,
      );

      expect(e1, equals(e2));
      expect(e1, isNot(equals(e3)));
      expect(e1.props, equals([m1, dummyForm, 3]));
    });

    test('AssessmentFormExportError props & equality', () {
      const msg = 'expErr';
      final s1 = AssessmentFormExportError(
        message: msg,
        assessmentForm: dummyForm,
      );
      final s2 = AssessmentFormExportError(
        message: msg,
        assessmentForm: dummyForm,
      );
      final s3 = AssessmentFormExportError(
        message: 'other',
        assessmentForm: dummyForm,
      );

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
      expect(s1.props, equals([msg, dummyForm]));
    });

    test('AssessmentFormSubmissionError props & equality', () {
      const msg = 'subErr';
      final s1 = AssessmentFormSubmissionError(
        message: msg,
        assessmentForm: dummyForm,
      );
      final s2 = AssessmentFormSubmissionError(
        message: msg,
        assessmentForm: dummyForm,
      );
      final s3 = AssessmentFormSubmissionError(
        message: 'other',
        assessmentForm: dummyForm,
      );

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
      expect(s1.props, equals([msg, dummyForm]));
    });

    test('AssessmentFormSaved props & equality', () {
      const msg = 'saved';
      final s1 = AssessmentFormSaved(message: msg, assessmentForm: dummyForm);
      final s2 = AssessmentFormSaved(message: msg, assessmentForm: dummyForm);
      final s3 = AssessmentFormSaved(message: 'x', assessmentForm: dummyForm);

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
      expect(s1.props, equals([msg, dummyForm]));
    });

    test('AssessmentFormExported props & equality', () {
      final e1 = AssessmentFormExported(
        exportResult: dummyResult,
        assessmentForm: dummyForm,
      );
      final e2 = AssessmentFormExported(
        exportResult: dummyResult,
        assessmentForm: dummyForm,
      );
      final e3 = AssessmentFormExported(
        exportResult: ExportResult(
          filePath: 'diff',
          fileName: '',
          format: '',
          fileSizeBytes: 3048,
          createdAt: DateTime.now(),
        ),
        assessmentForm: dummyForm,
      );

      expect(e1, equals(e2));
      expect(e1, isNot(equals(e3)));
      expect(e1.props, equals([dummyResult, dummyForm]));
    });

    test('AssessmentFormSubmitted props & equality', () {
      const msg = 'ok';
      final s1 = AssessmentFormSubmitted(
        message: msg,
        assessmentForm: dummyForm,
      );
      final s2 = AssessmentFormSubmitted(
        message: msg,
        assessmentForm: dummyForm,
      );
      final s3 = AssessmentFormSubmitted(
        message: 'no',
        assessmentForm: dummyForm,
      );

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
      expect(s1.props, equals([msg, dummyForm]));
    });

    test('AssessmentFormValidationError props & equality', () {
      const msg = 'valErr';
      final v1 = AssessmentFormValidationError(
        message: msg,
        sectionNumber: 2,
        assessmentForm: dummyForm,
      );
      final v2 = AssessmentFormValidationError(
        message: msg,
        sectionNumber: 2,
        assessmentForm: dummyForm,
      );
      final v3 = AssessmentFormValidationError(
        message: 'x',
        sectionNumber: 2,
        assessmentForm: dummyForm,
      );

      expect(v1, equals(v2));
      expect(v1, isNot(equals(v3)));
      expect(v1.props, equals([msg, 2, dummyForm]));
    });

    test('AssessmentFormConfirmationRequired props & equality', () {
      const msg = 'conf';
      const id = 'cid';
      final c1 = AssessmentFormConfirmationRequired(
        message: msg,
        confirmationId: id,
        assessmentForm: dummyForm,
        data: {'a': 1},
      );
      final c2 = AssessmentFormConfirmationRequired(
        message: msg,
        confirmationId: id,
        assessmentForm: dummyForm,
        data: {'a': 1},
      );
      final c3 = AssessmentFormConfirmationRequired(
        message: 'x',
        confirmationId: id,
        assessmentForm: dummyForm,
        data: {'a': 1},
      );

      expect(c1, equals(c2));
      expect(c1, isNot(equals(c3)));
      expect(
        c1.props,
        equals([
          msg,
          id,
          dummyForm,
          {'a': 1},
        ]),
      );
    });
  });

  group('AssessmentFormLoaded – props, copyWith & getters', () {
    test('default props & equality', () {
      final s1 = AssessmentFormLoaded();
      final s2 = AssessmentFormLoaded();
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      // number of props should match length of props list
      expect(s1.props.length, 18);
    });

    test('copyWith overrides fields correctly', () {
      final original = AssessmentFormLoaded(
        assessmentForm: dummyForm,
        currentStep: 2,
        totalSteps: 4,
        hasUnsavedChanges: true,
        isEditMode: true,
        exportHistory: [dummyResult],
        isInitializing: true,
        isSaving: true,
        isExporting: true,
        isSubmittingEmail: true,
        isValidating: true,
        lastSaveResult: 'save',
        lastExportResult: dummyResult,
        lastSubmissionResult: 'sub',
        validationError: 'val',
        showExportDialog: true,
        showCompletionDialog: true,
        showExportSuccessDialog: true,
      );

      final modified = original.copyWith(
        currentStep: 3,
        clearLastSaveResult: true,
        clearLastExportResult: true,
        clearLastSubmissionResult: true,
        clearValidationError: true,
        showExportDialog: false,
      );

      expect(
        modified,
        equals(
          AssessmentFormLoaded(
            assessmentForm: dummyForm,
            currentStep: 3,
            totalSteps: 4,
            hasUnsavedChanges: true,
            isEditMode: true,
            exportHistory: [dummyResult],
            isInitializing: true,
            isSaving: true,
            isExporting: true,
            isSubmittingEmail: true,
            isValidating: true,
            lastSaveResult: null,
            lastExportResult: null,
            lastSubmissionResult: null,
            validationError: null,
            showExportDialog: false,
            showCompletionDialog: true,
            showExportSuccessDialog: true,
          ),
        ),
      );
    });

    test('isLoading, canNavigate, canSave, canExport defaults', () {
      final s = AssessmentFormLoaded();
      expect(s.isLoading, isFalse);
      expect(s.canNavigate, isTrue);
      expect(s.canSave, isFalse);
      expect(s.canExport, isFalse);
    });

    test('loading flags affect isLoading & canNavigate', () {
      final s = AssessmentFormLoaded(isSaving: true);
      expect(s.isLoading, isTrue);
      expect(s.canNavigate, isFalse);
    });

    test('canSave & canExport true when form exists and not loading', () {
      final s = AssessmentFormLoaded(assessmentForm: dummyForm);
      expect(s.canSave, isTrue);
      expect(s.canExport, isTrue);
    });

    test('isOnLastStep & navigation helpers', () {
      final total = 5;
      final atLast = AssessmentFormLoaded(
        currentStep: total,
        totalSteps: total,
      );
      final beforeLast = AssessmentFormLoaded(
        currentStep: total - 1,
        totalSteps: total,
      );

      expect(atLast.isOnLastStep, isTrue);
      expect(beforeLast.isOnLastStep, isFalse);

      // canGoToNextStep only when < total and canNavigate
      expect(atLast.canGoToNextStep, isFalse);
      expect(beforeLast.canGoToNextStep, isTrue);

      // canGoToPreviousStep only when >1
      final atOne = AssessmentFormLoaded(currentStep: 1);
      final atTwo = AssessmentFormLoaded(currentStep: 2);
      expect(atOne.canGoToPreviousStep, isFalse);
      expect(atTwo.canGoToPreviousStep, isTrue);
    });
    test(
      'copyWith overrides only explicitly passed last* fields and showExportDialog',
      () {
        final firstExport = ExportResult(
          filePath: 'first',
          fileName: '',
          format: '',
          fileSizeBytes: 100,
          createdAt: DateTime(2025),
        );
        final secondExport = ExportResult(
          filePath: 'second',
          fileName: '',
          format: '',
          fileSizeBytes: 200,
          createdAt: DateTime(2026),
        );

        final original = AssessmentFormLoaded(
          lastSaveResult: 'saved1',
          lastExportResult: firstExport,
          lastSubmissionResult: 'submitted1',
          validationError: 'invalid1',
          showExportDialog: false,
        );

        final modified = original.copyWith(
          lastSaveResult: 'saved2',
          lastExportResult: secondExport,
          lastSubmissionResult: 'submitted2',
          validationError: 'invalid2',
          showExportDialog: true,
        );

        // clear flags are false by default, so we should get the new values:
        expect(modified.lastSaveResult, 'saved2');
        expect(modified.lastExportResult, secondExport);
        expect(modified.lastSubmissionResult, 'submitted2');
        expect(modified.validationError, 'invalid2');
        expect(modified.showExportDialog, isTrue);
      },
    );

    test(
      'copyWith with no args or clears preserves existing last* and showExportDialog',
      () {
        final firstExport = ExportResult(
          filePath: 'first',
          fileName: '',
          format: '',
          fileSizeBytes: 100,
          createdAt: DateTime(2025),
        );

        final original = AssessmentFormLoaded(
          lastSaveResult: 'saved1',
          lastExportResult: firstExport,
          lastSubmissionResult: 'submitted1',
          validationError: 'invalid1',
          showExportDialog: true,
        );

        // no clear flags, no new values → everything should carry over
        final same = original.copyWith();

        expect(same.lastSaveResult, 'saved1');
        expect(same.lastExportResult, firstExport);
        expect(same.lastSubmissionResult, 'submitted1');
        expect(same.validationError, 'invalid1');
        expect(same.showExportDialog, isTrue);
      },
    );
  });
}
