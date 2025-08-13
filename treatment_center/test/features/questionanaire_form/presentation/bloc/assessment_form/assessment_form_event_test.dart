import 'package:flutter_test/flutter_test.dart';

import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_event.dart';

// constructor requires. This one mirrors your tAssessmentList setup.
final _dummyForm = AssessmentFormEntity(
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

// Assume these both have const constructors. Adjust if not.
const _dummyOptions = ExportOptions();
final _dummyResult = ExportResult(
  filePath: 'some/path',
  fileName: '',
  format: '',
  fileSizeBytes: 1024,
  createdAt: DateTime.now(),
);

void main() {
  group('AssessmentFormEvent — equatability & props', () {
    test('InitializeAssessmentForm(null) props & ==', () {
      final e1 = const InitializeAssessmentForm();
      final e2 = const InitializeAssessmentForm();
      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
      expect(e1.props, [isNull]);
    });

    test('InitializeAssessmentForm(non-null) props & ==', () {
      const idA = 'abc';
      const idB = 'def';
      final e1 = const InitializeAssessmentForm(assessmentId: idA);
      final e2 = const InitializeAssessmentForm(assessmentId: idA);
      final e3 = const InitializeAssessmentForm(assessmentId: idB);

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
      expect(e1, isNot(equals(e3)));

      expect(e1.props, equals([idA]));
      expect(e3.props, equals([idB]));
    });

    test('UpdateAssessmentForm props & ==', () {
      final u1 = UpdateAssessmentForm(updatedForm: _dummyForm);
      final u2 = UpdateAssessmentForm(updatedForm: _dummyForm);
      // identity‐based for props, so two references to same object are equal
      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
      expect(u1.props, equals([_dummyForm]));
    });

    test('NavigateToNextStep props empty', () {
      final n1 = const NavigateToNextStep();
      final n2 = const NavigateToNextStep();
      expect(n1, equals(n2));
      expect(n1.props, isEmpty);
    });

    test('NavigateToPreviousStep props empty', () {
      final p1 = const NavigateToPreviousStep();
      final p2 = const NavigateToPreviousStep();
      expect(p1, equals(p2));
      expect(p1.props, isEmpty);
    });

    test('NavigateToStep props & ==', () {
      const sA = 2, sB = 3;
      final s1 = const NavigateToStep(step: sA);
      final s2 = const NavigateToStep(step: sA);
      final s3 = const NavigateToStep(step: sB);

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
      expect(s1.props, equals([sA]));
    });

    test('SaveAssessmentForm props empty', () {
      final s1 = const SaveAssessmentForm();
      final s2 = const SaveAssessmentForm();
      expect(s1, equals(s2));
      expect(s1.props, isEmpty);
    });

    test('ValidateCurrentSection props empty', () {
      final v1 = const ValidateCurrentSection();
      final v2 = const ValidateCurrentSection();
      expect(v1, equals(v2));
      expect(v1.props, isEmpty);
    });

    test('ExportAssessment props & ==', () {
      const fmtA = 'pdf';
      const fmtB = 'csv';
      final e1 = const ExportAssessment(format: fmtA, options: _dummyOptions);
      final e2 = const ExportAssessment(format: fmtA, options: _dummyOptions);
      final e3 = const ExportAssessment(format: fmtB, options: _dummyOptions);

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
      expect(e1, isNot(equals(e3)));
      expect(e1.props, equals([fmtA, _dummyOptions]));
    });

    test('LoadExportHistory props empty', () {
      final l1 = const LoadExportHistory();
      final l2 = const LoadExportHistory();
      expect(l1, equals(l2));
      expect(l1.props, isEmpty);
    });

    test('DeleteExportedFile props & ==', () {
      final d1 = DeleteExportedFile(file: _dummyResult, index: 0);
      final d2 = DeleteExportedFile(file: _dummyResult, index: 0);
      final d3 = DeleteExportedFile(file: _dummyResult, index: 1);

      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));
      expect(d1, isNot(equals(d3)));
      expect(d1.props, equals([_dummyResult, 0]));
    });

    test('ShareExportedFile props & ==', () {
      final s1 = ShareExportedFile(file: _dummyResult);
      final s2 = ShareExportedFile(file: _dummyResult);
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1.props, equals([_dummyResult]));
    });

    test('SubmitAssessmentViaEmail props & ==', () {
      const emailA = 'a@x.com';
      const emailB = 'b@y.com';
      const fmtsA = ['pdf', 'doc'];
      const fmtsB = ['doc'];
      const subj = 'sub';
      const body = 'bod';

      final m1 = SubmitAssessmentViaEmail(
        recipientEmail: emailA,
        exportFormats: fmtsA,
        customSubject: subj,
        customBody: body,
      );
      final m2 = SubmitAssessmentViaEmail(
        recipientEmail: emailA,
        exportFormats: fmtsA,
        customSubject: subj,
        customBody: body,
      );
      final m3 = SubmitAssessmentViaEmail(
        recipientEmail: emailB,
        exportFormats: fmtsB,
        customSubject: null,
        customBody: null,
      );

      expect(m1, equals(m2));
      expect(m1.hashCode, equals(m2.hashCode));
      expect(m1, isNot(equals(m3)));
      expect(m1.props, equals([emailA, fmtsA, subj, body, []]));
    });

    test('CompleteAssessmentOnly props empty', () {
      final c1 = const CompleteAssessmentOnly();
      final c2 = const CompleteAssessmentOnly();
      expect(c1, equals(c2));
      expect(c1.props, isEmpty);
    });

    test('CompleteAssessment props empty', () {
      final c1 = const CompleteAssessment();
      final c2 = const CompleteAssessment();
      expect(c1, equals(c2));
      expect(c1.props, isEmpty);
    });

    test('ShowExportDialog props empty', () {
      final s1 = const ShowExportDialog();
      final s2 = const ShowExportDialog();
      expect(s1, equals(s2));
      expect(s1.props, isEmpty);
    });

    test('HideExportDialog props empty', () {
      final h1 = const HideExportDialog();
      final h2 = const HideExportDialog();
      expect(h1, equals(h2));
      expect(h1.props, isEmpty);
    });

    test('ShowCompletionDialog props empty', () {
      final s1 = const ShowCompletionDialog();
      final s2 = const ShowCompletionDialog();
      expect(s1, equals(s2));
      expect(s1.props, isEmpty);
    });

    test('HideCompletionDialog props empty', () {
      final h1 = const HideCompletionDialog();
      final h2 = const HideCompletionDialog();
      expect(h1, equals(h2));
      expect(h1.props, isEmpty);
    });

    test('ClearUnsavedChanges props empty', () {
      final c1 = const ClearUnsavedChanges();
      final c2 = const ClearUnsavedChanges();
      expect(c1, equals(c2));
      expect(c1.props, isEmpty);
    });

    test('MarkFormAsChanged props empty', () {
      final m1 = const MarkFormAsChanged();
      final m2 = const MarkFormAsChanged();
      expect(m1, equals(m2));
      expect(m1.props, isEmpty);
    });

    test('ExportFailed props & ==', () {
      const errA = 'oops';
      const errB = 'uh oh';

      final x1 = const ExportFailed(error: errA);
      final x2 = const ExportFailed(error: errA);
      final x3 = const ExportFailed(error: errB);

      expect(x1, equals(x2));
      expect(x1.hashCode, equals(x2.hashCode));
      expect(x1, isNot(equals(x3)));
      expect(x1.props, equals([errA]));
    });
  });
}
