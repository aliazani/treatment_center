import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/analyse_assessment.dart';

/// Helper class for creating test assessment objects and fixtures for testing
class TestAssessmentFixtures {
  // Common constants to avoid magic values
  static final DateTime _defaultAssessmentDate = DateTime(2023, 5, 10);
  static final DateTime _defaultSubmissionDate = DateTime(2023, 5, 11);
  static const String _defaultFacilityName = 'Test Facility';

  /// Create a test assessor info object with standard test values
  static AssessorInfo createTestAssessorInfo() {
    return AssessorInfo(
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
  static GeoLocation createTestGeoLocation() {
    return const GeoLocation(
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
    );
  }

  /// Create a test facility identification object with standard test values
  static FacilityIdentification createTestFacilityIdentification() {
    return const FacilityIdentification(
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
  static FacilityServices createTestFacilityServices() {
    return const FacilityServices(
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
  static AssessmentItem createTestAssessmentItem({
    required String id,
    required String sectionNumber,
    AssessmentRating? selectedRating,
    String area = 'Test Area',
    String? comment,
  }) {
    return AssessmentItem(
      id: id,
      sectionNumber: sectionNumber,
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
    required String id,
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
    );
  }

  /// Create a test assessment section with configurable items
  static AssessmentSection createTestAssessmentSection({
    required String id,
    required String sectionNumber,
    int itemCount = 3,
    bool withRatings = false,
    AssessmentRating? ratingType,
    List<AssessmentItem>? predefinedItems,
  }) {
    // Use predefined items if provided, otherwise generate them
    final items =
        predefinedItems ??
        List<AssessmentItem>.generate(
          itemCount,
          (index) => createTestAssessmentItem(
            id: '$id-item-$index',
            sectionNumber: '$sectionNumber.${index + 1}',
            selectedRating:
                withRatings
                    ? (ratingType ?? AssessmentRating.meetsTarget())
                    : null,
          ),
        );

    return AssessmentSection(
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
            id: '$id-item-$index',
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
  static AssessmentForm createTestAssessmentForm({
    required String id,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool withRatings = false,
    bool isSubmitted = false,
    DateTime? submissionDate,
    List<AssessmentSection>? predefinedSections,
  }) {
    // Use predefined sections if provided, otherwise generate them
    final sections =
        predefinedSections ??
        List<AssessmentSection>.generate(
          sectionCount,
          (index) => createTestAssessmentSection(
            id: '$id-section-$index',
            sectionNumber: '${index + 1}',
            itemCount: itemsPerSection,
            withRatings: withRatings,
          ),
        );

    return AssessmentForm(
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
    );
  }

  /// Creates an assessment with a mix of different ratings
  /// (1 Meets, 1 Partially Meets, 2 Does Not Meet, 1 Don't Know, 1 Not Applicable)
  static AssessmentForm createMixedRatingsAssessment({
    required String id,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool isSubmitted = false,
    DateTime? submissionDate,
  }) {
    // Create specific sections with mixed ratings
    final section1Items = [
      createTestAssessmentItem(
        id: '$id-section-0-item-0',
        sectionNumber: '1.1',
        selectedRating: AssessmentRating.meetsTarget(),
      ),
      createTestAssessmentItem(
        id: '$id-section-0-item-1',
        sectionNumber: '1.2',
        selectedRating: AssessmentRating.partiallyMeetsTarget(),
      ),
      createTestAssessmentItem(
        id: '$id-section-0-item-2',
        sectionNumber: '1.3',
        selectedRating: AssessmentRating.doesNotMeetTarget(),
      ),
    ];

    final section2Items = [
      createTestAssessmentItem(
        id: '$id-section-1-item-0',
        sectionNumber: '2.1',
        selectedRating: AssessmentRating.dontKnow(),
      ),
      createTestAssessmentItem(
        id: '$id-section-1-item-1',
        sectionNumber: '2.2',
        selectedRating: AssessmentRating.notApplicable(),
      ),
      createTestAssessmentItem(
        id: '$id-section-1-item-2',
        sectionNumber: '2.3',
        selectedRating: AssessmentRating.doesNotMeetTarget(),
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
    );
  }

  /// Creates an assessment model with a mix of different ratings
  static AssessmentFormModel createMixedRatingsAssessmentModel({
    required String id,
    bool isSubmitted = false,
    DateTime? submissionDate,
  }) {
    // Convert the domain entity to a model
    final entity = createMixedRatingsAssessment(
      id: id,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
    );
    
    // Convert entity to model
    return AssessmentFormModel(
      id: entity.id,
      assessorInfo: createTestAssessorInfoModel(),
      geoLocation: createTestGeoLocationModel(),
      facilityIdentification: createTestFacilityIdentificationModel(),
      facilityServices: createTestFacilityServicesModel(),
      sections: entity.sections.map((section) {
        final items = section.items.map((item) {
          final rating = item.selectedRating != null
              ? AssessmentRatingModel(
                  id: item.selectedRating!.id,
                  value: item.selectedRating!.value,
                  label: item.selectedRating!.label,
                  description: item.selectedRating!.description,
                )
              : null;
              
          return AssessmentItemModel(
            id: item.id,
            sectionNumber: item.sectionNumber,
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
    );
  }

  /// Creates an assessment with 50% rated items (all Meets Target) and 50% unrated items
  static AssessmentForm createPartiallyRatedAssessment({
    required String id,
    int sectionCount = 2,
    int itemsPerSection = 3,
    bool isSubmitted = false,
    DateTime? submissionDate,
  }) {
    // Create sections with alternating rated and unrated items
    final sections = List<AssessmentSection>.generate(sectionCount, (
      sectionIndex,
    ) {
      final items = List<AssessmentItem>.generate(
        itemsPerSection,
        (itemIndex) => createTestAssessmentItem(
          id: '$id-section-$sectionIndex-item-$itemIndex',
          sectionNumber: '${sectionIndex + 1}.${itemIndex + 1}',
          selectedRating:
              itemIndex % 2 == 0 ? AssessmentRating.meetsTarget() : null,
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
    );
  }

  /// Creates an assessment model with partially rated items
  static AssessmentFormModel createPartiallyRatedAssessmentModel({
    required String id,
    bool isSubmitted = false,
    DateTime? submissionDate,
  }) {
    // Convert entity to model
    final entity = createPartiallyRatedAssessment(
      id: id,
      isSubmitted: isSubmitted,
      submissionDate: submissionDate,
    );
    
    final sections = entity.sections.map((section) {
      final items = section.items.map((item) {
        final rating = item.selectedRating != null
            ? AssessmentRatingModel(
                id: item.selectedRating!.id,
                value: item.selectedRating!.value,
                label: item.selectedRating!.label,
                description: item.selectedRating!.description,
              )
            : null;
        
        return AssessmentItemModel(
          id: item.id,
          sectionNumber: item.sectionNumber,
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
    );
  }

  /// Creates an assessment marked as submitted
  static AssessmentForm createSubmittedAssessment({
    required String id,
    DateTime? submissionDate,
  }) {
    return createMixedRatingsAssessment(id: id).copyWith(
      isSubmitted: true,
      submissionDate: submissionDate ?? DateTime(2024, 5, 1),
    );
  }

  /// Creates an assessment model marked as submitted
  static AssessmentFormModel createSubmittedAssessmentModel({
    required String id,
    DateTime? submissionDate,
  }) {
    return createMixedRatingsAssessmentModel(
      id: id,
      isSubmitted: true,
      submissionDate: submissionDate ?? DateTime(2024, 5, 1),
    );
  }

  /// Creates an assessment with sections but no items
  static AssessmentForm createAssessmentWithEmptySections({
    required String id,
    int sectionCount = 2,
  }) {
    final emptySections = List<AssessmentSection>.generate(
      sectionCount,
      (index) => AssessmentSection(
        id: '$id-section-$index',
        sectionNumber: '${index + 1}',
        title: 'Empty Section ${index + 1}',
        items: [],
      ),
    );

    return createTestAssessmentForm(id: id, predefinedSections: emptySections);
  }

  /// Creates an assessment model with sections but no items
  static AssessmentFormModel createAssessmentWithEmptySectionsModel({
    required String id,
    int sectionCount = 2,
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

    return createTestAssessmentFormModel(id: id, predefinedSections: emptySections);
  }

  /// Creates an assessment with a specific custom configuration for testing
  static AssessmentForm createCustomAssessment({required String id}) {
    // Create exactly 4 items with specific ratings for testing
    final sections = [
      AssessmentSection(
        id: 'section1',
        sectionNumber: '1',
        title: 'Section 1',
        items: [
          AssessmentItem(
            id: 'item1',
            sectionNumber: '1.1',
            area: 'Area 1',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: AssessmentRating.meetsTarget(),
          ),
          AssessmentItem(
            id: 'item2',
            sectionNumber: '1.2',
            area: 'Area 2',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: AssessmentRating.partiallyMeetsTarget(),
          ),
        ],
      ),
      AssessmentSection(
        id: 'section2',
        sectionNumber: '2',
        title: 'Section 2',
        items: [
          AssessmentItem(
            id: 'item3',
            sectionNumber: '2.1',
            area: 'Area 3',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: AssessmentRating.doesNotMeetTarget(),
          ),
          // Item with no rating
          AssessmentItem(
            id: 'item4',
            sectionNumber: '2.2',
            area: 'Area 4',
            meetsTargetDescription: 'Meets description',
            partiallyMeetsDescription: 'Partially meets description',
            doesNotMeetDescription: 'Does not meet description',
            selectedRating: null,
          ),
        ],
      ),
    ];

    return createTestAssessmentForm(id: id, predefinedSections: sections);
  }

  /// Creates an assessment model with a specific custom configuration for testing
  static AssessmentFormModel createCustomAssessmentModel({required String id}) {
    // Convert entity to model
    final entity = createCustomAssessment(id: id);
    
    final sections = entity.sections.map((section) {
      final items = section.items.map((item) {
        final rating = item.selectedRating != null
            ? AssessmentRatingModel(
                id: item.selectedRating!.id,
                value: item.selectedRating!.value,
                label: item.selectedRating!.label,
                description: item.selectedRating!.description,
              )
            : null;
        
        return AssessmentItemModel(
          id: item.id,
          sectionNumber: item.sectionNumber,
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
    );
  }

  /// Creates test assessment analysis instances for equality testing
  static AssessmentAnalysis createTestAnalysis({
    String assessmentId = 'test-id',
    String facilityName = _defaultFacilityName,
    DateTime? assessmentDate,
    double completionPercentage = 75.0,
    bool isSubmitted = true,
    int totalItems = 10,
    int completedItems = 8,
    int meetsTargetCount = 5,
    int partiallyMeetsCount = 2,
    int doesNotMeetCount = 1,
    int dontKnowCount = 0,
    int notApplicableCount = 0,
    DateTime? submissionDate,
  }) {
    return AssessmentAnalysis(
      assessmentId: assessmentId,
      facilityName: facilityName,
      assessmentDate: assessmentDate ?? _defaultAssessmentDate,
      completionPercentage: completionPercentage,
      isSubmitted: isSubmitted,
      totalItems: totalItems,
      completedItems: completedItems,
      meetsTargetCount: meetsTargetCount,
      partiallyMeetsCount: partiallyMeetsCount,
      doesNotMeetCount: doesNotMeetCount,
      dontKnowCount: dontKnowCount,
      notApplicableCount: notApplicableCount,
      submissionDate: submissionDate ?? DateTime(2023, 5, 15),
    );
  }
}