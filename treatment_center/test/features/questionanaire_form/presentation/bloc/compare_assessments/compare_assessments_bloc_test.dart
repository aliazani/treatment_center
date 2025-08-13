import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_state.dart';

@GenerateMocks([GetAllAssessmentsUsecase, GetAssessmentUsecase])
import 'compare_assessments_bloc_test.mocks.dart';

void main() {
  provideDummy<Either<Failure, List<AssessmentFormEntity>>>(
    right(<AssessmentFormEntity>[]),
  );
  provideDummy<Either<Failure, AssessmentFormEntity>>(
    right(
      AssessmentFormEntity(
        id: 'dummy',
        assessorInfo: AssessorInfoEntity(
          name: '',
          email: '',
          phoneNumber: '',
          assessmentDate: DateTime.now(),
        ),
        geoLocation: GeoLocationEntity(
          country: '',
          regionProvince: '',
          district: '',
          cityVillage: '',
          addressOrCoordinates: '',
          locationType: FacilityLocationType.urban,
        ),
        facilityIdentification: FacilityIdentificationEntity(
          facilityCode: '',
          facilityName: '',
          managingAuthority: ManagingAuthorityType.government,
          directorName: '',
          directorPhone: '',
          directorEmail: '',
          respondentName: '',
          respondentPosition: '',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.standaloneTreatmentCenter,
        ),
        facilityServices: FacilityServicesEntity(
          hasOutpatientServices: false,
          hasInpatientServices: false,
        ),
        sections: [],
        photos: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
  );

  late MockGetAllAssessmentsUsecase mockGetAll;
  late MockGetAssessmentUsecase mockGetById;
  late CompareAssessmentsBloc bloc;

  // Minimal "Facility Information" section to trigger special comparisons
  final facilitySection = AssessmentSectionEntity(
    id: 'sec1',
    sectionNumber: '1',
    title: 'Facility Information Assessment',
    items: [],
  );

  final a1 = AssessmentFormEntity(
    id: '1',
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
      addressOrCoordinates: 'A',
      locationType: FacilityLocationType.urban,
    ),
    facilityIdentification: FacilityIdentificationEntity(
      facilityCode: 'X',
      facilityName: 'Fx',
      managingAuthority: ManagingAuthorityType.government,
      directorName: 'Dir1',
      directorPhone: 'P1',
      directorEmail: 'e1@x.com',
      respondentName: 'Resp1',
      respondentPosition: 'Pos1',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.standaloneTreatmentCenter,
    ),
    facilityServices: FacilityServicesEntity(
      hasOutpatientServices: true,
      hasInpatientServices: false,
    ),
    sections: [facilitySection],
    photos: [],
    isSubmitted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final a2 = AssessmentFormEntity(
    id: '2',
    assessorInfo: AssessorInfoEntity(
      name: 'Bob',
      email: 'b@y.com',
      phoneNumber: '222',
      assessmentDate: DateTime(2025, 2, 1),
    ),
    geoLocation: GeoLocationEntity(
      country: 'C',
      regionProvince: 'R',
      district: 'D',
      cityVillage: 'V',
      addressOrCoordinates: 'A',
      locationType: FacilityLocationType.urban,
    ),
    facilityIdentification: FacilityIdentificationEntity(
      facilityCode: 'X',
      facilityName: 'Fx',
      managingAuthority: ManagingAuthorityType.government,
      directorName: 'Dir2',
      directorPhone: 'P2',
      directorEmail: 'e2@y.com',
      respondentName: 'Resp2',
      respondentPosition: 'Pos2',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.standaloneTreatmentCenter,
    ),
    facilityServices: FacilityServicesEntity(
      hasOutpatientServices: false,
      hasInpatientServices: true,
    ),
    sections: [facilitySection],
    photos: [],
    isSubmitted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final resultA = AssessmentComparisonResult(
    sectionComparisons: [],
    overviewComparison: AssessmentOverviewComparison(
      firstFacilityName: a1.facilityIdentification.facilityName,
      secondFacilityName: a2.facilityIdentification.facilityName,
      firstAssessmentDate: a1.assessorInfo.assessmentDate!,
      secondAssessmentDate: a2.assessorInfo.assessmentDate!,
      firstAssessorName: a1.assessorInfo.name,
      secondAssessorName: a2.assessorInfo.name,
    ),
    statistics: ComparisonStatistics(
      totalItems: 0,
      changedItems: 0,
      improvedItems: 0,
      declinedItems: 0,
      unchangedItems: 0,
      improvementPercentage: 0.0,
    ),
  );
  const failureMsg = 'oops';

  setUp(() {
    mockGetAll = MockGetAllAssessmentsUsecase();
    mockGetById = MockGetAssessmentUsecase();
    bloc = CompareAssessmentsBloc(
      getAllAssessments: mockGetAll,
      getAssessmentById: mockGetById,
    );
  });

  tearDown(() => bloc.close());

  group('LoadAssessmentsForComparison', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits error on failure',
      build: () {
        when(
          mockGetAll(const NoParams()),
        ).thenAnswer((_) async => left(ServerFailure(message: failureMsg)));
        return bloc;
      },
      act: (b) => b.add(const LoadAssessmentsForComparison()),
      expect:
          () => [
            const AssessmentComparisonLoading(),
            AssessmentComparisonError(message: failureMsg),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits error if fewer than 2 valid assessments',
      build: () {
        when(mockGetAll(const NoParams())).thenAnswer((_) async => right([a1]));
        return bloc;
      },
      act: (b) => b.add(const LoadAssessmentsForComparison()),
      expect:
          () => [
            const AssessmentComparisonLoading(),
            const AssessmentComparisonError(
              message: 'At least 2 assessments are required for comparison',
            ),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits AssessmentSelectionLoaded when 2+ valid assessments',
      build: () {
        when(
          mockGetAll(const NoParams()),
        ).thenAnswer((_) async => right([a1, a2]));
        return bloc;
      },
      act: (b) => b.add(const LoadAssessmentsForComparison()),
      expect:
          () => [
            const AssessmentComparisonLoading(),
            AssessmentSelectionLoaded(availableAssessments: [a1, a2]),
          ],
    );
  });

  group('SelectFirst/SecondAssessment', () {
    const selId = '1';
    setUp(() async {
      when(
        mockGetAll(const NoParams()),
      ).thenAnswer((_) async => right([a1, a2]));
      when(
        mockGetById(Params(assessmentId: selId)),
      ).thenAnswer((_) async => right(a1));
      // preload selection
      bloc.add(const LoadAssessmentsForComparison());
      await Future.delayed(Duration.zero);
    });

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'SelectFirstAssessment updates firstSelectedAssessment',
      build: () => bloc,
      seed: () => AssessmentSelectionLoaded(availableAssessments: [a1, a2]),
      act: (b) => b.add(const SelectFirstAssessment(assessmentId: '1')),
      expect:
          () => [
            AssessmentSelectionLoaded(
              availableAssessments: [a1, a2],
              firstSelectedAssessment: a1,
            ),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'SelectSecondAssessment updates secondSelectedAssessment',
      build: () => bloc,
      seed: () => AssessmentSelectionLoaded(availableAssessments: [a1, a2]),
      act: (b) => b.add(const SelectSecondAssessment(assessmentId: '1')),
      expect:
          () => [
            AssessmentSelectionLoaded(
              availableAssessments: [a1, a2],
              secondSelectedAssessment: a1,
            ),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'compareAssessments throws → emits [Error]',
      build: () {
        // Create a subclass that forces _generateComparisonResult to throw:
        return _FailingCompareBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      seed:
          () => AssessmentSelectionLoaded(
            availableAssessments: [a1, a2],
            firstSelectedAssessment: a1,
            secondSelectedAssessment: a2,
          ),
      act: (b) => b.add(const CompareAssessments()),
      expect:
          () => [
            isA<AssessmentComparisonError>().having(
              (e) => e.message,
              'message',
              contains('Failed to generate comparison'),
            ),
          ],
    );
  });

  group('CompareAssessments', () {
    setUp(() async {
      when(
        mockGetAll(const NoParams()),
      ).thenAnswer((_) async => right([a1, a2]));
      when(mockGetById(any)).thenAnswer((inv) async {
        final id = (inv.positionalArguments.first as Params).assessmentId;
        return id == '1' ? right(a1) : right(a2);
      });
      // preload selection
      bloc.add(const LoadAssessmentsForComparison());
      await Future.delayed(Duration.zero);
      bloc.add(const SelectFirstAssessment(assessmentId: '1'));
      await Future.delayed(Duration.zero);
      bloc.add(const SelectSecondAssessment(assessmentId: '2'));
      await Future.delayed(Duration.zero);
    });

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits error if selections are same',
      build: () => bloc,
      seed:
          () => AssessmentSelectionLoaded(
            availableAssessments: [a1, a2],
            firstSelectedAssessment: a1,
            secondSelectedAssessment: a1,
          ),
      act: (b) => b.add(const CompareAssessments()),
      expect:
          () => [
            const AssessmentComparisonError(
              message: 'Please select two different assessments to compare',
            ),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits ComparisonLoaded on successful compare',
      build: () => bloc,
      seed:
          () => AssessmentSelectionLoaded(
            availableAssessments: [a1, a2],
            firstSelectedAssessment: a1,
            secondSelectedAssessment: a2,
          ),
      act: (b) => b.add(const CompareAssessments()),
      expect:
          () => [
            isA<AssessmentComparisonLoaded>()
                .having((s) => s.firstAssessment.id, 'first id', '1')
                .having((s) => s.secondAssessment.id, 'second id', '2'),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'switchComparisonOrder swaps first and second in SelectionLoaded',
      build: () {
        when(mockGetAll(any)).thenAnswer((_) async => right([a1, a2]));
        return CompareAssessmentsBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      seed:
          () => AssessmentSelectionLoaded(
            availableAssessments: [a1, a2],
            firstSelectedAssessment: a1,
            secondSelectedAssessment: a2,
          ),
      act: (b) => b.add(const SwitchComparisonOrder()),
      expect:
          () => [
            AssessmentSelectionLoaded(
              availableAssessments: [a1, a2],
              firstSelectedAssessment: a2,
              secondSelectedAssessment: a1,
            ),
          ],
    );
  });

  group('SwitchComparisonOrder', () {
    setUp(() async {
      // go through compare flow
      when(
        mockGetAll(const NoParams()),
      ).thenAnswer((_) async => right([a1, a2]));
      when(mockGetById(any)).thenAnswer((inv) async {
        final id = (inv.positionalArguments.first as Params).assessmentId;
        return id == '1' ? right(a1) : right(a2);
      });
      bloc.add(const LoadAssessmentsForComparison());
      await Future.delayed(Duration.zero);
      bloc.add(const SelectFirstAssessment(assessmentId: '1'));
      await Future.delayed(Duration.zero);
      bloc.add(const SelectSecondAssessment(assessmentId: '2'));
      await Future.delayed(Duration.zero);
      bloc.add(const CompareAssessments());
      await Future.delayed(Duration.zero);
    });

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'swaps order when in ComparisonLoaded',
      build: () => bloc,
      act: (b) => b.add(const SwitchComparisonOrder()),
      skip: 0,
      expect:
          () => [
            isA<AssessmentComparisonLoaded>()
                .having((s) => s.firstAssessment.id, 'first', '2')
                .having((s) => s.secondAssessment.id, 'second', '1'),
          ],
    );
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'resetComparison in ComparisonLoaded → re‐loads assessments',
      build: () {
        when(
          mockGetAll(const NoParams()),
        ).thenAnswer((_) async => right([a1, a2]));
        return CompareAssessmentsBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      seed:
          () => AssessmentComparisonLoaded(
            firstAssessment: a1,
            secondAssessment: a2,
            comparisonResult: resultA,
          ),
      act: (b) => b.add(const ResetComparison()),
      expect:
          () => [
            const AssessmentComparisonLoading(),
            AssessmentSelectionLoaded(availableAssessments: [a1, a2]),
          ],
    );
  });

  group('ResetComparison', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'clears selections when in SelectionLoaded',
      build: () {
        when(
          mockGetAll(const NoParams()),
        ).thenAnswer((_) async => right([a1, a2]));
        // stub getById so SelectFirst/Second don't throw
        when(
          mockGetById(Params(assessmentId: '1')),
        ).thenAnswer((_) async => right(a1));
        when(
          mockGetById(Params(assessmentId: '2')),
        ).thenAnswer((_) async => right(a2));

        return bloc;
      },
      act: (b) {
        b.add(const LoadAssessmentsForComparison());
        b.add(const SelectFirstAssessment(assessmentId: '1'));
        b.add(const SelectSecondAssessment(assessmentId: '2'));
        b.add(const ResetComparison());
      },
      expect:
          () => [
            const AssessmentComparisonLoading(),
            AssessmentSelectionLoaded(availableAssessments: [a1, a2]),
            AssessmentSelectionLoaded(
              availableAssessments: [a1, a2],
              firstSelectedAssessment: a1,
            ),
            AssessmentSelectionLoaded(
              availableAssessments: [a1, a2],
              firstSelectedAssessment: a1,
              secondSelectedAssessment: a2,
            ),
            AssessmentSelectionLoaded(
              availableAssessments: [a1, a2],
              firstSelectedAssessment: null,
              secondSelectedAssessment: null,
            ),
          ],
    );
  });

  group('ToggleComparisonSection & FilterComparisonByType', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'toggles expandedSections and filters after compare',
      build: () => bloc,
      act: (b) {
        when(
          mockGetAll(const NoParams()),
        ).thenAnswer((_) async => right([a1, a2]));
        when(mockGetById(any)).thenAnswer((inv) async {
          final id = (inv.positionalArguments.first as Params).assessmentId;
          return id == '1' ? right(a1) : right(a2);
        });
        b.add(const LoadAssessmentsForComparison());
        b.add(const SelectFirstAssessment(assessmentId: '1'));
        b.add(const SelectSecondAssessment(assessmentId: '2'));
        b.add(const CompareAssessments());
        b.add(const ToggleComparisonSection(sectionId: 'Facility Information'));
        b.add(const FilterComparisonByType(filter: ComparisonFilter.declined));
      },
      skip: 5,
      expect:
          () => [
            isA<AssessmentComparisonLoaded>().having(
              (s) => s.expandedSections,
              'expandedSections',
              contains('Facility Information'),
            ),
            isA<AssessmentComparisonLoaded>().having(
              (s) => s.currentFilter,
              'filter',
              ComparisonFilter.declined,
            ),
          ],
    );
  });

  group('error-catching in handlers', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits error when getAll throws',
      build: () {
        when(mockGetAll(any)).thenThrow(Exception('boom'));
        return CompareAssessmentsBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      act: (b) => b.add(const LoadAssessmentsForComparison()),
      expect:
          () => [
            const AssessmentComparisonLoading(),
            isA<AssessmentComparisonError>().having(
              (e) => e.message,
              'message',
              startsWith('Failed to load assessments: Exception: boom'),
            ),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits error when selectFirst throws',
      build: () {
        when(
          mockGetById(
            argThat(isA<Params>().having((p) => p.assessmentId, 'id', '1')),
          ),
        ).thenThrow(Exception('first-oops'));
        return CompareAssessmentsBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      seed: () => AssessmentSelectionLoaded(availableAssessments: [a1, a2]),
      act: (b) => b.add(const SelectFirstAssessment(assessmentId: '1')),
      expect:
          () => [
            isA<AssessmentComparisonError>().having(
              (e) => e.message,
              'message',
              startsWith(
                'Failed to load first assessment: Exception: first-oops',
              ),
            ),
          ],
    );

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits error when selectSecond throws',
      build: () {
        when(
          mockGetById(
            argThat(isA<Params>().having((p) => p.assessmentId, 'id', '2')),
          ),
        ).thenThrow(Exception('second-oops'));
        return CompareAssessmentsBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      seed:
          () => AssessmentSelectionLoaded(
            availableAssessments: [a1, a2],
            firstSelectedAssessment: a1,
          ),
      act: (b) => b.add(const SelectSecondAssessment(assessmentId: '2')),
      expect:
          () => [
            isA<AssessmentComparisonError>().having(
              (e) => e.message,
              'message',
              startsWith(
                'Failed to load second assessment: Exception: second-oops',
              ),
            ),
          ],
    );
  });

  group('comparison field logic', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'ComparisonLoaded contains "Assessor Name" marked changed',
      build: () {
        when(mockGetAll(any)).thenAnswer((_) async => right([a1, a2]));
        when(mockGetById(any)).thenAnswer((inv) async {
          final id = (inv.positionalArguments.first as Params).assessmentId;
          return id == '1' ? right(a1) : right(a2);
        });
        return CompareAssessmentsBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      act: (b) {
        b.add(const LoadAssessmentsForComparison());
        b.add(const SelectFirstAssessment(assessmentId: '1'));
        b.add(const SelectSecondAssessment(assessmentId: '2'));
        b.add(const CompareAssessments());
      },
      // skip: Loading, SelectionLoaded, SelectionLoaded(first), SelectionLoaded(second)
      skip: 4,
      expect:
          () => [
            isA<AssessmentComparisonLoaded>().having(
              (loaded) {
                final section =
                    loaded.comparisonResult.sectionComparisons.first;
                return section.itemComparisons.firstWhere(
                  (c) => c.itemId == 'Assessor Name',
                );
              },
              'Assessor Name comparison',
              predicate<ItemComparison>(
                (c) =>
                    c.type == ComparisonType.different &&
                    c.description == 'Changed from Alice to Bob',
              ),
            ),
          ],
    );
  });
  group('SelectFirstAssessment – failure branch', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits [Error] when getAssessmentById returns a Left(failure)',
      build: () {
        // stub the usecase to return failure
        when(
          mockGetById(Params(assessmentId: '1')),
        ).thenAnswer((_) async => left(ServerFailure(message: 'first‐fail')));
        return bloc;
      },
      // start from the "selection loaded" state so the handler runs
      seed: () => AssessmentSelectionLoaded(availableAssessments: [a1, a2]),
      act: (b) => b.add(const SelectFirstAssessment(assessmentId: '1')),
      expect: () => [const AssessmentComparisonError(message: 'first‐fail')],
    );
  });

  group('SelectSecondAssessment – failure branch', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits [Error] when getAssessmentById returns a Left(failure)',
      build: () {
        when(
          mockGetById(Params(assessmentId: '2')),
        ).thenAnswer((_) async => left(ServerFailure(message: 'second‐fail')));
        return bloc;
      },
      seed:
          () => AssessmentSelectionLoaded(
            availableAssessments: [a1, a2],
            firstSelectedAssessment: a1,
          ),
      act: (b) => b.add(const SelectSecondAssessment(assessmentId: '2')),
      expect: () => [const AssessmentComparisonError(message: 'second‐fail')],
    );
  });

  group('CompareAssessments – item-based sections', () {
    final itemOnlyInFirst = AssessmentItemEntity(
      id: 1,
      area: 'OnlyInFirst',
      selectedRating: AssessmentRatingEntity(
        id: '1',
        value: 0,
        label: '',
        description: '',
      ),
      itemNumber: '',
      sectionNumber: '',
      meetsTargetDescription: '',
      partiallyMeetsDescription: '',
      doesNotMeetDescription: '',
    );

    final itemOnlyInSecond = AssessmentItemEntity(
      id: 2,
      area: 'OnlyInSecond',
      selectedRating: AssessmentRatingEntity(
        value: 1,
        label: '',
        description: '',
        id: '2',
      ),
      itemNumber: '',
      sectionNumber: '',
      meetsTargetDescription: '',
      partiallyMeetsDescription: '',
      doesNotMeetDescription: '',
    );

    final otherSec1 = AssessmentSectionEntity(
      id: 'sec1',
      sectionNumber: '1',
      title: 'Other Section',
      items: [itemOnlyInFirst],
    );
    final otherSec2 = AssessmentSectionEntity(
      id: 'sec2',
      sectionNumber: '2',
      title: 'Other Section',
      items: [itemOnlyInSecond],
    );

    // make clones of your a1 and a2 that include the second section
    final a1WithOther = a1.copyWith(sections: [facilitySection, otherSec1]);
    final a2WithOther = a2.copyWith(sections: [facilitySection, otherSec2]);

    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'emits a SectionComparison for "Other Section" with firstOnly & secondOnly',
      build: () {
        when(
          mockGetAll(const NoParams()),
        ).thenAnswer((_) async => right([a1WithOther, a2WithOther]));
        when(mockGetById(any)).thenAnswer((inv) async {
          final id = (inv.positionalArguments.first as Params).assessmentId;
          return id == '1' ? right(a1WithOther) : right(a2WithOther);
        });
        return bloc;
      },
      act: (b) async {
        b.add(const LoadAssessmentsForComparison());
        await Future.delayed(Duration.zero);
        b.add(const SelectFirstAssessment(assessmentId: '1'));
        await Future.delayed(Duration.zero);
        b.add(const SelectSecondAssessment(assessmentId: '2'));
        await Future.delayed(Duration.zero);
        b.add(const CompareAssessments());
      },
      // skip the Loading + first SelectionLoaded + two more SelectionLoaded states
      skip: 4,
      verify: (bloc) {
        final loaded = bloc.state as AssessmentComparisonLoaded;
        // find the SectionComparison for "Other Section"
        final other = loaded.comparisonResult.sectionComparisons.firstWhere(
          (s) => s.sectionTitle == 'Other Section',
        );

        // Expect exactly two comparisons: one firstOnly, one secondOnly
        expect(other.itemComparisons.length, 1);
        final comp = other.itemComparisons.single;
        expect(comp.type, ComparisonType.improved);
        expect(
          comp.description,
          'Improved from Don\'t Know (DK) to Does not meet target (+) (1)',
        );
      },
    );
  });

  group('SwitchComparisonOrder – error in ComparisonLoaded', () {
    blocTest<CompareAssessmentsBloc, AssessmentComparisonState>(
      'throws → emits [Error]',
      build: () {
        return _FailingSwitchBloc(
          getAllAssessments: mockGetAll,
          getAssessmentById: mockGetById,
        );
      },
      seed:
          () => AssessmentComparisonLoaded(
            firstAssessment: a1,
            secondAssessment: a2,
            comparisonResult: resultA,
          ),
      act: (b) => b.add(const SwitchComparisonOrder()),
      expect:
          () => [
            isA<AssessmentComparisonError>().having(
              (e) => e.message,
              'message',
              contains('Failed to switch comparison order'),
            ),
          ],
    );
  });

  // ───── cover firstOnly, secondOnly, unchanged, declined, default-rating, NA branches ─────
  group('CompareAssessments – item-level branches', () {
    // one item only in first
    final onlyFirst = AssessmentItemEntity(
      id: 1,
      area: 'X',
      selectedRating: AssessmentRatingEntity(
        id: '1',
        value: 2,
        label: '',
        description: '',
      ),
      itemNumber: '',
      sectionNumber: '',
      meetsTargetDescription: '',
      partiallyMeetsDescription: '',
      doesNotMeetDescription: '',
    );
    // one item only in second
    final onlySecond = AssessmentItemEntity(
      id: 2,
      area: 'X',
      selectedRating: AssessmentRatingEntity(
        id: '2',
        value: 3,
        label: '',
        description: '',
      ),
      itemNumber: '',
      sectionNumber: '',
      meetsTargetDescription: '',
      partiallyMeetsDescription: '',
      doesNotMeetDescription: '',
    );
    // identical-rating item
    final same1 = onlyFirst.copyWith(
      id: 3,
      selectedRating: onlyFirst.selectedRating,
    );
    // declined branch: first=3, second=1
    final dec1 = onlySecond.copyWith(
      id: 4,
      selectedRating: AssessmentRatingEntity(
        id: '4',
        value: 3,
        label: '',
        description: '',
      ),
    );
    final dec2 = onlyFirst.copyWith(
      id: 5,
      selectedRating: AssessmentRatingEntity(
        id: '5',
        value: 1,
        label: '',
        description: '',
      ),
    );
    // default (unknown) rating on one side
    final unknown1 = onlyFirst.copyWith(
      id: 6,
      selectedRating: AssessmentRatingEntity(
        id: '6',
        value: 99,
        label: '',
        description: '',
      ),
    );
    final unknown2 = onlySecond;
    // NA rating on both sides
    final na1 = onlyFirst.copyWith(
      id: 7,
      selectedRating: AssessmentRatingEntity(
        id: '7',
        value: -1,
        label: '',
        description: '',
      ),
    );
    onlyFirst.copyWith(
      id: 8,
      selectedRating: AssessmentRatingEntity(
        id: '8',
        value: -1,
        label: '',
        description: '',
      ),
    );

    Future<void> doCompareWithSections(
      List<AssessmentSectionEntity> s1,
      List<AssessmentSectionEntity> s2,
      void Function(AssessmentComparisonLoaded) verify,
    ) async {
      when(mockGetAll(const NoParams())).thenAnswer(
        (_) async => right([
          a1.copyWith(sections: [facilitySection, ...s1]),
          a2.copyWith(sections: [facilitySection, ...s2]),
        ]),
      );
      when(mockGetById(any)).thenAnswer((inv) async {
        final id = (inv.positionalArguments.first as Params).assessmentId;
        return id == '1'
            ? right(a1.copyWith(sections: [facilitySection, ...s1]))
            : right(a2.copyWith(sections: [facilitySection, ...s2]));
      });
      bloc.add(const LoadAssessmentsForComparison());
      await Future.delayed(Duration.zero);
      bloc.add(const SelectFirstAssessment(assessmentId: '1'));
      await Future.delayed(Duration.zero);
      bloc.add(const SelectSecondAssessment(assessmentId: '2'));
      await Future.delayed(Duration.zero);
      bloc.add(const CompareAssessments());
      await Future.delayed(Duration.zero);

      final loaded = bloc.state as AssessmentComparisonLoaded;
      verify(loaded);
    }

    test('firstOnly branch', () async {
      final sec = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [onlyFirst],
      );
      await doCompareWithSections([sec], [], (loaded) {
        final sc = loaded.comparisonResult.sectionComparisons.firstWhere(
          (s) => s.sectionTitle == 'S',
        );
        expect(sc.itemComparisons.single.type, ComparisonType.firstOnly);
        expect(
          sc.itemComparisons.single.description,
          'Only in first assessment',
        );
      });
    });

    test('secondOnly branch', () async {
      final sec = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [onlySecond],
      );
      await doCompareWithSections([], [sec], (loaded) {
        final sc = loaded.comparisonResult.sectionComparisons.firstWhere(
          (s) => s.sectionTitle == 'S',
        );
        expect(sc.itemComparisons.single.type, ComparisonType.secondOnly);
        expect(
          sc.itemComparisons.single.description,
          'Only in second assessment',
        );
      });
    });

    test('unchanged branch', () async {
      final sec = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [same1],
      );
      await doCompareWithSections([sec], [sec], (loaded) {
        final sc = loaded.comparisonResult.sectionComparisons.firstWhere(
          (s) => s.sectionTitle == 'S',
        );
        expect(sc.itemComparisons.single.type, ComparisonType.unchanged);
        expect(sc.itemComparisons.single.description, 'No change');
      });
    });

    test('declined branch', () async {
      final sec1 = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [dec1],
      );
      final sec2 = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [dec2],
      );
      await doCompareWithSections([sec1], [sec2], (loaded) {
        final sc = loaded.comparisonResult.sectionComparisons.firstWhere(
          (s) => s.sectionTitle == 'S',
        );
        final c = sc.itemComparisons.single;
        expect(c.type, ComparisonType.declined);
        expect(c.description, contains('Declined from'));
      });
    });

    test('default-rating branch', () async {
      final sec1 = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [unknown1],
      );
      final sec2 = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [unknown2],
      );
      await doCompareWithSections([sec1], [sec2], (loaded) {
        final sc = loaded.comparisonResult.sectionComparisons.firstWhere(
          (s) => s.sectionTitle == 'S',
        );
        expect(
          sc.itemComparisons.single.description,
          startsWith('Changed from No rating'),
        );
        expect(sc.itemComparisons.single.type, ComparisonType.different);
      });
    });

    test('NA-rating branch', () async {
      final sec = AssessmentSectionEntity(
        id: 's',
        sectionNumber: '2',
        title: 'S',
        items: [na1],
      );
      await doCompareWithSections([sec], [sec], (loaded) {
        final sc = loaded.comparisonResult.sectionComparisons.firstWhere(
          (s) => s.sectionTitle == 'S',
        );
        expect(sc.itemComparisons.single.type, ComparisonType.unchanged);
        expect(sc.itemComparisons.single.firstValue, 'Not Applicable (NA)');
      });
    });
  });

  group('item‐level null‐null branch', () {
    test('both items null → returns Unknown/unchanged', () {
      // use the existing mockUsecases to build a "real" bloc:
      final bloc = CompareAssessmentsBloc(
        getAllAssessments: mockGetAll,
        getAssessmentById: mockGetById,
      );
      final comp = bloc.compareItemForTest(null, null, 'X');
      expect(comp.type, ComparisonType.unchanged);
      expect(comp.area, 'Unknown');
    });
  });

  group('compareItemForTest description switch cases', () {
    late CompareAssessmentsBloc bloc;
    setUp(() {
      bloc = CompareAssessmentsBloc(
        getAllAssessments: mockGetAll,
        getAssessmentById: mockGetById,
      );
    });

    test('firstOnly → "Only in first assessment"', () {
      final item = AssessmentItemEntity(
        id: 1,
        area: 'Any',
        selectedRating: AssessmentRatingEntity(
          id: 'r1',
          value: 1,
          label: '',
          description: '',
        ),
        itemNumber: '',
        sectionNumber: '',
        meetsTargetDescription: '',
        partiallyMeetsDescription: '',
        doesNotMeetDescription: '',
      );
      final comp = bloc.compareItemForTest(item, null, '0');
      expect(comp.type, ComparisonType.firstOnly);
      expect(comp.description, 'Only in first assessment');
    });

    test('secondOnly → "Only in second assessment"', () {
      final item = AssessmentItemEntity(
        id: 2,
        area: 'Any',
        selectedRating: AssessmentRatingEntity(
          id: 'r2',
          value: 2,
          label: '',
          description: '',
        ),
        itemNumber: '',
        sectionNumber: '',
        meetsTargetDescription: '',
        partiallyMeetsDescription: '',
        doesNotMeetDescription: '',
      );
      final comp = bloc.compareItemForTest(null, item, '0');
      expect(comp.type, ComparisonType.secondOnly);
      expect(comp.description, 'Only in second assessment');
    });

    test('unchanged → "No change"', () {
      final item = AssessmentItemEntity(
        id: 3,
        area: 'Any',
        selectedRating: AssessmentRatingEntity(
          id: 'r3',
          value: 1,
          label: '',
          description: '',
        ),
        itemNumber: '',
        sectionNumber: '',
        meetsTargetDescription: '',
        partiallyMeetsDescription: '',
        doesNotMeetDescription: '',
      );
      final comp = bloc.compareItemForTest(item, item, '0');
      expect(comp.type, ComparisonType.unchanged);
      expect(comp.description, 'No change');
    });
  });
}

class _FailingCompareBloc extends CompareAssessmentsBloc {
  _FailingCompareBloc({
    required super.getAllAssessments,
    required super.getAssessmentById,
  });

  @override
  AssessmentComparisonResult generateComparisonResult(
    AssessmentFormEntity first,
    AssessmentFormEntity second,
  ) {
    throw Exception('compare-gen-fail');
  }
}

class _FailingSwitchBloc extends CompareAssessmentsBloc {
  _FailingSwitchBloc({
    required super.getAllAssessments,
    required super.getAssessmentById,
  });

  @override
  AssessmentComparisonResult generateComparisonResult(
    AssessmentFormEntity first,
    AssessmentFormEntity second,
  ) {
    throw Exception('switch-gen-fail');
  }
}
