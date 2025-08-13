import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_state.dart';

void main() {
  group('AssessmentState equatability', () {
    test('AssessmentInitial should be equal', () {
      expect(const AssessmentInitial(), equals(const AssessmentInitial()));
      expect(
        const AssessmentInitial().hashCode,
        equals(const AssessmentInitial().hashCode),
      );
      expect(const AssessmentInitial().props, isEmpty);
    });

    test('AssessmentLoading should be equal', () {
      expect(const AssessmentLoading(), equals(const AssessmentLoading()));
      expect(
        const AssessmentLoading().hashCode,
        equals(const AssessmentLoading().hashCode),
      );
      expect(const AssessmentLoading().props, isEmpty);
    });

    test('AssessmentError equality, hashCode and props', () {
      const msg1 = 'oops';
      const msg2 = 'uh-oh';

      final e1 = const AssessmentError(message: msg1);
      final e2 = const AssessmentError(message: msg1);
      final e3 = const AssessmentError(message: msg2);

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
      expect(e1, isNot(equals(e3)));
      expect(e1.props, equals([msg1]));
    });

    test('AssessmentDeleted equality, hashCode and props', () {
      const m1 = 'deleted';
      const m2 = 'gone';

      final d1 = const AssessmentDeleted(message: m1);
      final d2 = const AssessmentDeleted(message: m1);
      final d3 = const AssessmentDeleted(message: m2);

      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));
      expect(d1, isNot(equals(d3)));
      expect(d1.props, equals([m1]));
    });

    test('AssessmentCreated equality, hashCode and props', () {
      const id1 = '123';
      const id2 = '456';

      final c1 = const AssessmentCreated(assessmentId: id1);
      final c2 = const AssessmentCreated(assessmentId: id1);
      final c3 = const AssessmentCreated(assessmentId: id2);

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
      expect(c1.props, equals([id1]));
    });

    test('AssessmentUpdated equality, hashCode and props', () {
      const m1 = 'updated';
      const m2 = 'error';

      final u1 = const AssessmentUpdated(message: m1);
      final u2 = const AssessmentUpdated(message: m1);
      final u3 = const AssessmentUpdated(message: m2);

      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
      expect(u1, isNot(equals(u3)));
      expect(u1.props, equals([m1]));
    });
  });

  group('AssessmentLoaded', () {
    // create a dummy entity (fill in with required constructor args)
    final dummy = AssessmentFormEntity(
      id: 'a',
      assessorInfo: AssessorInfoEntity(
        name: 'Test Assessor',
        email: 'assessor@test.com',
        phoneNumber: '123-456-7890',
        assessmentDate: DateTime.now(),
      ),
      geoLocation: GeoLocationEntity(
        country: 'Test Country',
        regionProvince: 'regionProvince',
        district: 'district',
        cityVillage: 'cityVillage',
        addressOrCoordinates: 'addressOrCoordinates',
        locationType: FacilityLocationType.rural,
      ),
      facilityIdentification: FacilityIdentificationEntity(
        facilityCode: '123',
        facilityName: 'Test Facility',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Test Director',
        directorPhone: '123-456-7890',
        directorEmail: 'director@test.com',
        respondentName: 'Test Respondent',
        respondentPosition: 'Test Position',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
      ),
      facilityServices: FacilityServicesEntity(
        hasOutpatientServices: true,
        hasInpatientServices: true,
      ),
      sections: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final list = [dummy];

    test('equality, hashCode and props', () {
      final s1 = AssessmentLoaded(
        allAssessments: list,
        filteredAssessments: list,
        currentFilter: AssessmentFilter.all,
        searchQuery: '',
      );
      final s2 = AssessmentLoaded(
        allAssessments: list,
        filteredAssessments: list,
        currentFilter: AssessmentFilter.all,
        searchQuery: '',
      );
      final s3 = AssessmentLoaded(
        allAssessments: list,
        filteredAssessments: [],
        currentFilter: AssessmentFilter.draft,
        searchQuery: 'foo',
      );

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));

      expect(s1.props, equals([list, list, AssessmentFilter.all, '']));
    });

    test('copyWith overrides only specified fields', () {
      final original = AssessmentLoaded(
        allAssessments: list,
        filteredAssessments: list,
        currentFilter: AssessmentFilter.all,
        searchQuery: 'bar',
      );

      final modified = original.copyWith(
        filteredAssessments: [],
        currentFilter: AssessmentFilter.submitted,
      );

      expect(
        modified,
        equals(
          AssessmentLoaded(
            allAssessments: list,
            filteredAssessments: [],
            currentFilter: AssessmentFilter.submitted,
            searchQuery: 'bar',
          ),
        ),
      );

      // unchanged fields remain
      expect(modified.allAssessments, same(list));
      expect(modified.searchQuery, equals('bar'));
    });

    test('copyWith with only allAssessments overrides', () {
      final original = AssessmentLoaded(
        allAssessments: list,
        filteredAssessments: list,
        currentFilter: AssessmentFilter.draft,
        searchQuery: 'orig',
      );

      final newList = <AssessmentFormEntity>[
        dummy,
      ]; // could be same dummy or another
      final modified = original.copyWith(allAssessments: newList);

      expect(
        modified,
        equals(
          AssessmentLoaded(
            allAssessments: newList,
            filteredAssessments: list,
            currentFilter: AssessmentFilter.draft,
            searchQuery: 'orig',
          ),
        ),
      );
      // untouched
      expect(modified.filteredAssessments, same(list));
      expect(modified.currentFilter, equals(AssessmentFilter.draft));
      expect(modified.searchQuery, equals('orig'));
    });

    test('copyWith with only searchQuery overrides', () {
      final original = AssessmentLoaded(
        allAssessments: list,
        filteredAssessments: list,
        currentFilter: AssessmentFilter.submitted,
        searchQuery: 'foo',
      );

      final modified = original.copyWith(searchQuery: 'bar');

      expect(
        modified,
        equals(
          AssessmentLoaded(
            allAssessments: list,
            filteredAssessments: list,
            currentFilter: AssessmentFilter.submitted,
            searchQuery: 'bar',
          ),
        ),
      );
      // untouched
      expect(modified.allAssessments, same(list));
      expect(modified.filteredAssessments, same(list));
      expect(modified.currentFilter, equals(AssessmentFilter.submitted));
    });

    test('copyWith with no arguments returns identical state', () {
      final original = AssessmentLoaded(
        allAssessments: list,
        filteredAssessments: list,
        currentFilter: AssessmentFilter.all,
        searchQuery: 'xyz',
      );

      final modified = original.copyWith();

      // They should be equal and have same identity for lists
      expect(modified, equals(original));
      expect(modified.allAssessments, same(original.allAssessments));
      expect(modified.filteredAssessments, same(original.filteredAssessments));
      expect(modified.currentFilter, equals(original.currentFilter));
      expect(modified.searchQuery, equals(original.searchQuery));
    });
  });
}
