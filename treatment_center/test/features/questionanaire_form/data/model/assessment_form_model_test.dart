import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification.dart';

void main() {
  // Create test date
  final testDate = DateTime(2023, 5, 10);
  final testSubmitDate = DateTime(2023, 5, 15);
  
  // Create test models for all nested objects
  final tAssessorInfoModel = AssessorInfoModel(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phoneNumber: '1234567890',
    assessmentDate: testDate,
  );
  
  final tGeoLocationModel = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'San Francisco',
    cityVillage: 'San Francisco',
    addressOrCoordinates: '123 Main St',
    locationType: FacilityLocationType.urban,
  );
  
  final tFacilityIdModel = FacilityIdentificationModel(
    facilityCode: 'F12345',
    facilityName: 'City Hospital',
    managingAuthority: ManagingAuthorityType.government,
    directorName: 'Dr. Jane Smith',
    directorPhone: '5551234567',
    directorEmail: 'jsmith@cityhospital.org',
    respondentName: 'John Doe',
    respondentPosition: 'Facility Manager',
    structureType: FacilityStructureType.permanent,
    facilityType: FacilityType.screeningAndTemporaryIsolation,
    existingFacilityType: ExistingFacilityType.firstReferralHospital,
  );
  
  final tFacilityServicesModel = FacilityServicesModel(
    hasOutpatientServices: true,
    hasInpatientServices: true,
    totalInpatientBeds: 100,
    icuBeds: 20,
    hasEmergencyUnit: true,
    hasIcuOrHighDependencyUnit: true,
  );
  
  // Create items for a section
  final tItemModel1 = AssessmentItemModel(
    id: 'item_1',
    sectionNumber: '2.1',
    area: 'Area 1',
    meetsTargetDescription: 'Meets description 1',
    partiallyMeetsDescription: 'Partially meets description 1',
    doesNotMeetDescription: 'Does not meet description 1',
    selectedRating: AssessmentRatingModel.meetsTarget(),
  );
  
  final tItemModel2 = AssessmentItemModel(
    id: 'item_2',
    sectionNumber: '2.1',
    area: 'Area 2',
    meetsTargetDescription: 'Meets description 2',
    partiallyMeetsDescription: 'Partially meets description 2',
    doesNotMeetDescription: 'Does not meet description 2',
  );
  
  // Create a section
  final tSectionModel = AssessmentSectionModel(
    id: 'section_1',
    sectionNumber: '2.1',
    title: 'Facility Access and Flow',
    description: 'This section evaluates facility access',
    items: [tItemModel1, tItemModel2],
  );
  
  // Create the main AssessmentFormModel for testing
  final tAssessmentFormModel = AssessmentFormModel(
    id: 'assessment_1',
    assessorInfo: tAssessorInfoModel,
    geoLocation: tGeoLocationModel,
    facilityIdentification: tFacilityIdModel,
    facilityServices: tFacilityServicesModel,
    sections: [tSectionModel],
    notes: 'These are assessment notes',
    isSubmitted: false,
    submissionDate: null,
  );
  
  // Create JSON representations
  final tAssessorInfoJson = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone_number': '1234567890',
    'assessment_date': '2023-05-10T00:00:00.000',
  };
  
  final tGeoLocationJson = {
    'country': 'United States',
    'region_province': 'California',
    'district': 'San Francisco',
    'city_village': 'San Francisco',
    'address_or_coordinates': '123 Main St',
    'location_type': 0,
  };
  
  final tFacilityIdJson = {
    'facility_code': 'F12345',
    'facility_name': 'City Hospital',
    'managing_authority': 0,
    'other_managing_authority': null,
    'director_name': 'Dr. Jane Smith',
    'director_phone': '5551234567',
    'director_email': 'jsmith@cityhospital.org',
    'respondent_name': 'John Doe',
    'respondent_position': 'Facility Manager',
    'structure_type': 0,
    'facility_type': 0,
    'existing_facility_type': 0,
    'other_existing_facility_type': null,
  };
  
  final tFacilityServicesJson = {
    'has_outpatient_services': true,
    'has_inpatient_services': true,
    'total_inpatient_beds': 100,
    'icu_beds': 20,
    'has_emergency_unit': true,
    'has_icu_or_high_dependency_unit': true,
  };
  
  final tItemJson1 = {
    'id': 'item_1',
    'section_number': '2.1',
    'area': 'Area 1',
    'meets_target_description': 'Meets description 1',
    'partially_meets_description': 'Partially meets description 1',
    'does_not_meet_description': 'Does not meet description 1',
    'selected_rating': {
      'id': 'meets_target',
      'value': 3,
      'label': 'Meets target (+++) (3)',
      'description': 'The facility fully meets the requirements for this aspect of the assessment.',
    },
    'comment': null,
  };
  
  final tItemJson2 = {
    'id': 'item_2',
    'section_number': '2.1',
    'area': 'Area 2',
    'meets_target_description': 'Meets description 2',
    'partially_meets_description': 'Partially meets description 2',
    'does_not_meet_description': 'Does not meet description 2',
    'selected_rating': null,
    'comment': null,
  };
  
  final tSectionJson = {
    'id': 'section_1',
    'section_number': '2.1',
    'title': 'Facility Access and Flow',
    'description': 'This section evaluates facility access',
    'items': [tItemJson1, tItemJson2],
  };
  
  final tAssessmentFormJson = {
    'id': 'assessment_1',
    'assessor_info': tAssessorInfoJson,
    'geo_location': tGeoLocationJson,
    'facility_identification': tFacilityIdJson,
    'facility_services': tFacilityServicesJson,
    'sections': [tSectionJson],
    'notes': 'These are assessment notes',
    'is_submitted': false,
    'submission_date': null,
  };
  
  // Create submitted version for testing
  final tSubmittedAssessmentFormModel = AssessmentFormModel(
    id: 'assessment_1',
    assessorInfo: tAssessorInfoModel,
    geoLocation: tGeoLocationModel,
    facilityIdentification: tFacilityIdModel,
    facilityServices: tFacilityServicesModel,
    sections: [tSectionModel],
    notes: 'These are assessment notes',
    isSubmitted: true,
    submissionDate: testSubmitDate,
  );
  
  final tSubmittedAssessmentFormJson = {
    'id': 'assessment_1',
    'assessor_info': tAssessorInfoJson,
    'geo_location': tGeoLocationJson,
    'facility_identification': tFacilityIdJson,
    'facility_services': tFacilityServicesJson,
    'sections': [tSectionJson],
    'notes': 'These are assessment notes',
    'is_submitted': true,
    'submission_date': '2023-05-15T00:00:00.000',
  };

  group('AssessmentFormModel', () {
    test('should be a subclass of AssessmentForm entity', () {
      // assert
      expect(tAssessmentFormModel, isA<AssessmentForm>());
    });

    group('fromJson', () {
      test('should return a valid model when the JSON is valid', () {
        // arrange
        final Map<String, dynamic> jsonMap = tAssessmentFormJson;
        // act
        final result = AssessmentFormModel.fromJson(jsonMap);
        // assert
        expect(result.id, tAssessmentFormModel.id);
        expect(result.assessorInfo.name, tAssessmentFormModel.assessorInfo.name);
        expect(result.geoLocation.country, tAssessmentFormModel.geoLocation.country);
        expect(result.facilityIdentification.facilityName, 
               tAssessmentFormModel.facilityIdentification.facilityName);
        expect(result.facilityServices.hasOutpatientServices, 
               tAssessmentFormModel.facilityServices.hasOutpatientServices);
        expect(result.sections.length, tAssessmentFormModel.sections.length);
        expect(result.notes, tAssessmentFormModel.notes);
        expect(result.isSubmitted, tAssessmentFormModel.isSubmitted);
        expect(result.submissionDate, tAssessmentFormModel.submissionDate);
      });

      test('should correctly parse nested objects from JSON', () {
        // arrange
        final Map<String, dynamic> jsonMap = tAssessmentFormJson;
        // act
        final result = AssessmentFormModel.fromJson(jsonMap);
        // assert
        
        // Verify assessorInfo
        expect(result.assessorInfo.name, 'John Doe');
        expect(result.assessorInfo.email, 'john.doe@example.com');
        
        // Verify geoLocation
        expect(result.geoLocation.country, 'United States');
        expect(result.geoLocation.locationType, FacilityLocationType.urban);
        
        // Verify facilityIdentification
        expect(result.facilityIdentification.facilityName, 'City Hospital');
        expect(result.facilityIdentification.facilityType, 
               FacilityType.screeningAndTemporaryIsolation);
        
        // Verify facilityServices
        expect(result.facilityServices.hasInpatientServices, true);
        expect(result.facilityServices.totalInpatientBeds, 100);
        
        // Verify sections
        expect(result.sections.length, 1);
        expect(result.sections[0].title, 'Facility Access and Flow');
        
        // Verify items in section
        expect(result.sections[0].items.length, 2);
        expect(result.sections[0].items[0].area, 'Area 1');
        
        // Verify rating in item
        expect(result.sections[0].items[0].selectedRating?.value, 3);
        expect(result.sections[0].items[1].selectedRating, null);
      });

      test('should correctly parse submission date when present', () {
        // arrange
        final Map<String, dynamic> jsonMap = tSubmittedAssessmentFormJson;
        // act
        final result = AssessmentFormModel.fromJson(jsonMap);
        // assert
        expect(result.isSubmitted, true);
        expect(result.submissionDate, testSubmitDate);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // act
        final result = tAssessmentFormModel.toJson();
        // assert
        expect(result['id'], tAssessmentFormJson['id']);
        expect(result['assessor_info'], tAssessmentFormJson['assessor_info']);
        expect(result['geo_location'], tAssessmentFormJson['geo_location']);
        expect(result['facility_identification'], tAssessmentFormJson['facility_identification']);
        expect(result['facility_services'], tAssessmentFormJson['facility_services']);
        expect(result['notes'], tAssessmentFormJson['notes']);
        expect(result['is_submitted'], tAssessmentFormJson['is_submitted']);
        expect(result['submission_date'], tAssessmentFormJson['submission_date']);
        
        // Verify sections array
        expect(result['sections'].length, (tAssessmentFormJson['sections'] as List).length);
      });

      test('should include submission date when submitted', () {
        // act
        final result = tSubmittedAssessmentFormModel.toJson();
        // assert
        expect(result['is_submitted'], true);
        expect(result['submission_date'], '2023-05-15T00:00:00.000');
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // arrange
        final entity = AssessmentForm(
          id: 'assessment_1',
          assessorInfo: tAssessorInfoModel,
          geoLocation: tGeoLocationModel,
          facilityIdentification: tFacilityIdModel,
          facilityServices: tFacilityServicesModel,
          sections: [tSectionModel],
          notes: 'These are assessment notes',
          isSubmitted: false,
          submissionDate: null,
        );
        // act
        final result = AssessmentFormModel.fromEntity(entity);
        // assert
        expect(result, tAssessmentFormModel);
      });
    });

    group('entity methods', () {
      test('completionPercentage should calculate correctly', () {
        // In our test data, 1 out of 2 items has a rating
        expect(tAssessmentFormModel.completionPercentage, 50.0);
      });

      test('isComplete should return false when not all items are rated', () {
        expect(tAssessmentFormModel.isComplete, false);
      });

      test('isComplete should return true when all items are rated', () {
        // Create a fully completed section where all items have ratings
        final completedItemModel1 = tItemModel1; // Already has rating
        final completedItemModel2 = tItemModel2.copyWith(
          selectedRating: AssessmentRatingModel.partiallyMeetsTarget(),
        );
        
        final completedSectionModel = AssessmentSectionModel(
          id: 'section_1',
          sectionNumber: '2.1',
          title: 'Facility Access and Flow',
          description: 'This section evaluates facility access',
          items: [completedItemModel1, completedItemModel2],
        );
        
        final completedAssessmentFormModel = tAssessmentFormModel.copyWith(
          sections: [completedSectionModel],
        );
        
        expect(completedAssessmentFormModel.isComplete, true);
        expect(completedAssessmentFormModel.completionPercentage, 100.0);
      });

      test('markAsSubmitted should set appropriate flags and date', () {
        // act
        final result = tAssessmentFormModel.markAsSubmitted();
        // assert
        expect(result.isSubmitted, true);
        expect(result.submissionDate, isNotNull);
      });
    });
  });
}