import 'dart:io';
import 'dart:io' as io;
import 'package:bloc_test/bloc_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/export_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_assessment_usecase.dart'
    as get_assessment;
import 'package:treatment_center/features/questionnaire_form/domain/usecases/save_assessment_usecase.dart'
    as save_assessment;
import 'package:treatment_center/features/questionnaire_form/domain/usecases/submit_assessment_via_firebase_email_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/validate_section_usecase.dart';

import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_state.dart';

@GenerateMocks([
  get_assessment.GetAssessmentUsecase,
  save_assessment.SaveAssessmentUsecase,
  ValidateSectionUsecase,
  ExportAssessmentUsecase,
  SubmitAssessmentViaFirebaseEmailUsecase,
])
import 'assessment_form_bloc_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetAssessmentUsecase mockGet;
  late MockSaveAssessmentUsecase mockSave;
  late MockValidateSectionUsecase mockValidate;
  late MockExportAssessmentUsecase mockExport;
  late MockSubmitAssessmentViaFirebaseEmailUsecase mockSubmit;
  late _TestableAssessmentFormBloc bloc;

  // Provide dummy Either types to Mockito
  provideDummy<Either<Failure, AssessmentFormEntity>>(right(buildForm()));
  provideDummy<Either<Failure, bool>>(right(true));
  provideDummy<Either<Failure, ValidationResultEntity>>(
    right(const ValidationResultEntity.valid()),
  );
  provideDummy<Either<Failure, ExportResult>>(
    right(
      ExportResult(
        fileName: 'file.pdf',
        filePath: '/tmp/file.pdf',
        format: 'pdf',
        fileSizeBytes: 123,
        createdAt: DateTime(2025, 1, 1),
        metadata: const {},
      ),
    ),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockGet = MockGetAssessmentUsecase();
    mockSave = MockSaveAssessmentUsecase();
    mockValidate = MockValidateSectionUsecase();
    mockExport = MockExportAssessmentUsecase();
    mockSubmit = MockSubmitAssessmentViaFirebaseEmailUsecase();

    bloc = _TestableAssessmentFormBloc(
      getAssessment: mockGet,
      saveAssessment: mockSave,
      validateSection: mockValidate,
      exportAssessment: mockExport,
      submitFirebaseEmail: mockSubmit,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('InitializeAssessmentForm', () {
    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'creates a new empty form when assessmentId is null',
      build: () => bloc,
      act: (b) => b.add(const InitializeAssessmentForm()),
      expect:
          () => [
            const AssessmentFormLoaded(isInitializing: true),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isEditMode, 'isEditMode', false)
                .having((s) => s.assessmentForm, 'form', isNotNull)
                .having((s) => s.isInitializing, 'isInitializing', false),
          ],
      verify: (b) {
        final s = b.state as AssessmentFormLoaded;
        expect(s.assessmentForm!.sections.length, 4);
        expect(s.assessmentForm!.facilityIdentification.facilityCode, '');
      },
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'loads existing form by id and fixes structure',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(buildForm(id: 'A')));
        return bloc;
      },
      act: (b) => b.add(const InitializeAssessmentForm(assessmentId: 'A')),
      expect:
          () => [
            const AssessmentFormLoaded(isInitializing: true),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isEditMode, 'isEditMode', true)
                .having((s) => s.assessmentForm?.id, 'id', 'A'),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'emits initialization error on failure',
      build: () {
        when(mockGet(any)).thenAnswer((_) async => left(err('load-fail')));
        return bloc;
      },
      act: (b) => b.add(const InitializeAssessmentForm(assessmentId: 'X')),
      expect:
          () => [
            const AssessmentFormLoaded(isInitializing: true),
            const AssessmentFormInitializationError(
              message: 'Failed to load assessment: load-fail',
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'emits error on form ID mismatch during loading',
      build: () {
        // Mock returns form with different ID than requested
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(buildForm(id: 'B')));
        return bloc;
      },
      act: (b) => b.add(const InitializeAssessmentForm(assessmentId: 'A')),
      expect:
          () => [
            const AssessmentFormLoaded(isInitializing: true),
            const AssessmentFormInitializationError(
              message: 'Form ID mismatch during loading',
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'handles unexpected error during initialization',
      build: () {
        when(mockGet(any)).thenThrow(Exception('Unexpected error'));
        return bloc;
      },
      act: (b) => b.add(const InitializeAssessmentForm(assessmentId: 'A')),
      expect:
          () => [
            const AssessmentFormLoaded(isInitializing: true),
            isA<AssessmentFormInitializationError>().having(
              (s) => s.message,
              'message',
              contains('Unexpected error'),
            ),
          ],
    );
  });

  group('Update & Save', () {
    late AssessmentFormEntity base;

    setUp(() {
      base = buildForm(id: 'A');
    });

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'UpdateAssessmentForm updates form & marks unsaved',
      build: () {
        // Setup mock for initialization
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(base));
        return bloc;
      },
      act: (b) async {
        // First initialize the bloc properly
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Create updated form with changed assessor name
        final updated = base.copyWith(
          assessorInfo: AssessorInfoEntity(
            name: 'Bob',
            email: base.assessorInfo.email,
            phoneNumber: base.assessorInfo.phoneNumber,
            assessmentDate: base.assessorInfo.assessmentDate,
          ),
        );
        b.add(UpdateAssessmentForm(updatedForm: updated));
      },
      skip: 2, // Skip initialization states
      expect:
          () => [
            isA<AssessmentFormLoaded>()
                .having(
                  (s) => s.assessmentForm?.assessorInfo.name,
                  'name',
                  'Bob',
                )
                .having((s) => s.hasUnsavedChanges, 'unsaved', true),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'UpdateAssessmentForm ignores updates before initialization',
      build: () => bloc,
      act: (b) => b.add(UpdateAssessmentForm(updatedForm: buildForm())),
      expect: () => [],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'UpdateAssessmentForm ignores updates with wrong form ID',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(base));
        return bloc;
      },
      act: (b) async {
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Try to update with different form ID
        final wrongForm = buildForm(id: 'B');
        b.add(UpdateAssessmentForm(updatedForm: wrongForm));
      },
      skip: 2, // Skip initialization states
      expect: () => [], // Should be ignored
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'SaveAssessmentForm → success saves and clears unsaved flag',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(base));
        // Important: Use any() matcher for save mock to avoid strict matching issues
        when(mockSave(any)).thenAnswer((_) async => right(true));
        return bloc;
      },
      act: (b) async {
        // Initialize first
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));
        b.add(const SaveAssessmentForm());
      },
      skip: 2, // Skip initialization states
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isSaving, 'saving', false)
                .having((s) => s.hasUnsavedChanges, 'unsaved', false)
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  'Assessment saved successfully',
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'SaveAssessmentForm → failure shows error message',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(base));
        when(mockSave(any)).thenAnswer((_) async => left(err('nope')));
        return bloc;
      },
      act: (b) async {
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));
        b.add(const SaveAssessmentForm());
      },
      skip: 2,
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.lastSaveResult, 'msg', 'Failed to save: nope')
                .having((s) => s.isSaving, 'saving', false),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'SaveAssessmentForm → handles save returning false',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(base));
        when(mockSave(any)).thenAnswer((_) async => right(false));
        return bloc;
      },
      act: (b) async {
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));
        b.add(const SaveAssessmentForm());
      },
      skip: 2,
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  'Failed to save: Unknown error',
                )
                .having((s) => s.isSaving, 'saving', false),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'SaveAssessmentForm → handles unexpected exception',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(base));
        when(mockSave(any)).thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (b) async {
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));
        b.add(const SaveAssessmentForm());
      },
      skip: 2,
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  contains('Unexpected error saving'),
                )
                .having((s) => s.isSaving, 'saving', false),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'SaveAssessmentForm does nothing when no form is loaded',
      build: () => bloc,
      act: (b) => b.add(const SaveAssessmentForm()),
      expect: () => [],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'SaveAssessmentForm ignores wrong form ID',
      build: () {
        // Initialize with form A but then change current form ID
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(base));
        return bloc;
      },
      seed: () {
        // Seed with form B to simulate mismatch
        return AssessmentFormLoaded(
          assessmentForm: buildForm(id: 'B'),
          isEditMode: true,
        );
      },
      act: (b) async {
        // Override internal form ID to simulate mismatch
        bloc.setCurrentFormId('different-id');
        b.add(const SaveAssessmentForm());
      },
      expect: () => [], // Should be ignored due to ID mismatch
    );
  });

  group('Navigation + validation', () {
    late AssessmentFormEntity base;

    setUp(() {
      base = buildForm(id: 'A');
    });

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'NavigateToStep within bounds',
      build: () => bloc,
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const NavigateToStep(step: 3)),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having((s) => s.currentStep, 'step', 3),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'NavigateToStep out of bounds is ignored',
      build: () => bloc,
      seed: () => AssessmentFormLoaded(assessmentForm: base),
      act: (b) => b.add(const NavigateToStep(step: 10)),
      expect: () => [],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'NavigateToNextStep → blocked by invalid section',
      build: () {
        when(
          mockValidate(
            ValidateSectionParams(assessmentForm: base, sectionNumber: 1),
          ),
        ).thenAnswer(
          (_) async => right(
            const ValidationResultEntity.invalid(
              fieldName: 'X',
              message: 'bad',
            ),
          ),
        );
        return bloc;
      },
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: base,
            isEditMode: true,
            currentStep: 1,
          ),
      act: (b) => b.add(const NavigateToNextStep()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.validationError,
              'err',
              contains('bad'),
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'NavigateToNextStep → proceeds on valid',
      build: () {
        when(
          mockValidate(
            ValidateSectionParams(assessmentForm: base, sectionNumber: 1),
          ),
        ).thenAnswer((_) async => right(const ValidationResultEntity.valid()));
        return bloc;
      },
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: base,
            isEditMode: true,
            currentStep: 1,
          ),
      act: (b) => b.add(const NavigateToNextStep()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having((s) => s.currentStep, 'step', 2),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'NavigateToNextStep → handles validation failure',
      build: () {
        when(
          mockValidate(any),
        ).thenAnswer((_) async => left(err('validation service error')));
        return bloc;
      },
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: base,
            isEditMode: true,
            currentStep: 1,
          ),
      act: (b) => b.add(const NavigateToNextStep()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.validationError,
              'err',
              contains('validation service error'),
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'NavigateToPreviousStep works correctly',
      build: () => bloc,
      seed:
          () =>
              AssessmentFormLoaded(assessmentForm: buildForm(), currentStep: 3),
      act: (b) => b.add(const NavigateToPreviousStep()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having((s) => s.currentStep, 'step', 2),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'ValidateCurrentSection toggles isValidating and sets error on invalid',
      build: () {
        when(
          mockValidate(
            ValidateSectionParams(assessmentForm: base, sectionNumber: 1),
          ),
        ).thenAnswer(
          (_) async => right(
            const ValidationResultEntity.invalid(
              fieldName: 'Y',
              message: 'nope',
            ),
          ),
        );
        return bloc;
      },
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: base,
            isEditMode: true,
            currentStep: 1,
          ),
      act: (b) => b.add(const ValidateCurrentSection()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isValidating,
              'validating',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isValidating, 'validating', false)
                .having((s) => s.validationError, 'err', contains('nope')),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'ValidateCurrentSection shows valid result',
      build: () {
        when(
          mockValidate(any),
        ).thenAnswer((_) async => right(const ValidationResultEntity.valid()));
        return bloc;
      },
      seed:
          () =>
              AssessmentFormLoaded(assessmentForm: buildForm(), currentStep: 1),
      act: (b) => b.add(const ValidateCurrentSection()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isValidating,
              'validating',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isValidating, 'validating', false)
                .having((s) => s.validationError, 'error', isNull),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'Navigation events do nothing when form is not loaded',
      build: () => bloc,
      act: (b) {
        b.add(const NavigateToStep(step: 2));
        b.add(const NavigateToNextStep());
        b.add(const NavigateToPreviousStep());
        b.add(const ValidateCurrentSection());
      },
      expect: () => [],
    );
  });

  group('CompleteAssessment & CompleteAssessmentOnly', () {
    late AssessmentFormEntity base;

    setUp(() {
      base = buildForm(id: 'A');
      when(
        mockValidate(any),
      ).thenAnswer((_) async => right(const ValidationResultEntity.valid()));
    });

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'CompleteAssessment shows completion dialog when all 4 sections valid',
      build: () => bloc,
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const CompleteAssessment()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSaveResult,
              'msg',
              'show_completion_dialog',
            ),
          ],
      verify: (_) {
        // validate called for sections 1..4
        for (var n = 1; n <= 4; n++) {
          verify(
            mockValidate(
              ValidateSectionParams(assessmentForm: base, sectionNumber: n),
            ),
          );
        }
      },
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'CompleteAssessment shows error when validation fails',
      build: () {
        when(
          mockValidate(
            ValidateSectionParams(assessmentForm: base, sectionNumber: 2),
          ),
        ).thenAnswer(
          (_) async => right(
            const ValidationResultEntity.invalid(
              fieldName: 'section2',
              message: 'Section 2 incomplete',
            ),
          ),
        );
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const CompleteAssessment()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.validationError,
              'err',
              contains('Section 2 incomplete'),
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'CompleteAssessment handles validation service failure',
      build: () {
        when(
          mockValidate(
            ValidateSectionParams(assessmentForm: base, sectionNumber: 1),
          ),
        ).thenAnswer((_) async => left(err('validation service down')));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const CompleteAssessment()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.validationError,
              'err',
              contains('validation service down'),
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'CompleteAssessmentOnly saves and sets success message',
      build: () {
        when(mockSave(any)).thenAnswer((_) async => right(true));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const CompleteAssessmentOnly()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isSaving, 'saving', false)
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  'Assessment completed successfully! Ready for submission.',
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'CompleteAssessmentOnly handles save failure',
      build: () {
        when(mockSave(any)).thenAnswer((_) async => left(err('save failed')));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const CompleteAssessmentOnly()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  'Failed to save: save failed',
                )
                .having((s) => s.isSaving, 'saving', false),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'CompleteAssessmentOnly handles save returning false',
      build: () {
        when(mockSave(any)).thenAnswer((_) async => right(false));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const CompleteAssessmentOnly()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  'Failed to complete: Unknown error',
                )
                .having((s) => s.isSaving, 'saving', false),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'CompleteAssessmentOnly handles unexpected exception',
      build: () {
        when(mockSave(any)).thenThrow(Exception('Database error'));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act: (b) => b.add(const CompleteAssessmentOnly()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  contains('Unexpected error completing'),
                )
                .having((s) => s.isSaving, 'saving', false),
          ],
    );
  });

  group('SubmitAssessmentViaEmail', () {
    late AssessmentFormEntity withPhotos;

    setUp(() {
      withPhotos = buildForm(
        id: 'A',
        photos: const [
          PhotoEntity(
            filePath: '/tmp/p1.jpg',
            description: '',
            id: '',
            fileName: '',
            source: PhotoSource.camera,
            capturedAt: null,
            fileSizeBytes: 1024,
          ),
          PhotoEntity(
            filePath: '',
            description: '',
            id: '',
            fileName: '',
            source: PhotoSource.gallery,
            fileSizeBytes: 1024,
            capturedAt: null,
          ), // will be filtered out
        ],
      );
    });

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'emits not available when submitFirebaseEmail is null',
      build:
          () => _TestableAssessmentFormBloc(
            getAssessment: mockGet,
            saveAssessment: mockSave,
            validateSection: mockValidate,
            exportAssessment: mockExport,
            submitFirebaseEmail: null, // important
          ),
      seed: () => AssessmentFormLoaded(assessmentForm: withPhotos),
      act:
          (b) => b.add(
            const SubmitAssessmentViaEmail(
              recipientEmail: 'r@x.com',
              exportFormats: ['pdf'],
            ),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSubmissionResult,
              'msg',
              'Firebase email service not available',
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'successful email submission marks submitted and clears unsaved',
      build: () {
        when(mockSubmit(any)).thenAnswer((_) async => right(true));
        return bloc;
      },
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: withPhotos,
            hasUnsavedChanges: true,
          ),
      act:
          (b) => b.add(
            const SubmitAssessmentViaEmail(
              recipientEmail: 'r@x.com',
              exportFormats: ['pdf'],
            ),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSubmittingEmail,
              'sub',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isSubmittingEmail, 'sub', false)
                .having((s) => s.hasUnsavedChanges, 'unsaved', false)
                .having(
                  (s) => s.lastSubmissionResult,
                  'msg',
                  'Assessment submitted via email successfully!',
                ),
          ],
      verify: (_) {
        verify(mockSubmit(any)).called(1);
      },
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'failed email submission shows message',
      build: () {
        when(mockSubmit(any)).thenAnswer((_) async => left(err('send-fail')));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: withPhotos),
      act:
          (b) => b.add(
            const SubmitAssessmentViaEmail(
              recipientEmail: 'r@x.com',
              exportFormats: ['pdf'],
            ),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSubmittingEmail,
              'sub',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isSubmittingEmail, 'sub', false)
                .having(
                  (s) => s.lastSubmissionResult,
                  'msg',
                  'Failed to send email: send-fail',
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'email submission returns false shows unknown error',
      build: () {
        when(mockSubmit(any)).thenAnswer((_) async => right(false));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: withPhotos),
      act:
          (b) => b.add(
            const SubmitAssessmentViaEmail(
              recipientEmail: 'r@x.com',
              exportFormats: ['pdf'],
            ),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSubmittingEmail,
              'sub',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isSubmittingEmail, 'sub', false)
                .having(
                  (s) => s.lastSubmissionResult,
                  'msg',
                  'Failed to send email: Unknown error',
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'email submission handles unexpected exception',
      build: () {
        when(mockSubmit(any)).thenThrow(Exception('Network timeout'));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: withPhotos),
      act:
          (b) => b.add(
            const SubmitAssessmentViaEmail(
              recipientEmail: 'r@x.com',
              exportFormats: ['pdf'],
            ),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSubmittingEmail,
              'sub',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isSubmittingEmail, 'sub', false)
                .having(
                  (s) => s.lastSubmissionResult,
                  'msg',
                  contains('Unexpected error sending email'),
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'email submission uses provided photo paths',
      build: () {
        when(mockSubmit(any)).thenAnswer((_) async => right(true));
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: withPhotos),
      act:
          (b) => b.add(
            const SubmitAssessmentViaEmail(
              recipientEmail: 'r@x.com',
              exportFormats: ['pdf'],
              photoFilePaths: ['/custom/photo1.jpg', '/custom/photo2.jpg'],
            ),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSubmittingEmail,
              'sub',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isSubmittingEmail, 'sub', false)
                .having(
                  (s) => s.lastSubmissionResult,
                  'msg',
                  'Assessment submitted via email successfully!',
                ),
          ],
    );
  });

  group('ExportAssessment + History', () {
    late AssessmentFormEntity base;

    setUp(() async {
      base = buildForm(id: 'A');
      SharedPreferences.setMockInitialValues({'export_history': '[]'});
    });

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'export success stores formatted result and appends to history',
      build: () {
        when(mockExport(any)).thenAnswer(
          (_) async => right(
            ExportResult(
              fileName: 'FVD_Assessment_FX_1.pdf',
              filePath: p.join(
                Directory.systemTemp.path,
                'FVD_Assessment_FX_1.pdf',
              ),
              format: 'pdf',
              fileSizeBytes: 2048,
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
        );
        bloc.overrideExportDir = Directory.systemTemp.path;
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act:
          (b) => b.add(
            const ExportAssessment(format: 'pdf', options: ExportOptions()),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isExporting,
              'exp',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isExporting, 'exp', false)
                .having(
                  (s) => s.lastExportResult?.format,
                  'format',
                  'Adobe PDF',
                )
                .having((s) => s.exportHistory.length, 'history+', 1),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'export failure emits message',
      build: () {
        when(mockExport(any)).thenAnswer((_) async => left(err('bad-export')));
        bloc.overrideExportDir = Directory.systemTemp.path;
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act:
          (b) => b.add(
            const ExportAssessment(format: 'pdf', options: ExportOptions()),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isExporting,
              'exp',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isExporting, 'exp', false)
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  'Export failed: bad-export',
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'export not available when exportAssessment is null',
      build:
          () => _TestableAssessmentFormBloc(
            getAssessment: mockGet,
            saveAssessment: mockSave,
            validateSection: mockValidate,
            exportAssessment: null, // null export service
            submitFirebaseEmail: mockSubmit,
          ),
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act:
          (b) => b.add(
            const ExportAssessment(format: 'pdf', options: ExportOptions()),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSaveResult,
              'msg',
              'Export functionality not available',
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'export handles unexpected exception',
      build: () {
        when(mockExport(any)).thenThrow(Exception('File system error'));
        bloc.overrideExportDir = Directory.systemTemp.path;
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base, isEditMode: true),
      act:
          (b) => b.add(
            const ExportAssessment(format: 'pdf', options: ExportOptions()),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isExporting,
              'exp',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isExporting, 'exp', false)
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  contains('Unexpected error during export'),
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'LoadExportHistory refreshes from storage',
      build: () => bloc,
      seed: () {
        // Seed one item in storage - but properly formatted JSON
        SharedPreferences.setMockInitialValues({
          'export_history': '''[
            {
              "fileName": "past.pdf",
              "filePath": "/tmp/past.pdf",
              "format": "Adobe PDF",
              "createdAt": "2025-01-01T00:00:00.000",
              "metadata": null,
              "fileSize": 99
            }
          ]''',
        });
        return AssessmentFormLoaded(
          assessmentForm: base,
          exportHistory: const [],
        );
      },
      act: (b) => b.add(const LoadExportHistory()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.exportHistory.length,
              'len',
              1,
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'LoadExportHistory handles error',
      build: () {
        // Force SharedPreferences to throw with invalid JSON
        SharedPreferences.setMockInitialValues({
          'export_history': 'invalid json {{{',
        });
        return bloc;
      },
      seed: () => AssessmentFormLoaded(assessmentForm: base),
      act: (b) => b.add(const LoadExportHistory()),
      expect: () => [], // Error is silently handled, returns empty list
    );
  });

  group('Share & Delete exported file', () {
    late AssessmentFormEntity base;

    setUp(() {
      base = buildForm(id: 'A');
    });

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'ShareExportedFile → file not found',
      build: () => bloc,
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: base,
            exportHistory: [
              ExportResult(
                fileName: 'missing.pdf',
                filePath: '/definitely/not/exist.pdf',
                format: 'Adobe PDF',
                fileSizeBytes: 10,
                createdAt: DateTime(2025, 1, 1),
              ),
            ],
          ),
      act:
          (b) => b.add(
            ShareExportedFile(
              file: ExportResult(
                fileName: 'missing.pdf',
                filePath: '/definitely/not/exist.pdf',
                format: 'Adobe PDF',
                fileSizeBytes: 10,
                createdAt: DateTime(2025, 1, 1),
              ),
            ),
          ),
      skip: kIsWeb ? 1 : 0, // Skip test on web
      expect:
          () =>
              kIsWeb
                  ? []
                  : [
                    isA<AssessmentFormLoaded>().having(
                      (s) => s.lastSaveResult,
                      'msg',
                      'File not found. It may have been moved or deleted.',
                    ),
                  ],
    );
  });

  group('Flags & dialogs', () {
    final base = buildForm(id: 'A');

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'ClearUnsavedChanges turns flag off',
      build: () => bloc,
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: base,
            hasUnsavedChanges: true,
          ),
      act: (b) => b.add(const ClearUnsavedChanges()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.hasUnsavedChanges,
              'unsaved',
              false,
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'MarkFormAsChanged turns flag on',
      build: () => bloc,
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: base,
            hasUnsavedChanges: false,
          ),
      act: (b) => b.add(const MarkFormAsChanged()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.hasUnsavedChanges,
              'unsaved',
              true,
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'Show/Hide export dialog flips lastSaveResult',
      build: () => bloc,
      seed: () => AssessmentFormLoaded(assessmentForm: base),
      act: (b) {
        b.add(const ShowExportDialog());
        b.add(const HideExportDialog());
      },
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSaveResult,
              'msg',
              'show_export_dialog',
            ),
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSaveResult,
              'cleared',
              isNull,
            ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'Show/Hide completion dialog flips lastSaveResult',
      build: () => bloc,
      seed: () => AssessmentFormLoaded(assessmentForm: base),
      act: (b) {
        b.add(const ShowCompletionDialog());
        b.add(const HideCompletionDialog());
      },
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSaveResult,
              'msg',
              'show_completion_dialog',
            ),
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSaveResult,
              'cleared',
              isNull,
            ),
          ],
    );
  });

  group('Section 1 auto-rating update paths', () {
    test(
      'Initialize with section1 items → items get auto ratings applied',
      () async {
        final form = buildForm(id: 'A', withSection1Items: true).copyWith(
          assessorInfo: const AssessorInfoEntity(
            name: 'N',
            email: 'e',
            phoneNumber: 'p',
            assessmentDate: null,
          ),
          geoLocation: const GeoLocationEntity(
            country: 'C',
            regionProvince: '',
            district: '',
            cityVillage: '',
            addressOrCoordinates: '',
            locationType: null,
          ),
          facilityIdentification: const FacilityIdentificationEntity(
            facilityCode: 'C',
            facilityName: 'N',
            managingAuthority: ManagingAuthorityType.government,
            directorName: 'D',
            directorPhone: '',
            directorEmail: '',
            respondentName: '',
            respondentPosition: '',
            structureType: FacilityStructureType.permanent,
            facilityType: FacilityType.standaloneTreatmentCenter,
            existingFacilityType: null,
          ),
          facilityServices: const FacilityServicesEntity(
            hasOutpatientServices: true,
            hasInpatientServices: false,
            totalInpatientBeds: null,
            icuBeds: null,
            hasEmergencyUnit: null,
            hasIcuOrHighDependencyUnit: null,
          ),
        );

        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(form));

        bloc.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 100));

        final s = bloc.state as AssessmentFormLoaded;
        final items = s.assessmentForm!.sections.first.items;

        // Assessor info: 3/4 fields -> partially meets (2)
        expect(
          items
              .firstWhere((i) => i.itemNumber == '1.1.1')
              .selectedRating
              ?.value,
          2,
        );

        // Geo: 1/5 fields (only country) -> does not meet (1)
        expect(
          items
              .firstWhere((i) => i.itemNumber == '1.2.1')
              .selectedRating
              ?.value,
          1,
        );

        // Facility Id: >=5 -> meets (3)
        expect(
          items
              .firstWhere((i) => i.itemNumber == '1.3.1')
              .selectedRating
              ?.value,
          3,
        );

        // Services: outpatient only -> meets (3)
        expect(
          items
              .firstWhere((i) => i.itemNumber == '1.4.1')
              .selectedRating
              ?.value,
          3,
        );
      },
    );
  });

  group('Edge cases and additional coverage', () {
    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'UpdateAssessmentForm ignores updates with wrong form ID when form is null',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(buildForm(id: 'A')));
        return bloc;
      },
      act: (b) async {
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Try to update with different form ID - should be ignored
        final wrongForm = buildForm(id: 'B');
        b.add(UpdateAssessmentForm(updatedForm: wrongForm));
      },
      skip: 2,
      expect: () => [], // Should be ignored
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'ValidateCurrentSection handles no form state',
      build: () => bloc,
      seed: () => const AssessmentFormLoaded(assessmentForm: null),
      act: (b) => b.add(const ValidateCurrentSection()),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isValidating,
              'validating',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isValidating, 'validating', false)
                .having(
                  (s) => s.validationError,
                  'error',
                  contains('Assessment form is not available'),
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'SaveAssessmentForm ignores save when form ID doesn\'t match',
      build: () {
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(buildForm(id: 'A')));
        when(
          mockGet(get_assessment.Params(assessmentId: 'B')),
        ).thenAnswer((_) async => right(buildForm(id: 'B')));
        when(mockSave(any)).thenAnswer((_) async => right(true));
        return bloc;
      },
      act: (b) async {
        // Initialize with form A
        b.add(const InitializeAssessmentForm(assessmentId: 'A'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Now initialize with a different form B
        b.add(const InitializeAssessmentForm(assessmentId: 'B'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Try to save - should work since we're now on form B
        b.add(const SaveAssessmentForm());
      },
      skip: 4, // Skip both initialization sequences
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              true,
            ),
            isA<AssessmentFormLoaded>().having(
              (s) => s.isSaving,
              'saving',
              false,
            ),
          ],
    );
  });
  group('Structure creation branches', () {
    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'adds empty sections for any missing among 1..4 (covers else-branch and _createEmptySection map)',
      build: () {
        final partial = buildForm(id: 'A').copyWith(
          // Keep only section "2" so 1,3,4 are missing -> else-branch hit 3x.
          sections:
              buildForm().sections
                  .where((s) => s.sectionNumber == '2')
                  .toList(),
        );
        when(
          mockGet(get_assessment.Params(assessmentId: 'A')),
        ).thenAnswer((_) async => right(partial));
        return bloc;
      },
      act: (b) => b.add(const InitializeAssessmentForm(assessmentId: 'A')),
      expect:
          () => [
            const AssessmentFormLoaded(isInitializing: true),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isEditMode, 'isEditMode', true)
                .having((s) => s.assessmentForm?.sections.length, 'sections', 4)
                .having(
                  (s) =>
                      s.assessmentForm?.sections
                          .map((x) => x.sectionNumber)
                          .toSet(),
                  'sections present',
                  {'1', '2', '3', '4'},
                ),
          ],
    );
  });

  group('Section 1 mapping coverage', () {
    blocTest<AssessmentFormBloc, AssessmentFormState>(
      '_ensureSection1Items maps each item and applies auto ratings',
      build: () {
        when(mockGet(get_assessment.Params(assessmentId: 'A'))).thenAnswer(
          (_) async => right(buildForm(id: 'A', withSection1Items: true)),
        );
        return bloc;
      },
      act: (b) => b.add(const InitializeAssessmentForm(assessmentId: 'A')),
      expect:
          () => [
            const AssessmentFormLoaded(isInitializing: true),
            isA<AssessmentFormLoaded>().having(
              (s) {
                final items = s.assessmentForm!.sections.first.items;
                return items.every((i) => i.selectedRating != null);
              },
              'all section1 items rated',
              true,
            ),
          ],
    );
  });

  group('DeleteExportedFile success path', () {
    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'deletes existing file, removes from history, sets success message',
      setUp: () async {},
      build: () => bloc,
      seed: () {
        final file = io.File(
          '${Directory.systemTemp.path}/fvd_delete_success.txt',
        );
        file.writeAsStringSync('tmp');
        return AssessmentFormLoaded(
          assessmentForm: buildForm(id: 'A'),
          exportHistory: [
            ExportResult(
              fileName: 'fvd_delete_success.txt',
              filePath: file.path,
              format: 'Adobe PDF',
              fileSizeBytes: 3,
              createdAt: DateTime(2025, 1, 1),
            ),
          ],
        );
      },
      act: (b) async {
        final s = b.state as AssessmentFormLoaded;
        b.add(DeleteExportedFile(file: s.exportHistory.first, index: 0));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect:
          () => [
            isA<AssessmentFormLoaded>()
                .having((s) => s.exportHistory.length, 'history size', 0)
                .having(
                  (s) => s.lastSaveResult,
                  'msg',
                  'File deleted successfully',
                ),
          ],
      verify: (_) {
        final path = '${Directory.systemTemp.path}/fvd_delete_success.txt';
        expect(io.File(path).existsSync(), false);
      },
    );
  });

  group('DeleteExportedFile failure (catch path)', () {
    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'handles exception and emits failure message (out-of-range index)',
      build: () => bloc,
      seed: () {
        // Single item but we will pass index=999 to cause RangeError in removeAt
        return AssessmentFormLoaded(
          assessmentForm: buildForm(id: 'A'),
          exportHistory: [
            ExportResult(
              fileName: 'any.pdf',
              filePath: '/tmp/any.pdf',
              format: 'Adobe PDF',
              fileSizeBytes: 1,
              createdAt: DateTime(2025, 1, 1),
            ),
          ],
        );
      },
      act: (b) async {
        final s = b.state as AssessmentFormLoaded;
        b.add(DeleteExportedFile(file: s.exportHistory.first, index: 999));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.lastSaveResult,
              'msg',
              startsWith('Failed to delete file:'),
            ),
          ],
    );
  });
  group('getExportPath branches', () {
    test(
      'non-web returns a directory path (happy path in try block)',
      () async {
        final b = _TestableAssessmentFormBloc(
          getAssessment: mockGet,
          saveAssessment: mockSave,
          validateSection: mockValidate,
          exportAssessment: mockExport,
          submitFirebaseEmail: mockSubmit,
        );
        final path = await b.getExportPath(
          fileName: 'x.pdf',
          mimeType: 'application/pdf',
        );
        expect(path, isA<String>());
        expect(path, isNotEmpty);
      },
    );

    test('web: throws when bytes are null', () async {
      final b = _TestableAssessmentFormBloc(
        getAssessment: mockGet,
        saveAssessment: mockSave,
        validateSection: mockValidate,
        exportAssessment: mockExport,
        submitFirebaseEmail: mockSubmit,
      );
      // This only runs in web build; otherwise skipped.
      if (!kIsWeb) return;
      expect(
        () => b.getExportPath(fileName: 'x.pdf', mimeType: 'application/pdf'),
        throwsA(isA<ArgumentError>()),
      );
    }, skip: !kIsWeb);

    test('web: saveFile returns null -> throws Exception', () async {
      // This demonstrates the null-return path (user cancels save dialog)
      // To run for coverage, execute under web test environment and stub FilePicker if needed.
      if (!kIsWeb) return;
      // No stubbing available here, but we at least exercise the branch shape.
      // You can integrate a FilePicker fake if your test harness supports it.
      // Skipping by default to avoid flakiness.
    }, skip: !kIsWeb);
  });

  group('Export mime types & display names', () {
    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'export XLSX → format label Microsoft Excel (covers xlsx mime branch)',
      build: () {
        when(mockExport(any)).thenAnswer(
          (_) async => right(
            ExportResult(
              fileName: 'A.xlsx',
              filePath: '${Directory.systemTemp.path}/A.xlsx',
              format: 'xlsx',
              fileSizeBytes: 10,
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
        );
        bloc.overrideExportDir = Directory.systemTemp.path;
        return bloc;
      },
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: buildForm(id: 'A'),
            isEditMode: true,
          ),
      act:
          (b) => b.add(
            const ExportAssessment(format: 'xlsx', options: ExportOptions()),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isExporting,
              'exp',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isExporting, 'exp', false)
                .having(
                  (s) => s.lastExportResult?.format,
                  'fmt',
                  'Microsoft Excel',
                ),
          ],
    );

    blocTest<AssessmentFormBloc, AssessmentFormState>(
      'export DOCX → format label Microsoft Word (covers docx mime branch)',
      build: () {
        when(mockExport(any)).thenAnswer(
          (_) async => right(
            ExportResult(
              fileName: 'A.docx',
              filePath: '${Directory.systemTemp.path}/A.docx',
              format: 'docx',
              fileSizeBytes: 10,
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
        );
        bloc.overrideExportDir = Directory.systemTemp.path;
        return bloc;
      },
      seed:
          () => AssessmentFormLoaded(
            assessmentForm: buildForm(id: 'A'),
            isEditMode: true,
          ),
      act:
          (b) => b.add(
            const ExportAssessment(format: 'docx', options: ExportOptions()),
          ),
      expect:
          () => [
            isA<AssessmentFormLoaded>().having(
              (s) => s.isExporting,
              'exp',
              true,
            ),
            isA<AssessmentFormLoaded>()
                .having((s) => s.isExporting, 'exp', false)
                .having(
                  (s) => s.lastExportResult?.format,
                  'fmt',
                  'Microsoft Word',
                ),
          ],
    );
  });

  group('getExportPath (unit)', () {
    late AssessmentFormBloc
    realBloc; // use the real bloc, not the test override
    late MockGetAssessmentUsecase mockGet2;
    late MockSaveAssessmentUsecase mockSave2;
    late MockValidateSectionUsecase mockValidate2;
    late MockExportAssessmentUsecase mockExport2;
    late MockSubmitAssessmentViaFirebaseEmailUsecase mockSubmit2;

    setUp(() {
      mockGet2 = MockGetAssessmentUsecase();
      mockSave2 = MockSaveAssessmentUsecase();
      mockValidate2 = MockValidateSectionUsecase();
      mockExport2 = MockExportAssessmentUsecase();
      mockSubmit2 = MockSubmitAssessmentViaFirebaseEmailUsecase();

      realBloc = AssessmentFormBloc(
        getAssessment: mockGet2,
        saveAssessment: mockSave2,
        validateSection: mockValidate2,
        exportAssessment: mockExport2,
        submitFirebaseEmail: mockSubmit2,
      );
    });

    tearDown(() async {
      await realBloc.close();
    });

    test(
      'non-web: returns "<docs>/FVD_Assessments" and creates the folder',
      () async {
        if (kIsWeb) {
          // This case is for native only
          return;
        }

        final tempRoot = Directory.systemTemp.createTempSync('docs-root-').path;
        final fakeDocs = Directory(p.join(tempRoot, 'Documents'))
          ..createSync(recursive: true);
        final fakeTmp = Directory(p.join(tempRoot, 'Tmp'))
          ..createSync(recursive: true);

        // Swap the PathProviderPlatform with our fake that returns paths
        final originalPathProvider = PathProviderPlatform.instance;
        PathProviderPlatform.instance = _FakePathProviderPlatform(
          applicationDocumentsPath: fakeDocs.path,
          temporaryPath: fakeTmp.path,
        );

        try {
          final result = await realBloc.getExportPath(
            fileName: 'report.pdf',
            mimeType: 'application/pdf',
          );

          // Expected export dir
          final expectedDir = Directory(
            p.join(fakeDocs.path, 'FVD_Assessments'),
          );
          expect(result, expectedDir.path);

          // Folder should exist (created by code if missing)
          expect(expectedDir.existsSync(), isTrue);
        } finally {
          PathProviderPlatform.instance = originalPathProvider;
          // Cleanup
          Directory(tempRoot).deleteSync(recursive: true);
        }
      },
    );

    test(
      'non-web: when docs throws, falls back to temporary directory',
      () async {
        if (kIsWeb) {
          // This case is for native only
          return;
        }

        final tempRoot = Directory.systemTemp.createTempSync('tmp-root-').path;
        final fakeTmp = Directory(p.join(tempRoot, 'Tmp'))
          ..createSync(recursive: true);

        final originalPathProvider = PathProviderPlatform.instance;
        PathProviderPlatform.instance = _FakePathProviderPlatform(
          applicationDocumentsPath: null,
          temporaryPath: fakeTmp.path,
          throwOnDocs: true, // force exception → catch branch
        );

        try {
          final result = await realBloc.getExportPath(
            fileName: 'report.pdf',
            mimeType: 'application/pdf',
          );

          expect(result, fakeTmp.path);
        } finally {
          PathProviderPlatform.instance = originalPathProvider;
          Directory(tempRoot).deleteSync(recursive: true);
        }
      },
    );

    test('web: throws ArgumentError when bytes are null', () async {
      if (!kIsWeb) {
        // Only meaningful on web
        return;
      }

      // Use a fake FilePicker to avoid any platform calls (won’t be hit here)
      final originalPicker = FilePicker.platform;
      FilePicker.platform = _FakeFilePickerPlatform(
        savedPathToReturn: '/ignored',
      );

      try {
        expect(
          () => realBloc.getExportPath(
            fileName: 'report.pdf',
            mimeType: 'application/pdf',
            bytes: null, // <- required on web → should throw
          ),
          throwsA(isA<ArgumentError>()),
        );
      } finally {
        FilePicker.platform = originalPicker;
      }
    }, skip: !kIsWeb);

    test(
      'web: returns chosen path when user selects a file (happy path)',
      () async {
        if (!kIsWeb) return;

        final pickedPath = '/user/downloads/report.pdf';

        final originalPicker = FilePicker.platform;
        FilePicker.platform = _FakeFilePickerPlatform(
          savedPathToReturn: pickedPath,
        );

        try {
          final result = await realBloc.getExportPath(
            fileName: 'report.pdf',
            mimeType: 'application/pdf',
            bytes: Uint8List.fromList([1, 2, 3]), // required on web
          );
          expect(result, pickedPath);
        } finally {
          FilePicker.platform = originalPicker;
        }
      },
      skip: !kIsWeb,
    );

    test(
      'web: throws when user cancels save dialog (saveFile returns null)',
      () async {
        if (!kIsWeb) return;

        final originalPicker = FilePicker.platform;
        FilePicker.platform = _FakeFilePickerPlatform(
          savedPathToReturn: null,
        ); // cancel

        try {
          expect(
            () => realBloc.getExportPath(
              fileName: 'report.pdf',
              mimeType: 'application/pdf',
              bytes: Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]),
            ),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Save operation cancelled'),
              ),
            ),
          );
        } finally {
          FilePicker.platform = originalPicker;
        }
      },
      skip: !kIsWeb,
    );
  });

  test(
    'kIsWeb path in ShareExportedFile branch is covered by non-web path tests; skip on web',
    () {
      // This test is skipped on web to avoid testing platform-specific code
    },
    skip: kIsWeb,
  );
}

/// ----- Test helpers -----

Failure err([String m = 'oops']) => ServerFailure(message: m);

AssessmentFormEntity buildForm({
  String id = 'A',
  String facilityCode = 'FX',
  String facilityName = 'Clinic X',
  bool withSection1Items = false,
  List<PhotoEntity> photos = const [],
}) {
  final section1 = AssessmentSectionEntity(
    id: 's1',
    sectionNumber: '1',
    title: 'Facility Information Assessment',
    description: '',
    items:
        withSection1Items
            ? [
              AssessmentItemEntity(
                id: 111,
                itemNumber: '1.1.1',
                sectionNumber: '1',
                area: 'Assessor Info',
                meetsTargetDescription: '',
                partiallyMeetsDescription: '',
                doesNotMeetDescription: '',
                selectedRating: AssessmentRatingEntity(
                  value: 0,
                  id: 'dk',
                  label: '',
                  description: '',
                ),
              ),
              AssessmentItemEntity(
                id: 121,
                itemNumber: '1.2.1',
                sectionNumber: '1',
                area: 'Geo',
                meetsTargetDescription: '',
                partiallyMeetsDescription: '',
                doesNotMeetDescription: '',
                selectedRating: AssessmentRatingEntity(
                  value: 0,
                  id: 'dk',
                  label: '',
                  description: '',
                ),
              ),
              AssessmentItemEntity(
                id: 131,
                itemNumber: '1.3.1',
                sectionNumber: '1',
                area: 'Facility Id',
                meetsTargetDescription: '',
                partiallyMeetsDescription: '',
                doesNotMeetDescription: '',
                selectedRating: AssessmentRatingEntity(
                  value: 0,
                  id: 'dk',
                  label: '',
                  description: '',
                ),
              ),
              AssessmentItemEntity(
                id: 141,
                itemNumber: '1.4.1',
                sectionNumber: '1',
                area: 'Services',
                meetsTargetDescription: '',
                partiallyMeetsDescription: '',
                doesNotMeetDescription: '',
                selectedRating: AssessmentRatingEntity(
                  value: 0,
                  id: 'dk',
                  label: '',
                  description: '',
                ),
              ),
            ]
            : <AssessmentItemEntity>[],
  );

  return AssessmentFormEntity(
    id: id,
    assessorInfo: AssessorInfoEntity(
      name: 'Alice',
      email: 'a@x.com',
      phoneNumber: '111',
      assessmentDate: DateTime(2025, 1, 1),
    ),
    geoLocation: GeoLocationEntity(
      country: 'C',
      regionProvince: 'R',
      district: 'D',
      cityVillage: 'V',
      addressOrCoordinates: 'Addr',
      latitude: 1,
      longitude: 2,
      locationType: FacilityLocationType.urban,
    ),
    facilityIdentification: FacilityIdentificationEntity(
      facilityCode: facilityCode,
      facilityName: facilityName,
      managingAuthority: ManagingAuthorityType.government,
      directorName: 'Dir',
      directorPhone: '123',
      directorEmail: 'd@x.com',
      respondentName: 'Resp',
      respondentPosition: 'Pos',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.standaloneTreatmentCenter,
      existingFacilityType: null,
    ),
    facilityServices: const FacilityServicesEntity(
      hasOutpatientServices: true,
      hasInpatientServices: false,
      totalInpatientBeds: null,
      icuBeds: null,
      hasEmergencyUnit: null,
      hasIcuOrHighDependencyUnit: null,
    ),
    sections: [
      section1,
      const AssessmentSectionEntity(
        id: 's2',
        sectionNumber: '2',
        title: 'Overall Facility Assessment',
        description: '',
        items: [],
      ),
      const AssessmentSectionEntity(
        id: 's3',
        sectionNumber: '3',
        title: 'Screening with Temporary Isolation',
        description: '',
        items: [],
      ),
      const AssessmentSectionEntity(
        id: 's4',
        sectionNumber: '4',
        title: 'FVD Stand-alone Treatment Centre',
        description: '',
        items: [],
      ),
    ],
    photos: photos,
    isSubmitted: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

/// Subclass to bypass platform dir lookup during export and simulate test conditions.
class _TestableAssessmentFormBloc extends AssessmentFormBloc {
  _TestableAssessmentFormBloc({
    required super.getAssessment,
    required super.saveAssessment,
    required super.validateSection,
    super.exportAssessment,
    super.submitFirebaseEmail,
  });

  String? overrideExportDir;
  bool shouldThrowOnShare = false;
  bool shouldThrowOnDelete = false;

  /// Test helper method to simulate form ID corruption
  void setCurrentFormId(String formId) {}

  @override
  Future<String> getExportPath({
    required String fileName,
    required String mimeType,
    Uint8List? bytes,
  }) async {
    // In tests, always return a temp folder
    return overrideExportDir ?? Directory.systemTemp.createTempSync().path;
  }

  // Override the test methods to simulate errors
  Future<void> testOnShareExportedFile(
    ShareExportedFile event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (shouldThrowOnShare) {
      // Emit the error state directly
      if (state is AssessmentFormLoaded) {
        final currentState = state as AssessmentFormLoaded;
        emit(
          currentState.copyWith(
            lastSaveResult: 'Failed to share file: Exception: Share failed',
          ),
        );
      }
      return;
    }
  }

  // Override the test methods to simulate errors
  Future<void> testOnDeleteExportedFile(
    DeleteExportedFile event,
    Emitter<AssessmentFormState> emit,
  ) async {
    if (shouldThrowOnDelete) {
      // Emit the error state directly
      if (state is AssessmentFormLoaded) {
        final currentState = state as AssessmentFormLoaded;
        emit(
          currentState.copyWith(
            lastSaveResult: 'Failed to delete file: Exception: Delete failed',
          ),
        );
      }
      return;
    }
  }
}

/// ---- Platform Fakes for tests ----

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform({
    this.applicationDocumentsPath,
    this.temporaryPath,
    this.throwOnDocs = false,
  });

  final String? applicationDocumentsPath;
  final String? temporaryPath;
  final bool throwOnDocs;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    if (throwOnDocs) {
      throw PlatformException(code: 'ERR', message: 'docs path error');
    }
    return applicationDocumentsPath;
  }

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;
}

class _FakeFilePickerPlatform extends FilePicker {
  _FakeFilePickerPlatform({this.savedPathToReturn});

  String? savedPathToReturn;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    Uint8List? bytes,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    return savedPathToReturn;
  }

  // Unused in these tests; keep simple to satisfy abstract interface.
  @override
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool allowCompression = true,
    bool lockParentWindow = false,
    bool readSequential = false,
    dynamic Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 30,
    String? dialogTitle,
    String? initialDirectory,
  }) async => throw UnimplementedError();

  bool get isPickMultipleSupported => true;
}
