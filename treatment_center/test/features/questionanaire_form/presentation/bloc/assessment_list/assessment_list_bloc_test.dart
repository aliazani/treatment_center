import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_state.dart';

@GenerateMocks([GetAllAssessmentsUsecase, DeleteAssessmentUsecase])
import 'assessment_list_bloc_test.mocks.dart';

void main() {
  provideDummy<Either<Failure, List<AssessmentFormEntity>>>(
    Right(<AssessmentFormEntity>[]),
  );

  provideDummy<Either<Failure, void>>(const Right(null));
  group('AssessmentListBloc', () {
    late AssessmentListBloc assessmentBloc;
    late MockGetAllAssessmentsUsecase mockGetAllAssessments;
    late MockDeleteAssessmentUsecase mockDeleteAssessment;

    // Test data
    final tAssessmentList = [
      AssessmentFormEntity(
        id: '1',
        sections: const [],
        assessorInfo: const AssessorInfoEntity(
          name: 'Test Assessor',
          email: 'test@example.com',
          phoneNumber: '',
          assessmentDate: null,
        ),
        isSubmitted: true,
        geoLocation: const GeoLocationEntity(
          country: 'Country',
          regionProvince: 'Region',
          district: 'District',
          cityVillage: 'City',
          addressOrCoordinates: 'Address',
          locationType: FacilityLocationType.periUrban,
        ),
        facilityIdentification: const FacilityIdentificationEntity(
          facilityCode: 'facility code',
          facilityName: 'facility name',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'director name',
          directorPhone: 'director phone',
          directorEmail: 'director email',
          respondentName: 'respondent name',
          respondentPosition: 'respondent position',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
        ),
        facilityServices: const FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: true,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AssessmentFormEntity(
        id: '2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sections: const [],
        assessorInfo: const AssessorInfoEntity(
          name: 'Test Assessor 2',
          email: 'test2@example.com',
          phoneNumber: '',
          assessmentDate: null,
        ),
        isSubmitted: false,
        geoLocation: const GeoLocationEntity(
          country: 'Country',
          regionProvince: 'Region',
          district: 'District',
          cityVillage: 'City',
          addressOrCoordinates: 'Address',
          locationType: FacilityLocationType.periUrban,
        ),
        facilityIdentification: const FacilityIdentificationEntity(
          facilityCode: 'facility code 2',
          facilityName: 'facility name 2',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'director name 2',
          directorPhone: 'director phone 2',
          directorEmail: 'director email 2',
          respondentName: 'respondent name 2',
          respondentPosition: 'respondent position 2',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
        ),
        facilityServices: FacilityServicesEntity(
          hasOutpatientServices: false,
          hasInpatientServices: false,
        ),
      ),
    ];

    setUp(() {
      mockGetAllAssessments = MockGetAllAssessmentsUsecase();
      mockDeleteAssessment = MockDeleteAssessmentUsecase();
      assessmentBloc = AssessmentListBloc(
        getAllAssessments: mockGetAllAssessments,
        deleteAssessment: mockDeleteAssessment,
      );
    });

    tearDown(() {
      assessmentBloc.close();
    });

    test('initial state should be AssessmentInitial', () {
      expect(assessmentBloc.state, equals(const AssessmentInitial()));
    });

    group('LoadAssessments', () {
      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits [AssessmentLoading, AssessmentError] with generic failure message',
        build: () {
          when(mockGetAllAssessments(any)).thenAnswer(
            (_) async => Left(
              ServerFailure(
                message: 'Server error occurred. Please try again later.',
              ),
            ),
          );
          return assessmentBloc;
        },
        act: (bloc) => bloc.add(const LoadAssessments()),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(
                message: 'Server error occurred. Please try again later.',
              ),
            ],
      );
      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits [AssessmentLoading, AssessmentLoaded] when usecase returns data',
        build: () {
          // Setup mock BEFORE creating bloc
          when(
            mockGetAllAssessments(any),
          ).thenAnswer((_) async => Right(tAssessmentList));
          return assessmentBloc;
        },
        act: (bloc) => bloc.add(const LoadAssessments()),
        expect:
            () => [
              const AssessmentLoading(),
              AssessmentLoaded(
                allAssessments: tAssessmentList,
                filteredAssessments: tAssessmentList,
                currentFilter: AssessmentFilter.all,
                searchQuery: '',
              ),
            ],
        verify: (_) {
          verify(mockGetAllAssessments(const NoParams()));
        },
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits [AssessmentLoading, AssessmentLoaded] with empty lists when usecase returns no data',
        build: () {
          when(
            mockGetAllAssessments(any),
          ).thenAnswer((_) async => const Right([]));
          return assessmentBloc;
        },
        act: (bloc) => bloc.add(const LoadAssessments()),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentLoaded(
                allAssessments: [],
                filteredAssessments: [],
                currentFilter: AssessmentFilter.all,
                searchQuery: '',
              ),
            ],
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits [AssessmentLoading, AssessmentError] when usecase fails',
        build: () {
          when(mockGetAllAssessments(any)).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Server error')),
          );
          return assessmentBloc;
        },
        act: (bloc) => bloc.add(const LoadAssessments()),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(
                message: 'Server error occurred. Please try again later.',
              ),
            ],
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits [AssessmentLoading, AssessmentError] with network failure message',
        build: () {
          when(mockGetAllAssessments(any)).thenAnswer(
            (_) async => Left(
              NetworkFailure(
                message: 'Network error. Please check your connection.',
              ),
            ),
          );
          return assessmentBloc;
        },
        act: (bloc) => bloc.add(const LoadAssessments()),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(
                message: 'Network error. Please check your connection.',
              ),
            ],
      );
    });

    group('FilterAssessments', () {
      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits AssessmentLoaded with filtered assessments when filtering by draft',
        build: () => assessmentBloc,
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(
              const FilterAssessments(filter: AssessmentFilter.draft),
            ),
        expect:
            () => [
              AssessmentLoaded(
                allAssessments: tAssessmentList,
                // NEW: id "2" is !isSubmitted && !isComplete -> draft
                filteredAssessments: [tAssessmentList[1]],
                currentFilter: AssessmentFilter.draft,
                searchQuery: '',
              ),
            ],
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'does nothing when current state is not AssessmentLoaded',
        build: () => assessmentBloc,
        act:
            (bloc) => bloc.add(
              const FilterAssessments(filter: AssessmentFilter.draft),
            ),
        expect: () => [],
      );
    });

    group('SearchAssessments', () {
      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits AssessmentLoaded with searched assessments',
        build: () => assessmentBloc,
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(const SearchAssessments(query: 'Test Assessor')),
        expect:
            () => [
              AssessmentLoaded(
                allAssessments: tAssessmentList,
                filteredAssessments: tAssessmentList,
                currentFilter: AssessmentFilter.all,
                searchQuery: 'Test Assessor',
              ),
            ],
      );
    });

    group('DeleteAssessmentEvent', () {
      const tAssessmentId = '1';

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits [AssessmentLoading, AssessmentLoaded] when deletion is successful',
        build: () {
          when(
            mockDeleteAssessment(any),
          ).thenAnswer((_) async => const Right(null));
          return assessmentBloc;
        },
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(
              const DeleteAssessmentEvent(assessmentId: tAssessmentId),
            ),
        expect:
            () => [
              const AssessmentLoading(),
              AssessmentLoaded(
                allAssessments: [
                  tAssessmentList[1],
                ], // Only second assessment remains
                filteredAssessments: [tAssessmentList[1]],
                currentFilter: AssessmentFilter.all,
                searchQuery: '',
              ),
            ],
        verify: (_) {
          verify(mockDeleteAssessment(any)).called(1);
        },
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits [AssessmentLoading, AssessmentError] when deletion fails',
        build: () {
          when(mockDeleteAssessment(any)).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Delete failed')),
          );
          return assessmentBloc;
        },
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(
              const DeleteAssessmentEvent(assessmentId: tAssessmentId),
            ),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(
                message: 'Server error occurred. Please try again later.',
              ),
            ],
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'does nothing when current state is not AssessmentLoaded',
        build: () => assessmentBloc,
        act:
            (bloc) => bloc.add(
              const DeleteAssessmentEvent(assessmentId: tAssessmentId),
            ),
        expect: () => [],
      );
    });

    group('LoadAssessments - failure mapping', () {
      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits ValidationFailure → Validation error message',
        build: () {
          when(mockGetAllAssessments(any)).thenAnswer(
            (_) async => Left(ValidationFailure(message: 'Invalid input')),
          );
          return assessmentBloc;
        },
        act: (bloc) => bloc.add(const LoadAssessments()),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(message: 'Validation error: Invalid input'),
            ],
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits unknown Failure → unexpected error message',
        build: () {
          when(
            mockGetAllAssessments(any),
          ).thenAnswer((_) async => Left(DummyFailure()));
          return assessmentBloc;
        },
        act: (bloc) => bloc.add(const LoadAssessments()),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(
                message: 'An unexpected error occurred: some unknown error',
              ),
            ],
      );
    });

    group('FilterAssessments - completed & submitted', () {
      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits only submitted assessments when filter is submitted',
        build: () => assessmentBloc,
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(
              const FilterAssessments(filter: AssessmentFilter.submitted),
            ),
        expect:
            () => [
              AssessmentLoaded(
                allAssessments: tAssessmentList,
                filteredAssessments: [tAssessmentList[0]],
                currentFilter: AssessmentFilter.submitted,
                searchQuery: '',
              ),
            ],
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits only completed assessments when filter is completed',
        build: () => assessmentBloc,
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(
              const FilterAssessments(filter: AssessmentFilter.completed),
            ),
        expect:
            () => [
              AssessmentLoaded(
                allAssessments: tAssessmentList,
                // NEW: none are complete & unsubmitted in tAssessmentList
                filteredAssessments: [],
                currentFilter: AssessmentFilter.completed,
                searchQuery: '',
              ),
            ],
      );
    });

    group('DeleteAssessmentEvent - failure mapping', () {
      const tAssessmentId = '1';

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits ValidationFailure → Validation error message on delete',
        build: () {
          when(mockDeleteAssessment(any)).thenAnswer(
            (_) async => Left(ValidationFailure(message: 'Delete invalid')),
          );
          return assessmentBloc;
        },
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(
              const DeleteAssessmentEvent(assessmentId: tAssessmentId),
            ),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(
                message: 'Validation error: Delete invalid',
              ),
            ],
      );

      blocTest<AssessmentListBloc, AssessmentListState>(
        'emits unknown Failure → unexpected error message on delete',
        build: () {
          when(
            mockDeleteAssessment(any),
          ).thenAnswer((_) async => Left(DummyFailure()));
          return assessmentBloc;
        },
        seed:
            () => AssessmentLoaded(
              allAssessments: tAssessmentList,
              filteredAssessments: tAssessmentList,
              currentFilter: AssessmentFilter.all,
              searchQuery: '',
            ),
        act:
            (bloc) => bloc.add(
              const DeleteAssessmentEvent(assessmentId: tAssessmentId),
            ),
        expect:
            () => [
              const AssessmentLoading(),
              const AssessmentError(
                message: 'An unexpected error occurred: some unknown error',
              ),
            ],
      );
    });
  });
}

class DummyFailure extends Failure {
  const DummyFailure() : super(message: 'some unknown error');
}
