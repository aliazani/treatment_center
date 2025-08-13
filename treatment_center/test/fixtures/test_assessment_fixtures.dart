import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/photo_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
import 'package:uuid/uuid.dart';

/// Helper class for creating test assessment objects and fixtures for testing
class TestAssessmentFixtures {
  // Common constants to avoid magic values
  static final DateTime _defaultAssessmentDate = DateTime(2023, 5, 10);
  static final DateTime _defaultSubmissionDate = DateTime(2023, 5, 11);
  static final DateTime _defaultCreatedAt = DateTime(2023, 5, 9, 10, 0, 0);
  static final DateTime _defaultUpdatedAt = DateTime(2023, 5, 10, 14, 30, 0);
  static const String _defaultFacilityName = 'Test Facility';

  /// Create a test assessor info object with standard test values
  static AssessorInfoEntity createTestAssessorInfo() {
    return AssessorInfoEntity(
      name: 'Test Assessor',
      email: 'test@example.com',
      phoneNumber: '123456789',
      assessmentDate: _defaultAssessmentDate,
    );
  }

  /// Create a test assessor info model with standard test values
  static AssessorInfoModel createTestAssessorInfoModel() {
    return AssessorInfoModel(
      name: 'Test Assessor',
      email: 'test@example.com',
      phoneNumber: '123456789',
      assessmentDate: _defaultAssessmentDate,
    );
  }

  /// Create a test geo location object with standard test values
  static GeoLocationEntity createTestGeoLocation() {
    return const GeoLocationEntity(
      country: 'Test Country',
      regionProvince: 'Test Region',
      district: 'Test District',
      cityVillage: 'Test City',
      addressOrCoordinates: 'Test Address',
      locationType: FacilityLocationType.urban,
    );
  }

  /// Create a test geo location model with standard test values
  static GeoLocationModel createTestGeoLocationModel() {
    return const GeoLocationModel(
      country: 'Test Country',
      regionProvince: 'Test Region',
      district: 'Test District',
      cityVillage: 'Test City',
      addressOrCoordinates: 'Test Address',
      locationType: FacilityLocationType.urban,
      latitude: 50.80,
      longitude: 32.01,
    );
  }

  /// Create a test facility identification object with standard test values
  static FacilityIdentificationEntity createTestFacilityIdentification() {
    return const FacilityIdentificationEntity(
      facilityCode: 'TC001',
      facilityName: _defaultFacilityName,
      managingAuthority: ManagingAuthorityType.government,
      directorName: 'Test Director',
      directorPhone: '123456789',
      directorEmail: 'director@example.com',
      respondentName: 'Test Respondent',
      respondentPosition: 'Test Position',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.screeningAndTemporaryIsolation,
      existingFacilityType: ExistingFacilityType.primaryHealthClinic,
    );
  }

  /// Create a test facility identification model with standard test values
  static FacilityIdentificationModel createTestFacilityIdentificationModel() {
    return const FacilityIdentificationModel(
      facilityCode: 'TC001',
      facilityName: _defaultFacilityName,
      managingAuthority: ManagingAuthorityType.government,
      directorName: 'Test Director',
      directorPhone: '123456789',
      directorEmail: 'director@example.com',
      respondentName: 'Test Respondent',
      respondentPosition: 'Test Position',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.screeningAndTemporaryIsolation,
      existingFacilityType: ExistingFacilityType.primaryHealthClinic,
    );
  }

  /// Create a test facility services object with standard test values
  static FacilityServicesEntity createTestFacilityServices() {
    return const FacilityServicesEntity(
      hasOutpatientServices: true,
      hasInpatientServices: true,
      totalInpatientBeds: 50,
      icuBeds: 10,
      hasEmergencyUnit: true,
      hasIcuOrHighDependencyUnit: true,
    );
  }

  /// Create a test facility services model with standard test values
  static FacilityServicesModel createTestFacilityServicesModel() {
    return const FacilityServicesModel(
      hasOutpatientServices: true,
      hasInpatientServices: true,
      totalInpatientBeds: 50,
      icuBeds: 10,
      hasEmergencyUnit: true,
      hasIcuOrHighDependencyUnit: true,
    );
  }

  /// Create a test assessment item with configurable ID, section number and rating
  static AssessmentItemEntity createTestAssessmentItem({
    required int id,
    required String sectionNumber,
    AssessmentRatingEntity? selectedRating,
    String area = 'Test Area',
    String? comment,
  }) {
    return AssessmentItemEntity(
      id: id,
      sectionNumber: sectionNumber,
      itemNumber: id.toString(),
      area: area,
      meetsTargetDescription: 'Meets target description',
      partiallyMeetsDescription: 'Partially meets description',
      doesNotMeetDescription: 'Does not meet description',
      selectedRating: selectedRating,
      comment: comment,
    );
  }

  /// Create a test assessment item model with configurable ID, section number and rating
  static AssessmentItemModel createTestAssessmentItemModel({
    required int id,
    required String sectionNumber,
    AssessmentRatingModel? selectedRating,
    String area = 'Test Area',
    String? comment,
  }) {
    return AssessmentItemModel(
      id: id,
      sectionNumber: sectionNumber,
      area: area,
      meetsTargetDescription: 'Meets target description',
      partiallyMeetsDescription: 'Partially meets description',
      doesNotMeetDescription: 'Does not meet description',
      selectedRating: selectedRating,
      comment: comment,
      itemNumber: '$id',
    );
  }

  /// Create a test assessment section with configurable items
  static AssessmentSectionEntity createTestAssessmentSection({
    required String id,
    required String sectionNumber,
    int itemCount = 3,
    bool withRatings = false,
    AssessmentRatingEntity? ratingType,
    List<AssessmentItemEntity>? predefinedItems,
  }) {
    // Use predefined items if provided, otherwise generate them
    final items =
        predefinedItems ??
        List<AssessmentItemEntity>.generate(
          itemCount,
          (index) => createTestAssessmentItem(
            id: index,
            sectionNumber: '$sectionNumber.${index + 1}',
            selectedRating:
                withRatings
                    ? (ratingType ?? AssessmentRatingEntity.meetsTarget())
                    : null,
          ),
        );

    return AssessmentSectionEntity(
      id: id,
      sectionNumber: sectionNumber,
      title: 'Test Section $sectionNumber',
      description: 'Test section description',
      items: items,
    );
  }

  /// Create a test assessment section model with configurable items
  static AssessmentSectionModel createTestAssessmentSectionModel({
    required String id,
    required String sectionNumber,
    int itemCount = 3,
    bool withRatings = false,
    AssessmentRatingModel? ratingType,
    List<AssessmentItemModel>? predefinedItems,
  }) {
    // Use predefined items if provided, otherwise generate them
    final items =
        predefinedItems ??
        List<AssessmentItemModel>.generate(
          itemCount,
          (index) => createTestAssessmentItemModel(
            id: index,
            sectionNumber: '$sectionNumber.${index + 1}',
            selectedRating:
                withRatings
                    ? (ratingType ?? AssessmentRatingModel.meetsTarget())
                    : null,
          ),
        );

    return AssessmentSectionModel(
      id: id,
      sectionNumber: sectionNumber,
      title: 'Test Section $sectionNumber',
      description: 'Test section description',
      items: items,
    );
  }

  /// Create a basic test assessment form with configurable sections
  static AssessmentFormEntity createTestAssessmentForm({
    required String id,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool withRatings = false,
    bool isSubmitted = false,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AssessmentSectionEntity>? predefinedSections,
  }) {
    // Use predefined sections if provided, otherwise generate them
    final sections =
        predefinedSections ??
        List<AssessmentSectionEntity>.generate(
          sectionCount,
          (index) => createTestAssessmentSection(
            id: '$id-section-$index',
            sectionNumber: '${index + 1}',
            itemCount: itemsPerSection,
            withRatings: withRatings,
          ),
        );

    return AssessmentFormEntity(
      id: id,
      assessorInfo: createTestAssessorInfo(),
      geoLocation: createTestGeoLocation(),
      facilityIdentification: createTestFacilityIdentification(),
      facilityServices: createTestFacilityServices(),
      sections: sections,
      notes: 'Test assessment notes',
      isSubmitted: isSubmitted,
      submissionDate:
          isSubmitted ? (submissionDate ?? _defaultSubmissionDate) : null,
      createdAt: createdAt ?? _defaultCreatedAt,
      updatedAt: updatedAt ?? _defaultUpdatedAt,
    );
  }

  /// Create a test assessment form model with configurable sections
  /// This is the method needed for the local data source tests
  static AssessmentFormModel createTestAssessmentFormModel({
    required String id,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool withRatings = false,
    bool isSubmitted = false,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String notes = 'Test assessment notes',
    List<AssessmentSectionModel>? predefinedSections,
  }) {
    // Use predefined sections if provided, otherwise generate them
    final sections =
        predefinedSections ??
        List<AssessmentSectionModel>.generate(
          sectionCount,
          (index) => createTestAssessmentSectionModel(
            id: '$id-section-$index',
            sectionNumber: '${index + 1}',
            itemCount: itemsPerSection,
            withRatings: withRatings,
          ),
        );

    return AssessmentFormModel(
      id: id,
      assessorInfo: createTestAssessorInfoModel(),
      geoLocation: createTestGeoLocationModel(),
      facilityIdentification: createTestFacilityIdentificationModel(),
      facilityServices: createTestFacilityServicesModel(),
      sections: sections,
      notes: notes,
      isSubmitted: isSubmitted,
      submissionDate:
          isSubmitted ? (submissionDate ?? _defaultSubmissionDate) : null,
      createdAt: createdAt ?? _defaultCreatedAt,
      updatedAt: updatedAt ?? _defaultUpdatedAt,
    );
  }

  /// Creates an assessment with a mix of different ratings
  /// (1 Meets, 1 Partially Meets, 2 Does Not Meet, 1 Don't Know, 1 Not Applicable)
  static AssessmentFormEntity createMixedRatingsAssessment({
    required String id,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool isSubmitted = false,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Create specific sections with mixed ratings
    final section1Items = [
      createTestAssessmentItem(
        id: 0,
        sectionNumber: '1.1',
        selectedRating: AssessmentRatingEntity.meetsTarget(),
      ),
      createTestAssessmentItem(
        id: 1,
        sectionNumber: '1.2',
        selectedRating: AssessmentRatingEntity.partiallyMeetsTarget(),
      ),
      createTestAssessmentItem(
        id: 2,
        sectionNumber: '1.3',
        selectedRating: AssessmentRatingEntity.doesNotMeetTarget(),
      ),
    ];

    final section2Items = [
      createTestAssessmentItem(
        id: 0,
        sectionNumber: '2.1',
        selectedRating: AssessmentRatingEntity.dontKnow(),
      ),
      createTestAssessmentItem(
        id: 1,
        sectionNumber: '2.2',
        selectedRating: AssessmentRatingEntity.notApplicable(),
      ),
      createTestAssessmentItem(
        id: 2,
        sectionNumber: '2.3',
        selectedRating: AssessmentRatingEntity.doesNotMeetTarget(),
      ),
    ];

    final sections = [
      createTestAssessmentSection(
        id: '$id-section-0',
        sectionNumber: '1',
        predefinedItems: section1Items,
      ),
      createTestAssessmentSection(
        id: '$id-section-1',
        sectionNumber: '2',
        predefinedItems: section2Items,
      ),
    ];

    return createTestAssessmentForm(
      id: id,
      predefinedSections: sections,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an assessment model with a mix of different ratings
  static AssessmentFormModel createMixedRatingsAssessmentModel({
    required String id,
    bool isSubmitted = false,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Convert the domain entity to a model
    final entity = createMixedRatingsAssessment(
      id: id,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    // Convert entity to model
    return AssessmentFormModel(
      id: entity.id,
      assessorInfo: createTestAssessorInfoModel(),
      geoLocation: createTestGeoLocationModel(),
      facilityIdentification: createTestFacilityIdentificationModel(),
      facilityServices: createTestFacilityServicesModel(),
      sections:
          entity.sections.map((section) {
            final items =
                section.items.map((item) {
                  final rating =
                      item.selectedRating != null
                          ? AssessmentRatingModel(
                            id: item.selectedRating!.id,
                            value: item.selectedRating!.value,
                            label: item.selectedRating!.label,
                            description: item.selectedRating!.description,
                          )
                          : null;

                  return AssessmentItemModel(
                    id: item.id ?? 0,
                    sectionNumber: item.sectionNumber,
                    itemNumber: item.itemNumber,
                    area: item.area,
                    meetsTargetDescription: item.meetsTargetDescription,
                    partiallyMeetsDescription: item.partiallyMeetsDescription,
                    doesNotMeetDescription: item.doesNotMeetDescription,
                    selectedRating: rating,
                    comment: item.comment,
                  );
                }).toList();

            return AssessmentSectionModel(
              id: section.id,
              sectionNumber: section.sectionNumber,
              title: section.title,
              description: section.description,
              items: items,
            );
          }).toList(),
      notes: entity.notes,
      isSubmitted: entity.isSubmitted,
      submissionDate: entity.submissionDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Creates an assessment with 50% rated items (all Meets Target) and 50% unrated items
  static AssessmentFormEntity createPartiallyRatedAssessment({
    required String id,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool isSubmitted = false,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Create sections with alternating rated and unrated items
    final sections = List<AssessmentSectionEntity>.generate(sectionCount, (
      sectionIndex,
    ) {
      final items = List<AssessmentItemEntity>.generate(
        itemsPerSection,
        (itemIndex) => createTestAssessmentItem(
          id: itemIndex,
          sectionNumber: '${sectionIndex + 1}.${itemIndex + 1}',
          selectedRating:
              itemIndex % 2 == 0 ? AssessmentRatingEntity.meetsTarget() : null,
        ),
      );

      return createTestAssessmentSection(
        id: '$id-section-$sectionIndex',
        sectionNumber: '${sectionIndex + 1}',
        predefinedItems: items,
      );
    });

    return createTestAssessmentForm(
      id: id,
      predefinedSections: sections,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an assessment model with partially rated items
  static AssessmentFormModel createPartiallyRatedAssessmentModel({
    required String id,
    bool isSubmitted = false,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Convert entity to model
    final entity = createPartiallyRatedAssessment(
      id: id,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final sections =
        entity.sections.map((section) {
          final items =
              section.items.map((item) {
                final rating =
                    item.selectedRating != null
                        ? AssessmentRatingModel(
                          id: item.selectedRating!.id,
                          value: item.selectedRating!.value,
                          label: item.selectedRating!.label,
                          description: item.selectedRating!.description,
                        )
                        : null;

                return AssessmentItemModel(
                  id: item.id ?? 0,
                  sectionNumber: item.sectionNumber,
                  itemNumber: item.itemNumber,
                  area: item.area,
                  meetsTargetDescription: item.meetsTargetDescription,
                  partiallyMeetsDescription: item.partiallyMeetsDescription,
                  doesNotMeetDescription: item.doesNotMeetDescription,
                  selectedRating: rating,
                  comment: item.comment,
                );
              }).toList();

          return AssessmentSectionModel(
            id: section.id,
            sectionNumber: section.sectionNumber,
            title: section.title,
            description: section.description,
            items: items,
          );
        }).toList();

    return AssessmentFormModel(
      id: id,
      assessorInfo: createTestAssessorInfoModel(),
      geoLocation: createTestGeoLocationModel(),
      facilityIdentification: createTestFacilityIdentificationModel(),
      facilityServices: createTestFacilityServicesModel(),
      sections: sections,
      notes: 'Test assessment notes',
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt ?? _defaultCreatedAt,
      updatedAt: updatedAt ?? _defaultUpdatedAt,
    );
  }

  /// Creates an assessment marked as submitted
  static AssessmentFormEntity createSubmittedAssessment({
    required String id,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return createMixedRatingsAssessment(
      id: id,
      isSubmitted: true,
      submissionDate: submissionDate ?? DateTime(2024, 5, 1),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an assessment model marked as submitted
  static AssessmentFormModel createSubmittedAssessmentModel({
    required String id,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return createMixedRatingsAssessmentModel(
      id: id,
      isSubmitted: true,
      submissionDate: submissionDate ?? DateTime(2024, 5, 1),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an assessment with sections but no items
  static AssessmentFormEntity createAssessmentWithEmptySections({
    required String id,
    int sectionCount = 2,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final emptySections = List<AssessmentSectionEntity>.generate(
      sectionCount,
      (index) => AssessmentSectionEntity(
        id: '$id-section-$index',
        sectionNumber: '${index + 1}',
        title: 'Empty Section ${index + 1}',
        items: [],
      ),
    );

    return createTestAssessmentForm(
      id: id,
      predefinedSections: emptySections,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an assessment model with sections but no items
  static AssessmentFormModel createAssessmentWithEmptySectionsModel({
    required String id,
    int sectionCount = 2,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final emptySections = List<AssessmentSectionModel>.generate(
      sectionCount,
      (index) => AssessmentSectionModel(
        id: '$id-section-$index',
        sectionNumber: '${index + 1}',
        title: 'Empty Section ${index + 1}',
        items: [],
      ),
    );

    return createTestAssessmentFormModel(
      id: id,
      predefinedSections: emptySections,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an assessment with a specific custom configuration for testing
  static AssessmentFormEntity createCustomAssessment({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Create exactly 4 items with specific ratings for testing
    final sections = [
      AssessmentSectionEntity(
        id: 'section1',
        sectionNumber: '1',
        title: 'Section 1',
        items: [
          AssessmentItemEntity(
            id: 1,
            sectionNumber: '1.1',
            itemNumber: '1.1.1',
            area: 'Area 1',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: AssessmentRatingEntity.meetsTarget(),
          ),
          AssessmentItemEntity(
            id: 2,
            sectionNumber: '1.2',
            itemNumber: '1.2.1',
            area: 'Area 2',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: AssessmentRatingEntity.partiallyMeetsTarget(),
          ),
        ],
      ),
      AssessmentSectionEntity(
        id: 'section2',
        sectionNumber: '2',
        title: 'Section 2',
        items: [
          AssessmentItemEntity(
            id: 3,
            sectionNumber: '2.1',
            itemNumber: '2.1.1',
            area: 'Area 3',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: AssessmentRatingEntity.doesNotMeetTarget(),
          ),
          // Item with no rating
          AssessmentItemEntity(
            id: 4,
            sectionNumber: '2.2',
            itemNumber: '2.2.1',
            area: 'Area 4',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: null,
          ),
        ],
      ),
    ];

    return createTestAssessmentForm(
      id: id,
      predefinedSections: sections,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an assessment model with a specific custom configuration for testing
  static AssessmentFormModel createCustomAssessmentModel({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Convert entity to model
    final entity = createCustomAssessment(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final sections =
        entity.sections.map((section) {
          final items =
              section.items.map((item) {
                final rating =
                    item.selectedRating != null
                        ? AssessmentRatingModel(
                          id: item.selectedRating!.id,
                          value: item.selectedRating!.value,
                          label: item.selectedRating!.label,
                          description: item.selectedRating!.description,
                        )
                        : null;

                return AssessmentItemModel(
                  id: item.id ?? 0,
                  sectionNumber: item.sectionNumber,
                  itemNumber: item.itemNumber,
                  area: item.area,
                  meetsTargetDescription: item.meetsTargetDescription,
                  partiallyMeetsDescription: item.partiallyMeetsDescription,
                  doesNotMeetDescription: item.doesNotMeetDescription,
                  selectedRating: rating,
                  comment: item.comment,
                );
              }).toList();

          return AssessmentSectionModel(
            id: section.id,
            sectionNumber: section.sectionNumber,
            title: section.title,
            description: section.description,
            items: items,
          );
        }).toList();

    return AssessmentFormModel(
      id: id,
      assessorInfo: createTestAssessorInfoModel(),
      geoLocation: createTestGeoLocationModel(),
      facilityIdentification: createTestFacilityIdentificationModel(),
      facilityServices: createTestFacilityServicesModel(),
      sections: sections,
      notes: 'Test assessment notes',
      isSubmitted: false,
      submissionDate: null,
      createdAt: createdAt ?? _defaultCreatedAt,
      updatedAt: updatedAt ?? _defaultUpdatedAt,
    );
  }

  /// Creates test assessment analysis instances for equality testing
  // static AssessmentAnalysisUsecase createTestAnalysis({
  //   String assessmentId = 'test-id',
  //   String facilityName = _defaultFacilityName,
  //   DateTime? assessmentDate,
  //   double completionPercentage = 75.0,
  //   bool isSubmitted = true,
  //   int totalItems = 10,
  //   int completedItems = 8,
  //   int meetsTargetCount = 5,
  //   int partiallyMeetsCount = 2,
  //   int doesNotMeetCount = 1,
  //   int dontKnowCount = 0,
  //   int notApplicableCount = 0,
  //   DateTime? submissionDate,
  // }) {
  //   return AssessmentAnalysisUsecase(
  //     assessmentId: assessmentId,
  //     facilityName: facilityName,
  //     assessmentDate: assessmentDate ?? _defaultAssessmentDate,
  //     completionPercentage: completionPercentage,
  //     isSubmitted: isSubmitted,
  //     totalItems: totalItems,
  //     completedItems: completedItems,
  //     meetsTargetCount: meetsTargetCount,
  //     partiallyMeetsCount: partiallyMeetsCount,
  //     doesNotMeetCount: doesNotMeetCount,
  //     dontKnowCount: dontKnowCount,
  //     notApplicableCount: notApplicableCount,
  //     submissionDate: submissionDate ?? DateTime(2023, 5, 15),
  //   );
  // }

  // =================== PHOTO FIXTURES ===================

  /// Create a test photo model with configurable properties
  static PhotoModel createTestPhotoModel({
    String? id,
    String? fileName,
    String? filePath,
    PhotoSource? source,
    int? fileSizeBytes,
    DateTime? capturedAt,
    String? description,
  }) {
    return PhotoModel(
      id: Uuid().v4(), // unique per photo
      fileName: fileName ?? 'test_image.jpg',
      filePath: filePath ?? '/test/path/test_image.jpg',
      source: source ?? PhotoSource.camera,
      fileSizeBytes: fileSizeBytes ?? 2048,
      capturedAt: capturedAt ?? DateTime.now(),
      description: description,
    );
  }

  /// Create multiple test photos with different sources and properties
  static List<PhotoModel> createTestPhotos({
    int count = 3,
    bool mixSources = true,
    bool includeDescriptions = true,
    List<int>? fileSizes,
  }) {
    return List.generate(count, (index) {
      final sources = [PhotoSource.camera, PhotoSource.gallery];
      final source =
          mixSources ? sources[index % sources.length] : PhotoSource.camera;
      final fileSize =
          fileSizes != null && index < fileSizes.length
              ? fileSizes[index]
              : 1024 * (index + 1);

      return createTestPhotoModel(
        fileName: 'test_photo_${index + 1}.jpg',
        filePath: '/test/photos/test_photo_${index + 1}.jpg',
        source: source,
        fileSizeBytes: fileSize,
        description:
            includeDescriptions && index % 3 == 0
                ? 'Test photo ${index + 1} description'
                : null,
        capturedAt: DateTime.now().subtract(Duration(minutes: index * 5)),
      );
    });
  }

  /// Create an assessment model with photos
  static AssessmentFormModel createTestAssessmentModelWithPhotos({
    required String id,
    int photoCount = 2,
    bool mixPhotoSources = true,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool withRatings = false,
    bool isSubmitted = false,
    DateTime? submissionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final photos = createTestPhotos(
      count: photoCount,
      mixSources: mixPhotoSources,
    );

    final baseAssessment = createTestAssessmentFormModel(
      id: id,
      sectionCount: sectionCount,
      itemsPerSection: itemsPerSection,
      withRatings: withRatings,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    return baseAssessment.copyWith(photos: photos);
  }

  /// Create photos with specific timestamps for ordering tests
  static List<PhotoModel> createOrderedTestPhotos() {
    final now = DateTime.now();
    return [
      createTestPhotoModel(
        fileName: 'photo_3.jpg',
        capturedAt: now.subtract(Duration(minutes: 10)), // Latest
      ),
      createTestPhotoModel(
        fileName: 'photo_1.jpg',
        capturedAt: now.subtract(Duration(minutes: 30)), // Earliest
      ),
      createTestPhotoModel(
        fileName: 'photo_2.jpg',
        capturedAt: now.subtract(Duration(minutes: 20)), // Middle
      ),
    ];
  }

  // =================== PERFORMANCE TEST FIXTURES ===================

  /// Create multiple assessments for performance testing
  static List<AssessmentFormModel> createPerformanceTestAssessments({
    int count = 50,
    String idPrefix = 'perf',
    bool withPhotos = false,
    int photosPerAssessment = 2,
  }) {
    return List.generate(count, (index) {
      final assessment = createTestAssessmentFormModel(
        id: '$idPrefix-$index',
        sectionCount: 2,
        itemsPerSection: 3,
        withRatings: index % 2 == 0, // Alternate with/without ratings
      );

      if (withPhotos) {
        final photos = createTestPhotos(
          count: photosPerAssessment,
          mixSources: true,
        );
        return assessment.copyWith(photos: photos);
      }

      return assessment;
    });
  }

  /// Create an assessment with many photos for performance testing
  static AssessmentFormModel createLargePhotoAssessment({
    required String id,
    int photoCount = 10,
  }) {
    final photos = List.generate(
      photoCount,
      (index) => createTestPhotoModel(
        fileName: 'large_test_photo_${index + 1}.jpg',
        filePath: '/test/large_photos/large_test_photo_${index + 1}.jpg',
        source: index % 2 == 0 ? PhotoSource.camera : PhotoSource.gallery,
        fileSizeBytes: 5120 * (index + 1), // Varying large file sizes
      ),
    );

    return createTestAssessmentFormModel(id: id).copyWith(photos: photos);
  }

  // =================== ERROR SCENARIO FIXTURES ===================

  /// Create assessment with complex structure for error testing
  static AssessmentFormModel createComplexAssessmentForErrorTesting({
    required String id,
    bool includeRatings = true,
    int sectionCount = 3,
    int itemsPerSection = 4,
    int photoCount = 3,
  }) {
    final sections = List.generate(sectionCount, (sIndex) {
      final items = List.generate(itemsPerSection, (iIndex) {
        AssessmentRatingModel? rating;
        if (includeRatings && iIndex % 2 == 0) {
          final ratingTypes = [
            AssessmentRatingModel.meetsTarget(),
            AssessmentRatingModel.partiallyMeetsTarget(),
            AssessmentRatingModel.doesNotMeetTarget(),
          ];
          rating = ratingTypes[iIndex % ratingTypes.length];
        }

        return createTestAssessmentItemModel(
          id: sIndex * itemsPerSection + iIndex,
          sectionNumber: '${sIndex + 1}.${iIndex + 1}',
          selectedRating: rating,
        );
      });

      return createTestAssessmentSectionModel(
        id: '$id-section-$sIndex',
        sectionNumber: '${sIndex + 1}',
        predefinedItems: items,
      );
    });

    final photos = createTestPhotos(count: photoCount);

    return createTestAssessmentFormModel(
      id: id,
      predefinedSections: sections,
    ).copyWith(photos: photos);
  }

  // =================== UPDATE SCENARIO FIXTURES ===================

  /// Create assessment variants for testing simple vs complex updates
  static AssessmentFormModel createAssessmentForSimpleUpdate({
    required String id,
    String originalNotes = 'Original notes',
    bool originalSubmissionStatus = false,
  }) {
    return createTestAssessmentFormModel(
      id: id,
      notes: originalNotes,
      isSubmitted: originalSubmissionStatus,
    );
  }

  /// Create a simple update version of an assessment (only notes/submission status change)
  static AssessmentFormModel createSimpleUpdateAssessment({
    required AssessmentFormModel original,
    String? newNotes,
    bool? newSubmissionStatus,
    DateTime? newSubmissionDate,
  }) {
    return original.copyWith(
      notes: newNotes ?? 'Updated notes',
      isSubmitted: newSubmissionStatus ?? true,
      submissionDate: newSubmissionDate ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a complex update version of an assessment (core data changes)
  static AssessmentFormModel createComplexUpdateAssessment({
    required AssessmentFormModel original,
    String? newAssessorName,
    String? newFacilityCode,
    String? newFacilityName,
    String? newCountry,
  }) {
    final updatedAssessorInfo = AssessorInfoModel(
      name: newAssessorName ?? 'COMPLETELY DIFFERENT NAME',
      email: 'different@email.com',
      phoneNumber: '+9999999999',
      assessmentDate: DateTime.now(),
    );

    final updatedFacilityId = FacilityIdentificationModel(
      facilityCode: newFacilityCode ?? 'DIFFERENT001',
      facilityName: newFacilityName ?? 'Completely Different Hospital',
      managingAuthority: ManagingAuthorityType.privateForProfit,
      directorName: 'Dr. Different Director',
      directorPhone: '+8888888888',
      directorEmail: 'different@hospital.com',
      respondentName: 'Different Respondent',
      respondentPosition: 'Different Position',
      structureType: FacilityStructureType.temporaryShortTerm,
      facilityType: FacilityType.screeningAndTemporaryIsolation,
      existingFacilityType: ExistingFacilityType.otherGeneralHospital,
    );

    final updatedGeoLocation = GeoLocationModel(
      country: newCountry ?? 'Different Country',
      regionProvince: 'Different Region',
      district: 'Different District',
      cityVillage: 'Different City',
      addressOrCoordinates: 'Different Address',
      locationType: FacilityLocationType.rural,
      latitude: 34.5678,
      longitude: 78.9012,
    );

    return original.copyWith(
      assessorInfo: updatedAssessorInfo,
      facilityIdentification: updatedFacilityId,
      geoLocation: updatedGeoLocation,
      notes: 'Updated via complex path',
      updatedAt: DateTime.now(),
    );
  }

  // =================== SEARCH AND QUERY FIXTURES ===================

  /// Create test data specifically for search and query operations
  static Future<List<AssessmentFormModel>> createSearchTestData() {
    return Future.value([
      createTestAssessmentFormModel(
        id: 'search-1',
        isSubmitted: false,
      ).copyWith(
        assessorInfo: AssessorInfoModel(
          name: 'Dr. John Smith',
          email: 'john@test.com',
          phoneNumber: '+1111111111',
          assessmentDate: DateTime.now(),
        ),
        facilityIdentification: FacilityIdentificationModel(
          facilityCode: 'HOSP001',
          facilityName: 'Central Hospital',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Dr. Director',
          directorPhone: '+9999999999',
          directorEmail: 'director@hospital.com',
          respondentName: 'Respondent',
          respondentPosition: 'Admin',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
          existingFacilityType: ExistingFacilityType.firstReferralHospital,
        ),
      ),
      createTestAssessmentFormModel(
        id: 'search-2',
        isSubmitted: true,
        submissionDate: DateTime.now(),
      ).copyWith(
        assessorInfo: AssessorInfoModel(
          name: 'Dr. Jane Doe',
          email: 'jane@test.com',
          phoneNumber: '+2222222222',
          assessmentDate: DateTime.now(),
        ),
        facilityIdentification: FacilityIdentificationModel(
          facilityCode: 'CLINIC001',
          facilityName: 'Community Clinic',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Dr. Clinic Director',
          directorPhone: '+8888888888',
          directorEmail: 'director@clinic.com',
          respondentName: 'Clinic Respondent',
          respondentPosition: 'Manager',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
          existingFacilityType: ExistingFacilityType.firstReferralHospital,
        ),
      ),
    ]);
  }

  /// Create assessments for date range testing
  static List<AssessmentFormModel> createDateRangeTestAssessments() {
    final now = DateTime.now();
    return [
      createTestAssessmentFormModel(
        id: 'date-old',
        createdAt: now.subtract(Duration(days: 10)),
      ),
      createTestAssessmentFormModel(
        id: 'date-recent',
        createdAt: now.subtract(Duration(days: 2)),
      ),
      createTestAssessmentFormModel(id: 'date-today', createdAt: now),
    ];
  }

  // =================== VALIDATION AND EDGE CASE FIXTURES ===================

  /// Create an assessment with empty photo list
  static AssessmentFormModel createAssessmentWithoutPhotos({
    required String id,
  }) {
    return createTestAssessmentFormModel(id: id).copyWith(photos: []);
  }

  /// Create assessment with null/empty optional fields
  static AssessmentFormModel createMinimalAssessment({required String id}) {
    return createTestAssessmentFormModel(
      id: id,
      notes: '',
      isSubmitted: false,
      submissionDate: null,
    ).copyWith(photos: []);
  }

  /// Create assessment with maximum data (all optional fields filled)
  static AssessmentFormModel createMaximalAssessment({required String id}) {
    return createTestAssessmentFormModel(
      id: id,
      sectionCount: 5,
      itemsPerSection: 10,
      withRatings: true,
      isSubmitted: true,
      submissionDate: DateTime.now(),
      notes:
          'Comprehensive test assessment with all fields populated and extensive notes for testing purposes.',
    ).copyWith(
      photos: createTestPhotos(
        count: 8,
        mixSources: true,
        includeDescriptions: true,
      ),
    );
  }

  // =================== STREAM TESTING FIXTURES ===================

  /// Create assessments for stream testing with different states
  static List<AssessmentFormModel> createStreamTestAssessments() {
    final now = DateTime.now();
    return [
      createTestAssessmentFormModel(
        id: 'stream-unsubmitted-1',
        isSubmitted: false,
        createdAt: now.subtract(Duration(hours: 2)),
        updatedAt: now.subtract(Duration(hours: 1)),
      ),
      createTestAssessmentFormModel(
        id: 'stream-unsubmitted-2',
        isSubmitted: false,
        createdAt: now.subtract(Duration(hours: 3)),
        updatedAt: now.subtract(Duration(minutes: 30)),
      ),
      createTestAssessmentFormModel(
        id: 'stream-submitted-1',
        isSubmitted: true,
        submissionDate: now.subtract(Duration(days: 1)),
        createdAt: now.subtract(Duration(days: 2)),
        updatedAt: now.subtract(Duration(days: 1)),
      ),
    ];
  }

  // =================== PHOTO OPERATION SPECIFIC FIXTURES ===================

  /// Create photos with specific descriptions for testing description handling
  static List<PhotoModel> createPhotosWithMixedDescriptions() {
    return [
      createTestPhotoModel(
        fileName: 'with_description.jpg',
        description: 'Has description',
      ),
      createTestPhotoModel(
        fileName: 'without_description.jpg',
        description: null,
      ),
      createTestPhotoModel(fileName: 'empty_description.jpg', description: ''),
    ];
  }

  /// Create photos with different file sizes for testing
  static List<PhotoModel> createPhotosWithVariedSizes() {
    return [
      createTestPhotoModel(fileName: 'small_photo.jpg', fileSizeBytes: 512),
      createTestPhotoModel(fileName: 'medium_photo.jpg', fileSizeBytes: 2048),
      createTestPhotoModel(fileName: 'large_photo.jpg', fileSizeBytes: 8192),
    ];
  }

  /// Create a set of replacement photos for update testing
  static List<PhotoModel> createReplacementPhotos({String prefix = 'updated'}) {
    return [
      createTestPhotoModel(
        fileName: '${prefix}_photo_1.png',
        source: PhotoSource.gallery,
        description: 'Updated photo description',
        fileSizeBytes: 4096,
      ),
      createTestPhotoModel(
        fileName: '${prefix}_photo_2.png',
        source: PhotoSource.camera,
        fileSizeBytes: 4096,
      ),
      createTestPhotoModel(
        fileName: '${prefix}_photo_3.png',
        source: PhotoSource.gallery,
        fileSizeBytes: 8192,
        description: 'Third updated photo',
      ),
    ];
  }

  // =================== CONCURRENT OPERATION FIXTURES ===================

  /// Create identical assessments for concurrent operation testing
  static List<AssessmentFormModel> createConcurrentTestAssessments({
    required String baseId,
    int count = 3,
  }) {
    final baseAssessment = createTestAssessmentFormModel(id: baseId);
    return List.generate(count, (index) => baseAssessment);
  }

  // =================== BULK OPERATION FIXTURES ===================

  /// Create multiple assessments for bulk operations testing
  static List<AssessmentFormModel> createBulkTestAssessments({
    int count = 3,
    String idPrefix = 'bulk',
    bool mixSubmissionStatus = true,
  }) {
    return List.generate(count, (index) {
      final isSubmitted = mixSubmissionStatus ? index % 2 == 0 : false;
      return createTestAssessmentFormModel(
        id: '$idPrefix-$index',
        isSubmitted: isSubmitted,
        submissionDate: isSubmitted ? DateTime.now() : null,
      );
    });
  }

  /// Creates an assessment with specific rating labels for testing label counting
  static AssessmentFormModel createAssessmentWithSpecificRatingLabels({
    required String id,
  }) {
    final sections = [
      TestAssessmentFixtures.createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: AssessmentRatingModel(
              id: 'dk-rating',
              value: 0,
              label: 'DK', // Contains "DK"
              description: 'Don\'t Know',
            ),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            selectedRating: AssessmentRatingModel(
              id: 'na-rating',
              value: -1,
              label: 'NA', // Contains "NA"
              description: 'Not Applicable',
            ),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 3,
            sectionNumber: '1.3',
            selectedRating: AssessmentRatingModel(
              id: 'idk-rating',
              value: 0,
              label: 'IDK_Status', // Contains "DK" in middle
              description: 'I Don\'t Know Status',
            ),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 4,
            sectionNumber: '1.4',
            selectedRating: AssessmentRatingModel(
              id: 'status-na-rating',
              value: -1,
              label: 'Status_NA_Value', // Contains "NA" in middle
              description: 'Status Not Applicable Value',
            ),
          ),
        ],
      ),
    ];

    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
      predefinedSections: sections,
    );
  }

  /// Creates an assessment with special characters for XML escaping tests
  static AssessmentFormModel createAssessmentWithSpecialCharacters({
    required String id,
  }) {
    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
    ).copyWithModels(
      facilityIdentification: FacilityIdentificationModel(
        facilityCode: 'TF001',
        facilityName: 'Test & Company <Special>',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dr. Smith & Associates',
        directorPhone: '+1234567890',
        directorEmail: 'director@test.com',
        respondentName: 'Jane "Expert" Doe',
        respondentPosition: 'Manager',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.primaryHealthClinic,
      ),
      assessorInfo: AssessorInfoModel(
        name: 'John <XML> & Test',
        email: 'test+special@example.com',
        phoneNumber: '+1234567890',
        assessmentDate: DateTime(2023, 5, 10),
      ),
    );
  }

  /// Creates an assessment with special characters in facility code
  static AssessmentFormModel createAssessmentWithSpecialCodeCharacters({
    required String id,
  }) {
    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
    ).copyWithModels(
      facilityIdentification: FacilityIdentificationModel(
        facilityCode: 'TF/001<>',
        facilityName: 'Test Facility',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dr. Smith',
        directorPhone: '+1234567890',
        directorEmail: 'director@test.com',
        respondentName: 'Jane Doe',
        respondentPosition: 'Manager',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.primaryHealthClinic,
      ),
    );
  }

  /// Creates an assessment with "Not Applicable" rating
  static AssessmentFormModel createAssessmentWithNotApplicableRating({
    required String id,
  }) {
    final sections = [
      TestAssessmentFixtures.createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: AssessmentRatingModel(
              id: 'na-rating',
              value: -1,
              label: 'Not Applicable',
              description: 'This item is not applicable',
            ),
          ),
        ],
      ),
    ];

    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
      predefinedSections: sections,
    );
  }

  /// Creates an assessment with unknown rating value
  static AssessmentFormModel createAssessmentWithUnknownRating({
    required String id,
  }) {
    final sections = [
      TestAssessmentFixtures.createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: AssessmentRatingModel(
              id: 'unknown-rating',
              value: 99, // Unknown value
              label: 'Unknown Rating',
              description: 'This is an unknown rating type',
            ),
          ),
        ],
      ),
    ];

    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
      predefinedSections: sections,
    );
  }

  /// Creates an assessment with null value rating
  static AssessmentFormModel createAssessmentWithNullValueRating({
    required String id,
  }) {
    final sections = [
      TestAssessmentFixtures.createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: null, // Null rating
          ),
        ],
      ),
    ];

    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
      predefinedSections: sections,
    );
  }

  /// Creates an assessment that matches the specific test data from the original test
  /// This has exactly 4 items with 3 completed (75% completion rate)
  static AssessmentFormModel createOriginalTestAssessment({
    required String id,
    String facilityCode = 'TF001',
  }) {
    final sections = [
      TestAssessmentFixtures.createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: AssessmentRatingModel(
              id: 'meets-target',
              value: 3,
              label: 'Meets Target',
              description: 'Meets the target standard',
            ),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            selectedRating: AssessmentRatingModel(
              id: 'does-not-meet',
              value: 1,
              label: 'Does Not Meet',
              description: 'Does not meet the standard',
            ),
          ),
        ],
      ),
      TestAssessmentFixtures.createTestAssessmentSectionModel(
        id: '$id-section-2',
        sectionNumber: '2',
        predefinedItems: [
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 3,
            sectionNumber: '2.1',
            selectedRating: AssessmentRatingModel(
              id: 'partially-meets',
              value: 2,
              label: 'Partially Meets',
              description: 'Partially meets the standard',
            ),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 4,
            sectionNumber: '2.2',
            selectedRating: null, // Unrated item
          ),
        ],
      ),
    ];

    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
      predefinedSections: sections,
      isSubmitted: true,
    ).copyWithModels(
      facilityIdentification: FacilityIdentificationModel(
        facilityCode: facilityCode,
        facilityName: 'Test Facility',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dr. Smith',
        directorPhone: '+1234567890',
        directorEmail: 'director@test.com',
        respondentName: 'Jane Doe',
        respondentPosition: 'Manager',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.primaryHealthClinic,
      ),
      geoLocation: GeoLocationModel(
        country: 'Test Country',
        regionProvince: 'Test Region',
        district: 'Test District',
        cityVillage: 'Test City',
        addressOrCoordinates: '123 Test St',
        latitude: 10.0,
        longitude: 20.0,
        locationType: FacilityLocationType.urban,
      ),
      assessorInfo: AssessorInfoModel(
        name: 'John Doe',
        email: 'john@test.com',
        phoneNumber: '+1234567890',
        assessmentDate: DateTime(2024, 1, 15),
      ),
      facilityServices: FacilityServicesModel(
        hasOutpatientServices: true,
        hasInpatientServices: true,
        totalInpatientBeds: 100,
        icuBeds: 10,
        hasEmergencyUnit: true,
        hasIcuOrHighDependencyUnit: true,
      ),
    );
  }

  /// Creates a comprehensive assessment for integration testing
  static AssessmentFormModel createComprehensiveTestAssessment({
    required String id,
    bool includeAllRatingTypes = true,
  }) {
    if (!includeAllRatingTypes) {
      return TestAssessmentFixtures.createTestAssessmentFormModel(id: id);
    }

    final sections = [
      TestAssessmentFixtures.createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 3,
            sectionNumber: '1.3',
            selectedRating: AssessmentRatingModel.doesNotMeetTarget(),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 4,
            sectionNumber: '1.4',
            selectedRating: AssessmentRatingModel.dontKnow(),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 5,
            sectionNumber: '1.5',
            selectedRating: AssessmentRatingModel.notApplicable(),
          ),
          TestAssessmentFixtures.createTestAssessmentItemModel(
            id: 6,
            sectionNumber: '1.6',
            selectedRating: null, // Not answered
          ),
        ],
      ),
    ];

    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
      predefinedSections: sections,
    );
  }

  /// Creates an assessment for export performance testing
  static AssessmentFormModel createPerformanceTestAssessment({
    required String id,
    int sectionCount = 10,
    int itemsPerSection = 20,
  }) {
    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
      sectionCount: sectionCount,
      itemsPerSection: itemsPerSection,
      withRatings: true,
    );
  }

  /// Creates an assessment with very long text content for template testing
  static AssessmentFormModel createLongContentAssessment({required String id}) {
    final longText =
        'This is a very long facility name that contains many characters and might cause issues with template processing if not handled properly. ' *
        5;

    final facilityId = FacilityIdentificationModel(
      facilityCode: 'TC001',
      facilityName: longText,
      managingAuthority: ManagingAuthorityType.government,
      directorName: longText,
      directorPhone: '123456789',
      directorEmail: 'director@example.com',
      respondentName: 'Test Respondent',
      respondentPosition: 'Test Position',
      structureType: FacilityStructureType.permanent,
      facilityType: FacilityType.screeningAndTemporaryIsolation,
      existingFacilityType: ExistingFacilityType.primaryHealthClinic,
    );

    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
    ).copyWith(facilityIdentification: facilityId, notes: longText);
  }

  /// Creates an assessment with minimal required data for validation testing
  static AssessmentFormModel createMinimalValidAssessment({
    required String id,
    String facilityName = 'Minimal Facility',
    String facilityCode = 'MIN001',
  }) {
    return TestAssessmentFixtures.createMinimalAssessment(id: id).copyWith(
      facilityIdentification: FacilityIdentificationModel(
        facilityCode: facilityCode,
        facilityName: facilityName,
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Test Director',
        directorPhone: '123456789',
        directorEmail: 'director@example.com',
        respondentName: 'Test Respondent',
        respondentPosition: 'Test Position',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.primaryHealthClinic,
      ),
      sections: [
        TestAssessmentFixtures.createTestAssessmentSectionModel(
          id: '$id-section-1',
          sectionNumber: '1',
          itemCount: 1,
          withRatings: true,
        ),
      ],
    );
  }

  /// Creates assessments with different facility types for testing variety
  static List<AssessmentFormModel> createVariedFacilityTypeAssessments({
    String idPrefix = 'varied',
  }) {
    final facilityTypes = [
      FacilityType.screeningAndTemporaryIsolation,
      FacilityType.standaloneTreatmentCenter,
    ];

    return facilityTypes.asMap().entries.map((entry) {
      final index = entry.key;
      final facilityType = entry.value;

      return TestAssessmentFixtures.createTestAssessmentFormModel(
        id: '$idPrefix-$index',
      ).copyWithModels(
        facilityIdentification: FacilityIdentificationModel(
          facilityCode: 'FT00${index + 1}',
          facilityName: 'Facility Type ${index + 1}',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Test Director',
          directorPhone: '123456789',
          directorEmail: 'director@example.com',
          respondentName: 'Test Respondent',
          respondentPosition: 'Test Position',
          structureType: FacilityStructureType.permanent,
          facilityType: facilityType,
          existingFacilityType: ExistingFacilityType.primaryHealthClinic,
        ),
      );
    }).toList();
  }

  /// Creates an assessment with different managing authority types
  static AssessmentFormModel createAssessmentWithManagingAuthority({
    required String id,
    required ManagingAuthorityType managingAuthority,
  }) {
    return TestAssessmentFixtures.createTestAssessmentFormModel(
      id: id,
    ).copyWithModels(
      facilityIdentification: FacilityIdentificationModel(
        facilityCode: 'TC001',
        facilityName: 'Test Facility',
        managingAuthority: managingAuthority,
        directorName: 'Test Director',
        directorPhone: '123456789',
        directorEmail: 'director@example.com',
        respondentName: 'Test Respondent',
        respondentPosition: 'Test Position',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.primaryHealthClinic,
      ),
    );
  }

  /// Creates assessment data for boundary condition testing
  static Map<String, AssessmentFormModel> createBoundaryTestAssessments() {
    return {
      'zero_items':
          TestAssessmentFixtures.createAssessmentWithEmptySectionsModel(
            id: 'boundary-zero',
          ),
      'single_item': TestAssessmentFixtures.createTestAssessmentFormModel(
        id: 'boundary-single',
        sectionCount: 1,
        itemsPerSection: 1,
        withRatings: true,
      ),
      'max_items': TestAssessmentFixtures.createMaximalAssessment(
        id: 'boundary-max',
      ),
      'empty_strings': TestAssessmentFixtures.createMinimalAssessment(
        id: 'boundary-empty',
      ),
    };
  }

  static AssessmentFormModel createAssessmentWithEmptySectionOneAndOthers({
    required String id,
    int sectionCount = 2,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final emptySections = List<AssessmentSectionModel>.generate(
      sectionCount,
      (index) => AssessmentSectionModel(
        id: '$id-section-$index',
        sectionNumber: '${index + 1}',
        title: 'Empty Section ${index + 1}',
        items: [],
      ),
    );
    return AssessmentFormModel(
      id: id,
      assessorInfo: AssessorInfoModel(
        name: '',
        email: '',
        phoneNumber: '',
        assessmentDate: null,
      ),
      geoLocation: GeoLocationModel(
        country: '',
        regionProvince: '',
        district: '',
        cityVillage: '',
        addressOrCoordinates: '',
        latitude: null,
        longitude: null,
        locationType: null,
      ),
      facilityIdentification: FacilityIdentificationModel(
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
      ),
      sections: emptySections,
      isSubmitted: false,
      createdAt: createdAt ?? _defaultCreatedAt,
      updatedAt: updatedAt ?? _defaultUpdatedAt,
      facilityServices: FacilityServicesModel(
        hasOutpatientServices: null,
        hasInpatientServices: null,
      ),
    );
  }

  /// Creates an assessment with double values for coordinates
  static AssessmentFormModel createAssessmentWithDoubleValues({
    required String id,
    double latitude = 10.523,
    double longitude = 20.732,
  }) {
    return createTestAssessmentFormModel(id: id).copyWithModels(
      geoLocation: GeoLocationModel(
        country: 'Test Country',
        regionProvince: 'Test Region',
        district: 'Test District',
        cityVillage: 'Test City',
        addressOrCoordinates: '123 Test St',
        latitude: latitude,
        longitude: longitude,
        locationType: FacilityLocationType.urban,
      ),
      facilityServices: FacilityServicesModel(
        hasOutpatientServices: true,
        hasInpatientServices: true,
        totalInpatientBeds: 100,
        icuBeds: 10,
        hasEmergencyUnit: true,
        hasIcuOrHighDependencyUnit: true,
      ),
    );
  }

  /// Creates an assessment with null coordinate values
  static AssessmentFormModel createAssessmentWithNullValues({
    required String id,
  }) {
    return createTestAssessmentFormModel(id: id).copyWithModels(
      facilityIdentification: FacilityIdentificationModel(
        facilityName: 'Test Facility',
        facilityCode: 'TF001',
        directorName: '',
        directorPhone: '',
        directorEmail: '',
        respondentName: '',
        respondentPosition: '',
        managingAuthority: ManagingAuthorityType.government,
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: null,
      ),
      geoLocation: GeoLocationModel(
        country: 'Test Country',
        regionProvince: 'Test Region',
        district: 'Test District',
        cityVillage: 'Test City',
        addressOrCoordinates: '123 Test St',
        latitude: null,
        longitude: null,
        locationType: FacilityLocationType.urban,
      ),
    );
  }

  /// Creates an assessment with mixed value types for testing cell value handling
  static AssessmentFormModel createAssessmentWithMixedValueTypes({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'Complex Item with special characters: & < > " \' €',
            selectedRating: AssessmentRatingModel(
              value: 3,
              label: 'Complex Data',
              id: '',
              description: '',
            ),
            comment: 'Test comment with special characters: & < > " \' €',
          ),
        ],
      ),
    ];

    return createTestAssessmentFormModel(
      id: id,
      predefinedSections:
          sections
              .map(
                (e) => createTestAssessmentSectionModel(
                  id: e.id ?? '',
                  sectionNumber: e.sectionNumber,
                  predefinedItems:
                      e.items
                          .map(
                            (item) => createTestAssessmentItemModel(
                              id: item.id ?? 0,
                              sectionNumber: item.sectionNumber,
                              selectedRating:
                                  item.selectedRating != null
                                      ? AssessmentRatingModel(
                                        id: item.selectedRating!.id,
                                        value: item.selectedRating!.value,
                                        label: item.selectedRating!.label,
                                        description:
                                            item.selectedRating!.description,
                                      )
                                      : null,
                              area: item.area,
                              comment: item.comment,
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    );
  }

  /// Creates an assessment with "Don't Know" (DK) rating
  static AssessmentFormModel createAssessmentWithDKRating({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'Don\'t Know Item',
            selectedRating: AssessmentRatingModel(
              value: 0,
              label: 'DK',
              id: '',
              description: '',
            ),
          ),
          createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            area: 'Regular Item',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
        ],
      ),
    ];

    final sectionModels =
        sections
            .map(
              (e) => createTestAssessmentSectionModel(
                id: e.id ?? '',
                sectionNumber: e.sectionNumber,
                predefinedItems:
                    e.items
                        .map(
                          (item) => createTestAssessmentItemModel(
                            id: item.id ?? 0,
                            sectionNumber: item.sectionNumber,
                            selectedRating:
                                item.selectedRating != null
                                    ? AssessmentRatingModel(
                                      id: item.selectedRating!.id,
                                      value: item.selectedRating!.value,
                                      label: item.selectedRating!.label,
                                      description:
                                          item.selectedRating!.description,
                                    )
                                    : null,
                            area: item.area,
                            comment: item.comment,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();
    return createTestAssessmentFormModel(
      id: id,
      predefinedSections: sectionModels,
    );
  }

  /// Creates an assessment with "Not Applicable" (NA) rating
  static AssessmentFormModel createAssessmentWithNARating({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'Not Applicable Item',
            selectedRating: AssessmentRatingModel(
              value: -1,
              label: 'NA',
              id: '',
              description: '',
            ),
          ),
          createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            area: 'Regular Item',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
        ],
      ),
    ];

    final sectionModels =
        sections
            .map(
              (e) => createTestAssessmentSectionModel(
                id: e.id ?? '',
                sectionNumber: e.sectionNumber,
                predefinedItems:
                    e.items
                        .map(
                          (item) => createTestAssessmentItemModel(
                            id: item.id ?? 0,
                            sectionNumber: item.sectionNumber,
                            selectedRating:
                                item.selectedRating != null
                                    ? AssessmentRatingModel(
                                      id: item.selectedRating!.id,
                                      value: item.selectedRating!.value,
                                      label: item.selectedRating!.label,
                                      description:
                                          item.selectedRating!.description,
                                    )
                                    : null,
                            area: item.area,
                            comment: item.comment,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();
    return createTestAssessmentFormModel(
      id: id,
      predefinedSections: sectionModels,
    );
  }

  /// Creates an assessment with special characters in section names
  static AssessmentFormModel createAssessmentWithSpecialSectionNames({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'Item 1',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
        ],
      ).copyWith(title: 'Section/With\\Special?*[]<>Characters'),
    ];

    final sectionModels =
        sections
            .map(
              (e) => createTestAssessmentSectionModel(
                id: e.id ?? '',
                sectionNumber: e.sectionNumber,
                predefinedItems:
                    e.items
                        .map(
                          (item) => createTestAssessmentItemModel(
                            id: item.id ?? 0,
                            sectionNumber: item.sectionNumber,
                            selectedRating:
                                item.selectedRating != null
                                    ? AssessmentRatingModel(
                                      id: item.selectedRating!.id,
                                      value: item.selectedRating!.value,
                                      label: item.selectedRating!.label,
                                      description:
                                          item.selectedRating!.description,
                                    )
                                    : null,
                            area: item.area,
                            comment: item.comment,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();
    return createTestAssessmentFormModel(
      id: id,
      predefinedSections: sectionModels,
    );
  }

  /// Creates an assessment with section descriptions
  static AssessmentFormModel createAssessmentWithSectionDescriptions({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'Building condition',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
        ],
      ).copyWith(
        title: 'Infrastructure Assessment',
        description:
            'This section evaluates the physical infrastructure and basic facilities.',
      ),
      createTestAssessmentSectionModel(
        id: '$id-section-2',
        sectionNumber: '2',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '2.1',
            area: 'Equipment availability',
            selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
          ),
        ],
      ).copyWith(
        title: 'Equipment Assessment',
        description:
            'This section covers medical equipment and technical resources available.',
      ),
    ];

    final sectionModels =
        sections
            .map(
              (e) => createTestAssessmentSectionModel(
                id: e.id ?? '',
                sectionNumber: e.sectionNumber,
                predefinedItems:
                    e.items
                        .map(
                          (item) => createTestAssessmentItemModel(
                            id: item.id ?? 0,
                            sectionNumber: item.sectionNumber,
                            selectedRating:
                                item.selectedRating != null
                                    ? AssessmentRatingModel(
                                      id: item.selectedRating!.id,
                                      value: item.selectedRating!.value,
                                      label: item.selectedRating!.label,
                                      description:
                                          item.selectedRating!.description,
                                    )
                                    : null,
                            area: item.area,
                            comment: item.comment,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();
    return createTestAssessmentFormModel(
      id: id,
      predefinedSections: sectionModels,
    );
  }

  /// Creates an assessment with specific ratings for rating counting tests
  static AssessmentFormModel createAssessmentWithSpecificRatings({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'Rating 3',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
          createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            area: 'Rating 3',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
          createTestAssessmentItemModel(
            id: 3,
            sectionNumber: '1.3',
            area: 'Rating 1',
            selectedRating: AssessmentRatingModel.doesNotMeetTarget(),
          ),
          createTestAssessmentItemModel(
            id: 4,
            sectionNumber: '1.4',
            area: 'Rating 2',
            selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
          ),
        ],
      ),
    ];

    return createTestAssessmentFormModel(id: id, predefinedSections: sections);
  }

  /// Creates an assessment with specific labels for label counting tests
  static AssessmentFormModel createAssessmentWithSpecificLabels({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'DK Item',
            selectedRating: AssessmentRatingModel(
              value: 0,
              label: 'DK',
              id: '',
              description: '',
            ),
          ),
          createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            area: 'NA Item',
            selectedRating: AssessmentRatingModel(
              value: -1,
              label: 'NA',
              id: '',
              description: '',
            ),
          ),
          createTestAssessmentItemModel(
            id: 3,
            sectionNumber: '1.3',
            area: 'Contains DK',
            selectedRating: AssessmentRatingModel(
              value: 0,
              label: 'Status_DK_Value',
              id: '',
              description: '',
            ),
          ),
          createTestAssessmentItemModel(
            id: 4,
            sectionNumber: '1.4',
            area: 'Contains NA',
            selectedRating: AssessmentRatingModel(
              value: -1,
              label: 'Value_NA_Status',
              id: '',
              description: '',
            ),
          ),
        ],
      ),
    ];

    return createTestAssessmentFormModel(id: id, predefinedSections: sections);
  }

  /// Creates an assessment with unanswered items for rating counting
  static AssessmentFormModel createAssessmentWithUnansweredItems({
    required String id,
  }) {
    final sections = [
      createTestAssessmentSectionModel(
        id: '$id-section-1',
        sectionNumber: '1',
        predefinedItems: [
          createTestAssessmentItemModel(
            id: 1,
            sectionNumber: '1.1',
            area: 'Answered',
            selectedRating: AssessmentRatingModel.meetsTarget(),
          ),
          createTestAssessmentItemModel(
            id: 2,
            sectionNumber: '1.2',
            area: 'Unanswered',
            selectedRating: null,
          ),
          createTestAssessmentItemModel(
            id: 3,
            sectionNumber: '1.3',
            area: 'Answered',
            selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
          ),
          createTestAssessmentItemModel(
            id: 4,
            sectionNumber: '1.4',
            area: 'Unanswered',
            selectedRating: null,
          ),
        ],
      ),
    ];

    return createTestAssessmentFormModel(id: id, predefinedSections: sections);
  }

  /// Creates an assessment with empty facility code
  static AssessmentFormModel createAssessmentWithEmptyFacilityCode({
    required String id,
  }) {
    return createTestAssessmentFormModel(id: id).copyWithModels(
      facilityIdentification: FacilityIdentificationModel(
        facilityName: 'Test Facility',
        facilityCode: '',
        directorName: 'Dr. Smith',
        directorPhone: '+1234567890',
        directorEmail: 'director@test.com',
        respondentName: 'Jane Doe',
        respondentPosition: 'Manager',
        managingAuthority: ManagingAuthorityType.government,
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.firstReferralHospital,
      ),
    );
  }

  /// Creates photos with mixed sources for testing
  static List<PhotoModel> createPhotosWithMixedSources({int count = 4}) {
    return List.generate(count, (index) {
      final sources = [PhotoSource.camera, PhotoSource.gallery];
      return createTestPhotoModel(
        fileName: 'mixed_photo_${index + 1}.jpg',
        filePath: '/test/mixed_photos/mixed_photo_${index + 1}.jpg',
        source: sources[index % sources.length],
        fileSizeBytes: 1024 * (index + 1),
      );
    });
  }

  /// Creates an assessment with mixed photo sources
  static AssessmentFormModel createAssessmentWithMixedPhotoSources({
    required String id,
  }) {
    final photos = createPhotosWithMixedSources();
    return createTestAssessmentFormModel(id: id).copyWith(photos: photos);
  }

  /// Creates photos with large file sizes (>5MB)
  static List<PhotoModel> createLargePhotos({int count = 3}) {
    return List.generate(count, (index) {
      return createTestPhotoModel(
        fileName: 'large_photo_${index + 1}.jpg',
        filePath: '/test/large_photos/large_photo_${index + 1}.jpg',
        source: index % 2 == 0 ? PhotoSource.camera : PhotoSource.gallery,
        fileSizeBytes: 6 * 1024 * 1024, // 6MB - larger than 5MB threshold
      );
    });
  }

  /// Creates an assessment with large photos
  static AssessmentFormModel createAssessmentWithLargePhotos({
    required String id,
  }) {
    final photos = createLargePhotos();
    final normalPhotos = [createTestPhotoModel(fileName: 'normal.jpg')];
    return createTestAssessmentFormModel(
      id: id,
    ).copyWith(photos: [...photos, ...normalPhotos]);
  }

  /// Creates an assessment with complete section 1 data
  static AssessmentFormModel createAssessmentWithCompleteSection1({
    required String id,
  }) {
    return createTestAssessmentFormModel(id: id)
        .copyWithModels(
          facilityIdentification: FacilityIdentificationModel(
            facilityName: 'Complete Test Facility',
            facilityCode: 'CTF001',
            directorName: 'Dr. Complete Smith',
            directorPhone: '+1234567890',
            directorEmail: 'complete@test.com',
            respondentName: 'Complete Jane Doe',
            respondentPosition: 'Complete Manager',
            managingAuthority: ManagingAuthorityType.government,
            structureType: FacilityStructureType.permanent,
            facilityType: FacilityType.screeningAndTemporaryIsolation,
            existingFacilityType: ExistingFacilityType.firstReferralHospital,
          ),
          geoLocation: GeoLocationModel(
            country: 'Complete Country',
            regionProvince: 'Complete Region',
            district: 'Complete District',
            cityVillage: 'Complete City',
            addressOrCoordinates: '123 Complete St',
            latitude: 10.0,
            longitude: 20.0,
            locationType: FacilityLocationType.urban,
          ),
          assessorInfo: AssessorInfoModel(
            name: 'Complete John Doe',
            email: 'complete.john@test.com',
            phoneNumber: '+1234567890',
            assessmentDate: DateTime(2024, 1, 15),
          ),
          facilityServices: FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: 100,
            icuBeds: 10,
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          ),
        )
        .copyWith(photos: createTestPhotos(count: 2));
  }

  /// Creates an assessment with incomplete section 1 data
  static AssessmentFormModel createAssessmentWithIncompleteSection1({
    required String id,
  }) {
    return createTestAssessmentFormModel(id: id)
        .copyWithModels(
          facilityIdentification: FacilityIdentificationModel(
            facilityName: 'Incomplete Facility',
            facilityCode: '',
            directorName: '',
            directorPhone: '',
            directorEmail: '',
            respondentName: '',
            respondentPosition: '',
            managingAuthority: ManagingAuthorityType.government,
            structureType: FacilityStructureType.permanent,
            facilityType: FacilityType.screeningAndTemporaryIsolation,
            existingFacilityType: null,
          ),
          geoLocation: GeoLocationModel(
            country: '',
            regionProvince: '',
            district: '',
            cityVillage: '',
            addressOrCoordinates: '',
            latitude: null,
            longitude: null,
            locationType: FacilityLocationType.urban,
          ),
          assessorInfo: AssessorInfoModel(
            name: '',
            email: '',
            phoneNumber: '',
            assessmentDate: DateTime(2024, 1, 15),
          ),
          facilityServices: FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: false,
            totalInpatientBeds: null,
            icuBeds: null,
            hasEmergencyUnit: null,
            hasIcuOrHighDependencyUnit: null,
          ),
        )
        .copyWith(photos: []);
  }
}
